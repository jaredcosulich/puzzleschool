board = exports ? provide('./board', {})
circuitousObject = require('./object')
Client = require('../common_objects/client').Client

class board.Board extends circuitousObject.Object
    cellDimension: 20
    
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
          
    drawWire: (e) ->
        x = Client.x(e)
        y = Client.y(e)
        
        active = @wireInfo.active
        offset = @el.offset()

        if active
            xDiff = Math.abs(active.position.x - x)
            yDiff = Math.abs(active.position.y - y)
            if (active.direction == 'horizontal' and yDiff > xDiff) or
               (active.direction == 'vertical' and xDiff > yDiff)
                x = active.position.x
                y = active.position.y
                active.element.remove() unless active.element.height() and active.element.width()
                delete @wireInfo.active
                active = null
            else
                active.position.x = x
                active.position.y = y                
        
        if not active
            @createWire(x, y)
            return
            
        if not active.direction
            active.direction = (if xDiff > yDiff then 'horizontal' else 'vertical')
            active.element.addClass(active.direction)
            
        if active.direction == 'horizontal'    
            rightOffset = @el.closest('.circuitous').width() - @width
            active.element.css
                left: (if active.start.x < x then active.start.x - offset.left else null)
                right: (if active.start.x > x then @width - (active.start.x - offset.left) + rightOffset  else null)
                width: Math.abs(x - active.start.x)
        else
            active.element.css
                top: (if active.start.y < y then active.start.y - offset.top else null)
                bottom: (if active.start.y > y then @height - (active.start.y - offset.top)  else null)
                height: Math.abs(y - active.start.y)
                
        
    createWire: (x, y) ->
        offset = @el.offset()
        active = @wireInfo.active =
            start: {x: x, y: y}
            position: {x: x, y: y}
            element: $(document.createElement('DIV'))
            
        active.element.addClass('wire')
        active.element.css
            left: active.start.x - offset.left
            top: active.start.y - offset.top
        @el.append(active.element)
        
        
        
        
        
        
        
        