analyzer = exports ? provide('./analyzer', {})
circuitousObject = require('./object')

class analyzer.Analyzer extends circuitousObject.Object
    constructor: (@board) ->
        @init()

    init: ->
        @info = {matrix: {}, node: {}, sections: {}, components: {}}
        
    run: ->
        @init()
        @analyze()
        @createMatrix()
        # console.log(@info.matrix)
        @saveMatrixIdentityLoops()
        # console.log(JSON.stringify(@info.matrix))
        @solveMatrix()
        @deleteShorts()
        @checkPolarizedComponents()
        return @roundedComponentValues()

    roundedComponentValues: ->
        componentInfo = {}
        
        round = (number) -> (if isNaN(number) then number else Math.round(number * 100.0) / 100.0)
        
        for sectionId, section of @info.sections
            # @board.clearColors()
            # console.log('section', section.resistance, section.amps)
            # @board.color((cid for cid of section.components), 2)
            # debugger
            
            for cid of section.components
                resistance = round(section.resistance)
                amps = round(section.amps) 
                amps = 'infinite' if amps > 1000
                componentInfo[cid] = {resistance: resistance, amps: amps}
        return componentInfo
        
        
    analyze: ->
        for cid, component of @board.components when component.voltage
            continue if @info.components[cid]
            for positiveTerminal in component.currentNodes('positive')
                startNode = @board.boardPosition(positiveTerminal)
                @createSections([{component: component, node: startNode}])
                
                startSections = (s for s in @info.node[@nodeId(startNode)] when not @compareNodes(s.nodes[0], s.nodes[1])) 
                if (startKeys = Object.keys(startSections)).length == 2
                    startKey = if @compareNodes(startSections[startKeys[1]].nodes[1], startNode) then 1 else 0
                    end = if startKey == 1 then startSections[startKeys[0]] else startSections[startKeys[1]]
                    start = startSections[startKeys[startKey]]                    
                    @consumeSection(start, end)

        # @board.clearColors()
        # for sid, section of @info.sections
        #     console.log('section', sid)
        #     @board.color((cid for cid of section.components), 2)
        #     debugger
        
    nodeId: (node) -> "#{node.x}:#{node.y}"
                    
    newSection: (node) ->
        section = {nodes: [node], resistance: 0, components: {}, sections: {}, id: @generateId('section')}
        return section
                        
    createSections: (sectionInfos) ->
        connections = [] 
        for sectionInfo in sectionInfos
            connections = connections.concat(@createSection(sectionInfo.component, sectionInfo.node))
        @createSections(connections) if connections.length    
                        
    createSection: (component, node) ->
        section = @newSection(node)
        connections = @analyzeSection(section, component, @otherNode(@boardNodes(component), node))
        @endSection(section)
        return connections
          
    analyzeSection: (section, component, node) ->
        if @addToSection(section, component, node)            
            connections = (c for c in @findConnections(node) when c.component != component)
            
            if component.nodes.length == 1
                connections = (c for c in connections when not @info.components[c.component.id])
            
            for connection in connections
                if connection.component.nodes.length == 1
                    connections = [connection]
                    break
            
            # @board.clearColors()
            # @board.color([c.component.id], 1) for c in connections
            # debugger

            if connections.length == 1
                connection = connections[0]
                return @analyzeSection(section, connection.component, connection.otherNode)
            else if connections.length > 1
                return connections
        return []
                        
    addToSection: (section, component, node) ->
        # console.log(component.id)
        # @board.clearColors()
        # @board.color([component.id], 1)
        # debugger
        return false if @info.components[component.id]

        if (componentNodes = @boardNodes(component)).length > 1
            component.direction = (if @compareNodes(node, componentNodes[1]) then 1 else -1)

        if component.voltage
            voltage = component.voltage * (if node.negative then 1 else -1)
            section.voltage = (section.voltage or 0) + voltage

        section.resistance += component.resistance or 0
        section.components[component.id] = true
        section.nodes[1] = node 
        @info.components[component.id] = section.id
        
        return true
        
    consumeSection: (section, sectionToBeConsumed) ->
        @deleteSection(section)
        @deleteSection(sectionToBeConsumed)
        for cid of sectionToBeConsumed.components
            @info.components[cid] = section.id
            section.components[cid] = true
        section.resistance = (section.resistance or 0) + (sectionToBeConsumed.resistance or 0)
        section.voltage = (section.voltage or 0) + (sectionToBeConsumed.voltage or 0) 
        section.nodes[1] = sectionToBeConsumed.nodes[1]
        @recordSection(section)

    endSection: (section) ->
        return unless Object.keys(section.components).length
        section.direction = 1 unless section.direction
        
        if section.direction == -1
            for cid of section.components
                component = @board.componentsAndWires()[cid]
                component.direction = component.direction * -1
                
        @recordSection(section, component)
                        
    findConnections: (node) ->
        connections = []
        
        for id, c of @board.components
            for n in (nodes = c.currentNodes())
                matchingNode = @board.boardPosition(n)
                continue unless @compareNodes(matchingNode, node)
                if nodes.length == 1
                    otherNode = matchingNode                   
                else
                    otherNode = @board.boardPosition(@otherNode(nodes, n))
                connections.push({component: c, otherNode: otherNode, node: node})

        for segment in @board.wires.find(node)
            connections.push({component: segment, otherNode: @otherNode(segment.nodes, node), node: node})

        return connections
       
    compareNodes: (node1, node2) -> node1.x == node2.x and node1.y == node2.y
                    
    recordSection: (section) ->
        @info.sections[section.id] = section 
        node1Coords = @nodeId(section.nodes[0])
        node2Coords = @nodeId(section.nodes[1])
        @info.node[node1Coords] or= {} 
        @info.node[node1Coords][section.id] = section
        @info.node[node2Coords] or= {}
        @info.node[node2Coords][section.id] = section
        
        # @board.clearColors()
        # console.log('record section', section.id, section.direction, node1Coords, node2Coords)
        # @board.color((cid for cid of section.components), 2)    
        # debugger

    deleteSection: (section) ->
        delete @info.sections[section.id]
        delete @info.node[@nodeId(section.nodes[0])][section.id]
        delete @info.node[@nodeId(section.nodes[1])][section.id]

    otherNode: (nodes, node) -> (n for n in nodes when not @compareNodes(n, node))[0]
        
    boardNodes: (component) -> 
        if nodes = component.currentNodes?()
            nodes.map((node) => @board.boardPosition(node))
        else
            component.nodes
            
    addToMatrixLoop: (section, direction, node) ->
        @info.matrix.currentLoop.path.push(section.id)
        @info.matrix.currentLoop.nodes[@nodeId(node)] = true
        @info.matrix.currentLoop.startNode = node unless @info.matrix.currentLoop.startNode
        @info.matrix.currentLoop.sections[section.id] = {resistance: section.resistance * direction * -1}
        @info.matrix.currentLoop.voltage += section.voltage * direction * -1 if section.voltage
        @completeMatrixLoop() if @compareNodes(section.nodes...) and Object.keys(@info.matrix.currentLoop.sections).length == 1
        
        @info.matrix.pathsAnalyzed[@info.matrix.currentLoop.path.join('__')] = true

        # @board.color((cid for cid of section.components), 1)
        # console.log('add to loop', @info.matrix.totalLoops, direction, @info.matrix.currentLoop.voltage, section.resistance * direction * -1, section.id)
        # debugger

    initMatrix: ->
        @info.matrix.loops = {}
        @info.matrix.unsavedIdentityLoops = []
        @info.matrix.sections = []
        @info.matrix.pathsToTry = []
        @info.matrix.pathsAnalyzed = {}
        @info.matrix.totalLoops = 0
           
    addMatrixLoop: ->
        # @board.clearColors()
        @info.matrix.currentLoop = {voltage: 0, sections: {}, path: [], nodes: {}}
        
    completeMatrixLoop: (loopInfo=@info.matrix.currentLoop)->
        loopInfo.completed = true
        if loopInfo.identity
            loopInfo.id = ("#{sid}:#{s.resistance}" for sid, s of loopInfo.sections).join('__')        
        else
            loopInfo.id = (sid for sid of loopInfo.sections).sort().join('__')
        return if @info.matrix.loops[loopInfo.id]
        
        for sid of loopInfo.sections
            @info.matrix.sections.push(sid) if @info.matrix.sections.indexOf(sid) == -1
        
        @info.matrix.totalLoops += 1
        @info.matrix.loops[loopInfo.id] = loopInfo

        # console.log('')
        # @board.clearColors()
        # for sid of loopInfo.sections
        #     @board.color((cid for cid of @info.sections[sid].components), 2)
        # console.log('completeLoop', "identity=#{loopInfo.identity}", loopInfo.voltage, (s.resistance for sid, s of loopInfo.sections))
        # debugger
        # @board.clearColors()
        
    matrixLoopDirection: (section, startingNode) ->
        nodeAligned = @compareNodes(section.nodes[0], startingNode)
        if (nodeAligned and section.direction == 1) or (!nodeAligned and section.direction == -1)
            direction = 1
        else
            direction = -1        
        
    addMatrixIndentityLoop: (node, sections) ->
        # console.log('')
        # @board.clearColors()
        # @board.addDot(x: node.x, y: node.y, color: 'green')
        # for sid, section of sections
        #     @board.color((cid for cid of @info.sections[sid].components), (@matrixLoopDirection(section, node) + 2))
        # console.log('identity loop', ((@matrixLoopDirection(section, node) * -1) for sid, section of sections))
        # debugger
        # @board.clearColors()

        identityLoop = {identity: true, voltage: 0, sections: {}}
        for sid, section of sections
            identityLoop.sections[sid] = {resistance: @matrixLoopDirection(section, node) * -1}
        @info.matrix.unsavedIdentityLoops.push(identityLoop)
        
    saveMatrixIdentityLoops: ->
        for identityLoop in @info.matrix.unsavedIdentityLoops
            for sectionId of identityLoop.sections when @info.matrix.sections.indexOf(sectionId) == -1
                delete identityLoop.sections[sectionId]
            @completeMatrixLoop(identityLoop) if Object.keys(identityLoop.sections).length
        delete @info.matrix.unsavedIdentityLoops
        
    createMatrix: ->
        @initMatrix()
        
        for cid, component of @board.components
            @addMatrixLoop()
            nextSection = @info.sections[@info.components[cid]]
            continue if not nextSection
            
            @addToMatrixLoop(nextSection, 1, nextSection.nodes[0])
            
            nextNode = nextSection.nodes[0]
            while nextSection 
                nextNode = @otherNode(nextSection.nodes, nextNode)   

                if nextNode
                    nextSections = @info.node[@nodeId(nextNode)]
                    @addMatrixIndentityLoop(nextNode, nextSections)
            
                lastSection = nextSection
                nextSection = null

                if nextNode and @compareNodes(nextNode, @info.matrix.currentLoop.startNode)
                    @completeMatrixLoop() 
                else if nextNode and not @info.matrix.currentLoop.nodes[@nodeId(nextNode)]
                    if Object.keys(nextSections).length > 2
                        for sid of nextSections
                            continue if @info.matrix.currentLoop.sections[sid]
                            continue if @info.matrix.pathsAnalyzed[[@info.matrix.currentLoop.path..., sid].join('__')]
                            if nextSection
                                @info.matrix.pathsToTry.push(@info.matrix.currentLoop.path.concat([sid]))
                            else
                                nextSection = @info.sections[sid]
                                direction = @matrixLoopDirection(nextSection, nextNode)

                if not nextSection
                    @addMatrixLoop() 
                    if (path = @info.matrix.pathsToTry.splice(0, 1)[0])
                        nextNode = @info.sections[path[0]].nodes[0]
                        for sectionId, index in path
                            nextSection = @info.sections[sectionId]
                            direction = @matrixLoopDirection(nextSection, nextNode)
                            if index < path.length - 1
                                @addToMatrixLoop(nextSection, direction, nextNode)
                                nextNode = @otherNode(nextSection.nodes, nextNode)                            
                
                if nextSection
                    @addToMatrixLoop(nextSection, direction, nextNode)
                     
    
    fillOutMatrix: ->
        for index, loopInfo of @info.matrix.loops
            loopInfo.adjustedVoltage = loopInfo.voltage
            for sectionId of loopInfo.sections
                loopInfo.sections[sectionId].adjusted = loopInfo.sections[sectionId].resistance
                for index2, loopInfo2 of @info.matrix.loops when index2 != index
                    loopInfo2.sections[sectionId] or= {resistance: 0, adjusted: 0}

    reduceMatrix: ->
        return unless Object.keys(@info.matrix.loops).length
        sectionIds = @info.matrix.sections    

        # console.log(sectionIds)
        # for loopId, loopInfo of @info.matrix.loops
        #     console.log((loopInfo.sections[sid].adjusted for sid in sectionIds).join(' | '), loopInfo.adjustedVoltage)
        # console.log('')
        
        equalsZero = (number) => ((@board.wires.resistance * -1) < number < @board.wires.resistance)

        for sectionId, variableIndex in sectionIds
            for factorLoopId, factorLoop of @info.matrix.loops
                tested = true
                for testSectionId, testIndex in sectionIds when testIndex < variableIndex
                    if not equalsZero(factorLoop.sections[testSectionId].adjusted)
                        tested = false
                        break
                tested = false if equalsZero(factorLoop.sections[sectionId].adjusted)
                break if tested
            factor = factorLoop.sections[sectionId].adjusted
            # console.log(variableIndex, factor)
            continue unless factor
                
            for adjustingLoopId, adjustingLoop of @info.matrix.loops when adjustingLoopId != factorLoopId
                adjustingfactor = adjustingLoop.sections[sectionId].adjusted
                
                for adjustingSectionId, adjustingVariableIndex in sectionIds
                    adjustingSection = adjustingLoop.sections[adjustingSectionId]
                    adjustingSection.adjusted = adjustingSection.adjusted - (factorLoop.sections[adjustingSectionId].adjusted * (adjustingfactor/factor))
                    adjustingSection.adjusted = 0 if equalsZero(adjustingSection.adjusted)
                
                adjustingLoop.adjustedVoltage = adjustingLoop.adjustedVoltage - (factorLoop.adjustedVoltage * (adjustingfactor/factor))
                adjustingLoop.adjustedVoltage = 0 if equalsZero(adjustingLoop.adjustedVoltage)
        
            # for loopId, loopInfo of @info.matrix.loops
            #     console.log((loopInfo.sections[sid].adjusted for sid in sectionIds).join(' | '), loopInfo.adjustedVoltage)
            # console.log('')
            
        for loopId, loopInfo of @info.matrix.loops
            variableCount = 0
            for sectionId, sectionInfo of loopInfo.sections
                variableCount += 1 unless equalsZero(sectionInfo.adjusted)
            loopInfo.unsolved = true if variableCount > 1
                    
    assignAmps: ->
        for sectionId, index in @info.matrix.sections
            continue if @info.sections[sectionId].amps
            for loopInfoIndex, loopInfo of @info.matrix.loops when not loopInfo.unsolved
                break if loopInfo.sections[sectionId].adjusted != 0
            if loopInfo    
                @info.sections[sectionId].amps = loopInfo.adjustedVoltage / loopInfo.sections[sectionId].adjusted
            
            # @board.clearColors()
            # @board.color((cid for cid of @info.sections[sectionId].components), 1)
            # console.log('amps', @info.sections[sectionId].amps)
            # debugger
            
        # console.log('')
        # for loopId, loopInfo of @info.matrix.loops
        #     console.log(("#{loopInfo.sections[sid].adjusted} / #{@info.sections[sid].amps}" for sid in @info.matrix.sections).join(' | '), loopInfo.adjustedVoltage)

            
    solveMatrix: ->
        delete loopInfo.unsolved for loopId, loopInfo of @info.matrix.loops
        @fillOutMatrix()
        @reduceMatrix()
        @assignAmps()           

    deleteShorts: ->
        changeMade = false
        
        for sid, section of @info.sections
            if section.resistance < 0.01 and Math.abs(section.amps) > 1000
                changeMade = true
                section.amps = 'infinite'

        for loopId, loopInfo of @info.matrix.loops
            for sid of loopInfo.sections
                delete @info.matrix.loops[loopId] if @info.sections[sid].amps == 'infinite'
        
        if changeMade
            delete section.amps for sid, section of @info.sections when section.amps != 'infinite'
            @solveMatrix()
            @deleteShorts()

                        
    checkPolarizedComponents: ->
        changeMade = false
        for cid, component of @board.components when component.nodes.length > 1 and component.nodes and not component.voltage
            section = @info.sections[@info.components[cid]]
            if @info.matrix.sections.indexOf(section.id) > -1
                if section.amps > 0 and component.direction < 0 or section.amps < 0 and component.direction > 0
                    changeMade = true
                    @info.matrix.sections.splice(@info.matrix.sections.indexOf(section.id, 1))
                    for loopId, loopInfo of @info.matrix.loops
                        delete @info.matrix.loops[loopId] if loopInfo.sections[section.id]
        
        if changeMade
            delete section.amps for sid, section of @info.sections
            @solveMatrix()
            @checkPolarizedComponents()
        