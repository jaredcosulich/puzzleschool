board = exports ? provide('./board', {})
circuitousObject = require('./object')
Client = require('../common_objects/client').Client
Animation = require('../common_objects/animation').Animation

class board.Board extends circuitousObject.Object
    cellDimension: 32
    
    constructor: ({@el}) ->
        @items = []
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
                
    addItem: (item, x, y) ->
        offset = @el.offset()
        onBoardX = offset.left < x < offset.left + @width
        onBoardY = offset.top < y < offset.top + @height
        if onBoardX and onBoardY 
            @items.push(item)
            item.positionAt(@roundedCoordinates({x: x, y: y}))
        else
            return false
        return true
            
    removeItem: (item) -> @items.splice(@items.indexOf(item), 1)
            
    initWire: ->
        @wireInfo = {positions: {}, nodes: {}}
        @el.bind 'mousedown.draw_wire', (e) =>
            $(document.body).one 'mouseup.draw_wire', => 
                @el.unbind('mousemove.draw_wire')
                delete @wireInfo.start      
                delete @wireInfo.continuation
                delete @wireInfo.erasing
                delete @wireInfo.lastSegment      
                          
            @el.bind 'mousemove.draw_wire', (e) => @drawWire(e)
            @drawWire(e)
            
    roundedCoordinates: (coords, offset) ->
        halfDim = @cellDimension / 2
        offsetCoords = 
            x: coords.x - (offset?.left or 0) + halfDim
            y: coords.y - (offset?.top or 0) + halfDim
            
        return {
            x: (Math.round(offsetCoords.x / @cellDimension) * @cellDimension) - halfDim
            y: (Math.round(offsetCoords.y / @cellDimension) * @cellDimension) - halfDim
        }
        
    addDot: ({x, y, color}) ->
        console.log('dot', x, y)
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
        
    recordSegmentPosition: (element, start, end) ->
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
            
            if last = @wireInfo.lastSegment
                if last.hasClass('vertical')
                    xDiff = xDiff * 0.75 
                else
                    yDiff = yDiff * 0.75 
            
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
        # return unless parseInt(elapsed) % 200 == 0
        
        for item in @items when item.powerSource
            for negativeTerminal in item.currentTerminals('negative')
                if (circuit = @traceConnections(@boardNode(negativeTerminal), item)).complete
                    if circuit.totalResistance > 0
                        amps = item.voltage / circuit.totalResistance
                        console.log('complete', circuit.totalResistance, amps)
                    else
                        amps = 'infinite'
                        for item in circuit.items
                            item.el.css(backgroundColor: '#FF0000')
                        console.log('complete', circuit.totalResistance, amps)
                        return
                else
                    console.log('incomplete')

                for item in circuit.items
                    item.el.css(backgroundColor: '#000')
                    
    boardNode: (objectNode) ->
        offset = @el.offset()
        return {
            x: objectNode.x - offset.left 
            y: objectNode.y - offset.top
        }
        
    compareNodes: (node1, node2) -> node1.x == node2.x and node1.y == node2.y
                    
    traceConnections: (node, item, circuit={totalResistance: 0, items: []}) ->         
        if (nextNodeInfo = @findConnection(node, item))
            circuit.totalResistance += nextNodeInfo.item.resistance or 0
            circuit.items.push(nextNodeInfo.item)
            if nextNodeInfo.item.powerSource    
                circuit.complete = true 
            else           
                return @traceConnections(nextNodeInfo.otherNode, nextNodeInfo.item, circuit)
        else
            circuit.complete = false
        return circuit
    
    findConnection: (node, item) ->
        for i in @items when i.powerSource
            for positiveTerminal in i.currentTerminals('positive')
                return {item: i} if @compareNodes(@boardNode(positiveTerminal), node)
                
        wireSegment = (segment for segment in @getSegmentsAt(node) when segment.el != item.el)[0]
        return false unless wireSegment
        otherNode = (n for n in wireSegment.nodes when not @compareNodes(n, node))[0]
        return {item: wireSegment, otherNode: otherNode}
         
            