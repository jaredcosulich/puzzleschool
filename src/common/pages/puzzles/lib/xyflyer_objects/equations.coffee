equations = exports ? provide('./equations', {})
EquationComponent = require('./equation_component').EquationComponent

class equations.Equations
    defaultText: 'Drop Equation Fragment Here'

    constructor: ({@gameArea, @el, @plot, submit}) ->
        @equations = @$('.equations')
        @possibleFragments = @$('.possible_fragments')
        @dropAreas = []
        @dragAreas = []
        @$('.launch').bind 'click', => submit()

    $: (selector) -> $(selector, @el)

    add: ->
        equationCount = @equations.find('.equation').length
        @equations.append """
            <div class='equation' id='equation_#{equationCount + 1}'>
                #{@defaultText}
            </div>
        """        
        equation = @equations.find("#equation_#{equationCount + 1}")
        @addDropArea(equation)

    addDropArea: (dropAreaElement, parent) ->
        offset = dropAreaElement.offset()
        gameAreaOffset = @gameArea.offset()
        dropArea = 
            id: dropAreaElement.attr('id')
            top: offset.top - gameAreaOffset.top
            left: offset.left - gameAreaOffset.left
            bottom: offset.top + offset.height - gameAreaOffset.top
            right: offset.left + (offset.width or 12) - gameAreaOffset.left
            element: dropAreaElement
            childAreas: []
        @dropAreas.push(dropArea)    
        @setParentChildDropAreas(dropArea, parent)

    setParentChildDropAreas: (dropArea, parent) ->
        return unless dropArea and parent
        parent.childAreas.push(dropArea)
        dropArea.parentArea = parent
        
    addComponent: (equationFragment, equationAreas) ->
        equationComponent = new EquationComponent
            gameArea: @gameArea
            equationFragment: equationFragment
            equationAreas: equationAreas
            trackDrag: (left, top, component) => @trackComponentDragging(left, top, component)
            endDrag: (component) => @endComponentDragging(component)

        @possibleFragments.append(equationComponent.element)
        
    trackComponentDragging: (left, top, component) ->
        @selectedDropArea = null
        left = left + (component.width() / 2)
        top = top + (component.height() / 2)
        @clearDrag()
        for dropArea in @dropAreas
            continue unless left >= dropArea.left and
               left <= dropArea.right and
               top >= dropArea.top and
               top <= dropArea.bottom               
            @highlightDropArea(dropArea, true)

    clearDrag: ->
        @$('.component_over').removeClass('component_over')
        @$('.accept_component').removeClass('accept_component').css(width: 'auto')
            
    highlightDropArea: (dropArea, readyToDrop) ->
        if dropArea.childAreas.length
            @highlightDropArea(da) for da in dropArea.childAreas
        else 
            dropArea.element.width(dropArea.right - dropArea.left) if not dropArea.element.width()
            if readyToDrop
                dropArea.element.addClass('component_over')
                @selectedDropArea = dropArea 
            else
                dropArea.element.addClass('accept_component')

    endComponentDragging: (component) ->
        @clearDrag()
        return unless @selectedDropArea
        element = @selectedDropArea.element
        element.addClass('with_component')
        @formatEquationDropAreas(@selectedDropArea, component)
        @plotFormula(@selectedDropArea)
        component.element.hide()
        @selectedDropArea = null
        
    formatEquationDropAreas: (dropArea, component) ->
        fragment = component.equationFragment
        dropArea.element.html """
            <div class='accept_fragment'></div>
            <div class='fragment'>#{fragment}</div>
            <div class='accept_fragment'></div>
        """
        for acceptFragment in dropArea.element.find('.accept_fragment')
            @addDropArea($(acceptFragment), dropArea)
    
    getFormula: (dropArea) ->
        element = $(dropArea.element)[0]
        if element.textContent then element.textContent else element.innerText      
        
    plotFormula: (dropArea) ->
        dropArea = dropArea.parentArea while dropArea.parentArea
        @plot(dropArea.id, @getFormula(dropArea))    
        
        
        
        