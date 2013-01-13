slider = exports ? provide('./slider', {})

class slider.Slider
    radius: 6
    
    constructor: ({@paper, @x, @y, @width, @min, @max, @unit, @val}) ->
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
                @propertiesEditor.set('voltage', (@voltageCalc(@deltaX)/@segment)*@unit)
                @lastDeltaX = @deltaX                
            else
                @el.noClick = false
            @deltaX = 0
            $.timeout 10, => @el.noClick = false
        
        @knob.drag(onDrag, onStart, onEnd)        
            
        @el.push(guide)
        @el.push(@knob)
    
    moveKnob: (dX, dY) =>    
        @deltaX = @lastDeltaX + dX
        @deltaX = @right - @left if @deltaX > @right - @left
        @deltaX = 0 if @deltaX < 0
        @deltaX = @voltageCalc(@deltaX)
        @knob.transform("t#{@deltaX},#{0}")
        @initPropertiesGlow(@el)
        @propertiesClick(@el, true)
        @propertiesEditor.set('voltage', (@voltageCalc(@deltaX)/@segment)*@unit)

    set: (@val) ->
        @lastDeltaX = @segment * (@val / @unit)
        @moveKnob(0,0)

