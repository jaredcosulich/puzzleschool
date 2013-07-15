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

        leftRemainder = offset.left % @cellDimension
        leftRemainder = leftRemaineder - @cellDimension if leftRemainder > (@cellDimension / 2)

        topRemainder = offset.top % @cellDimension
        topRemainder = topRemainder - @cellDimension if topRemainder > (@cellDimension / 2)

        return {
            x: (Math.floor(coords.x / @cellDimension) * @cellDimension) + (@cellDimension / 2) + leftRemainder
            y: (Math.floor(coords.y / @cellDimension) * @cellDimension) + (@cellDimension / 2) + topRemainder
        }
         
    drawWire: (e) ->
        coords = @roundedCoordinates(x: Client.x(e), y: Client.y(e))
        
        active = @wireInfo.active

        if active
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
        offset = @el.offset()
        if active.direction == 'horizontal'
            rightOffset = @el.closest('.circuitous').width() - @width
            active.element.css
                left: (if active.start.x <coords. x then active.start.x - offset.left else null)
                right: (if active.start.x > coords.x then @width - (active.start.x - offset.left) + rightOffset  else null)
                width: Math.abs(coords.x - active.start.x)
            active.position.x = coords.x
        else
            active.element.css
                top: (if active.start.y < coords.y then active.start.y - offset.top else null)
                bottom: (if active.start.y > coords.y then @height - (active.start.y - offset.top)  else null)
                height: Math.abs(coords.y - active.start.y)                
            active.position.y = coords.y
        
    createWire: (coords) ->
        offset = @el.offset()
        active = @wireInfo.active =
            start: {x: coords.x, y: coords.y}
            position: {x: coords.x, y: coords.y}
            element: $(document.createElement('DIV'))
            
        active.element.addClass('wire')
        active.element.css
            left: active.start.x - offset.left
            top: active.start.y - offset.top
        @el.append(active.element)
        
        
        
        
        
        
        
        