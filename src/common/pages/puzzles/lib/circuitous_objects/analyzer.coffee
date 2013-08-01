analyzer = exports ? provide('./analyzer', {})
circuitousObject = require('./object')

class analyzer.Analyzer extends circuitousObject.Object
    constructor: (@board) ->
        @init()

    init: ->
        @info = {node: {}, nodes: {}, sections: {}, components: {}, path: {}}
        
    run: ->
        @reduce()
        return if (keys = Object.keys(@info.sections[@level])).length != 1
            
        circuit = @info.sections[@level][keys[0]]
        if circuit and circuit.negativeComponentId and Object.keys(circuit.components).length > 1
            powerSource = @board.components[circuit.negativeComponentId]
            circuit.complete = (@compareObjectNodes(powerSource, circuit.nodes))
            if circuit.resistance > 0
                circuit.amps = powerSource.voltage / circuit.resistance
            else
                circuit.amps = 'infinite'
        else
            circuit.complete = false
            
        circuit.sections = []
        if circuit.complete
            for sid, section of @info.sections[1]
                continue if section.deadEnd
                if section.parallelSection
                    parallelSection = @info.sections[2][section.parallelSection]
                    parallelSection.amps = circuit.amps unless parallelSection.amps
                    if not circuit.resistance
                        section.amps = (if section.resistance then 0 else 'infinite')
                    else 
                        section.amps = parallelSection.amps * (section.resistance / circuit.resistance)
                else
                    section.amps = circuit.amps
                circuit.sections.push(section)

        return circuit
        
        
    initLevel: (@level) ->
        @info.node[level] = {}
        @info.nodes[level] = {}
        @info.sections[level] = {}
        @info.components[level] = {}
        @info.path[level] = []

    compareNodes: (node1, node2) -> node1.x == node2.x and node1.y == node2.y
    compareObjectNodes: (object, nodes) ->
        objectNodes = (@board.boardPosition(n) for n in object.currentNodes())
        return true if (@compareNodes(nodes[0], objectNodes[0]) or @compareNodes(nodes[0], objectNodes[1])) and
                       (@compareNodes(nodes[1], objectNodes[0]) or @compareNodes(nodes[1], objectNodes[1]))
        return false

    reduce: (level=1) ->
        @initLevel(level)
        for cid, component of @board.components when component.powerSource
            for negativeTerminal in component.currentNodes('negative')
                node = @board.boardPosition(negativeTerminal)
                existingSection = (s for sid, s of (@info.sections[level-1] or {}) when s.components?[cid])[0]
                if existingSection
                    otherNode = @otherNode(existingSection.nodes, node)
                    otherNode.negative = true
                @combineSections(level, otherNode or node, existingSection or component, @newSection(node))

        if Object.keys(@info.sections[@level]).length > 1
            @redraw(@level)
        
        if Object.keys(@info.sections[@level]).length > 1
            @initLevel(@level+1)
            if @reduceParallels(@level)
                @reduce(@level+1) 
            
    recordSection: (level, section) ->
        @info.path[level].push(section.id)
        @info.sections[level][section.id] = section 
    
        # console.log(level, 'adding', section.id)
        # @board.color((id for id of section.components), Object.keys(@info.sections[level]).length - 1)
        # debugger

        @recordSectionAtNodes(level, section)
        
    recordSectionAtNodes: (level, section) ->
        node1Coords = "#{section.nodes[0].x}:#{section.nodes[0].y}"
        node2Coords = "#{section.nodes[1].x}:#{section.nodes[1].y}"
        @info.node[level]["#{node1Coords}"] or= {} 
        @info.node[level]["#{node1Coords}"][section.id] = section
        @info.node[level]["#{node2Coords}"] or= {}
        @info.node[level]["#{node2Coords}"][section.id] = section
        @info.nodes[level]["#{node1Coords}#{node2Coords}"] or= {} 
        @info.nodes[level]["#{node1Coords}#{node2Coords}"][section.id] = section
        @info.nodes[level]["#{node2Coords}#{node1Coords}"] or= {}
        @info.nodes[level]["#{node2Coords}#{node1Coords}"][section.id] = section        
        
    deleteSection: (level, section) ->
        @info.path[level].splice(@info.path[level].indexOf(section.id), 1)
        delete @info.sections[level][section.id]
        @deleteSectionAtNodes(level, section)

    deleteSectionAtNodes: (level, section) ->
        node1Coords = "#{section.nodes[0].x}:#{section.nodes[0].y}"
        node2Coords = "#{section.nodes[1].x}:#{section.nodes[1].y}"
        delete @info.node[level]["#{node1Coords}"][section.id]
        delete @info.node[level]["#{node2Coords}"][section.id]
        delete @info.nodes[level]["#{node1Coords}#{node2Coords}"][section.id]
        delete @info.nodes[level]["#{node2Coords}#{node1Coords}"][section.id]               

    otherNode: (nodes, node) -> (n for n in nodes when not @compareNodes(n, node))[0]

    redraw: (level) ->
        changeMade = false
        endNode = null
        for sid in @info.path[level]
            # @board.clearColors()
            section = @info.sections[level][sid]

            # console.log('analyzing', section.id)
            # @board.color((id for id of section.components), 1)
            # debugger

            endNode = if endNode then @otherNode(section.nodes, endNode) else section.nodes[1]
            connections = @info.node[level]["#{endNode.x}:#{endNode.y}"]
            
            # console.log('connections', Object.keys(connections).length)
            # @board.color((id for id of connectingSection.components), 2) for csid, connectingSection of connections when csid != sid
            # debugger
            
            if Object.keys(connections).length > 2
                for csid, connectingSection of connections when csid != sid
                    if not connectingSection.resistance and not connectingSection.powerSource
                        changeMade = true

                        # console.log('delete', connectingSection.id)
                        # @board.color((id for id of connectingSection.components), 3)
                        # debugger
                        
                        @deleteSection(level, connectingSection)
                        cEndNode = @otherNode(connectingSection.nodes, endNode)
                        cConnections = @info.node[level]["#{cEndNode.x}:#{cEndNode.y}"]

                        # console.log('connecting connections', Object.keys(cConnections).length, "#{cEndNode.x}:#{cEndNode.y}")
                        # @board.color((id for id of ccs.components), 4) for ccsid, ccs of cConnections when ccsid != csid
                        # debugger
                        
                        for ccsid, ccs of cConnections
                            @deleteSectionAtNodes(level, ccs)
                            ccStartNodeIndex = (if @compareNodes(ccs.nodes[0], cEndNode) then 0 else 1)
                            ccs.nodes[ccStartNodeIndex] = endNode
                            @recordSectionAtNodes(level, ccs) 
                            @deleteSection(level, ccs) if @compareNodes(ccs.nodes...)
                        section.components[ccid] = true for ccid of connectingSection.components
            else if Object.keys(connections).length == 2
                for csid, connectingSection of connections when csid != sid
                    otherNode = @otherNode(connectingSection.nodes, endNode)
                    @deleteSection(level, connectingSection)
                    @addToSection(level, section, otherNode, connectingSection)
                    endNodeIndex = (if @compareNodes(section.nodes[0], endNode) then 0 else 1)
                    section.nodes[endNodeIndex] = otherNode
                    changeMade = true
                    
            if changeMade       
                @redraw(level) 
                return true
                 
        return false
                        
    reduceParallels: (level) ->
        reductionFound = false
        
        analyzed = {}
        for nodeIds, sections of @info.nodes[level-1]
            section = sections[Object.keys(sections)[0]]
            node1Coords = "#{section.nodes[0].x}:#{section.nodes[0].y}"
            node2Coords = "#{section.nodes[1].x}:#{section.nodes[1].y}"
                        
            continue if analyzed[node1Coords] and analyzed[node2Coords] and analyzed[node1Coords] == analyzed[node2Coords]

            for id, s of sections when s.deadEnd  
                reductionFound = true
                delete sections[id]
                
            if not Object.keys(sections).length
                delete @info.nodes[level-1][nodeIds]
                continue       
            
            if Object.keys(sections).length > 1
                reductionFound = true
                resistance = 0
                resistance += (1.0 / section.resistance) for id, section of sections
                parallel = 
                    id: @generateId()
                    resistance: (1.0 / resistance)
                    components: {}
                    nodes: section.nodes
                    sections: []  
                
                for id, section of sections
                    section.parallelSection = parallel.id
                    parallel.sections.push(id)
                    for cid of section.components
                        parallel.components[cid] = true
                                  
                analyzed[node1Coords] = analyzed[node2Coords] = parallel.id
                @recordSection(level, parallel)
            
                componentIds = []
                componentIds = componentIds.concat(id for id of section.components) for id, section of sections
            else
                analyzed[node1Coords] = analyzed[node2Coords] = section.id
                @recordSection(level, section)

        @reduceParallels() if reductionFound
        return reductionFound

    combineSections: (level, node, component, section) ->
        if @addToSection(level, section, node, component)            
            if (connections = @findConnections(level, node, component, section)).length == 1
                connection = connections[0]
                if section.components[connection.component.id] or 
                   not @combineSections(level, connection.otherNode, connection.component, section)
                    @endSection(level, section, node, connection.component)
            else if connections.length > 1
                @endSection(level, section, node, component)
                for connection in connections
                    parallelSection = @combineSections(level, connection.otherNode, connection.component, @newSection(node))
            else
                section.deadEnd = true
                @endSection(level, section, node, component)
            return true
        return false

    findConnections: (level, node, component, circuit) ->
        connections = []
        if level > 1          
            for id, connection of @info.node[level-1]["#{node.x}:#{node.y}"] when connection.id != component.id
                otherNode = @otherNode(connection.nodes, node)
                connections.push({component: connection, otherNode: otherNode})
            return connections
        else
            for id, c of @board.components when (c != component and (id == circuit.negativeComponentId or !circuit.components[id]))
                for n in (nodes = c.currentNodes())
                    matchingNode = @board.boardPosition(n)
                    continue unless @compareNodes(matchingNode, node)
                    if nodes.length == 1
                        return [{component: c, otherNode: matchingNode}]                    
                    else
                        otherNode = @otherNode(nodes, matchingNode)
                    connections.push({component: c, otherNode: @board.boardPosition(otherNode)})

            for segment in @board.wires.find(node) when not circuit.components[segment.id]
                connections.push({component: segment, otherNode: @otherNode(segment.nodes, node)})

        return connections

    newSection: (node) ->
        section = {nodes: [node], resistance: 0, components: {}, id: @generateId()}
        return section

    addToSection: (level, section, node, component) ->
        return false if @info.components[level][component.id]

        if component.powerSource and node.negative
            section.powerSource = true
            section.negativeComponentId = component.negativeComponentId or component.id
            section.nodes[0].negative = true   

        section.resistance += component.resistance or 0
        if component.components            
            section.components[cid] = true for cid of component.components
        else
            section.components[component.id] = true
        @info.components[level][component.id] = section.id
        return true

    endSection: (level, section, node, component, record) ->
        section.powerSource = true if component.powerSource

        section.nodes.push(node)              
        @recordSection(level, section)

        # console.log('end section', level, JSON.stringify(section.nodes))
        # @board.color((id for id of section.components), Object.keys(@info.sections[level]).length - 1)
        # debugger if level > 1
        
        
        