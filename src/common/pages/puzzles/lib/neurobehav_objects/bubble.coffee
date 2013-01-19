bubble = exports ? provide('./bubble', {})

class bubble.Bubble
    width: 210
    arrowHeight: 15
    arrowWidth: 20
    arrowOffset: 24
    spacing: 20
    backgroundColor: '#49494A'
    
    constructor: ({@paper, @x, @y, @width, @height}) -> 
        @init()
        
    $: (selector) -> @el.find(selector)
    
    init: ->
        
    createContainer: ->    
        @container = @paper.set()
        @base = @paper.rect(@x - @arrowOffset, @y - @arrowHeight - @height, @width, @height, 12)
        @container.push(@base)
        
        @arrow = @paper.path """
            M#{@x-(@arrowWidth/2)},#{@y-@arrowHeight-2}
            L#{@x},#{@y}
            L#{@x+(@arrowWidth/2)},#{@y-@arrowHeight-2}
        """
        @container.push(@arrow)
        @container.attr(fill: @backgroundColor, stroke: 'none')
        @container.toFront()
        bbox = @container.getBBox()
                            
    show: ({content, callback})->
        return if @container
        @createContainer()
        content(@container)
        @container.attr(transform: "s0,0,#{@x},#{@y}")
        @container.animate(
            {transform: "s1"}, 
            100, 
            'linear',
            => callback() if callback
        )
        @visible = true
        
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
    
    

