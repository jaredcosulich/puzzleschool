equation = exports ? provide('./equation', {})

class equation.Equation
    defaultText: 'Drop Equation Here'

    constructor: ({@gameArea, @id, @plot}) ->
        @dropAreas = []
        @el = $(document.createElement('DIV'))
        @el.addClass('equation')
        @el.addClass('equation accept_fragment')
        @el.attr('id', @id)
        @el.html(@defaultText)

        @initHover()
        
    $: (selector) -> $(selector, @el)
        
    clientX: (e) => (e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX) - @gameArea.offset().left
    clientY: (e) => (e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY) - @gameArea.offset().top
    
    initHover: () ->
        testDropArea = (dropArea, over) =>
            if dropArea.dirtyCount
                for da in dropArea.childAreas
                    return true if testDropArea(da)
            else if dropArea.component
                return true if over
                dropArea.element.addClass('accept_component')
            return false
        
        @el.bind 'mousemove.fragment', (e) =>
            @selectedDropArea = @overlappingDropAreas
                left: @clientX(e)
                top: @clientY(e)
                test: (dropArea, over) => testDropArea(dropArea, over)

            @selectedDropArea.element.addClass('component_over') if @selectedDropArea
            
        @el.bind 'mouseout.fragment', => @clear()
        
        @el.bind 'mousedown.fragment', (e) => 
            return if @selectedDropArea.dirtyCount or !@selectedDropArea?.component
            @selectedDropArea.element.removeClass('with_component')
            @selectedDropArea.element.html(@selectedDropArea.defaultText)
            @selectedDropArea.component.mousedown(e)
            @selectedDropArea.component.move(e)
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
        @$('.accept_component').removeClass('accept_component')
            
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
            over = (
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
            return dropArea if test(dropArea, over)
            
    addDropArea: (dropAreaElement=@el, parentArea=null) ->
        hiddenWidth = 30
        offset = dropAreaElement.offset()
        gameAreaOffset = @gameArea.offset()
        dropArea = 
            id: dropAreaElement.attr('id')
            index: @dropAreas.length
            defaultText: (if dropAreaElement == @el then @defaultText else '')
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
        return false if dropArea.childAreas.length
        if readyToDrop
            dropArea.element.addClass('component_over')
            return true 
        else
            dropArea.element.removeClass('component_over')
            return false
                
    formatDropArea: (dropArea, component) ->
        fragment = component.equationFragment
        dropArea.element.html """
            <div class='accept_fragment'></div>
            #{@formatFragment(fragment)}
            <div class='accept_fragment'></div>
        """
        for acceptFragment in dropArea.element.find('.accept_fragment')
            @addDropArea($(acceptFragment), dropArea)
    
    formatFragment: (fragment) ->
        constant = '<div class=\'fragment\'>'
        accept = '<div class=\'accept_fragment\'></div>'
        fragment.replace(
            /(.*)\((.*)\)/, 
            "#{constant}$1(</div>#{accept}#{constant}$2</div>#{accept}#{constant})</div>"
        )
