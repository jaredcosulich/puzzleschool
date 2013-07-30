analyzer = exports ? provide('./analyzer', {})
circuitousObject = require('./object')

class analyzer.Analyzer extends circuitousObject.Object
    constructor: (@board) ->
        @init()

    init: ->
        @info = {node: {}, nodes: {}, sections: {}, components: {}}
        
    run: ->
        @reduceSections()
        
        if (keys = Object.keys(@info.sections[@level])).length > 1
            console.log('incomplete', circuit)
            
        circuit = @info.sections[@level][keys[0]]
        powerSource = @board.components[circuit.negativeComponentId]
        if (@compareObjectNodes(powerSource, circuit.nodes))
            if circuit.resistance > 0
                amps = powerSource.voltage / circuit.resistance
                for id of circuit.components  
                    c = @componentsAndWires()[id] 
                    c.receivingCurrent = true
                    c.setCurrent?(amps)                         
                console.log('complete', circuit.resistance, amps)
            else
                amps = 'infinite'
                for id of circuit.components
                    c = @componentsAndWires()[id] 
                    c.excessiveCurrent = true
                    c.el.addClass('excessive_current')
                console.log('complete', circuit.resistance, amps)
        else
            console.log('incomplete')

    initLevel: (@level) ->
        @info.node[level] = {}
        @info.nodes[level] = {}
        @info.sections[level] = {}
        @info.components[level] = {}

    compareNodes: (node1, node2) -> node1.x == node2.x and node1.y == node2.y
    compareObjectNodes: (object, nodes) ->
        objectNodes = (@board.boardPosition(n) for n in object.nodes)
        console.log(JSON.stringify(nodes), JSON.stringify(objectNodes))
        return true if (@compareNodes(nodes[0], objectNodes[0]) or @compareNodes(nodes[0], objectNodes[1])) and
                       (@compareNodes(nodes[1], objectNodes[0]) or @compareNodes(nodes[1], objectNodes[1]))
        return false

    reduceSections: (level=1) ->
        @initLevel(level)
        @board.clearColors()
        for id, component of @board.components when component.powerSource
            for negativeTerminal in component.currentNodes('negative')
                node = @board.boardPosition(negativeTerminal)
                @combineSections(level, node, component, @newSection(node))
    
        if Object.keys(@info.sections[@level]).length > 1
            @initLevel(@level+1)
            if @reduceParallels(@level)
                @reduceSections(@level+1) 
            
    recordSection: (level, section) ->
        node1Coords = "#{section.nodes[0].x}:#{section.nodes[0].y}"
        node2Coords = "#{section.nodes[1].x}:#{section.nodes[1].y}"

        @info.sections[level][section.id] = section        
        @info.node[level]["#{node1Coords}"] or= {} 
        @info.node[level]["#{node1Coords}"][section.id] = section
        @info.node[level]["#{node2Coords}"] or= {}
        @info.node[level]["#{node2Coords}"][section.id] = section
        @info.nodes[level]["#{node1Coords}#{node2Coords}"] or= {} 
        @info.nodes[level]["#{node1Coords}#{node2Coords}"][section.id] = section
        @info.nodes[level]["#{node2Coords}#{node1Coords}"] or= {}
        @info.nodes[level]["#{node2Coords}#{node1Coords}"][section.id] = section        

    reduceParallels: (level) ->
        reductionFound = false

        analyzed = {}
        for nodeIds, sections of @info.nodes[level-1]
            section = sections[Object.keys(sections)[0]]
            node1Coords = "#{section.nodes[0].x}:#{section.nodes[0].y}"
            node2Coords = "#{section.nodes[1].x}:#{section.nodes[1].y}"
                        
            continue if analyzed[node1Coords] and analyzed[node2Coords] and analyzed[node1Coords] == analyzed[node2Coords]
            
            if Object.keys(sections).length > 1
                reductionFound = true
                resistance = 0
                resistance += (1.0 / section.resistance) for id, section of sections
                parallel = {id: @generateId(), resistance: (1.0 / resistance), components: {}, nodes: section.nodes}   
                
                for id, section of sections
                    for cid of section.components
                        parallel.components[cid] = true
                                  
                analyzed[node1Coords] = analyzed[node2Coords] = parallel.id
                console.log('parallel', level, parallel) if level == 3
                @recordSection(level, parallel)
            
                @board.clearColors()
                componentIds = []
                componentIds = componentIds.concat(id for id of section.components) for id, section of sections
                # @board.color(componentIds, 0)            
                # debugger
            else
                analyzed[node1Coords] = analyzed[node2Coords] = section.id
                console.log('not parallel', level, section) if level == 3
                @recordSection(level, section)

        @reduceParallels() if reductionFound
        return reductionFound

    combineSections: (level, node, component, section) ->
        # @board.color((id for id of component.components), 1) if level > 1 and component.components
        if @addToSection(level, section, node, component)            
            if (connections = @findConnections(level, node, component, section)).length == 1
                connection = connections[0]
                if section.components[connection.component.id]
                    @endSection(level, section, node, connection.component)
                else
                    return @combineSections(level, connection.otherNode, connection.component, section)
            else if connections.length > 1
                @endSection(level, section, node, component)
                for connection in connections
                    parallelSection = @combineSections(level, connection.otherNode, connection.component, @newSection(node))
            else
                @endSection(level, section, node, component)
        else
            @endSection(level, section, node, component) if Object.keys(section.components).length

    findConnections: (level, node, component, circuit) ->
        connections = []
        if level > 1          
            for id, connection of @info.node[level]["#{node.x}:#{node.y}"] when connection.id != component.id
                otherNode = (otherNode for otherNode in connection.nodes when not @compareNodes(node, otherNode))[0]
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
                        otherNode = (otherNode for otherNode in nodes when not @compareNodes(matchingNode, otherNode))[0]
                    connections.push({component: c, otherNode: @board.boardPosition(otherNode)})

            for segment in @board.wires.find(node) when not circuit.components[segment.id]
                otherNode = (n for n in segment.nodes when not @compareNodes(n, node))[0]
                connections.push({component: segment, otherNode: otherNode})

        return connections

    newSection: (node) ->
        section = {nodes: [node], resistance: 0, components: {}, id: @generateId()}
        return section

    addToSection: (level, section, node, component) ->
        return false if @info.components[level][component.id]

        if component.powerSource and node.negative
            section.powerSource = true
            section.negativeComponentId = component.id
            section.nodes[0].negative = true   

        section.resistance += component.resistance or 0            
        section.components[component.id] = true
        section.components[cid] = true for cid of component.components
        @info.components[level][component.id] = section.id unless component.powerSource
        return true

    endSection: (level, section, node, component, record) ->
        if component.powerSource and node.positive
            section.powerSource = true
            section.positiveComponent = component

        section.nodes.push(node)             
        @recordSection(level, section)

        # console.log('end section', level, JSON.stringify(section.nodes))
        # @board.color((id for id of section.components), Object.keys(@info.sections[level]).length - 1)
        # debugger if level > 1
        
        
        