board = exports ? provide('./board', {})
circuitousObject = require('./object')
Client = require('../common_objects/client').Client

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
        else
            return false
            
    initWire: ->
        @wireInfo = {positions: {}}
        @el.bind 'mousedown.draw_wire', (e) =>
            $(document.body).one 'mouseup.draw_wire', => 
                @el.unbind('mousemove.draw_wire')
                delete @wireInfo.start      
                delete @wireInfo.continuation
                delete @wireInfo.erasing
                delete @wireInfo.lastSegment      
                          
            @el.bind 'mousemove.draw_wire', (e) => @drawWire(e)
            @drawWire(e)
            
    roundedCoordinates: (coords) ->
        offset = @el.offset()
        
        halfDim = @cellDimension / 2
        offsetCoords = 
            x: coords.x - offset.left + halfDim
            y: coords.y - offset.top + halfDim
            
        return {
            x: (Math.round(offsetCoords.x / @cellDimension) * @cellDimension) - halfDim
            y: (Math.round(offsetCoords.y / @cellDimension) * @cellDimension) - halfDim
        }
        
    recordSegmentPosition: (segment, start, end) ->
        xCoords = [start.x, end.x].sort().join(':')
        yCoords = [start.y, end.y].sort().join(':')
        @wireInfo.positions[xCoords] or= {}
        @wireInfo.positions[xCoords][yCoords] = segment

    getSegmentPosition: (start, end) ->
        @wireInfo.positions[[start.x, end.x].sort().join(':')]?[[start.y, end.y].sort().join(':')]
         
    drawWire: (e) ->
        coords = @roundedCoordinates(x: Client.x(e), y: Client.y(e))

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

        if @wireInfo.erasing or (existingSegment and !@wireInfo.continuation)
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
        segment.remove()
        @recordSegmentPosition(null, @wireInfo.start, coords)
        @wireInfo.erasing = true
        return segment
        
        
        
        
        