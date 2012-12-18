equation = exports ? provide('./equation', {})

class equation.Equation
    defaultText: 'Drop Equation Fragment Here'

    constructor: ({@gameArea, @id, @plot}) ->
        @dropAreas = []
        @el = $(document.createElement('DIV'))
        @el.addClass('equation')
        @el.attr('id', @id)
        @el.html(@defaultText)

        @initHover()
        
    $: (selector) -> $(selector, @el)
        
    clientX: (e) => (e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX) - @gameArea.offset().left
    clientY: (e) => (e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY) - @gameArea.offset().top
    
    initHover: () ->
        @el.bind 'mouseover.fragment', (e) =>
            overlapping = @overlappingDropAreas
                left: @clientX(e)
                top: @clientY(e)
                
            for dropArea in overlapping
                if not dropArea.dirty and dropArea.component
                    dropArea.element.addClass('component_over') 
                    @selectedDropArea = dropArea

        @el.bind 'mouseout.fragment', => @clear()
        
        @el.bind 'mousedown.fragment', (e) => 
            return if @selectedDropArea.dirty or !@selectedDropArea?.component
            @selectedDropArea.element.removeClass('with_component')
            @selectedDropArea.element.html(@selectedDropArea.defaultText)
            @selectedDropArea.component.mousedown(e)
            @selectedDropArea.component = null
            for dropArea in @selectedDropArea.childAreas
                @dropAreas.splice(dropArea.index, 1)
            @selectedDropArea.childAreas = []
            @selectedDropArea.plot()
            
    clear: ->
        @selectedDropArea = null
        @el.removeClass('component_over')
        @el.removeClass('accept_component')
        @$('.component_over').removeClass('component_over')
        @$('.accept_component').removeClass('accept_component').css(width: 'auto')
            
    appendTo: (container) ->
        container.append(@el)
        @addDropArea()  

    overlappingDropAreas: (area) ->
        area.right = area.left if not area.right
        area.bottom = area.top if not area.bottom
        overlapping = []
        for dropArea in @dropAreas
            continue unless (
                area.left >= dropArea.left and
                area.left <= dropArea.right and
                area.top >= dropArea.top and
                area.top <= dropArea.bottom   
            ) or (
                area.right >= dropArea.left and
                area.right <= dropArea.right and
                area.bottom >= dropArea.top and
                area.bottom <= dropArea.bottom   
            )  
            overlapping.push(dropArea)
        return overlapping

    addDropArea: (dropAreaElement=@el, parent=null, hiddenIndex=0) ->
        hiddenWidth = 30
        offset = dropAreaElement.offset()
        gameAreaOffset = @gameArea.offset()
        dropArea = 
            id: dropAreaElement.attr('id')
            index: @dropAreas.length
            defaultText: (if dropAreaElement == @el then @defaultText else '')
            top: offset.top - gameAreaOffset.top
            left: offset.left - gameAreaOffset.left + (hiddenIndex * hiddenWidth)
            bottom: offset.top + offset.height - gameAreaOffset.top
            right: offset.left + (offset.width or hiddenWidth) - gameAreaOffset.left + (hiddenIndex * hiddenWidth)
            width: (offset.width or hiddenWidth)
            height: offset.height
            element: dropAreaElement
            childAreas: []
            
        dropArea.highlight = (readyToDrop) => @highlightDropArea(dropArea, readyToDrop) 
        dropArea.format = (component) => @formatDropArea(dropArea, component) 
        dropArea.plot = () => @plot(dropArea)
        
        @dropAreas.push(dropArea)    
        @setParentChildDropAreas(dropArea, parent)

    setParentChildDropAreas: (dropArea, parent) ->
        return unless dropArea and parent
        parent.childAreas.push(dropArea)
        dropArea.parentArea = parent

    highlightDropArea: (dropArea, readyToDrop) ->
        if dropArea.childAreas.length
            @highlightDropArea(da) for da in dropArea.childAreas
        else 
            dropArea.element.width(dropArea.width) if not dropArea.element.width()
            if readyToDrop
                dropArea.element.addClass('component_over')
                return true 
            else
                dropArea.element.addClass('accept_component')
                
    formatDropArea: (dropArea, component) ->
        fragment = component.equationFragment
        dropArea.element.html """
            <div class='accept_fragment'></div>
            <div class='fragment'>#{fragment}</div>
            <div class='accept_fragment'></div>
        """
        for acceptFragment, index in dropArea.element.find('.accept_fragment')
            @addDropArea($(acceptFragment), dropArea, index)
    