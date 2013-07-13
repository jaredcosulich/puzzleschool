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
                delete @wireStart
                
            @wireInfo.active =
                start: 
                    x: Client.x(e)
                    y: Client.y(e)
                position: 
                    x: Client.x(e)
                    y: Client.y(e)
            
                
            @el.bind 'mousemove.draw_wire', (e) => @drawWire(e)
            
    drawWire: (e) ->
        x = Client.x(e)
        y = Client.y(e)
        
        active = @wireInfo.active
        if not active.element
            active.element = $(document.createElement('DIV'))
            active.element.addClass('wire')
            active.element.css
                left: active.start.x - @el.offset().left
                bottom: @height - (active.start.y - @el.offset().top)
            @el.append(active.element)
            
        xDiff = Math.abs(active.position.x - x)
        yDiff = Math.abs(active.position.y - y)
        
        if not active.direction
            active.direction = (if xDiff > yDiff then 'horizontal' else 'vertical')
            active.element.addClass(active.direction)
            
        if active.direction == 'horizontal'    
            active.element.css(width: x - active.start.xDiff)
        else
            active.element.css(height: active.start.y - y)
                
        
        
        
        
        
        
        
        
        