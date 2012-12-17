equations = exports ? provide('./equations', {})
Equation = require('./equation').Equation
EquationComponent = require('./equation_component').EquationComponent

class equations.Equations
    constructor: ({@gameArea, @el, @plot, submit}) ->
        @equationsArea = @$('.equations')
        @possibleFragments = @$('.possible_fragments')
        @equations = []
        @$('.launch').bind 'click', => submit()

    $: (selector) -> $(selector, @el)

    add: ->
        equationCount = @equationsArea.find('.equation').length
        equation = new Equation
            gameArea: @gameArea
            id: "equation_#{equationCount + 1}"
            
        @equations.push(equation)
        equation.appendTo(@equationsArea)
        
    addComponent: (equationFragment, equationAreas) ->
        equationComponent = new EquationComponent
            gameArea: @gameArea
            equationFragment: equationFragment
            equationAreas: equationAreas
            trackDrag: (left, top, component) => @trackComponentDragging(left, top, component)
            endDrag: (component) => @endComponentDragging(component)

        @possibleFragments.append(equationComponent.element)
        
    trackComponentDragging: (left, top, component) ->
        x = left + (component.width()/2)
        y = top + (component.height()/2)
        left = x - (component.width()/3)
        right = x + (component.width()/3)
        top = y - (component.height()/3)
        bottom = y + (component.height()/3)
        @selectedDropArea = null
        @clearDrag()
        for equation in @equations
            for dropArea in equation.dropAreas
                continue unless (
                    left >= dropArea.left and
                    left <= dropArea.right and
                    top >= dropArea.top and
                    top <= dropArea.bottom   
                ) or (
                    right >= dropArea.left and
                    right <= dropArea.right and
                    bottom >= dropArea.top and
                    bottom <= dropArea.bottom   
                )  
                @selectedDropArea = dropArea if dropArea.highlight(true) 

    clearDrag: ->
        @$('.component_over').removeClass('component_over')
        @$('.accept_component').removeClass('accept_component').css(width: 'auto')
            
    endComponentDragging: (component) ->
        @clearDrag()
        return unless @selectedDropArea
        element = @selectedDropArea.element
        element.addClass('with_component')
        @selectedDropArea.component = component
        @selectedDropArea.format(component)
        @plotFormula(@selectedDropArea)
        @selectedDropArea.width = @selectedDropArea.element.width()
        component.element.hide()
        @selectedDropArea = null
            
    getFormula: (dropArea) ->
        element = $(dropArea.element)[0]
        if element.textContent then element.textContent else element.innerText      
        
    plotFormula: (dropArea) ->
        dropArea = dropArea.parentArea while dropArea.parentArea
        if @plot(dropArea.id, @getFormula(dropArea))    
            dropArea.element.removeClass('bad_formula')
        else
            dropArea.element.addClass('bad_formula')
        
        
        