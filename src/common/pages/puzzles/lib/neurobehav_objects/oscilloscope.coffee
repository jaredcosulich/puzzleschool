oscilloscope = exports ? provide('./oscilloscope', {})
neurobehavObject = require('./object')

class oscilloscope.Oscilloscope extends neurobehavObject.Object
    objectType: 'oscilloscope'
    objectName: 'Oscilloscope'
    width: 180
    height: 96
    screenWidth: 150
    screenHeight: 90
    centerOffset: 75
    screenColor: '#64A539'
    xDelta: 1
    
    constructor: ({@board, @connectorPosition}) ->
        super(arguments...)
        
        @draw()
        @drawThreshold()
        @initImage()
        setInterval(
           (=> @fire()),
           @periodicity
        )        
        
    init: ->
        @image = @paper.set()
        @scale = @screenHeight/2
        @xAxis = @screenHeight - 12
        
        if not @connectorPosition
            @connectorPosition = 
                top: @position.top + @height
                left: @position.left - 72
        
    draw: ->
        graph = @paper.rect(
            @position.left, 
            @position.top, 
            @screenWidth + 12, 
            @screenHeight + 12, 
            6
        )
        graph.attr
            fill: '#ACACAD'
        @image.push(graph)

        bbox = graph.getBBox()
        startingX = (if @connectorPosition.left > bbox.x then bbox.x + bbox.width else bbox.x)
        startingY = bbox.y + (bbox.height / 2)

        @screen = @paper.rect(
            graph.attr('x') + 6, 
            graph.attr('y') + 6, 
            @screenWidth, 
            @screenHeight, 
            6
        ) 
        @screen.attr
            fill: 'black'
        @image.push(@screen)
        
        endX = startingX + ((@connectorPosition.left - startingX)/2)
        endY = startingY + ((@connectorPosition.top - startingY)/2)
        connection = @paper.path """
            M#{startingX},#{startingY}
            L#{endX},#{endY}
        """
        connection.attr('stroke-width': 2)
        @image.push(connection)
        
        slope = (endY - startingY) / (startingX - endX)
        xDistance = if slope < 0 then 5 else -5
        xDistance = if Math.abs(slope) < 1 then xDistance * slope else xDistance
        @needle = @paper.path """
            M#{endX - xDistance},#{endY - (xDistance*(1/slope))}
            L#{@connectorPosition.left}, #{@connectorPosition.top}
            L#{endX + xDistance},#{endY + (xDistance*(1/slope))}
            L#{endX - xDistance},#{endY - (xDistance*(1/slope))}
        """
        @needle.attr(fill: 'white')
        @image.push(@needle)
        
        xDistance = if slope < 0 then 3 else -3
        xDistance = if Math.abs(slope) < 1 then xDistance * slope else xDistance
        innerNeedle = @paper.path """
            M#{endX - xDistance},#{endY - (xDistance*(1/slope))}
            L#{@connectorPosition.left}, #{@connectorPosition.top}
            L#{endX + xDistance},#{endY + (xDistance*(1/slope))}
        """
        innerNeedle.attr(stroke: '#ccc')
        @image.push(innerNeedle)
        super()
        
    initImage: ->
        @image.properties = 
            description: @description
            
        @image.attr
            cursor: 'move'
         
        glow = @initMoveGlow(@image) 
        
        lastDX = 0
        lastDY = 0
        onDrag = (dX, dY) =>
            @unattach() if @neuron
            @image.toFront()
            @image.transform("...T#{dX - lastDX},#{dY - lastDY}")
            glow.transform("...T#{dX - lastDX},#{dY - lastDY}")
            lastDX = dX 
            lastDY = dY
            
        onStart = => 
            glow.show()
        
        onEnd = =>
            glow.attr(opacity: 0)
            lastDX = 0
            lastDY = 0
            bbox = @needle.getBBox()
            for element in @paper.getElementsByPoint(bbox.x, bbox.y + bbox.height)
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
        bbox = @screen.getBBox()
        if @firePosition >= @screenWidth
            @firePosition = 0
            start = "M#{bbox.x}, #{bbox.y + (@lastVoltage or @xAxis)}"
            if @voltageDisplay
                for part in @voltageDisplay.items
                    part.attr(path: start)
            else
                @voltageDisplay = @screenPath(start)
            @voltageDisplay.attr('clip-rect': "#{bbox.x}, #{bbox.y}, #{bbox.width}, #{bbox.height}")
            
        for part in @voltageDisplay.items
            part.attr
                path: """
                    #{part.attr('path')}
                    L#{bbox.x + @firePosition}, #{bbox.y + voltage}
                """
            
        @firePosition += @xDelta
        @lastVoltage = voltage
        
    drawThreshold: ->
        @thresholdLine.remove() if @thresholdLine
        if (threshold = @neuron?.properties?.threshold?.value)
            bbox = @screen.getBBox()
            translatedThreshold = bbox.y + @xAxis - (threshold * @scale)
            path = []
            for x in [0...@screenWidth] by 10
                path.push("M#{bbox.x + x},#{translatedThreshold}")
                path.push("L#{bbox.x + x+5},#{translatedThreshold}")
                
            @thresholdLine = @screenPath(path.join(''))
            @thresholdLine.attr(opacity: 0.75)
            @thresholdLine.toFront()
            
    attachTo: (@neuron) ->
        $(@neuron).bind 'threshold.change.oscilloscope', => @drawThreshold()
        @drawThreshold()
        
    unattach: -> 
        $(@neuron).unbind 'threshold.change.oscilloscope' if @neuron
        @neuron = null
        @voltageDisplay.remove()
        @voltageDisplay = null
        @firePosition = 0
        @drawThreshold()