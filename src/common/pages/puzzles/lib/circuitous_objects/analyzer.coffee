analyzer = exports ? provide('./analyzer', {})
circuitousObject = require('./object')

class analyzer.Analyzer extends circuitousObject.Object
    constructor: (@board) ->
        @init()

    init: ->
        @info = {matrix: {}, node: {}, nodes: {}, sections: {}, components: {}}
        
    run: ->
        @analyze()
        @createMatrix()
        console.log(@info.matrix)
        # solution = @solveMatrix()
        # console.log(solution)
                        
    analyze: ->
        for cid, component of @board.components when component.powerSource
            continue if @info.components[cid]
            for positiveTerminal in component.currentNodes('positive')
                node = @board.boardPosition(positiveTerminal)
                @createSection(component, node)

    newSection: (node) ->
        section = {nodes: [node], resistance: 0, components: {}, sections: {}, id: @generateId('section')}
        return section
                        
    createSection: (component, node) ->
        section = @newSection(node)
        connections = @analyzeSection(section, component, @otherNode(@boardNodes(component), node))
        if connections?.length > 1
            @createSection(c.component, c.node) for c in connections
        @endSection(section)
          
    analyzeSection: (section, component, node) ->
        if @addToSection(section, component, node)            
            connections = @findConnections(node, section)
            
            # @board.clearColors()
            # @board.color([c.component.id], 1) for c in connections
            # debugger

            if connections.length == 1
                connection = connections[0]
                return @analyzeSection(section, connection.component, connection.otherNode)
            else if connections.length > 1
                return connections
        return
                        
    addToSection: (section, component, node) ->
        return false if @info.components[component.id]

        if component.powerSource
            section.direction = (if node.negative then 1 else -1)
            voltage = component.voltage * component.direction
            section.voltage = (section.voltage or 0) + voltage
            section.powerSource = true
            section.negativeComponentId = component.negativeComponentId or component.id

        section.resistance += component.resistance or 0
        section.components[component.id] = true
        section.nodes[1] = node 
        @info.components[component.id] = section.id

        return true

    endSection: (section) ->
        return unless Object.keys(section.components).length
        section.direction = 1 unless section.direction
        @recordSection(section, component)
                        
    findConnections: (node, exceptInSection) ->
        connections = []
        for id, c of @board.components when not exceptInSection?.components[id]
            for n in (nodes = c.currentNodes())
                matchingNode = @board.boardPosition(n)
                continue unless @compareNodes(matchingNode, node)
                if nodes.length == 1
                    return [{component: c, otherNode: matchingNode, node: node}]                   
                else
                    otherNode = @board.boardPosition(@otherNode(nodes, n))
                connections.push({component: c, otherNode: otherNode, node: node})

        for segment in @board.wires.find(node) when not exceptInSection?.components[segment.id]
            connections.push({component: segment, otherNode: @otherNode(segment.nodes, node), node: node})

        return connections
       
    compareNodes: (node1, node2) -> node1.x == node2.x and node1.y == node2.y
                    
    recordSection: (section, children) ->
        if children
            children = [children] unless /Array/.test(children.constructor)
            for child in children
                child.parentId = section.id  
                section.sections[child.id] = true
        
        @info.sections[section.id] = section 

        node1Coords = "#{section.nodes[0].x}:#{section.nodes[0].y}"
        node2Coords = "#{section.nodes[1].x}:#{section.nodes[1].y}"
        
        @info.node["#{node1Coords}"] or= {} 
        @info.node["#{node1Coords}"][section.id] = section
        @info.node["#{node2Coords}"] or= {}
        @info.node["#{node2Coords}"][section.id] = section
        @info.nodes["#{node1Coords}#{node2Coords}"] or= {} 
        @info.nodes["#{node1Coords}#{node2Coords}"][section.id] = section
        @info.nodes["#{node2Coords}#{node1Coords}"] or= {}
        @info.nodes["#{node2Coords}#{node1Coords}"][section.id] = section    
        
        # @board.clearColors()
        # console.log('record section', section.id, section.direction, node1Coords, node2Coords)
        # @board.color((cid for cid of section.components), 2)    
        # debugger

    otherNode: (nodes, node) -> (n for n in nodes when not @compareNodes(n, node))[0]
        
    boardNodes: (component) -> 
        if nodes = component.currentNodes?()
            nodes.map((node) => @board.boardPosition(node))
        else
            component.nodes
            
    addToMatrixLoop: (section, direction) ->
        @currentMatrixLoop().start = section.id unless @currentMatrixLoop().start
        @currentMatrixLoop()[section.id] = {resistance: section.resistance * direction}
        @currentMatrixLoop().voltage += section.voltage * direction if section.voltage

        # @board.color((cid for cid of section.components), 1)
        # console.log('add to loop', @info.matrix.currentLoop, direction, @currentMatrixLoop()[section.id], @currentMatrixLoop().voltage)
        # debugger
           
    addMatrixLoop: () ->
        @board.clearColors()
        @info.matrix.currentLoop or= 0
        @info.matrix.currentLoop += 1
        @info.matrix[@info.matrix.currentLoop] = {voltage: 0}
        
    currentMatrixLoop: -> @info.matrix[@info.matrix.currentLoop]
                 
    matrixLoopDirection: (section, startingNode) ->
        nodeAligned = @compareNodes(section.nodes[0], startingNode)
        if (nodeAligned and section.direction == 1) or (!nodeAligned and section.direction == -1)
            direction = 1
        else
            direction = -1        
        return direction
           
    createMatrix: ->
        allSections = {}
        allSections[sid] = true for sid of @info.sections

        @addMatrixLoop()

        nextSection = @info.sections[Object.keys(allSections)[0]]
        @addToMatrixLoop(nextSection, 1)
        delete allSections[nextSection.id]
        
        nextNode = nextSection.nodes[1]
        while Object.keys(allSections).length or not @currentMatrixLoop().completed
            lastSection = nextSection
            nextSection = null
            nextSections = @info.node["#{nextNode.x}:#{nextNode.y}"]
            
            for sid, section of nextSections when sid != lastSection.id and sid == @currentMatrixLoop().start
                nextSection = section
                break
                
            if not nextSection
                for sid, section of nextSections when allSections[sid]
                    nextSection = section
                    direction = @matrixLoopDirection(section, nextNode) 
                    break if direction == 1
                    
            if not nextSection
                for sid, section of nextSections when not @currentMatrixLoop()[sid]
                    nextSection = section 
                    direction = @matrixLoopDirection(section, nextNode) 
                    break if direction == 1

            @currentMatrixLoop().completed = (nextSection.id == @currentMatrixLoop().start)

            if not nextSection or @currentMatrixLoop().completed
                return unless Object.keys(allSections).length               
                @addMatrixLoop()
                nextSection = @info.sections[(sid for sid of allSections)[0]]
                direction = 1
                nextNode = nextSection.nodes[0]
                
            @addToMatrixLoop(nextSection, direction)
            delete allSections[nextSection.id]
            nextNode = @otherNode(nextSection.nodes, nextNode)
        
        