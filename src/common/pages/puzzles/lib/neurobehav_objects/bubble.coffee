bubble = exports ? provide('./bubble', {})

class bubble.Bubble
    width: 210
    arrowHeight: 15
    arrowWidth: 20
    arrowOffset: 24
    spacing: 20
    backgroundColor: '#49494A'
    
    constructor: ({@paper, @x, @y, @width, @height, @position}) -> 
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
        # else
            
        @container.attr(transform: "s0,0,#{@x},#{@y}")
        @container.animate(
            {transform: "s1"}, 
            100, 
            'linear',
            => callback() if callback
        )
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
        @visible = false
    
    

