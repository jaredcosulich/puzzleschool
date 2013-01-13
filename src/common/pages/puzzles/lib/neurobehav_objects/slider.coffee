slider = exports ? provide('./slider', {})

class slider.Slider
    radius: 6
    
    constructor: ({@paper, @x, @y, @width, @min, @max, @unit}) ->
        @segment = @width / (@max - @min)   
        @listeners = []
        @init()
        
    init: ->
        @el = @paper.set()
        
        @range = @max / @unit
        @segment = @width / @range

        guide = @paper.path("M#{@x},#{@y}L#{@x + @width},#{@y}")
        guide.attr
            'stroke': "#ccc"
            'stroke-width': 5
            'stroke-linecap': 'round'
        
        @knob = @paper.circle(@x, @y, @radius)
        @knob.attr
            cursor: 'move'
            stroke: '#555'
            fill: 'r(0.5, 0.5)#ddd-#666'
        
        @lastDeltaX = (@segment * @val)/@unit
        @deltaX = 0        
        @knob.transform("t#{@lastDeltaX},0")

        onDrag = (dX, dY) => @moveKnob(dX, dY)
        onStart = => @el.noClick = true
            
        onEnd = =>
            if @deltaX
                @lastDeltaX = @deltaX                
            else
                @el.noClick = false
            @deltaX = 0
            $.timeout 10, => @el.noClick = false
        
        @knob.drag(onDrag, onStart, onEnd)        
            
        @el.push(guide)
        @el.push(@knob)
        
    addListener: (listener) ->
        @listeners.push(listener)
            
    moveKnob: (dX=0, dY=0) =>    
        @deltaX = @lastDeltaX + dX
        @deltaX = @width if @deltaX > @width
        @deltaX = @min if @deltaX < @min   
        segments = Math.round(@deltaX / @segment)
        @val = @unit * segments
        @knob.transform("t#{@deltaX},#{0}")        
        for listener in @listeners
            listener(@val)
        
    set: (val) ->
        return if val == @val
        @lastDeltaX = @segment * (val / @unit)
        @moveKnob()

