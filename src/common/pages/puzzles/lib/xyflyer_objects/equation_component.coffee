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
        @element.html(@display(@equationFragment))
        @elementContainer.append(@element)
        
        @placeHolder = $(document.createElement('DIV'))
        @placeHolder.addClass('place_holder')
        @placeHolder.hide()

        if @equationFragment.length > 3
            @elementContainer.addClass('long')
            @placeHolder.addClass('long')

        @transformer = new Transformer(@element)
        
    display: (html) -> html.replace('*', '&times;')    
        
    initMove: ->
        @elementContainer.unbind('mousedown.drag touchstart.drag')
        if window.appScale
            @elementContainer.bind 'touchstart.drag', (e) => @mousedown(e)
        else
            @elementContainer.bind 'mousedown.drag', (e) => @mousedown(e)
        
    appendTo: (@container) ->
        @container.append(@placeHolder) 
        @container.append(@elementContainer)

    initMeasurements: ->
        @offset = @element.offset()
        @gameAreaOffset = @gameArea.offset()

    mousedown: (e) ->
        e.preventDefault() if e.preventDefault
        @initDragging()
        @move(e)
        @showPlaceHolder()

    initDragging: ->
        @initMeasurements()
        @gameArea.addClass('dragging')
        @element.addClass('dragging')
        body = $(document.body)
        if window.appScale        
            body.bind 'touchmove.drag', (e) => @move(e)
            body.one 'touchend.drag', (e) => @endMove(e)         
        else
            body.bind 'mousemove.drag', (e) => @move(e)
            body.one 'mouseup.drag', (e) => @endMove(e)         
        
    showPlaceHolder: ->
        @placeHolder.show()
        @placeHolder.html(@display(@element.html()))           
        @placeHolder.css
            position: 'absolute'
            top: @offset.top - @container.offset().top
            left: @offset.left - @container.offset().left
        
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
        return unless @gameArea.hasClass('dragging')
        @gameArea.removeClass('dragging')
        
        if @endDrag(@)
            @placeHolder.show()
            @elementContainer.unbind('mousedown.drag touchstart.drag')
            @inUse = true
            @transformer.translate(-10000, -10000)
        else
            @reset()
        
        $(document.body).unbind('mousemove.drag touchmove.drag')
    
    reset: ->
        @element.removeClass('dragging')
        @placeHolder.hide()
        @inUse = false
        @transformer.translate(0, 0)
        @initMove()
        
        
