equations = exports ? provide('./equations', {})
Equation = require('./equation').Equation
EquationComponent = require('./equation_component').EquationComponent

class equations.Equations
    constructor: ({@el, @gameArea, @plot, submit}) ->
        @equationsArea = @$('.equations')
        @possibleFragments = @$('.possible_fragments')
        @equations = []
        @equationComponents = []
        @$('.launch').bind 'click', => submit()
        @initHints()

    $: (selector) -> $(selector, @el)

    add: (solution, startingFragment, solutionComponents, variables) ->
        equationCount = @equationsArea.find('.equation').length
        equation = new Equation
            id: "equation_#{equationCount + 1}"
            gameArea: @gameArea
            solution: solution
            solutionComponents: solutionComponents
            startingFragment: startingFragment
            variables: variables
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
        @equationComponents.push(equationComponent)
        
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
        
    initHints: ->
        @el.find('.hint').bind 'click', => @showHint()
        
    testFragment: (fragment, solution, formula, complete) ->
        solutionIndex = solution.indexOf(fragment)
        return false unless formula[solutionIndex - 1] == solution[solutionIndex - 1]
        return (if complete then solutionIndex == formula.indexOf(fragment) else solutionIndex != formula.indexOf(fragment))

    displayHint: (component, dropAreaElement) ->
        gameAreaOffset = @gameArea.offset()
        dragThis = @$('.drag_this')
        dragThis.css
            opacity: 0
            top: component.top() + component.height() - gameAreaOffset.top
            left: component.left() + (component.width()/2) - gameAreaOffset.left
        dragThis.animate
            opacity: 1
            duration: 250
            complete: => 
                component.element.one 'mousedown.hint', =>
                    $(document.body).one 'mouseup.hint', =>
                        $(document.body).unbind 'mousemove.hint'    
                        dragThis.animate
                            opacity: 0
                            duration: 250
                            complete: => dragThis.css(top: -1000, left: -1000)
                        
                    $(document.body).one 'mousemove.hint', =>
                        $(document.body).unbind 'mouseup.hint'
                        dragThis.animate
                            opacity: 0
                            duration: 250
                            complete: => dragThis.css(top: -1000, left: -1000)

                        dropHere = @$('.drop_here')
                        dropHere.css
                            opacity: 0
                            top: dropAreaElement.offset().top + dropAreaElement.height() - gameAreaOffset.top
                            left: dropAreaElement.offset().left + (dropAreaElement.width()/2) - gameAreaOffset.left
                        dropHere.animate
                            opacity: 1
                            duration: 250
                            complete: => 
                                component.element.one 'mouseup.hint', =>
                                    dropHere.animate
                                        opacity: 0, 
                                        duration: 250
                                        complete: => dropHere.css(top: -1000, left: -1000)
                           
        

    showHint: ->
        for equation in @equations
            formula = equation.formula()
            solution = equation.solution
            if formula != solution
                if (solutionComponents = equation.solutionComponents)
                    for solutionComponent in solutionComponents when not solutionComponent.set 
                        component = (c for c in @equationComponents when c.equationFragment == solutionComponent.fragment)[0]
                        
                        possible = equation.el.find('div')
                        if solutionComponent.after
                            for p in possible
                                if equation.straightFormula($(p)) == solutionComponent.after
                                    accept = $(p).next()
                                    break
                        else
                            accept = $(possible[0])
                        
                        if accept
                            @displayHint(component, accept)
                            solutionComponent.set = true
                            return 
                else
                    components = @equationComponents.sort((a, b) -> b.equationFragment.length - a.equationFragment.length)
                    for component in components
                        fragment = component.equationFragment
                        if @testFragment(fragment, solution, formula)
                            for dropArea in equation.dropAreas
                                continue if dropArea.component or dropArea.fixed
                                element = dropArea.element
                                element.html(fragment)
                                test = @testFragment(fragment, solution, equation.formula(), true)
                                element.html('')
                                @displayHint(component, dropArea.element) if test 
                                return
                console.log('VARIABLE!')
            else
                console.log('LAUNCH!')
        
        
        
        
        