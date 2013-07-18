draggable = exports ? provide('../common_objects/draggable', {})
Transformer = require('../common_objects/transformer').Transformer
Client = require('../common_objects/client').Client

class draggable.Draggable
    initDrag: (@dragElement, @trackDrag, center)->
        @transformer = new Transformer(@dragElement)
        @dragElement.bind 'mousedown.drag touchstart.drag', (e) =>
            e.stop()
            $(document.body).one 'mouseup.drag touchend.drag', (e) =>
                $(document.body).unbind('mousemove.drag touchstart.drag')
                @drag(e, true)
                
            if center   
                offset = @dragElement.offset()
                @startX = offset.left + (offset.width/2) unless @startX
                @startY = offset.top + (offset.height/2) unless @startY
            else 
                @startX = Client.x(e) unless @startX
                @startY = Client.y(e) unless @startY
            $(document.body).bind 'mousemove.drag touchstart.drag', (e) => @drag(e)

    drag: (e, stopDrag) ->
        console.log(@dragElement.offset(), @startX, @startY)
        currentX = Client.x(e)
        currentY = Client.y(e)
        @transformer.translate(currentX - @startX, currentY - @startY)
        @trackDrag(@, currentX, currentY, stopDrag)
        
    dragTo: ({x, y}) ->
        @transformer.translate(x - @startX, y - @startY)

    resetDrag: -> 
        delete @startX
        delete @startY
        @transformer.translate(0, 0)