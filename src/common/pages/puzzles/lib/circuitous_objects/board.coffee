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
                delete @wireInfo.active      
                delete @wireInfo.continuation
                delete @wireInfo.erasing
                          
            @el.bind 'mousemove.draw_wire', (e) => @drawActiveWire(e)
            @drawActiveWire(e)
            
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
        
    recordActiveWirePosition: (coords) ->
        @wireInfo.positions[coords.x] or= {}
        @wireInfo.positions[coords.x][coords.y] = @wireInfo.active 
         
    drawActiveWire: (e) ->
        coords = @roundedCoordinates(x: Client.x(e), y: Client.y(e))

        if active = @wireInfo.active
            xDiff = Math.abs(active.position.x - coords.x)
            yDiff = Math.abs(active.position.y - coords.y)
            return if xDiff < @cellDimension and yDiff < @cellDimension
                        
            xStartDiff = Math.abs(active.start.x - coords.x)
            yStartDiff = Math.abs(active.start.y - coords.y)
            if (active.direction == 'horizontal' and yStartDiff - xDiff > (@cellDimension * 0.75)) or
               (active.direction == 'vertical' and xStartDiff - yDiff > (@cellDimension * 0.75))
                @wireInfo.continuation = true
                coords.x = active.position.x
                coords.y = active.position.y
                active.element.remove() unless active.element.height() and active.element.width()
                delete @wireInfo.active
                active = null
        
        if not active
            @createActiveWire(coords)
            return
            
        if @wireInfo.erasing
            @eraseActiveWire(coords)
        else
            if not active.direction
                active.direction = (if xDiff > yDiff then 'horizontal' else 'vertical')
                active.element.addClass(active.direction)
            
            @adjustActiveWire(coords)
            
    createActiveWire: (coords) ->
        if (!@wireInfo.continuation and active = @wireInfo.active = @wireInfo.positions[coords.x]?[coords.y])
            @wireInfo.erasing = true
            @eraseActiveWire(coords)
        else    
            active = @wireInfo.active = 
                element: $(document.createElement('DIV'))             
                position: {x: coords.x, y: coords.y}
            @setActiveWireStart(coords)
            active.element.addClass('wire')
            @el.append(active.element)
            @recordActiveWirePosition(coords)
        
    setActiveWireStart: (coords) ->
        return unless (active = @wireInfo.active)
        active.start = {x: coords.x, y: coords.y}
        @positionActiveWire(coords)
        
    positionActiveWire: (coords) ->      
        return unless (active = @wireInfo.active)
        
        if active.direction == 'horizontal'
            rightOffset = @el.closest('.circuitous').width() - @width  
            left = active.start.x >= coords.x
            className = (if left then 'left' else 'right')
        else 
            top = active.start.y >= coords.y
            className = (if top then 'up' else 'down')

        active.element.css
            left: (if not left then active.start.x else null)
            right: (if left then @width - active.start.x + rightOffset else null)
            top: (if not top then active.start.y else null)
            bottom: (if top then @height - active.start.y else null)
    
        active.element.addClass(className) unless active.element.hasClass(className)
            
    adjustActiveWire: (coords) ->
        return unless active = @wireInfo.active
        @recordActiveWirePosition(coords)

        @positionActiveWire(coords)
        if active.direction == 'horizontal'
            active.element.css(width: Math.abs(coords.x - active.start.x))
            active.position.x = coords.x
        else
            active.element.css(height: Math.abs(coords.y - active.start.y))                
            active.position.y = coords.y
        
    splitActiveWire: (coords) ->

    eraseActiveWire: (coords) ->    
        console.log('erase', coords)
        return unless (active = @wireInfo.active)        
        active.position = {x: coords.x, y: coords.y}
        if coords.x == active.start.x and coords.y == active.start.y
            if active.direction == 'horizontal'
                active.element.width = parseInt(active.element.width() - Math.abs(coords.x - active.start.x))            
            else
                active.element.height = parseInt(active.element.height() - Math.abs(coords.y - active.start.y))            
            @setActiveWireStart(coords)
        else
            @adjustActiveWire(coords)

        
        
        
        
        
        
        