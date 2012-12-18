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
        @el.bind 'mousemove.fragment', (e) =>
            @clear()
            @selectedDropArea = @overlappingDropAreas
                left: @clientX(e)
                top: @clientY(e)
                test: (dropArea) => !dropArea.dirtyCount and dropArea.component

            @selectedDropArea.element.addClass('component_over') if @selectedDropArea
            
        @el.bind 'mouseout.fragment', => @clear()
        
        @el.bind 'mousedown.fragment', (e) => 
            return if @selectedDropArea.dirtyCount or !@selectedDropArea?.component
            @selectedDropArea.element.removeClass('with_component')
            @selectedDropArea.element.html(@selectedDropArea.defaultText)
            @selectedDropArea.component.mousedown(e)
            @selectedDropArea.component = null
            for dropArea in @selectedDropArea.childAreas
                @dropAreas.splice(dropArea.index, 1)
            @selectedDropArea.childAreas = []
            @selectedDropArea.parentArea.dirtyCount -= 1 if @selectedDropArea.parentArea
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

    overlappingDropAreas: ({left, right, top, bottom, test}) ->
        right = left if not right
        bottom = top if not bottom
        overlapping = []
        gameAreaOffset = @gameArea.offset()
        for dropArea in @dropAreas
            offset = dropArea.element.offset()
            offset.left -= gameAreaOffset.left
            offset.top -= gameAreaOffset.top
            continue unless (
                left >= offset.left and
                left <= offset.left + offset.width and
                top >= offset.top and
                top <= offset.top + offset.height   
            ) or (
                right >= offset.left and
                right <= offset.left + offset.width and
                bottom >= offset.top and
                bottom <= offset.top + offset.height  
            )  
            return dropArea if test(dropArea)   
        return false
            
    addDropArea: (dropAreaElement=@el, parentArea=null) ->
        hiddenWidth = 30
        offset = dropAreaElement.offset()
        gameAreaOffset = @gameArea.offset()
        dropArea = 
            id: dropAreaElement.attr('id')
            index: @dropAreas.length
            defaultText: (if dropAreaElement == @el then @defaultText else '')
            width: (offset.width or hiddenWidth)
            height: offset.height
            element: dropAreaElement
            childAreas: []
            dirtyCount: 0
            
        dropArea.highlight = (readyToDrop) => @highlightDropArea(dropArea, readyToDrop) 
        dropArea.format = (component) => @formatDropArea(dropArea, component) 
        dropArea.plot = () => @plot(dropArea)

        if parentArea
            parentArea.childAreas.push(dropArea)
            dropArea.parentArea = parentArea
            
        @dropAreas.push(dropArea)  

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
        return false
                
    formatDropArea: (dropArea, component) ->
        fragment = component.equationFragment
        dropArea.element.html """
            <div class='accept_fragment'></div>
            <div class='fragment'>#{fragment}</div>
            <div class='accept_fragment'></div>
        """
        for acceptFragment in dropArea.element.find('.accept_fragment')
            @addDropArea($(acceptFragment), dropArea)
    