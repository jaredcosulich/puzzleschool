draggable = exports ? provide('../common_objects/draggable', {})
Transformer = require('../common_objects/transformer').Transformer
Client = require('../common_objects/client').Client

class draggable.Draggable
    initDrag: (@dragElement, @trackDrag, center) ->
        @transformer = new Transformer(@dragElement)
        
        @dragElement.bind 'mousedown.drag touchstart.drag', (e) =>
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