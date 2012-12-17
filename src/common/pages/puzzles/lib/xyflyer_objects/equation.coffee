equation = exports ? provide('./equation', {})

class equation.Equation
    defaultText: 'Drop Equation Fragment Here'

    constructor: ({@gameArea, @id}) ->
        @dropAreas = []
        @el = $(document.createElement('DIV'))
        @el.addClass('equation')
        @el.attr('id', @id)
        @el.html(@defaultText)

        @initHover()
        
    initHover: () ->
        @el.bind 'mouseover.fragment', =>
            # dropArea.element.addClass('over_dropped')    

        @el.bind 'mouseout.fragment', =>
            # dropArea.element.removeClass('over_dropped')  
            
    appendTo: (container) ->
        container.append(@el)
        @addDropArea()  

    addDropArea: (dropAreaElement=@el, parent=null, hiddenIndex=0) ->
        hiddenWidth = 30
        offset = dropAreaElement.offset()
        gameAreaOffset = @gameArea.offset()
        dropArea = 
            id: dropAreaElement.attr('id')
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
    