equations = exports ? provide('./equations', {})
Equation = require('./equation').Equation
EquationComponent = require('./equation_component').EquationComponent

class equations.Equations
    constructor: ({@el, @gameArea, @plot, submit}) ->
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
        @el.addClass('show_places')
        x = left + (component.width()/2)
        y = top + (component.height()/2)
        @selectedDropArea = null
        for equation in @equations
            @selectedDropArea = equation.overlappingDropAreas
                x: x
                y: y
                test: (dropArea, over) => dropArea?.highlight(over)
            return if @selectedDropArea

    clearDrag: ->
        @el.removeClass('show_places')
        equation.clear() for equation in @equations
            
    endComponentDragging: (component) ->
        @clearDrag()
        return unless @selectedDropArea
        element = @selectedDropArea.element
        element.addClass('with_component')
        @selectedDropArea.component = component
        @selectedDropArea.parentArea.dirtyCount += 1 if @selectedDropArea.parentArea
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
        if data == dropArea.defaultText
            @plot(dropArea.id, '')  
        else
            dropArea.element.addClass('bad_formula') unless @plot(dropArea.id, data)    
            
        
        
        