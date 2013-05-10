equations = exports ? provide('./equations', {})
Equation = require('./equation').Equation
EquationComponent = require('./equation_component').EquationComponent

class equations.Equations
    constructor: ({@el, @gameArea, @plot, submit, @registerEvent}) ->
        @equationsArea = @$('.equations')
        @possibleFragments = @$('.possible_fragments')
        @equations = []
        @equationComponents = []
        
        launch = @$('.launch')
        if window.appScale
            launch.bind 'touchstart.launch', => 
                launch.addClass('active')
                launch.one 'touchend.launch', => launch.removeClass('active')
                submit()
        else
            launch.bind 'click.launch', => submit()
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
        return equation
    
    remove: (equation) ->
        index = (if equation then @equations.indexOf(equation) else @equations.length - 1)
        equation = @equations.splice(index, 1)[0]
        @plot(equation.id)
        equation.container.remove()
        @length = @equations.length
        
    addComponent: (equationFragment, side) ->
        equationComponent = new EquationComponent
            gameArea: @gameArea
            equationFragment: equationFragment
            side: side
            trackDrag: (left, top, width, height, component) => @trackComponentDragging(left, top, width, height, component)
            endDrag: (component) => @endComponentDragging(component)

        equationComponent.appendTo(@possibleFragments.find('.fragments'))
        @equationComponents.push(equationComponent)

        rows = []
        top = 0
        first = @equationComponents[0]
        for equationComponent, index in @equationComponents
            if equationComponent.top() != top
                first = equationComponent
                top = equationComponent.top()
            
            if index == @equationComponents.length - 1 or @equationComponents[index + 1].top() != top
                fragmentsWidth = equationComponent.left() + equationComponent.width() - first.left()
                lastRow = rows[rows.length - 1]
                
                if lastRow and lastRow.width - lastRow.last.width() > fragmentsWidth
                    lastRowShift = parseInt(lastRow.first.elementContainer.css('marginLeft')) + (lastRow.last.width() / 2)
                    lastRow.first.elementContainer.css(marginLeft: lastRowShift)
                    fragmentsWidth = equationComponent.left() + equationComponent.width() - first.left() + (lastRow.last.width() / 2) + 24
                    first = lastRow.last
                    
                rows.push({first: first, width: fragmentsWidth, last: equationComponent})
                shift = ((@possibleFragments.width() - fragmentsWidth) / 2) - 6
                
                first.elementContainer.css(marginLeft: shift)
                
        return equationComponent
        
    removeComponent: (equationComponent) ->
        index = (if equationComponent then @equationComponents.indexOf(equationComponent) else @equationComponents.length - 1)
        equationComponent = @equationComponents.splice(index, 1)[0]
        equationComponent.element.remove()
        
        
    trackComponentDragging: (left, top, width, height, component) ->
        @el.addClass('show_places') unless @el.hasClass('show_places')
        @selectedDropArea = null
        for equation in @equations
            equation.expandLastAccept()
            
            selected = equation.overlappingDropAreas
                x: left
                y: top
                width: width
                height: height
                test: (dropArea, over) =>
                    over = false if @selectedDropArea
                    result = dropArea?.highlight(over)
                    equation.expandLastAccept()
                    return result
            @selectedDropArea or= selected    

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
        hints = @el.find('.hints')
        hints.bind 'mousedown.hint touchstart.hint', =>
            hints.one 'mouseup.hint touchend.hint', => @showHint()
        @$('.drag_this').bind('dragstart', (e) -> e.stop(); return false)
        @$('.drop_here').bind('dragstart', (e) -> e.stop(); return false)
        @$('.drop_here_right').bind('dragstart', (e) -> e.stop(); return false)
        @$('.launch').bind('dragstart', (e) -> e.stop(); return false)
        
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
        
        areaOffset = @equationsArea.offset()
        gameAreaOffset = @gameArea.offset()
        
        if component.inUse
            dragElement = component.dropArea.element
        else
            dragElement = component.element
            
        offset = dragElement.offset()
        top = offset.top + offset.height - gameAreaOffset.top
        left = offset.left + (offset.width/2) - areaOffset.left
        
        if left > (@equationsArea.width() / 2)
            dragThis = @$('.drag_this_right')
            left -= dragThis.width()
        else
            dragThis = @$('.drag_this')
            
        dragThis.css
            opacity: 0
            top: top
            left: left
        dragThis.animate
            opacity: 1
            duration: 250
            complete: => 
                $(document.body).one 'mousedown.hint touchstart.hint', ->
                    dragThis.css(opacity: 0, top: -1000, left: -1000)

                dragElement.one 'mousedown.hint touchstart.hint', =>
                    $.timeout 10, =>
                        if (dropAreaOffset = dropAreaElement.offset()).top == 0 and solutionComponent
                            dropAreaOffset = @findComponentDropAreaElement(equation, solutionComponent).offset()

                        top = dropAreaOffset.top + dropAreaOffset.height - gameAreaOffset.top
                        left = dropAreaOffset.left + Math.min(30, (dropAreaOffset.width/2)) - areaOffset.left
                        
                        if left > (@equationsArea.width()/2)
                            dropHere = @$('.drop_here_right')
                            left -= dropHere.width() 
                        else 
                            dropHere = @$('.drop_here')
                            
                        $(document.body).one 'mouseup.hint touchend.hint', =>
                            dropHere.animate
                                opacity: 0, 
                                duration: 250
                                complete: => dropHere.css(top: -1000, left: -1000)
                    
                        dropHere.css
                            opacity: 1
                            top: top
                            left: left
                             
                        $.timeout 300, =>
                            if (dropAreaOffset = dropAreaElement.offset()).top == 0 and solutionComponent
                                dropAreaOffset = @findComponentDropAreaElement(equation, solutionComponent).offset()

                            dropHere.css
                                top: dropAreaOffset.top + dropAreaOffset.height - gameAreaOffset.top
                            
    displayVariable: (variable, value) ->
        areaOffset = @equationsArea.offset()
        gameAreaOffset = @gameArea.offset()       
        hintsOffset = @el.find('.hints a').offset()
        
        hintPopup = @$('.hint_popup')
        hintPopup.css
            opacity: 0
            top: hintsOffset.top - hintPopup.height() - gameAreaOffset.top - 18
            left: hintsOffset.left + (hintsOffset.width/2) - (hintPopup.width()/2) - areaOffset.left
        hintPopup.html("Set #{variable} = #{value}")
        hintPopup.animate
            opacity: 1
            duration: 250
        $(document.body).one 'mousedown.variable touchstart.variable', ->
            hintPopup.animate
                opacity: 0
                duration: 250
                complete: ->
                    hintPopup.css
                        top: -1000
                        left: -1000
                                   
    findComponentDropAreaElement: (equation, solutionComponent) ->
        possible = equation.el.find('div:not(.removing)')
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
                    for dropArea in equation.dropAreas when dropArea.component
                        dc = dropArea.component
                        valid = (c for c in equation.solutionComponents when c.fragment == dc.equationFragment)
                        continue if (v for v in valid when v.after == dc.after).length
                        wrongSpot = (v for v in valid when v.after != dc.after)
                        if not valid.length or wrongSpot.length
                            @displayHint(dropArea.component, dropArea.component.placeHolder, equation)
                            return
                        
                    for solutionComponent in equation.solutionComponents
                        continue if formula.indexOf(solutionComponent.after + solutionComponent.fragment) > -1
                        component = null
                        valid = (c for c in @equationComponents when c.equationFragment == solutionComponent.fragment)
                        if valid.length > 1
                            valid = (v for v in valid when not v.inUse)
                        if valid.length > 1
                            component = (v for v in valid when v.after != solutionComponent.after)[0]
                        component = valid[0] if not component
                        continue if not component or component.after == solutionComponent.after
                        accept = @findComponentDropAreaElement(equation, solutionComponent)
                        if accept?.length
                            @displayHint(component, accept, equation, solutionComponent)
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
                            @displayVariable(variable, info.solution)
                        return

        if allEquationsSet
            launch = @$('.launch_hint')
            launchOffset = @$('.launch').offset()
            launch.css
                opacity: 1
                top: launchOffset.top + launchOffset.height - @gameArea.offset().top
                left: launchOffset.left + (launchOffset.width/2) - @equationsArea.offset().left
            @$('.launch').one 'mouseup.hint touchend.hint', =>
                launch.css(opacity: 0, top: -1000, left: -1000)
                
        
        
        
        
        