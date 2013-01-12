oscilloscope = exports ? provide('./oscilloscope', {})
neurobehavObject = require('./object')

class oscilloscope.Oscilloscope extends neurobehavObject.Object
    objectType: 'oscilloscope'
    objectName: 'Oscilloscope'
    width: 180
    height: 96
    connectionLength: 60
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
        @image = @paper.set()
        @scale = @screenHeight/2
        @xAxis = @screenHeight - 12
        
    draw: ->
        graph = @paper.rect(
            @position.left + 9, 
            @position.top, 
            @screenWidth + 12, 
            @screenHeight + 12, 
            6
        )
        graph.attr
            fill: '#ACACAD'
        @image.push(graph)

        startingX = graph.attr('x')
        startingY = graph.attr('y') + (graph.attr('height') / 2)

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
        
        connectionSegment = @connectionLength/10
        slope = ((@position.top + @height) - startingY) / ((startingX - (connectionSegment*4)) - (startingX - (@connectionLength)))
        
        endX = startingX - (connectionSegment*5)
        endY = startingY + (slope * connectionSegment)
        connection = @paper.path """
            M#{startingX},#{startingY}
            L#{startingX - (connectionSegment*4)},#{startingY}
            L#{endX},#{endY}
        """
        connection.attr('stroke-width': 2)
        @image.push(connection)
        
        @needle = @paper.path """
            M#{endX - 5},#{endY - (5*(1/slope))}
            L#{(startingX - (@connectionLength))}, #{@position.top + @height}
            L#{endX + 5},#{endY + (5*(1/slope))}
            L#{endX - 5},#{endY - (5*(1/slope))}
        """
        @needle.attr(fill: 'white')
        @image.push(@needle)
        
        innerNeedle = @paper.path """
            M#{endX - 3},#{endY - (3*(1/slope))}
            L#{(startingX - (@connectionLength))}, #{@position.top + @height}
            L#{endX + 3},#{endY + (3*(1/slope))}
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
            @image.toFront()
            @image.transform("...T#{dX - lastDX},#{dY - lastDY}")
            glow.transform("...T#{dX - lastDX},#{dY - lastDY}")
            lastDX = dX 
            lastDY = dY
            
        onStart = => 
            @showProperties(@image)        
            @unattach()
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
            @voltageDisplay.remove() if @voltageDisplay
            @firePosition = 0
            @voltageDisplay = @screenPath """
                M#{bbox.x}, #{bbox.y + (@lastVoltage or @xAxis)}
            """
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
        @firePosition = 0
        @drawThreshold()