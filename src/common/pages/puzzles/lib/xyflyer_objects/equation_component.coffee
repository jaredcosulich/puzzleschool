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

    initMove: ->
        @element.bind 'mousedown.move touchstart.move', (e) => @mousedown(e)

    mousedown: (e) ->
        @gameArea.addClass('dragging')
        body = $(document.body)
        body.bind 'mousemove.move touchmove.move', (e) => @move(e)
        body.one 'mouseup.move touchend.move', (e) => @endMove(e) 
        @element.show()

    move: (e) ->
        e.preventDefault() if e.preventDefault        
        left = @clientX(e) - (@element.width() / 2)
        top = @clientY(e) - (@element.height() / 2)
        @element.css
            position: 'absolute'
            left: left
            top: top
        @trackDrag(left, top, @) if @trackDrag
        
    endMove: (e) ->
        @element.css
            position: 'static'
            top: 'auto'
            left: 'auto'
            
        @gameArea.removeClass('dragging')
        
        @endDrag(@)
        
        $(document.body).unbind('mousemove.move touchmove.move')
        