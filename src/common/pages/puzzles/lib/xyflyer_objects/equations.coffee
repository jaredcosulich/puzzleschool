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

    add: (startingFragment, variables) ->
        equationCount = @equationsArea.find('.equation').length
        equation = new Equation
            gameArea: @gameArea
            startingFragment: startingFragment
            variables: variables
            id: "equation_#{equationCount + 1}"
            plot: (eq) => @plotFormula(eq)
            
        @equations.push(equation)
        equation.appendTo(@equationsArea)
        
    addComponent: (equationFragment, equationAreas) ->
        equationComponent = new EquationComponent
            gameArea: @gameArea
            equationFragment: equationFragment
            equationAreas: equationAreas
            trackDrag: (left, top, component) => @trackComponentDragging(left, top, component)
            endDrag: (component) => @endComponentDragging(component)

        equationComponent.appendTo(@possibleFragments)
        
    trackComponentDragging: (left, top, component) ->
        @el.addClass('show_places') unless @el.hasClass('show_places')
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
        return false unless @selectedDropArea
        @selectedDropArea.accept(component)
        @selectedDropArea = null
        return true
            
    plotFormula: (equation) ->
        @checkMultipleEquations()
        equation.el.removeClass('bad_formula')
        formulaData = equation.formulaData()
        equation.el.addClass('bad_formula') unless @plot(equation.id, formulaData) or !formulaData.length
            
    checkMultipleEquations: ->
        inUseEquations = 0
        for equation in @equations
            if equation.el.html() != equation.defaultText 
                inUseEquations += 1 
                break if inUseEquations > 1
            
        for equation in @equations
            if inUseEquations > 1
                equation.showRange()
            else
                equation.hideRange()
        
        
        
        
        
        
        