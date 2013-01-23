bubble = exports ? provide('./bubble', {})

class bubble.Bubble
    width: 210
    arrowHeight: 15
    arrowWidth: 20
    spacing: 20
    backgroundColor: '#49494A'
    
    constructor: ({@paper, @x, @y, @width, @height, @position, @arrowOffset, @html, @onHide, @onShow}) -> 
        @init()
                
    $: (selector) -> @el.find(selector)
    
    init: ->
        @arrowOffset or= 24
        if @position in ['left', 'right']
            if @y - @arrowOffset < 3
                @arrowOffset = @y - 3
                
            if @y - @arrowOffset + @height > @paper.height
                @arrowOffset = @height - @y - 3
        
    createContainer: ->    
        @container = @paper.set()
        @createBase()
        @createArrow()
        @container.attr(fill: @backgroundColor, stroke: 'none')
        @container.toFront()
        bbox = @container.getBBox()
    
    createBase: ->
        x = switch @position
            when 'right' then @x + @arrowHeight
            when 'left' then @x - @arrowHeight - @width
            else @x - @arrowOffset
        
        y = switch @position
            when 'right', 'left' then @y - @arrowOffset
            else @y - @arrowHeight - @height
        
        @base = @paper.rect(x, y, @width, @height, 12)
        @container.push(@base)
                            
    createArrow: ->
        @arrow = switch @position
            when 'right'
                @paper.path """
                    M#{@x+@arrowHeight+2},#{@y-(@arrowWidth/2)}
                    L#{@x},#{@y}
                    L#{@x+@arrowHeight+2},#{@y+(@arrowWidth/2)}
                """
            when 'left'
                @paper.path """
                    M#{@x-@arrowHeight-2},#{@y-(@arrowWidth/2)}
                    L#{@x},#{@y}
                    L#{@x-@arrowHeight-2},#{@y+(@arrowWidth/2)}
                """
            else
                @paper.path """
                    M#{@x-(@arrowWidth/2)},#{@y-@arrowHeight-2}
                    L#{@x},#{@y}
                    L#{@x+(@arrowWidth/2)},#{@y-@arrowHeight-2}
                """
        @container.push(@arrow)
                                
                            
    show: (content)->
        return if @animating or @container
        @animating = true
        @createContainer()
        if content
            content(@container)
        else
            @createHtml()
                
        @container.attr(transform: "s0,0,#{@x},#{@y}")
        @container.animate(
            {transform: "s1"}, 
            250, 
            'linear',
            => 
                @onShow() if @onShow
                @animating = false
        )   

        @syncHtml()
        
        @visible = true
        @container.toFront()
        
        $(document.body).bind 'mousedown.hide_bubble', (e) =>
            x = e.clientX - @paper.canvas.offsetLeft
            y = e.clientY - @paper.canvas.offsetTop
            if @base not in @paper.getElementsByPoint(x, y)
                @hide()
                $(document.body).unbind('mousedown.hide_bubble')
        
    hide: () -> 
        return if @animating or not @container
        @animating = true
        @container.animate(
            {transform: "s0,0,#{@x},#{@y}"}, 
            250, 
            'linear', 
            => 
                @container.remove()
                @container = null
                @onHide() if @onHide
                @animating = false
        )

        @syncHtml(false)
        
        @visible = false

    syncHtml: (show=true, equalTimes=0) =>
        return unless @htmlContainer
        height = parseInt(@htmlContainer.height())
        width = parseInt(@htmlContainer.width())
        
        bbox = @base.getBBox()
        toHeight = bbox?.height or 0
        toWidth = bbox?.width or 0

        unless show
            toWidth = Math.max(toWidth - 50, 0)
            toHeight = Math.max(toHeight - 50, 0)
            
        if height == toHeight and width == toWidth
            equalTimes += 1
        else
            equalTimes = 0
        
        return if equalTimes > 10

        toLeft = @paper.canvas.offsetLeft + (bbox?.x or 0)
        toTop = @paper.canvas.offsetTop + (bbox?.y or 0)
        
        @htmlContainer.css
            height: toHeight
            width: toWidth
            left: toLeft
            top: toTop
        setTimeout((=> @syncHtml(show, equalTimes)), 1)
        
    createHtml: ->
        return if @htmlContainer
        @htmlContainer = $(document.createElement('DIV'))
        @htmlContainer.addClass('bubble_description')
        @htmlContainer.html("<div class='description'>#{@html}</div>")
        @htmlContainer.css
            top: 0
            left: 0
            width: 0 
            height: 0 
            
        padding = 12
        bbox = @base.getBBox()
        width = bbox.width - (padding*2)
        height = bbox.height - (padding*2)
        @htmlContainer.find('.description').css(width: width, height: height, backgroundColor: @backgroundColor)
        $(document.body).append(@htmlContainer)    
        
    setHtml: (@html) ->
        @htmlContainer?.find('.description')?.html(@html)
    

