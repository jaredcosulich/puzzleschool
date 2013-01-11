oscilloscope = exports ? provide('./oscilloscope', {})
neurobehavObject = require('./object')

class oscilloscope.Oscilloscope extends neurobehavObject.Object
    objectType: 'oscilloscope'
    objectName: 'Oscilloscope'
    width: 180
    height: 48
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

        startingX = @graph.attr('x')
        startingY = @graph.attr('y') + (@graph.attr('height') / 2)

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
        
        connectionLength = 20
        slope = ((@position.top + @height) - startingY) / ((startingX - connectionLength) - @position.left)
        
        endX = startingX - connectionLength - 10
        endY = startingY + (slope * 10)
        connection = @paper.path """
            M#{startingX},#{startingY}
            L#{startingX - (connectionLength)},#{startingY}
            L#{endX},#{endY}
        """
        connection.attr('stroke-width': 2)
        @image.push(connection)
        
        needle = @paper.path """
            M#{endX - 5},#{endY - (5*(1/slope))}
            L#{@position.left}, #{@position.top + @height}
            L#{endX + 5},#{endY + (5*(1/slope))}
            L#{endX - 5},#{endY - (5*(1/slope))}
        """
        needle.attr(fill: 'white')
        @image.push(needle)
        
        innerNeedle = @paper.path """
            M#{endX - 3},#{endY - (3*(1/slope))}
            L#{@position.left}, #{@position.top + @height}
            L#{endX + 3},#{endY + (3*(1/slope))}
        """
        innerNeedle.attr(stroke: '#ccc')
        @image.push(innerNeedle)
        
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
        bbox = @screen.getBBox()
        if @firePosition >= @screenWidth
            @voltageDisplay.remove() if @voltageDisplay
            @firePosition = 0
            @voltageDisplay = @screenPath """
                M#{bbox.x}, #{bbox.y + (@lastVoltage or @xAxis)}
            """
            
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