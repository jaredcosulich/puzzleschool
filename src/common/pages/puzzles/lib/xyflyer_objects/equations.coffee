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
            plot: (dropArea) => @plotFormula(dropArea)
            
            
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
            overlapping = equation.overlappingDropAreas
                left: left
                right: right
                top: top
                bottom: bottom
            for dropArea in overlapping
                @selectedDropArea = dropArea if dropArea?.highlight(true) 

    clearDrag: ->
        equation.clear() for equation in @equations
            
    endComponentDragging: (component) ->
        @clearDrag()
        return unless @selectedDropArea
        element = @selectedDropArea.element
        element.addClass('with_component')
        @selectedDropArea.component = component
        @selectedDropArea.parent.dirty = true if @selectedDropArea.parent
        @selectedDropArea.format(component)
        @selectedDropArea.plot()
        @selectedDropArea.width = @selectedDropArea.element.width()
        component.element.hide()
        @selectedDropArea = null
            
    getFormula: (dropArea) ->
        element = $(dropArea.element)[0]
        if element.textContent then element.textContent else element.innerText      
        
    plotFormula: (dropArea) ->
        dropArea = dropArea.parentArea while dropArea.parentArea
        dropArea.element.removeClass('bad_formula')
        data = @getFormula(dropArea)
        return if not data.length or data == dropArea.defaultText
        dropArea.element.addClass('bad_formula') unless @plot(dropArea.id, data)    
            
        
        
        