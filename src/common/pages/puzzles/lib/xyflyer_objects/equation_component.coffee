equationComponent = exports ? provide('./equation_component', {})
Transformer = require('./transformer').Transformer

class equationComponent.EquationComponent
    
    constructor: ({@gameArea, @equationFragment, @trackDrag, @endDrag}) ->
        @initElement()
        @initMove()
        
    clientX: (e) => (e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX) - @gameArea.offset().left
    clientY: (e) => (e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY) - @gameArea.offset().top
    top: -> @element.offset().top
    left: -> @element.offset().left
    width: -> @element.width()
    height: -> @element.height()
        
    initElement: ->
        @element = $(document.createElement('DIV'))
        @element.addClass('equation_component')
        @element.html(@equationFragment)
        
        @placeHolder = $(document.createElement('DIV'))
        @placeHolder.addClass('place_holder')
        @placeHolder.hide()

        @transformer = new Transformer(@element)
        
    initMove: ->
        @element.bind 'mousedown.move touchstart.move', (e) => @mousedown(e)
        
    appendTo: (@container) ->
        @container.append(@placeHolder) 
        @container.append(@element)

    initMeasurements: ->
        return if @offset
        @offset = @element.offset()
        @gameAreaOffset = @gameArea.offset()
        @placeHolder.css
            position: 'absolute'
            top: @offset.top - @container.offset().top
            left: @offset.left - @container.offset().left

    mousedown: (e) ->
        @initMeasurements()
        
        @gameArea.addClass('dragging')
        body = $(document.body)
        
        body.bind 'mousemove.move touchmove.move', (e) => @move(e)
        body.one 'mouseup.move touchend.move', (e) => @endMove(e) 
        @element.addClass('dragging')
        @element.css(visibility: 'visible')

    move: (e) ->
        e.preventDefault() if e.preventDefault 
        x = @clientX(e)
        y = @clientY(e)       
        y -= 30 if e.type == 'touchmove'
        dx = x - @offset.left - (@offset.width/2) + @gameAreaOffset.left
        dy = y - @offset.top - (@offset.height/2) + @gameAreaOffset.top

        @transformer.translate(dx, dy)

        @placeHolder.show()
        @placeHolder.html(@element.html())   

        @trackDrag(x, y, @) if @trackDrag
        
    endMove: (e) ->
        return unless @element.hasClass('dragging')
        @element.removeClass('dragging')
        @gameArea.removeClass('dragging')
        
        @transformer.end()

        if @endDrag(@)
            @element.css(visibility: 'hidden')
            @placeHolder.show()
        else
            @element.css(visibility: 'visible')
            @placeHolder.hide()

        @transformer.translate(0, 0)
        
        $(document.body).unbind('mousemove.move touchmove.move')
        
