component = exports ? provide('./component', {})
Transformer = require('../common_objects/transformer').Transformer
Client = require('../common_objects/client').Client

class component.Component
    constructor: ({@container, @drag}) ->
        @el = $(document.createElement('DIV'))
        @container.append(@el)
        
    $: (selector) -> @el.find(selector)    
    
    initDrag: ->
        @transformer = new Transformer(@el)
        @draggable.bind 'mousedown.drag touchstart.drag', (e) =>
            startX = Client.x(e)
            startY = Client.y(e)

            $(document.body).bind 'mousemove.drag touchstart.drag', (e) =>
                currentX = Client.x(e)
                currentY = Client.y(e)
                @transformer.translate(currentX - startX, currentY - startY)
                @drag(@, currentX, currentY)

            $(document.body).one 'mouseup.drag touchend.drag',(e) =>
                $(document.body).unbind 'mousemove.drag touchstart.drag'
                if @transformer.dx and @transformer.dy
                    @drag(@, Client.x(e), Client.y(e), true)
                    @transformer.translate(0, 0)
                    
