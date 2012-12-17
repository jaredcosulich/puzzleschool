equations = exports ? provide('./equations', {})
EquationComponent = require('./equation_component').EquationComponent

class equations.Equations
    defaultText: 'Drop Equation Fragment Here'

    constructor: ({@gameArea, @el, @plot, submit}) ->
        @equations = @$('.equations')
        @possibleFragments = @$('.possible_fragments')
        @$('.launch').bind 'click', => submit()

    $: (selector) -> $(selector, @el)

    add: ->
        equationCount = @equations.find('.equation').length
        @equations.append """
            <div class='equation' id='equation_#{equationCount + 1}'>
                #{@defaultText}
            </div>
        """
        equation = @equations.find("#equation_#{equationCount}")
        
    addComponent: (equationFragment, equationAreas) ->
        equationComponent = new EquationComponent
            gameArea: @gameArea
            equationFragment: equationFragment
            equationAreas: equationAreas
            trackDrag: (left, top, component) => @trackComponentDragging(left, top, component)
            endDrag: (component) => @endComponentDragging(component)

        @possibleFragments.append(equationComponent.element)
        
    trackComponentDragging: (left, top, component) ->
        equations = @equations.find('.equation')     
        for e in equations
            equation = $(e)
            equation.removeClass('accept_component')
            offset = equation.offset()
            gameAreaOffset = @gameArea.offset()
            continue unless left >= offset.left - gameAreaOffset.left and
               left <= offset.left + offset.width - gameAreaOffset.left and
               top >= offset.top - gameAreaOffset.top and
               top <= offset.top + offset.height - gameAreaOffset.top
            equation.addClass('accept_component')

    endComponentDragging: (component) ->
        acceptingComponent = $(@equations.find('.accept_component')[0])  
        return unless acceptingComponent.length
        acceptingComponent.removeClass('accept_component')
        acceptingComponent.addClass('with_component')
        acceptingComponent.html('')
        acceptingComponent.append """
            <div class=''>#{component.equationFragment}</div>
        """
        component.element.hide()
        equation = if acceptingComponent.hasClass('equation') then acceptingComponent else acceptingComponent.closest('.equation')
        equation.data('formula', component.equationFragment)
        @plot(equation.attr('id'), equation.data('formula'))    