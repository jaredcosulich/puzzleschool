board = exports ? provide('./board', {})
circuitousObject = require('./object')
Client = require('../common_objects/client').Client
Animation = require('../common_objects/animation').Animation

class board.Board extends circuitousObject.Object
    cellDimension: 32
    
    constructor: ({@el}) ->
        @components = {}
        @init()

    init: ->
        @width = @el.width()
        @height = @el.height()
        @drawGrid()
        @initWire()
        @initElectricity()
        
    drawGrid: ->
        rows = @height / @cellDimension
        columns = @width / @cellDimension
        for row in [1..rows]
            for column in [1..columns]
                cell = $(document.createElement('DIV'))
                cell.addClass('cell')
                cell.css(width: @cellDimension-1, height: @cellDimension-1)
                @el.append(cell)
                
    componentsAndWires: -> 
        wireSegments = []
        wireSegments.push((wireSegment for xCoords, wireSegment of nodes)...) for yCoords, nodes of @wireInfo.positions
        [(component for id, component of @components)..., wireSegments...]
                
    addComponent: (component, x, y) ->
        component.boardId = "#{new Date().getTime()}#{Math.random()}" unless component.boardId
        
        offset = @el.offset()
        boardPosition = @boardPosition(x: x, y: y)
        
        onBoardX = 0 < boardPosition.x < @width
        onBoardY = 0 < boardPosition.y < @height
        if onBoardX and onBoardY 
            @components[component.boardId] = component
            roundedBoardPosition = @roundedCoordinates(boardPosition, component.centerOffset)
            component.positionAt(@componentPosition(roundedBoardPosition))
            # for node in component.currentNodes()
            #     @addDot(@boardPosition(node))
        else
            return false
        return true
            
    removeComponent: (component) -> 
        @components[component.boardId]?.setCurrent(0)
        delete @components[component.boardId]
            
    initWire: ->
        @wireInfo = {positions: {}, nodes: {}}
        @el.bind 'mousedown.draw_wire', (e) =>
            $(document.body).one 'mouseup.draw_wire', => 
                $(document.body).unbind('mousemove.draw_wire')
                delete @wireInfo.start      
                delete @wireInfo.continuation
                delete @wireInfo.erasing
                delete @wireInfo.lastSegment      
                          
            $(document.body).bind 'mousemove.draw_wire', (e) => @drawWire(e)
            @drawWire(e)
            
    roundedCoordinates: (coords, offset) ->
        halfDim = @cellDimension / 2
        offsetCoords = 
            x: coords.x - (offset?.left or offset?.x or 0) + halfDim
            y: coords.y - (offset?.top or offset?.y or 0) + halfDim
            
        return {
            x: (Math.round(offsetCoords.x / @cellDimension) * @cellDimension) - halfDim
            y: (Math.round(offsetCoords.y / @cellDimension) * @cellDimension) - halfDim
        }
        
    addDot: ({x, y, color}) ->
        dot =  $(document.createElement('DIV'))
        dot.html('&nbsp;')
        dot.css
            position: 'absolute'
            backgroundColor: color or 'red'
            width: 4
            height: 4
            marginTop: -2
            marginLeft: -2
            left: x
            top: y
            zIndex: 9
        @el.append(dot)
        console.log('dot', x, y, dot)
        
    recordSegmentPosition: (element, start, end) ->
        # @addDot(start)
        # @addDot(end)
        xCoords = [start.x, end.x].sort().join(':')
        yCoords = [start.y, end.y].sort().join(':')
        node1 = "#{start.x}:#{start.y}"
        node2 = "#{end.x}:#{end.y}"
        
        if element
            segment = 
                el: element
                nodes: [start, end]
        
            xCoords = [start.x, end.x].sort().join(':')
            yCoords = [start.y, end.y].sort().join(':')
            @wireInfo.positions[xCoords] or= {}
            @wireInfo.positions[xCoords][yCoords] = segment
        
            @wireInfo.nodes[node1] or= {}
            @wireInfo.nodes[node1][node2] = segment

            @wireInfo.nodes[node2] or= {}
            @wireInfo.nodes[node2][node1] = segment
        else
            delete @wireInfo.positions[xCoords][yCoords]
            delete @wireInfo.nodes[node1][node2]
            delete @wireInfo.nodes[node2][node1]

    getSegmentPosition: (start, end) ->
        @wireInfo.positions[[start.x, end.x].sort().join(':')]?[[start.y, end.y].sort().join(':')]
        
    getSegmentsAt: (node) -> (segment for endPoint, segment of @wireInfo.nodes["#{node.x}:#{node.y}"])  
         
    drawWire: (e) ->
        coords = @roundedCoordinates({x: Client.x(e), y: Client.y(e)}, @el.offset())

        if start = @wireInfo.start
            xDiff = Math.abs(start.x - coords.x)
            yDiff = Math.abs(start.y - coords.y)
                        
            return if xDiff < @cellDimension and yDiff < @cellDimension
            
            xDelta = yDelta = 0
            if xDiff > yDiff
                xDelta = @cellDimension * (if start.x > coords.x then -1 else 1)
            else 
                yDelta = @cellDimension * (if start.y > coords.y then -1 else 1)
                
            for i in [0...Math.floor(Math.max(xDiff, yDiff) / @cellDimension)]
                @createOrEraseWireSegment(x: start.x + xDelta, y: start.y + yDelta)
        else
            @wireInfo.start = coords
            
    createOrEraseWireSegment: (coords) ->
        existingSegment = @getSegmentPosition(@wireInfo.start, coords)

        if @wireInfo.erasing or (existingSegment and (!@wireInfo.continuation or (existingSegment == @wireInfo.lastSegment)))
            segment = @eraseWireSegment(coords) if existingSegment
        else
            segment = @createWireSegment(coords) unless existingSegment
            
        @wireInfo.lastSegment = segment 
        @wireInfo.start = coords
        
    createWireSegment: (coords) ->
        segment = $(document.createElement('DIV'))
        segment.addClass('wire_segment')
        segment.css
            left: Math.min(@wireInfo.start.x, coords.x)
            top: Math.min(@wireInfo.start.y, coords.y)
        
        if Math.abs(@wireInfo.start.x - coords.x) > Math.abs(@wireInfo.start.y - coords.y)
            segment.width(@cellDimension)
            segment.addClass('horizontal')
        else
            segment.height(@cellDimension)
            segment.addClass('vertical')
            
        @el.append(segment)
        @recordSegmentPosition(segment, @wireInfo.start, coords)   
        @wireInfo.continuation = true
        return segment
    
    eraseWireSegment: (coords) ->
        return unless (segment = @getSegmentPosition(@wireInfo.start, coords))
        segment.el.remove()
        @recordSegmentPosition(null, @wireInfo.start, coords)
        @wireInfo.erasing = true unless @wireInfo.continuation
        return segment.el
     
    initElectricity: ->
        @electricalAnimation = new Animation()    
        @electricalAnimation.start 
            method: ({deltaTime, elapsed}) => @moveElectricity(deltaTime, elapsed)
        
    moveElectricity: (deltaTime, elapsed) ->
        # @slowTime = (@slowTime or 0) + deltaTime
        # return unless @slowTime > 2000
        # @slowTime -= 2000
        
        for piece in @componentsAndWires()
            piece.receivingCurrent = false
            piece.excessiveCurrent = false 
        
        for id, component of @components when component.powerSource
            for negativeTerminal in component.currentTerminals('negative')
                if (circuit = @traceConnections(@boardPosition(negativeTerminal), component)).complete
                    if circuit.totalResistance > 0
                        amps = component.voltage / circuit.totalResistance
                        for c in circuit.components   
                            c.receivingCurrent = true
                            c.setCurrent?(amps)                         
                        # console.log('complete', circuit.totalResistance, amps)
                    else
                        amps = 'infinite'
                        for c in circuit.components
                            c.excessiveCurrent = true
                            c.el.addClass('excessive_current')
                        # console.log('complete', circuit.totalResistance, amps)
                else
                    # console.log('incomplete')

        for piece in @componentsAndWires()
            piece.el.removeClass('excessive_current') unless piece.excessiveCurrent
            piece.setCurrent?(0) unless piece.receivingCurrent
                    
    boardPosition: (componentPosition) ->
        offset = @el.offset()
        return {
            x: componentPosition.x - offset.left + 1
            y: componentPosition.y - offset.top + 1
        }
        
    componentPosition: (boardPosition) ->
        offset = @el.offset()
        return {
            x: boardPosition.x + offset.left - 1
            y: boardPosition.y + offset.top - 1
        }
        
    compareNodes: (node1, node2) -> node1.x == node2.x and node1.y == node2.y
                    
    traceConnections: (node, component, circuit={totalResistance: 0, components: []}) ->
        circuit.id = "#{new Date().getTime()}#{Math.random()}" unless circuit.id        
        if (nextNodeInfo = @findConnection(node, component, circuit.id))
            circuit.totalResistance += nextNodeInfo.component.resistance or 0
            circuit.components.push(nextNodeInfo.component)
            if nextNodeInfo.component.powerSource    
                circuit.complete = true 
            else           
                return @traceConnections(nextNodeInfo.otherNode, nextNodeInfo.component, circuit)
        else
            circuit.complete = false
        return circuit
    
    findConnection: (node, component, circuitId) ->
        for id, c of @components when c != component
            if c.powerSource
                for positiveTerminal in c.currentTerminals('positive')
                    return {component: c} if @compareNodes(@boardPosition(positiveTerminal), node)
            else
                for n in c.currentNodes() when @compareNodes(@boardPosition(n), node)
                    if c.soloNode
                        c.setComingFrom(circuitId, component)
                        otherNode = n
                    else
                        otherNode = (otherNode for otherNode in c.currentNodes() when not @compareNodes(@boardPosition(n), otherNode))[0]
                    return {component: c, otherNode: @boardPosition(otherNode)}
                        
        for segment in @getSegmentsAt(node)
            continue if segment.el == component.el
            continue if segment.el == component.comingFrom?(circuitId)?.el
            wireSegment = segment
            break
            
        return false unless wireSegment
        otherNode = (n for n in wireSegment.nodes when not @compareNodes(n, node))[0]
        return {component: wireSegment, otherNode: otherNode}
         
            