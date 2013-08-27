draggable = exports ? provide('../common_objects/draggable', {})
Transformer = require('../common_objects/transformer').Transformer
Client = require('../common_objects/client').Client

class draggable.Draggable
    initDrag: (@dragElement, @trackDrag, center, buffer) ->
        @transformer = new Transformer(@dragElement)
        
        @dragElement.bind 'mousedown.drag touchstart.drag', (e) =>
            if buffer
                leftBuffer = buffer.left or 0
                rightBuffer = buffer.right or 0
                topBuffer = buffer.top or 0
                bottomBuffer = buffer.bottom or 0
                offset = @dragElement.offset()
                shiftX = if @currentX then @currentX - @startX else 0
                shiftY = if @currentY then @currentY - @startY else 0
                if not (offset.left + leftBuffer < Client.x(e) - shiftX < offset.left + offset.width - rightBuffer) or
                   not (offset.top + topBuffer < Client.y(e) - shiftY < offset.top + offset.height - bottomBuffer)
                    return

            e.stop()
            $(document.body).one 'mouseup.drag touchend.drag', (e) =>
                $(document.body).unbind('mousemove.drag touchstart.drag')
                @drag(e, 'stop')
            @setStartDrag(e, center)
            @drag(e, 'start')
            $(document.body).bind 'mousemove.drag touchmove.drag', (e) => @drag(e, 'move')
    
    setStartDrag: (e, center) ->
        if center
            offset = @dragElement.offset()
            @startX = offset.left + (offset.width/2)
            @startY = offset.top + (offset.height/2)
        else
            @startX = Client.x(e)
            @startY = Client.y(e)        

    drag: (e, state) -> @dragTo(x: Client.x(e), y: Client.y(e), state: state)
        
    dragTo: ({x, y, state}) ->
        @currentX = x
        @currentY = y
        @transformer.translate(@currentX - @startX, @currentY - @startY)
        @trackDrag(@, @currentX, @currentY, state)

    resetDrag: -> 
        delete @startX
        delete @startY
        @transformer.translate(0, 0)