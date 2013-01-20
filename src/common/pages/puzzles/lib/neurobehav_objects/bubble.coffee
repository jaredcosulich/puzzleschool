bubble = exports ? provide('./bubble', {})

class bubble.Bubble
    width: 210
    arrowHeight: 15
    arrowWidth: 20
    arrowOffset: 24
    spacing: 20
    backgroundColor: '#49494A'
    
    constructor: ({@paper, @x, @y, @width, @height, @position, @html}) -> 
        @init()
        
    $: (selector) -> @el.find(selector)
    
    init: ->
        
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
            else @x - @arrowOffset
        
        y = switch @position
            when 'right' then @y - @arrowOffset
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
            else
                @paper.path """
                    M#{@x-(@arrowWidth/2)},#{@y-@arrowHeight-2}
                    L#{@x},#{@y}
                    L#{@x+(@arrowWidth/2)},#{@y-@arrowHeight-2}
                """
        @container.push(@arrow)
                                
                            
    show: ({content, callback})->
        return if @container
        @createContainer()
        if content
            content(@container)
        else
            @createHtml()
                
            
        @container.attr(transform: "s0,0,#{@x},#{@y}")
        @container.animate(
            {transform: "s1"}, 
            100, 
            'linear',
            => callback() if callback
        )

        @animateHtml()
        
        @visible = true
        @container.toFront()
        
    hide: ({callback}) -> 
        return unless @container
        @container.animate(
            {transform: "s0,0,#{@x},#{@y}"}, 
            100, 
            'linear', 
            => 
                @container.remove()
                @container = null
                callback() if callback
        )

        @animateHtml(false)
        
        @visible = false

    animateHtml: (grow=true) =>
        height = parseInt(@htmlContainer.height())
        toHeight = if grow then parseInt(@htmlContainer.data('height')) else 0
        return if height == toHeight
        width = parseInt(@htmlContainer.width())
        toWidth = if grow then parseInt(@htmlContainer.data('width')) else 0
        increment = if grow then 20 else -20
        diffHeight = toHeight - height
        diffWidth = toWidth - width
        heightDiff = if grow then Math.min(diffHeight, increment) else Math.max(diffHeight, increment)
        widthDiff = if grow then Math.min(diffWidth, increment) else Math.max(diffWidth, increment)
        @htmlContainer.height(height + heightDiff)
        @htmlContainer.width(width + widthDiff)
        setTimeout((=> @animateHtml(grow)), 1)
        
    createHtml: ->
        return if @htmlContainer
        @htmlContainer = $(document.createElement('DIV'))
        @htmlContainer.addClass('bubble_description')
        @htmlContainer.html("<div class='description'>#{@html}</div>")

        bbox = @base.getBBox()
        offsetX = @paper.canvas.offsetLeft
        offsetY = @paper.canvas.offsetTop
        padding = 12
        @htmlContainer.css
            backgroundColor: @backgroundColor
            top: offsetY + bbox.y + padding
            left: offsetX + bbox.x + padding
            width: 0 
            height: 0 
            
        width = bbox.width - (padding*2)
        height = bbox.height - (padding*2)
        @htmlContainer.data('width', width)
        @htmlContainer.data('height', height)
        @htmlContainer.find('.description').width(width).height(height)
        $(document.body).append(@htmlContainer)    
        
    
    

