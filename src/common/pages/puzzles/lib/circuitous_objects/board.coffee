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
        @wireInfo = {}
        @el.bind 'mousedown.draw_wire', (e) =>
            $(document.body).one 'mouseup.draw_wire', => 
                @el.unbind('mousemove.draw_wire')
                delete @wireInfo.active                
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
         
    drawWire: (e) ->
        coords = @roundedCoordinates(x: Client.x(e), y: Client.y(e))

        if active = @wireInfo.active
            xDiff = Math.abs(active.position.x - coords.x)
            yDiff = Math.abs(active.position.y - coords.y)
            return if xDiff < @cellDimension and yDiff < @cellDimension
            if (active.direction == 'horizontal' and yDiff > xDiff) or
               (active.direction == 'vertical' and xDiff > yDiff)
                coords.x = active.position.x
                coords.y = active.position.y
                active.element.remove() unless active.element.height() and active.element.width()
                delete @wireInfo.active
                active = null
        
        if not active
            @createWire(coords)
            return
            
        if not active.direction
            active.direction = (if xDiff > yDiff then 'horizontal' else 'vertical')
            active.element.addClass(active.direction)
            
        @adjustActiveWire(coords)
            
    adjustActiveWire: (coords) ->
        return unless active = @wireInfo.active
        if active.direction == 'horizontal'
            rightOffset = @el.closest('.circuitous').width() - @width
            active.element.css
                left: (if active.start.x < coords. x then active.start.x else null)
                right: (if active.start.x > coords.x then @width - active.start.x + rightOffset  else null)
                width: Math.abs(coords.x - active.start.x)
            active.position.x = coords.x
        else
            active.element.css
                top: (if active.start.y < coords.y then active.start.y else null)
                bottom: (if active.start.y > coords.y then @height - active.start.y else null)
                height: Math.abs(coords.y - active.start.y)                
            active.position.y = coords.y
        
    createWire: (coords) ->
        active = @wireInfo.active =
            start: {x: coords.x, y: coords.y}
            position: {x: coords.x, y: coords.y}
            element: $(document.createElement('DIV'))
            
        active.element.addClass('wire')
        active.element.css
            left: active.start.x
            top: active.start.y
        @el.append(active.element)
        
        
        
        
        
        
        
        