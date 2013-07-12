draggable = exports ? provide('../common_objects/draggable', {})
Transformer = require('../common_objects/transformer').Transformer
Client = require('../common_objects/client').Client

class draggable.Draggable
    initDrag: (@dragElement, @trackDrag)->
        @transformer = new Transformer(@dragElement)
        @dragElement.bind 'mousedown.drag touchstart.drag', (e) =>
            e.stop()
            $(document.body).one 'mouseup.drag touchend.drag', (e) =>
                $(document.body).unbind('mousemove.drag touchstart.drag')
                @drag(e, true)
                
            @startX = Client.x(e) unless @startX
            @startY = Client.y(e) unless @startY
            $(document.body).bind 'mousemove.drag touchstart.drag', (e) => @drag(e)

    drag: (e, stopDrag) ->
        currentX = Client.x(e)
        currentY = Client.y(e)
        @transformer.translate(currentX - @startX, currentY - @startY)
        @trackDrag(@, currentX, currentY, stopDrag)
        
    resetDrag: -> 
        delete @startX
        delete @startY
        @transformer.translate(0, 0)