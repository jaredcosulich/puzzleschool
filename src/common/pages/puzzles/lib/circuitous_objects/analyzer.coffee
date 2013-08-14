analyzer = exports ? provide('./analyzer', {})
circuitousObject = require('./object')

class analyzer.Analyzer extends circuitousObject.Object
    constructor: (@board) ->
        @init()

    init: ->
        @info = {matrix: {}, node: {}, sections: {}, components: {}}
        
    run: ->
        @analyze()
        @createMatrix()
        console.log(@info.matrix)
        @solveMatrix()
        componentInfo = {}
        for sectionId, sectionInfo of @info.matrix.loops[1].sections
            for cid, component of @info.sections[sectionId].components
                componentInfo[cid] = sectionInfo
        return componentInfo
                        
    analyze: ->
        for cid, component of @board.components when component.voltage
            continue if @info.components[cid]
            for positiveTerminal in component.currentNodes('positive')
                startNode = @board.boardPosition(positiveTerminal)
                @createSection(component, startNode)
                
                startSections = @info.node["#{startNode.x}:#{startNode.y}"] 
                if (startKeys = Object.keys(startSections)).length == 2
                    startKey = if @compareNodes(startSections[startKeys[1]].nodes[1], startNode) then 1 else 0
                    end = if startKey == 1 then startSections[startKeys[0]] else startSections[startKeys[1]]
                    start = startSections[startKeys[startKey]]                    
                    @consumeSection(start, end)


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

        if component.voltage
            section.direction = (if node.negative then 1 else -1)
            voltage = component.voltage * section.direction
            section.voltage = (section.voltage or 0) + voltage

        section.resistance += component.resistance or 0
        section.components[component.id] = true
        section.nodes[1] = node 
        @info.components[component.id] = section.id

        return true
        
    consumeSection: (section, sectionToBeConsumed) ->
        @deleteSection(sectionToBeConsumed)
        section.components[cid] = true for cid of sectionToBeConsumed.components
        section.resistance = (section.resistance or 0) + (sectionToBeConsumed.resistance or 0)
        section.voltage = (section.voltage or 0) + (sectionToBeConsumed.voltage or 0) 
        section.nodes[1] = sectionToBeConsumed.nodes[1]

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
                    
    recordSection: (section) ->
        @info.sections[section.id] = section 
        node1Coords = "#{section.nodes[0].x}:#{section.nodes[0].y}"
        node2Coords = "#{section.nodes[1].x}:#{section.nodes[1].y}"
        @info.node["#{node1Coords}"] or= {} 
        @info.node["#{node1Coords}"][section.id] = section
        @info.node["#{node2Coords}"] or= {}
        @info.node["#{node2Coords}"][section.id] = section
        
        # @board.clearColors()
        # console.log('record section', section.id, section.direction, node1Coords, node2Coords)
        # @board.color((cid for cid of section.components), 2)    
        # debugger

    deleteSection: (section) ->
        delete @info.sections[section.id]
        delete @info.node["#{section.nodes[0].x}:#{section.nodes[0].y}"][section.id]
        delete @info.node["#{section.nodes[1].x}:#{section.nodes[1].y}"][section.id]

    otherNode: (nodes, node) -> (n for n in nodes when not @compareNodes(n, node))[0]
        
    boardNodes: (component) -> 
        if nodes = component.currentNodes?()
            nodes.map((node) => @board.boardPosition(node))
        else
            component.nodes
            
    addToMatrixLoop: (section, direction) ->
        @info.matrix.currentLoop.start = section.id unless @info.matrix.currentLoop.start
        @info.matrix.currentLoop.sections[section.id] = {resistance: section.resistance * direction}
        @info.matrix.currentLoop.voltage += section.voltage * direction if section.voltage
        @completeMatrixLoop() if @compareNodes(section.nodes...)
        
        # @board.color((cid for cid of section.components), 1)
        # console.log('add to loop', @info.matrix.totalLoops, direction, @info.matrix.currentLoop.voltage, section.resistance * direction)
        # debugger

    initMatrix: ->
        @info.matrix.loops = {}
        @info.matrix.sections = []
        @info.matrix.totalLoops = 0
           
    addMatrixLoop: ->
        # @board.clearColors()
        @info.matrix.currentLoop = {voltage: 0, sections: {}}

    completeMatrixLoop: (loopInfo=@info.matrix.currentLoop)->
        loopInfo.completed = true
        
        for sid of loopInfo.sections
            @info.matrix.sections.push(sid) if @info.matrix.sections.indexOf(sid) == -1
        
        index = 1
        index += 1 while (sid = @info.matrix.sections[index - 1]) and (!loopInfo.sections[sid]?.resistance or @info.matrix.loops[index])
        @info.matrix.loops[index] = loopInfo
        @info.matrix.totalLoops += 1

        # console.log('')
        # @board.clearColors()
        # for sid, section of loopInfo.sections
        #     @board.color((cid for cid of section.components), 2)
        #     console.log('completeLoop', @info.matrix.sections.indexOf(sid), loopInfo.sections[sid].resistance)
        # debugger
        
    matrixLoopDirection: (section, startingNode) ->
        nodeAligned = @compareNodes(section.nodes[0], startingNode)
        if (nodeAligned and section.direction == 1) or (!nodeAligned and section.direction == -1)
            direction = 1
        else
            direction = -1        
        return direction
        
    addMatrixIndentityLoop: (node, sections) ->
        identityLoop = {voltage: 0, sections: {}}
        for sid, section of sections
            identityLoop.sections[sid] = {resistance: @matrixLoopDirection(section, node)}
        @completeMatrixLoop(identityLoop)

        # @board.clearColors()
        # for sid, section of sections
        #     @board.color((cid for cid of section.components), 2)
        #     console.log('add to loop identity', identityLoop.sections[sid].resistance)
        # debugger
        
    createMatrix: ->
        @initMatrix()
        
        identityLoops = {}
        allSections = {}
        allSections[sid] = true for sid of @info.sections

        @addMatrixLoop()

        nextSection = @info.sections[Object.keys(allSections)[0]]
        @addToMatrixLoop(nextSection, 1)
        delete allSections[nextSection.id]
        
        nextNode = nextSection.nodes[1]
        while Object.keys(allSections).length or not @info.matrix.currentLoop.completed
            lastSection = nextSection
            nextSection = null
            nextSections = @info.node["#{nextNode.x}:#{nextNode.y}"]
            
            if Object.keys(nextSections).length > 2
                identityLoopId = (sid for sid of nextSections).sort().join('__')
                unless identityLoops[identityLoopId]
                    identityLoops[identityLoopId] = true
                    @addMatrixIndentityLoop(nextNode, nextSections)
                
            for sid, section of nextSections when sid != lastSection.id and sid == @info.matrix.currentLoop.start
                nextSection = section
                break
                
            if not nextSection
                for sid, section of nextSections when allSections[sid]
                    nextSection = section
                    direction = @matrixLoopDirection(section, nextNode) 
                    break if direction == 1
                    
            if not nextSection
                for sid, section of nextSections when not @info.matrix.currentLoop.sections[sid]
                    nextSection = section 
                    direction = @matrixLoopDirection(section, nextNode) 
                    break if direction == 1

            @completeMatrixLoop() if nextSection and nextSection.id == @info.matrix.currentLoop.start

            if not nextSection or @info.matrix.currentLoop.completed
                return unless Object.keys(allSections).length               
                @addMatrixLoop()
                nextSection = @info.sections[(sid for sid of allSections)[0]]
                direction = 1
                nextNode = nextSection.nodes[0]
                
            @addToMatrixLoop(nextSection, direction)
            delete allSections[nextSection.id]            
            nextNode = @otherNode(nextSection.nodes, nextNode)
    
    fillOutMatrix: ->
        for index, loopInfo of @info.matrix.loops
            loopInfo.adjustedVoltage = loopInfo.voltage
            for sectionId of loopInfo.sections
                loopInfo.sections[sectionId].adjusted = loopInfo.sections[sectionId].resistance
                for index2, loopInfo2 of @info.matrix.loops when index2 != index
                    loopInfo2.sections[sectionId] or= {resistance: 0, adjusted: 0}

    reduceMatrix: ->
        sectionIds = @info.matrix.sections    

        # for debugLoopIndex in [1..@info.matrix.totalLoops]
        #     console.log((@info.matrix.loops[debugLoopIndex].sections[sid].adjusted for sid in sectionIds).join(' | '), @info.matrix.loops[debugLoopIndex].adjustedVoltage)

        for sectionId, variableIndex in sectionIds
            factorLoop = @info.matrix.loops[variableIndex + 1]
            factor = factorLoop.sections[sectionId].adjusted
                
            for loopIndex in [1..@info.matrix.totalLoops] when loopIndex != variableIndex + 1
                adjustingLoop = @info.matrix.loops[loopIndex]
                adjustingfactor = adjustingLoop.sections[sectionId].adjusted
                
                for adjustingSectionId, adjustingVariableIndex in sectionIds
                    adjustingSection = adjustingLoop.sections[adjustingSectionId]
                    adjustingSection.adjusted = adjustingSection.adjusted - (factorLoop.sections[adjustingSectionId].adjusted * (adjustingfactor/factor))
                
                adjustingLoop.adjustedVoltage = adjustingLoop.adjustedVoltage - (factorLoop.adjustedVoltage * (adjustingfactor/factor))
        
                # console.log('')
                # for debugLoopIndex in [1..@info.matrix.totalLoops]
                #     console.log((@info.matrix.loops[debugLoopIndex].sections[sid].adjusted for sid in sectionIds).join(' | '), @info.matrix.loops[debugLoopIndex].adjustedVoltage)
                    
    assignAmps: ->
        for sectionId, index in @info.matrix.sections
            loopInfo = @info.matrix.loops[index + 1]
            amps = Math.round(100.0 * (loopInfo.adjustedVoltage / loopInfo.sections[sectionId].adjusted)) / 100.0
            for loopIndex, settingLoop of @info.matrix.loops
                settingLoop.sections[sectionId].amps = amps
            
    solveMatrix: ->
        @fillOutMatrix()
        @reduceMatrix()
        @assignAmps()           


        