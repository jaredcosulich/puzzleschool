draggable = exports ? provide('../common_objects/draggable', {})
Transformer = require('../common_objects/transformer').Transformer
Client = require('../common_objects/client').Client

class draggable.Draggable
    initDrag: (@dragElement, @trackDrag, center) ->
        @transformer = new Transformer(@dragElement)
        
        if center
            offset = @dragElement.offset()
            @startX = offset.left + (offset.width/2)
            @startY = offset.top + (offset.height/2)
        
        @dragElement.bind 'mousedown.drag touchstart.drag', (e) =>
            e.stop()
            $(document.body).one 'mouseup.drag touchend.drag', (e) =>
                $(document.body).unbind('mousemove.drag touchstart.drag')
                @drag(e, 'stop')
                
            if not center
                @startX = Client.x(e) unless @startX
                @startY = Client.y(e) unless @startY

            @drag(e, 'start')
            $(document.body).bind 'mousemove.drag touchmove.drag', (e) => @drag(e, 'move')

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