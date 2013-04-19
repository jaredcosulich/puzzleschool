equationComponent = exports ? provide('./equation_component', {})
Transformer = require('./transformer').Transformer

class equationComponent.EquationComponent
    
    constructor: ({@gameArea, @equationFragment, @trackDrag, @endDrag}) ->
        @initElement()
        @initMove()
        @inUse = false
        
    clientX: (e) => (e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX) - @gameArea.offset().left
    clientY: (e) => (e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY) - @gameArea.offset().top
    top: -> @elementContainer.offset().top
    left: -> @elementContainer.offset().left
    width: -> @elementContainer.width()
    height: -> @elementContainer.height()
        
    initElement: ->
        @elementContainer = $(document.createElement('DIV'))
        @elementContainer.addClass('equation_component_container')
        
        @element = $(document.createElement('DIV'))
        @element.addClass('equation_component')
        @element.html(@equationFragment)
        @elementContainer.append(@element)
        
        @placeHolder = $(document.createElement('DIV'))
        @placeHolder.addClass('place_holder')
        @placeHolder.hide()

        @transformer = new Transformer(@element)
        
    initMove: ->
        @elementContainer.unbind('mousedown.drag touchstart.drag')
        @elementContainer.bind 'mousedown.drag touchstart.drag', (e) => @mousedown(e)
        
    appendTo: (@container) ->
        @container.append(@placeHolder) 
        @container.append(@elementContainer)

    initMeasurements: ->
        return if @offset
        @offset = @element.offset()
        @gameAreaOffset = @gameArea.offset()

    mousedown: (e) ->
        e.preventDefault() if e.preventDefault
        @initMeasurements()
        @move(e)
        
        @gameArea.addClass('dragging')
        body = $(document.body)
        
        body.bind 'mousemove.drag touchmove.drag', (e) => @move(e)
        body.one 'mouseup.drag touchend.drag', (e) => @endMove(e) 
        @element.css(visibility: 'visible')
        @setDragging()

        @placeHolder.css
            position: 'absolute'
            top: @offset.top - @container.offset().top
            left: @offset.left - @container.offset().left

        
    setDragging: ->
        @element.addClass('dragging')
        @placeHolder.show()
        @placeHolder.html(@element.html())           
        
    move: (e) ->
        e.preventDefault() if e.preventDefault 
        x = @clientX(e)
        y = @clientY(e) 
        y -= 30 / (window.appScale or 1) if e.type.match(/touch/)
        offset = @element.offset()
        dx = x - offset.left - (offset.width/2) + @gameAreaOffset.left
        dy = y - offset.top - (offset.height/2) + @gameAreaOffset.top

        @transformer.translate(dx, dy)

        @trackDrag(x, y, @) if @trackDrag
        
    endMove: (e) ->
        return unless @element.hasClass('dragging')
        @element.removeClass('dragging')
        @gameArea.removeClass('dragging')
        
        if @endDrag(@)
            @element.css(visibility: 'hidden')
            @placeHolder.show()
            @elementContainer.unbind('mousedown.drag touchstart.drag')
            @inUse = true
        else
            @reset()

        @transformer.translate(0, 0)
        
        $(document.body).unbind('mousemove.drag touchmove.drag')
    
    reset: ->
        @element.css(visibility: 'visible')
        @placeHolder.hide()
        @inUse = false
        @initMove()
        
        
