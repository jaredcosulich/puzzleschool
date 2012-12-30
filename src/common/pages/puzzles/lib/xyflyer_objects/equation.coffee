equation = exports ? provide('./equation', {})

class equation.Equation
    defaultText: 'Drag equations from below and drop here'

    constructor: ({@gameArea, @id, @plot}) ->
        @dropAreas = []
        @container = $(document.createElement('DIV'))
        @container.addClass('equation_container')
        @container.html('<div class=\'intro\'>Y=</div>')
        
        @el = $(document.createElement('DIV'))
        @el.addClass('equation')
        @el.attr('id', @id)
        
        @container.append(@el)

        @initHover()
        
        @initRange()
        
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
                x: @clientX(e)
                y: @clientY(e)
                test: (dropArea, over) => testDropArea(dropArea, over)

            @selectedDropArea.element.addClass('component_over') if @selectedDropArea
            
        @el.bind 'mouseout.fragment', => @clear()
        
        @el.bind 'mousedown.fragment', (e) => 
            return if @selectedDropArea?.dirtyCount or !@selectedDropArea?.component
            @selectedDropArea.element.removeClass('with_component')
            @selectedDropArea.element.html(@selectedDropArea.defaultText)
            @selectedDropArea.component.mousedown(e)
            @selectedDropArea.component.move(e)
            @selectedDropArea.component = null

            for childArea in @selectedDropArea.childAreas
                @dropAreas.splice(childArea.index, 1)
            @selectedDropArea.childAreas = []
                
            emptyIndices = []
            for dropArea in @dropAreas when not dropArea.component
                dropArea.element.remove()
                emptyIndices.push(dropArea.index)
                
            @dropAreas.splice(emptyIndex, 1) for emptyIndex in emptyIndices.reverse()
            dropArea.wrap() for dropArea in @dropAreas
            
            @addFirstDropArea() if not @dropAreas.length
            
            @selectedDropArea.parentArea.dirtyCount -= 1 if @selectedDropArea.parentArea
            @selectedDropArea.plot()
            
    clear: ->
        @selectedDropArea = null
        @el.removeClass('component_over')
        @el.removeClass('accept_component')
        @$('.component_over').removeClass('component_over')
        @$('.accept_component').removeClass('accept_component')
            
    appendTo: (area) ->
        area.append(@container)
        @addFirstDropArea()
        
    addFirstDropArea: ->
        dropAreaElement = @newDropArea()
        dropAreaElement.html(@defaultText)
        dropAreaElement.addClass('only_area')
        @el.append(dropAreaElement)
        @addDropArea(dropAreaElement)
        
    newDropArea: ->
        dropArea = $(document.createElement('DIV'))
        dropArea.addClass('accept_fragment')
        return dropArea
        
    overlappingDropAreas: ({x, y, test}) ->
        overlapping = []
        gameAreaOffset = @gameArea.offset()
        for dropArea in @dropAreas
            offset = dropArea.element.offset()
            offset.left -= gameAreaOffset.left
            offset.top -= gameAreaOffset.top
            over = (
                x >= offset.left and
                x <= offset.left + offset.width and
                y >= offset.top and
                y <= offset.top + offset.height   
            )  
            return dropArea if test(dropArea, over)
            
    addDropArea: (dropAreaElement, parentArea=null) ->
        dropArea = 
            id: dropAreaElement.attr('id')
            index: @dropAreas.length
            defaultText: (if dropAreaElement == @el then @defaultText else '')
            element: dropAreaElement
            childAreas: []
            dirtyCount: 0
            formula: => @formula()
            
        dropArea.highlight = (readyToDrop) => @highlightDropArea(dropArea, readyToDrop) 
        dropArea.format = (component) => @formatDropArea(dropArea, component) 
        dropArea.plot = () => @plot(dropArea)
        dropArea.wrap = () => @wrap(dropArea)

        if parentArea
            parentArea.childAreas.push(dropArea)
            dropArea.parentArea = parentArea
            
        @dropAreas.push(dropArea)  
        
        @el.find('.only_area').removeClass('only_area') if @el.find('.accept_fragment').length > 1

    wrap: (dropArea) ->
        if !(previous = dropArea.element.previous()).length or previous.hasClass('with_component')
            beforeDropArea = @newDropArea()
            dropArea.element.before(beforeDropArea)
            @addDropArea(beforeDropArea)

        if !(next = dropArea.element.next()).length or next.hasClass('with_component')
            afterDropArea = @newDropArea()
            dropArea.element.after(afterDropArea)
            @addDropArea(afterDropArea)
        
    highlightDropArea: (dropArea, readyToDrop) ->
        return false if dropArea.childAreas.length or dropArea.component
        if readyToDrop
            dropArea.element.addClass('component_over')
            return true 
        else
            dropArea.element.removeClass('component_over')
            return false
                
    formatDropArea: (dropArea, component) ->
        fragment = component.equationFragment
        element = dropArea.element
        element.html(@formatFragment(fragment))
        for acceptFragment in element.find('.accept_fragment')
            @addDropArea($(acceptFragment), dropArea)
        
    formatFragment: (fragment) ->
        constant = '<div class=\'fragment\'>'
        accept = '<div class=\'accept_fragment\'></div>'
        fragment = fragment.replace(
            /(.*)\((.*)\)/, 
            "#{constant}$1(</div>#{accept}#{constant}$2</div>#{accept}#{constant})</div>"
        )
        if fragment.indexOf(constant) == -1
            fragment = "#{constant}#{fragment}</div>"
        
        return fragment
    
    formula: ->
        element = @el[0]
        text = if element.textContent then element.textContent else element.innerText      
        text = '' if text == @defaultText
        return text if not @range.from
        range = "{#{@range.from}<=x<=#{@range.to}}"
        return "#{text}#{range}"
       
    initRange: ->
        element = $(document.createElement('DIV'))
        element.addClass('range')
        element.html('From X = <input type=\'text\' class=\'from\'></input> to X = <input type=\'text\' class=\'to\'></input>')
        @container.append(element)
        
        setTimeout(
            (=>
                element.find('input').bind 'keyup', =>
                    @setRange(element.find('.from').val(), element.find('.to').val())
                
                @range =
                   element: element
                   hidden: false
                   height: element.css('height')
                   padding: element.css('paddingTop')
                @hideRange()
            ), 10
        )
        
    showRange: ->
        return unless @range.hidden
        @range.element.animate
            height: @range.height
            paddingTop: @range.padding
            paddingBottom: @range.padding
            duration: 250
        @range.hidden = false
        
    hideRange: ->
        return if @range.hidden
        @range.element.animate
            height: 0
            paddingTop: 0
            paddingBottom: 0
            duration: 250
        @range.hidden = true
            
    setRange: (from=null, to=null) ->
        @range.element.find('.from').val(if from? then from else '')
        @range.element.find('.to').val(if to? then to else '')
        @range.from = from
        @range.to = to
        @plot(@dropAreas[0])
        
