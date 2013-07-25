analyzer = exports ? provide('./analyzer', {})
circuitousObject = require('./object')

class analyzer.Analyzer extends circuitousObject.Object
    constructor: (@board) ->
        @init()

    init: ->
        @info = {node: {}, nodes: {}, sections: {}, components: {}}
        
    run: ->
        @reduceSections()

        # for 
        # if (circuit = ).complete
        #     if circuit.resistance > 0
        #         amps = component.voltage / circuit.resistance
        #         for id of circuit.components  
        #             c = @componentsAndWires()[id] 
        #             c.receivingCurrent = true
        #             c.setCurrent?(amps)                         
        #         console.log('complete', circuit.resistance, amps)
        #     else
        #         amps = 'infinite'
        #         for id of circuit.components
        #             c = @componentsAndWires()[id] 
        #             c.excessiveCurrent = true
        #             c.el.addClass('excessive_current')
        #         console.log('complete', circuit.resistance, amps)
        # else
        #     console.log('incomplete', circuit)

    initLevel: (level) ->
        @info.node[level] = {}
        @info.nodes[level] = {}
        @info.sections[level] = {}
        @info.components[level] = {}

    compareNodes: (node1, node2) -> node1.x == node2.x and node1.y == node2.y

    reduceSections: (level=1) ->
        @initLevel(level)
        for id, component of @board.components when component.powerSource
            for negativeTerminal in component.currentNodes('negative')
                node = @board.boardPosition(negativeTerminal)
                @combineSections(level, node, component, @newSection(node))

        level += 1
        @initLevel(level)
        @reduceSections(level) if @reduceParallels(level)

    reduceParallels: (level) ->
        reductionFound = false

        for nodeIds, sections of @info.nodes[level-1] when Object.keys(sections).length > 1
            console.log('parallel', nodeIds)
            # reductionFound = true
            # resistance = 0
            # resistance += (1.0 / section.resistance) for id, section of sections
            # parallel = {id: @generateId(), resistance: (1.0 / resistance), nodes: section.nodes}
            # @info.node[level]["#{section.nodes[0].x}:#{section.nodes[0].y}"][parallel.id] = parallel
            # @info.node[level]["#{section.nodes[1].x}:#{section.nodes[1].y}"][parallel.id] = parallel
            # 
            # @board.clearColors()
            # componentIds = []
            # componentIds = componentIds.concat(id for id of section.components) for id, section of sections
            # @board.color(componentIds, 0)            
            # debugger

        @reduceParallels() if reductionFound
        return reductionFound

    combineSections: (level, node, component, section) ->
        if @addToSection(level, section, node, component)            
            if (connections = @findConnections(level, node, component, section)).length == 1
                connection = connections[0]
                if section.components[connection.component.id]
                    @endSection(level, section, node, connection.component)
                else
                    return @combineSections(level, connection.otherNode, connection.component, section, @newSection(node))
            else if connections.length > 1
                @endSection(level, section, node, component)
                for connection in connections
                    parallelSection = @combineSections(level, connection.otherNode, connection.component, @newSection(node))
        else
            @endSection(level, section, node, component)

    findConnections: (level, node, component, circuit) ->
        connections = []
        if level > 1
            existingConnections = @info.node[level-1]["#{node.x}:#{node.y}"]
            if existingConnections and (Object.keys(existingConnections).length == 1 or existingConnections.parallel)
                connection = existingConnections.parallel
                connection = existingConnections[0] unless connection
                otherNode = (otherNode for otherNode in connection.nodes when not @compareNodes(node, otherNode))[0]
                return [{component: connection, node: node, otherNode: otherNode}]
        else
            for id, c of @board.components when (c != component and (id == circuit.negativeComponentId or !circuit.components[id]))
                for n in (nodes = c.currentNodes())
                    matchingNode = @board.boardPosition(n)
                    continue unless @compareNodes(matchingNode, node)
                    if nodes.length == 1
                        return [{component: c, matchingNode: matchingNode, otherNode: matchingNode}]                    
                    else
                        otherNode = (otherNode for otherNode in nodes when not @compareNodes(matchingNode, otherNode))[0]
                    connections.push({component: c, matchingNode: matchingNode, otherNode: @board.boardPosition(otherNode)})

            for segment in @board.wires.find(node) when not circuit.components[segment.id]
                matchingNode = (n for n in segment.nodes when @compareNodes(n, node))[0] 
                otherNode = (n for n in segment.nodes when not @compareNodes(n, node))[0]
                connections.push({component: segment, matchingNode: matchingNode, otherNode: otherNode})

        return connections

    newSection: (node) ->
        section = {nodes: [node], resistance: 0, components: {}, id: @generateId()}
        return section

    addToSection: (level, section, node, component) ->
        return false if @info.components[level][component.id]

        if component.powerSource and node.negative
            section.negativeComponentId = component.id   

        section.resistance += component.resistance or 0            
        section.components[component.id] = true
        @info.components[level][component.id] = section.id unless component.powerSource
        return true

    endSection: (level, section, node, component) ->
        if component.powerSource and node.positive
            section.positiveComponent = component

        section.nodes.push(node)             

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
        @board.color((id for id of section.components), Object.keys(@info.sections[level]).length - 1)
        
        
        