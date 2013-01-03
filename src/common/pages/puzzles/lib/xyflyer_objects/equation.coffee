equation = exports ? provide('./equation', {})

class equation.Equation
    defaultText: 'Drag equations below and drop here'

    constructor: ({@gameArea, @id, @plot, @startingFragment, @variables}) ->
        @dropAreas = []
        @container = $(document.createElement('DIV'))
        @container.addClass('equation_container')
        @container.html('<div class=\'intro\'>Y=</div>')
        
        @el = $(document.createElement('DIV'))
        @el.addClass('equation')
        @el.attr('id', @id)

        if @startingFragment?.length
            @el.addClass('starting_fragment')
        else
            @startingFragment = @defaultText 
        
        @container.append(@el)

        @initHover()
        
        @initRange()
        
    $: (selector) -> $(selector, @el)
        
    clientX: (e) => (e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX) - @gameArea.offset().left
    clientY: (e) => (e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY) - @gameArea.offset().top
    
    initHover: () ->
        testDropArea = (dropArea, over) =>
            return false if dropArea.fixed
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
            c = @selectedDropArea.component
            $(document.body).one 'mouseup.component', -> c.endMove(e)
            @removeFragment(@selectedDropArea, e)

    removeFragment: (dropArea, e) ->
        dropArea.component.mousedown(e)
        dropArea.component.move(e)
        
        @el.find('.accept_component').removeClass('accept_component')
        
        dropArea.element.removeClass('with_component')
        dropArea.element.html(dropArea.startingFragment)

        dropArea.component = null

        @removeDropArea(childArea) for childArea in dropArea.childAreas
        dropArea.childAreas = []
            
        removeDropAreas = []
        for da in @dropAreas when not da.component and not da.fixed
            da.element.remove()
            removeDropAreas.push(da)
            
        @removeDropArea(da) for da in removeDropAreas
        @wrap(da) for da in @dropAreas
        
        @addFirstDropArea() if not @dropAreas.length
        
        dropArea.parentArea.dirtyCount -= 1 if dropArea.parentArea
        @initVariables()
        @plot(@)
        
            
    removeDropArea: (dropAreaToRemove) ->
        removeIndex = -1
        for dropArea, index in @dropAreas
            if dropArea == dropAreaToRemove       
                removeIndex = index  
                break                
        @dropAreas.splice(removeIndex, 1) if removeIndex > -1
        
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
        @el.append(dropAreaElement)
        @addDropArea(dropAreaElement)
        
        dropAreaElement.html(@startingFragment)
        if @startingFragment == @defaultText
            dropAreaElement.addClass('only_area')
        else
            dropAreaElement.addClass('fragment')
            dropAreaElement.removeClass('accept_fragment')
            dropArea = @dropAreas[@dropAreas.length - 1]
            dropArea.fixed = true
            @wrap(dropArea)
            dropArea.width = dropAreaElement.width()
            
        @initVariables()
        @plot(@)
        
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
            id: @id
            index: @dropAreas.length
            startingFragment: (if dropAreaElement == @el then @startingFragment else '')
            element: dropAreaElement
            childAreas: []
            dirtyCount: 0
            formulaData: => @formulaData()
            
        dropArea.highlight = (readyToDrop) => @highlightDropArea(dropArea, readyToDrop) 
        dropArea.accept = (component) => @accept(dropArea, component) 

        if parentArea
            parentArea.childAreas.push(dropArea)
            dropArea.parentArea = parentArea
            
        @dropAreas.push(dropArea)  
        
        @el.find('.only_area').removeClass('only_area') if @el.find('.accept_fragment').length > 1

    accept: (dropArea, component) ->
        element = dropArea.element
        element.addClass('with_component')
        dropArea.component = component
        dropArea.parentArea.dirtyCount += 1 if dropArea.parentArea
        @formatDropArea(dropArea, component)
        @wrap(dropArea)
        @plot(@)
        @initVariables()
        dropArea.width = dropArea.element.width()
        component.placeHolder.unbind('click.placeholder')
        component.placeHolder.one 'click.placeholder', (e) =>
            @removeFragment(dropArea, e)
            component.endMove(e)
            
    wrap: (dropArea) ->
        if !(previous = dropArea.element.previous()).length or previous.hasClass('with_component')
            beforeDropArea = @newDropArea()
            dropArea.element.before(beforeDropArea)
            @addDropArea(beforeDropArea)

        if !(next = dropArea.element.next()).length or next.hasClass('with_component')
            afterDropArea = @newDropArea()
            dropArea.element.after(afterDropArea)
            @addDropArea(afterDropArea)
            
        @wrapChildren(dropArea)

    wrapChildren: (dropArea) ->
        for fragment in dropArea.element.find('.fragment')
            fragment = $(fragment)
            if (previous = fragment.previous()).hasClass('fragment')
                beforeDropArea = @newDropArea()
                fragment.before(beforeDropArea)
                @addDropArea(beforeDropArea, dropArea)

            if (next = fragment.next()).hasClass('fragment')
                afterDropArea = @newDropArea()
                fragment.after(afterDropArea)
                @addDropArea(afterDropArea, dropArea)
            
        
    highlightDropArea: (dropArea, readyToDrop) ->
        return false if dropArea.childAreas.length or dropArea.component or dropArea.fixed
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
        
    formatFragment: (fragment) ->
        constant = '<div class=\'fragment\'>'
        fragment = fragment.replace(
            /(.*)\((.*)\)/, 
            "#{constant}$1(</div>#{constant}$2</div>#{constant})</div>"
        )
        if fragment.indexOf(constant) == -1
            fragment = "#{constant}#{fragment}</div>"
        
        return fragment
    
    formulaData: ->
        "#{@formula()}#{@rangeText()}"

    rangeText: ->
        return '' if not @range?.from
        "{#{@range.from}<=x<=#{@range.to}}"
        
    straightFormula: ->
        element = @el[0]
        text = if element.textContent then element.textContent else element.innerText      
        text = '' if text == @defaultText
        return text
        
    formula: ->
        text = @straightFormula()
        for variable of @variables
            info = @variables[variable]
            continue if not info.get
            text = text.replace(variable, info.get())
            
        return text
        
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
        return unless @range?.hidden
        @range.element.animate
            height: @range.height
            paddingTop: @range.padding
            paddingBottom: @range.padding
            duration: 250
        @range.hidden = false
        
    hideRange: ->
        return if not @range or @range.hidden
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
        @plot(@)
        
    initVariables: ->
        formula = @straightFormula()
        for variable of @variables
            if formula.indexOf(variable) > -1
                @initVariable(variable) 
            else if @variables[variable].element
                @removeVariable(variable)
                
    initVariable: (variable) ->
        info = @variables[variable] 
        return if info.element
        element = $(document.createElement('DIV'))
        element.addClass('variable')
        element.html """
            #{variable} = <input type='text' value='#{info.start}'/>
            <div class='slider'><div class='track'></div><div class='knob'></div>
        """
        @container.append(element)

        setTimeout(
            (=>
                info.set(info.start)
                input = element.find('input')
                knob = element.find('.knob') 
                trackWidth = element.find('.track').width()
                input.bind 'keyup.variable', (e) => 
                    return unless 47 < e.keyCode < 58 or 188 < e.keyCode < 191
                    @variables[variable].set(input.val()) unless isNaN(input.val())       
                           
                knob.bind 'mousedown.drag_knob', (e) =>
                    e.preventDefault() if e.preventDefault
                    body = $(document.body)
                    startingX = e.clientX - parseInt(knob.css('left'))
                    body.bind 'mousemove.drag_knob', (e) =>
                        e.preventDefault() if e.preventDefault
                        left = e.clientX - startingX
                        left = 0 if left < 0
                        left = trackWidth if left > trackWidth
                        knob.css(left: left)
                        percentage = left/trackWidth
                        info.set(info.min + (percentage * Math.abs(info.max - info.min)))
                        
                    body.one 'mouseup.drag_knob', =>
                        body.unbind 'mousemove.drag_knob'
                        
            ), 10   
        )

        info.get = => element.find('input').val()
        info.set = (val) =>
            incrementedVal = Math.round(val / info.increment) * info.increment
            decimalPosition = "#{info.increment}".length - 2 if -1 < info.increment < 1
            incrementedVal = incrementedVal.toFixed(decimalPosition) if decimalPosition > -1
            element.find('input').val("#{incrementedVal}")

            trackWidth = element.find('.track').width()
            element.find('.knob').css(left: trackWidth * (Math.abs(info.min - val) / Math.abs(info.max - info.min)))
            @plot(@)
        info.element = element
            
    removeVariable: (variable) ->
        element = @variables[variable].element
        element.animate
            height: 0
            duration: 250
            complete: -> element.remove()
        delete @variables[variable].element
        delete @variables[variable].get
        delete @variables[variable].set
        
