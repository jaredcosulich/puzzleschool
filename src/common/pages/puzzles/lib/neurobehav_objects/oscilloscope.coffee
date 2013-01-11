oscilloscope = exports ? provide('./oscilloscope', {})
neurobehavObject = require('./object')

class oscilloscope.Oscilloscope extends neurobehavObject.Object
    objectType: 'oscilloscope'
    objectName: 'Oscilloscope'
    width: 80
    height: 42
    screenWidth: 150
    screenHeight: 90
    screenColor: '#64A539'
    xDelta: 1
    
    constructor: ({@board}) ->
        super(arguments...)
        
        @draw()
        @drawThreshold()
        @initImage()
        setInterval(
           (=> @fire()),
           @periodicity
        )        
        
    init: ->
        @scale = @screenHeight/2
        @xAxis = @screenHeight - 12
        
    draw: ->
        @image = @paper.set()
        @graph = @paper.rect(
            @position.left + (@screenWidth/2) - 6, 
            @position.top - (@screenHeight/2) - 6, 
            @screenWidth + 12, 
            @screenHeight + 12, 
            6
        )
        @graph.attr
            fill: '#ACACAD'
        @image.push(@graph)

        @screen = @paper.rect(
            @position.left + (@screenWidth/2), 
            @position.top - (@screenHeight/2), 
            @screenWidth, 
            @screenHeight, 
            6
        ) 
        @screen.attr
            fill: 'black'
        @image.push(@screen)
        
    initImage: ->
        @image.properties = 
            description: @description
            
        @image.attr
            cursor: 'move'
         
        glow = @initMoveGlow(@graph) 
        @image.toFront()
        
        lastDX = 0
        lastDY = 0 
        fullDX = 0
        fullDY = 0
        onDrag = (dX, dY) =>
            fullDX = lastDX + dX 
            fullDY = lastDY + dY
            @image.transform("t#{fullDX},#{fullDY}")
            glow.transform("t#{fullDX},#{fullDY}")
            
        onStart = => 
            @showProperties(@image)        
            @unattach()
            glow.show()
        
        onEnd = =>
            glow.attr(opacity: 0)
            lastDX = fullDX
            lastDY = fullDY
            for element in @paper.getElementsByPoint(@position.left + fullDX, (@position.top + @height) + fullDY)
                if element.objectType == 'neuron'
                    @attachTo(element.object)
            
        @image.drag(onDrag, onStart, onEnd)        
        glow.drag(onDrag, onStart, onEnd)
        
    screenPath: (path) ->
        set = @paper.set()
        border = @paper.path(path)
        line = @paper.path(path)
        border.attr(stroke: @screenColor, 'stroke-opacity': 0.5, 'stroke-width': 3)
        line.attr(stroke: @screenColor)
        set.push(border, line)
        @image.push(set)
        return set
        
    fire: () ->
        return unless @neuron
        voltage = @xAxis - (@neuron.takeReading() * @scale)
        @firePosition or= @screenWidth
        if @firePosition >= @screenWidth
            @voltageDisplay.remove() if @voltageDisplay
            @firePosition = 0
            @voltageDisplay = @screenPath """
                M#{@screen.attr('x')}, #{@screen.attr('y') + (@lastVoltage or @xAxis)}
            """
            
        for part in @voltageDisplay.items
            part.attr
                path: """
                    #{part.attr('path')}
                    L#{@screen.attr('x') + @firePosition}, #{@screen.attr('y') + voltage}
                """
            
        @firePosition += @xDelta
        @lastVoltage = voltage
        
    drawThreshold: ->
        @thresholdLine.remove() if @thresholdLine
        if (threshold = @neuron?.properties?.threshold?.value)
            translatedThreshold = @screen.attr('y') + @xAxis - (threshold * @scale)
            path = []
            for x in [0...@screenWidth] by 10
                path.push("M#{@screen.attr('x') + x},#{translatedThreshold}")
                path.push("L#{@screen.attr('x') + x+5},#{translatedThreshold}")
                
            @thresholdLine = @screenPath(path.join(''))
            @thresholdLine.toFront()
            
    attachTo: (@neuron) ->
        $(@neuron).bind 'threshold.change.oscilloscope', => @drawThreshold()
        @drawThreshold()
        
    unattach: -> 
        $(@neuron).unbind 'threshold.change.oscilloscope' if @neuron
        @neuron = null
        @voltageDisplay.remove()
        @firePosition = 0
        @drawThreshold()