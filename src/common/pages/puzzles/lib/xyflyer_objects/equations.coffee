equations = exports ? provide('./equations', {})
Equation = require('./equation').Equation
EquationComponent = require('./equation_component').EquationComponent

class equations.Equations
    constructor: ({@el, @gameArea, @plot, submit, @registerEvent}) ->
        @equationsArea = @$('.equations')
        @possibleFragments = @$('.possible_fragments')
        @equations = []
        @equationComponents = []
        if window.AppMobi
            @$('.launch').bind 'touchstart.launch', => submit()
        else
            @$('.launch').bind 'mousedown.launch', => submit()
        @initHints()
        @initBackspace()
        @length = 0

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
        @length = @equations.length
        equation.appendTo(@equationsArea)
    
    remove: (equation) ->
        index = (if equation then @equations.indexOf(equation) else @equations.length - 1)
        equation = @equations.splice(index-1, 1)[0]
        equation.container.remove()
        @length = @equations.length
        
    addComponent: (equationFragment) ->
        equationComponent = new EquationComponent
            gameArea: @gameArea
            equationFragment: equationFragment
            trackDrag: (left, top, component) => @trackComponentDragging(left, top, component)
            endDrag: (component) => @endComponentDragging(component)

        equationComponent.appendTo(@possibleFragments)
        @equationComponents.push(equationComponent)
        
    removeComponent: (equationComponent) ->
        index = (if equation then @equationComponents.indexOf(equation) else @equationComponents.length - 1)
        equationComponent = @equationComponents.splice(index-1, 1)[0]
        equationComponent.element.remove()
        
        
    trackComponentDragging: (left, top, component) ->
        @el.addClass('show_places') unless @el.hasClass('show_places')
        @selectedDropArea = null
        for equation in @equations
            equation.expandLastAccept()
            
            @selectedDropArea = equation.overlappingDropAreas
                x: left
                y: top
                test: (dropArea, over) => 
                    result = dropArea?.highlight(over)
                    equation.expandLastAccept()
                    return result
                
            return if @selectedDropArea

    clearDrag: ->
        @el.removeClass('show_places')
        equation.clear() for equation in @equations
            
    endComponentDragging: (component) ->
        @clearDrag()
        return false unless @selectedDropArea
        @lastComponent = component
        @selectedDropArea.accept(component)
        
        if @registerEvent
            @registerEvent
                type: 'move'
                info: 
                    equationId: @selectedDropArea.id
                    fragment: component.equationFragment
                    time: new Date()
        
        @selectedDropArea = null
        return true
            
    plotFormula: (equation) ->
        @checkMultipleEquations()
        equation.hideBadFormula()
        formulaData = equation.formulaData()
        equation.showBadFormula() unless @plot(equation.id, formulaData) or !formulaData.length
            
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
        
    initBackspace: ->
        window.onkeydown = (e) => 
            return if $('.opaque_screen').css('opacity') > 0
            e.preventDefault() if e.preventDefault if e.keyCode == 8 and document.activeElement?.type != 'text'
            
    initHints: ->
        @el.find('.hint').bind 'click', => @showHint()
        
    testFragment: (fragment, solution, formula, complete) ->
        solutionIndex = solution.indexOf(fragment)
        return false unless formula[solutionIndex - 1] == solution[solutionIndex - 1]
        return (if complete then solutionIndex == formula.indexOf(fragment) else solutionIndex != formula.indexOf(fragment))

    displayHint: (component, dropAreaElement, equation, solutionComponent) ->
        if @registerEvent
            @registerEvent
                type: 'hint'
                info: 
                    equationId: dropAreaElement.id
                    fragment: component.equationFragment
                    time: new Date()
        
        gameAreaOffset = @gameArea.offset()
        
        if component.inUse
            dragElement = component.dropArea.element
        else
            dragElement = component.element
            
        offset = dragElement.offset()
        top = offset.top + offset.height - gameAreaOffset.top
        left = offset.left + (offset.width/2) - gameAreaOffset.left
    
        dragThis = @$('.drag_this')
        dragThis.css
            opacity: 0
            top: top
            left: left
        dragThis.animate
            opacity: 1
            duration: 250
            complete: => 
                dragElement.one 'mousedown.hint touchstart.hint', =>
                    $(document.body).one 'mouseup.hint touchend.hint', =>
                        $(document.body).unbind 'mousemove.hint touchmove.hint'    
                        dragThis.animate
                            opacity: 0
                            duration: 250
                            complete: => dragThis.css(top: -1000, left: -1000)
                        
                    $(document.body).one 'mousemove.hint touchmove.hint', =>
                        $(document.body).unbind 'mouseup.hint touchend.hint'
                        dragThis.animate
                            opacity: 0
                            duration: 250
                            complete: => dragThis.css(top: -1000, left: -1000)

                        dropHere = @$('.drop_here') 
                        if (offset = dropAreaElement.offset()).top == 0
                            offset = @findComponentDropAreaElement(equation, solutionComponent).offset()
                        
                        dropHere.css
                            opacity: 0
                            top: offset.top + offset.height - gameAreaOffset.top
                            left: offset.left + (offset.width/2) - gameAreaOffset.left
                        dropHere.animate
                            opacity: 1
                            duration: 250
                            complete: => 
                                component.element.one 'mouseup.hint touchend.hint', =>
                                    dropHere.animate
                                        opacity: 0, 
                                        duration: 250
                                        complete: => dropHere.css(top: -1000, left: -1000)
                                   
    findComponentDropAreaElement: (equation, solutionComponent) ->
        possible = equation.el.find('div')
        if solutionComponent.after.length
            for p in possible
                sf = equation.straightFormula($(p))
                if sf == solutionComponent.after or sf.replace(solutionComponent.fragment, '') == solutionComponent.after
                    accept = $(p).next()
                    break
        else
            accept = $(possible[0])
        return accept

    showHint: ->
        allEquationsSet = true
        for equation in @equations
            formula = equation.formula()
            straightFormula = equation.straightFormula()
            completedSolution = solution = equation.solution
            for variable of equation.variables
                info = equation.variables[variable]
                completedSolution = completedSolution.replace(variable, info.solution) if info.solution
                
            if formula != completedSolution
                allEquationsSet = false
                if straightFormula != solution                     
                    if (solutionComponents = equation.solutionComponents)
                        for solutionComponent in solutionComponents
                            component = (c for c in @equationComponents when c.equationFragment == solutionComponent.fragment)[0]
                            continue if component.after == solutionComponent.after
                            accept = @findComponentDropAreaElement(equation, solutionComponent)
                            if accept?.length
                                @displayHint(component, accept, equation, solutionComponent)
                                return 
                    else
                        for dropArea in equation.dropAreas when dropArea.component
                            if solution.indexOf(dropArea.component.equationFragment) == -1
                                @displayHint(dropArea.component, dropArea.component.placeHolder)
                                return
                    
                        components = @equationComponents.sort((a, b) -> b.equationFragment.length - a.equationFragment.length)
                        for component in components
                            fragment = component.equationFragment
                            if @testFragment(fragment, solution, straightFormula)
                                for dropArea in equation.dropAreas
                                    continue if dropArea.component or dropArea.fixed
                                    element = dropArea.element
                                    element.html(fragment)
                                    test = @testFragment(fragment, solution, equation.straightFormula(), true)
                                    element.html('')
                                    if test 
                                        @displayHint(component, dropArea.element) 
                                        return
                else
                    for variable of equation.variables
                        info = equation.variables[variable]
                        continue if not info.element or parseFloat(info.get()) == parseFloat(info.solution)
                        if (existing = @$(".hints .#{variable}_hint")).length
                            existing.animate
                                opacity: 0
                                duration: 500
                                complete: =>
                                    existing.animate
                                        opacity: 1
                                        duration: 500
                        else
                            @$('.hints').append """
                                <p class='#{variable}_hint'>Set #{variable} = #{info.solution}</p>
                            """
                        return

        # if @equations.length > 1
        #     for equation, index in @equations
        #         if not equation.rangeText.length
        #             if (existing = @$(".hints .#{equation.id}_range_hint")).length
        #                 existing.animate
        #                     opacity: 0
        #                     duration: 500
        #                     complete: =>
        #                         existing.animate
        #                             opacity: 1
        #                             duration: 500
        #                 return
        #             else
        #                 @$('.hints').append """
        #                     <p class='#{equation.id}_range_hint'>
        #                         Set the start and end point for equation #{index + 1}.
        #                         <br/>
        #                         Click on the graph to get the exact coordinate.
        #                     </p>
        #                 """
        #                 return
                    
                    
        if allEquationsSet
            launch = @$('.launch_hint')
            launchOffset = @$('.launch').offset()
            launch.css
                opacity: 0
                top: launchOffset.top + launchOffset.height - @gameArea.offset().top
                left: launchOffset.left + (launchOffset.width/2) - @gameArea.offset().left
            launch.animate
                opacity: 1
                duration: 250
                complete: => 
                    @$('.launch').one 'mouseup.hint touchend.hint', =>
                        launch.animate
                            opacity: 0
                            duration: 250
                            complete: => launch.css(top: -1000, left: -1000)
                
        
        
        
        
        