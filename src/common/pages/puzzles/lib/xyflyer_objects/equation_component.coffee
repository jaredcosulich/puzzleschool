equationComponent = exports ? provide('./equation_component', {})

class equationComponent.EquationComponent
    
    constructor: ({@gameArea, @equationFragment, @equationAreas, @trackDrag, @endDrag}) ->
        @equationAreas or= []
        @initElement()
        @initMove()
        
    clientX: (e) => (e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX) - @gameArea.offset().left
    clientY: (e) => (e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY) - @gameArea.offset().top
    width: -> @element.width()
    height: -> @element.height()
        
    initElement: ->
        @element = $(document.createElement('DIV'))
        @element.addClass('equation_component')
        @element.addClass(@equationAreas.join(' '))
        @element.html(@equationFragment)
        
        @placeHolder = $(document.createElement('DIV'))
        @placeHolder.addClass('place_holder')
        
    initMove: ->
        @element.bind 'mousedown.move touchstart.move', (e) => @mousedown(e)
        
    appendTo: (container) ->
        container.append(@element)
        container.append(@placeHolder) 
        @placeHolder.hide()

    mousedown: (e) ->
        @gameArea.addClass('dragging')
        body = $(document.body)
        body.bind 'mousemove.move touchmove.move', (e) => @move(e)
        body.one 'mouseup.move touchend.move', (e) => @endMove(e) 
        @element.addClass('dragging')
        @element.show()

    move: (e) ->
        e.preventDefault() if e.preventDefault        
        left = @clientX(e) - (@element.width() / 2)
        top = @clientY(e) - (@element.height() / 2)
        top -= 90 if e.type == 'touchmove'
        @element.css
            position: 'absolute'
            left: left
            top: top

        @placeHolder.show()
        @placeHolder.html(@element.html())   

        @trackDrag(left, top, @) if @trackDrag
        
    endMove: (e) ->
        return unless @element.hasClass('dragging')
        @element.removeClass('dragging')
        @gameArea.removeClass('dragging')
        
        @element.css
            position: 'static'
            top: 'auto'
            left: 'auto'

        if @endDrag(@)
            @element.hide()
            @placeHolder.show()
        else
            @element.show()
            @placeHolder.hide()
        
        $(document.body).unbind('mousemove.move touchmove.move')
        