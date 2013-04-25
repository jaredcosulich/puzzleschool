equation = exports ? provide('./equation', {})
Transformer = require('./transformer').Transformer

class equation.Equation
    defaultText: 'Drag equations below and drop here'

    constructor: ({@id, @gameArea, @solution, @solutionComponents, @startingFragment, @variables, @plot}) ->
        @dropAreas = []
        @container = $(document.createElement('DIV'))
        @container.addClass('equation_container')
        @container.html('<div class=\'intro\'>Y=</div>')
        
        @el = $(document.createElement('DIV'))
        @el.addClass('equation')
        @el.attr('id', @id)
        @el.bind "touchstart touchmove touchend", (e) -> e.preventDefault() if e.preventDefault

        if @startingFragment?.length
            @startingElement = @formatFragment(@startingFragment)
            @el.addClass('starting_fragment')
        else
            @startingElement = @defaultText 
        
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
            if not @selectedDropArea
                @selectedDropArea = @overlappingDropAreas
                    x: @clientX(e)
                    y: @clientY(e)
                    test: (dropArea, over) => testDropArea(dropArea, over)
                    
            return if @selectedDropArea?.dirtyCount or !@selectedDropArea?.component
            component = @selectedDropArea.component
            component.initDragging()
            component.move(e)
            @removeFragment(@selectedDropArea, e)

    removeFragment: (dropArea, e) ->
        @el.find('.accept_component').removeClass('accept_component')
        @el.find('.accept_fragment:not(.with_component)').removeClass('accept_fragment')
        
        dropArea.element.removeClass('with_component')
        
        dropArea.component.after = null    
        dropArea.component = null
        
        @removeDropArea(childArea) for childArea in dropArea.childAreas
        dropArea.childAreas = []
         
        removeDropAreas = []
        for da in @dropAreas when not da.component and not da.fixed
            da.element.addClass('removing')
            removeDropAreas.push(da)
    
        $(document.body).one 'mouseup.removing_drop_area touchend.removing_drop_area', =>
            @$('.removing').remove()      
    
        @removeDropArea(da) for da in removeDropAreas
        @wrap(da) for da in @dropAreas
        @addFirstDropArea() if not @dropAreas.length
        
        @recordComponentPositions()
        
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
        @el.find('.accept_fragment').css(width: '')
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
        
        dropAreaElement.html(@startingElement)
        if @startingElement == @defaultText
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
            continue unless dropArea.element.hasClass('accept_fragment')
            
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
            startingFragment: (if dropAreaElement == @el then @startingElement else '')
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
        component.dropArea = dropArea
        dropArea.parentArea.dirtyCount += 1 if dropArea.parentArea
        @formatDropArea(dropArea, component)
        @wrap(dropArea)
        @initVariables()
        dropArea.width = dropArea.element.width()
        
        element.bind 'touchstart.remove', (e) =>
            return if dropArea.dirtyCount or !dropArea.component
            component.move(e)
            element.hide()
            component.initDragging()
            $.timeout(100, => @removeFragment(dropArea, e))
        
        component.placeHolder.unbind('mousedown.placeholder touchstart.placeholder')
        component.placeHolder.bind 'mousedown.placeholder touchstart.placeholder', (e) =>
            component.placeHolder.one 'mouseup.placeholder touchend.placeholder', (e) =>
                @removeFragment(dropArea, e)
                component.endMove(e)        
        
        @recordComponentPositions()
        @plot(@)
            
    recordComponentPositions: ->
        for dropArea in @dropAreas when dropArea.component
            previousWithComponent = dropArea.element.previous()
            if previousWithComponent
                previousWithComponent = previousWithComponent.previous() unless previousWithComponent.hasClass('with_component')
                dropArea.component.after = @straightFormula(previousWithComponent)
            else 
                delete dropArea.component.after
            
    wrap: (dropArea) ->
        return unless dropArea.element?.parent()?.length
        previous = dropArea.element.previous()
        previous = previous.previous() while previous.hasClass('removing')
        if !previous.length or previous.hasClass('with_component') or previous.hasClass('fragment')
            beforeDropArea = @newDropArea()
            dropArea.element.before(beforeDropArea)
            @addDropArea(beforeDropArea)

        next = dropArea.element.next()
        next = next.next() while next.hasClass('removing')
        if !next.length or next.hasClass('with_component') or next.hasClass('fragment')
            afterDropArea = @newDropArea()
            dropArea.element.after(afterDropArea)
            @addDropArea(afterDropArea)
            
        @wrapChildren(dropArea)

    wrapChildren: (dropArea) ->
        for fragment in dropArea.element.find('.fragment:not(.removing)')
            fragment = $(fragment)
            previous = fragment.previous()
            previous = previous.previous() while previous.hasClass('removing')
            if previous.hasClass('fragment')
                beforeDropArea = @newDropArea()
                fragment.before(beforeDropArea)
                @addDropArea(beforeDropArea, dropArea)

            next = fragment.next()
            next = next.next() while next.hasClass('removing')
            if next.hasClass('fragment')
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
            /(.*\()(.*)\)(\^*\d*\**\/*)*/g, 
            "#{constant}$1</div>#{constant}$2</div>#{constant})$3</div>"
        )
        if fragment.indexOf(constant) == -1
            fragment = "#{constant}#{fragment}</div>"

        return fragment
    
    formulaData: ->
        return @formula()
        "#{@formula()}#{@rangeText()}"

    rangeText: ->
        return '' if not @range?.from
        "{#{@range.from}<=x<=#{@range.to}}"
        
    straightFormula: (el = @el) ->
        return '' if not el.length
        element = el[0]
        
        if el.find('.removing').length > 0
            tempEl = element.cloneNode(true)
            $(tempEl).find('.removing').remove()
            element = tempEl
            
        text = if element.textContent then element.textContent else element.innerText      
        text = '' if text == @defaultText
        return text or ''
        
    formula: ->
        text = @straightFormula()
        for variable of @variables
            info = @variables[variable]
            continue if not info.get
            text = text.replace(///(^|[^a-w])#{variable}($|[^a-w])///, "$1#{info.get()}$2")
            
        return text
        
    initRange: ->
        return
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
        return
        return unless @range?.hidden
        @range.element.animate
            height: @range.height
            paddingTop: @range.padding
            paddingBottom: @range.padding
            duration: 250
        @range.hidden = false
        
    hideRange: ->
        return
        return if not @range or @range.hidden
        @range.element.animate
            height: 0
            paddingTop: 0
            paddingBottom: 0
            duration: 250
        @range.hidden = true
            
    setRange: (from=null, to=null) ->
        return
        @range.element.find('.from').val(if from? then from else '')
        @range.element.find('.to').val(if to? then to else '')
        @range.from = from
        @range.to = to
        @plot(@)
        
    initVariables: ->
        formula = @straightFormula()
        for variable of @variables
            if ///(^|[^a-w])#{variable}($|[^a-w])///.test(formula)
                @initVariable(variable) 
            else if @variables[variable].element?.closest('.equation_container')[0] == @container[0]
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

        setTimeout((=>
            input = element.find('input')
            track = element.find('.track')
            knob = element.find('.knob') 

            info.knobTransformer = new Transformer(knob)           
            info.set(info.start)

            trackWidth = element.find('.track').width()
            input.bind 'keyup.variable', (e) => 
                return unless 47 < e.keyCode < 58 or 188 < e.keyCode < 191
                @variables[variable].set(input.val()) unless isNaN(input.val())       
                       
            element.bind 'mousedown.drag_knob touchstart.drag_knob', (e) =>
                e.preventDefault() if e.preventDefault
                body = $(document.body)
                x = @clientX(e)
                offsetLeft = knob.offset().left - @gameArea.offset().left + (knob.width()/2)
                x = offsetLeft if x < offsetLeft
                startingX = x - offsetLeft
                body.bind 'mousemove.drag_knob touchmove.drag_knob', (e) =>
                    e.preventDefault() if e.preventDefault
                    dx = @clientX(e) - offsetLeft
                    dx = 0 if dx < 0
                    dx = trackWidth if dx > trackWidth 
                    info.knobTransformer.translate(dx, 0)
                    percentage = dx/trackWidth
                    info.set(info.min + (percentage * Math.abs(info.max - info.min)))
                    
                body.one 'mouseup.drag_knob touchend.drag_knob', =>
                    body.unbind 'mousemove.drag_knob touchmove.drag_knob'
        ), 10)

        info.get = => element.find('input').val()
        info.set = (val) =>
            incrementedVal = Math.round(val / info.increment) * info.increment
            decimalPosition = "#{info.increment}".length - 2 if -1 < info.increment < 1
            incrementedVal = incrementedVal.toFixed(decimalPosition) if decimalPosition > -1
            element.find('input').val("#{incrementedVal}")

            trackWidth = element.find('.track').width()
            left = trackWidth * (Math.abs(info.min - val) / Math.abs(info.max - info.min))
            info.knobTransformer.translate(left, 0)
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
        
    expandLastAccept: ->
        lastAccept = @el.find('.accept_fragment:last-child:not(.removing)')
        prevOffset = lastAccept.previous()?.offset()
        if prevOffset
            remainder =  prevOffset.left + prevOffset.width - @el.offset().left
        else
            remainder = 0
        lastAccept.width(@el.width() - remainder - 12)
        
    hideBadFormula: ->
        @el.removeClass('bad_formula')
        if @badFormula
            @badFormula.animation.stop() if @badFormula.animation
            @badFormula.animation = @badFormula.animate
                height: 0
                paddingTop: 0
                paddingBottom: 0
                duration: 500
                complete: => 
                    return unless @badFormula
                    @badFormula.remove()
                    delete @badFormula = null
                    
    showBadFormula: ->
        @el.addClass('bad_formula')
        if not @badFormula
            @badFormula = $(document.createElement('DIV'))
            @badFormula.addClass('bad_formula_message')
            @badFormula.html('This equation is not valid.')
            @container.append(@badFormula)
            @badFormula.data('height', @badFormula.height())
            @badFormula.height(0)
        
        @badFormula.animation.stop() if @badFormula.animation
        @badFormula.animation = @badFormula.animate
            height: @badFormula.data('height')
            duration: 500


