oscilloscope = exports ? provide('./oscilloscope', {})
neurobehavObject = require('./object')

class oscilloscope.StaticOscilloscope extends neurobehavObject.Object
    objectType: 'oscilloscope'
    objectName: 'Oscilloscope'
    imageSrc: 'oscilloscope.png'
    width: 80
    height: 42
    axisLineCount: 5.0
    xDelta: 1
    scale: 100
    
    constructor: ({@container}) ->
        super(arguments...)
        
        @drawGrid()
        @createImage()      
        @initImage()
        setInterval(
           (=> @fire()),
           @periodicity
        )        
        
    init: ->
        backgroundCanvas = document.createElement('CANVAS')
        @container.append(backgroundCanvas)
        @canvasWidth = backgroundCanvas.width = $(backgroundCanvas).width()
        @canvasHeight = backgroundCanvas.height = $(backgroundCanvas).height()   
        @backgroundContext = backgroundCanvas.getContext('2d')

        voltageCanvas = document.createElement('CANVAS')
        @container.append(voltageCanvas)
        voltageCanvas.width = $(voltageCanvas).width()
        voltageCanvas.height = $(voltageCanvas).height()   
        @voltageContext = voltageCanvas.getContext('2d')

        @voltageContext.strokeStyle = 'rgba(255, 92, 92, 1)'    
        @voltageContext.lineWidth = 1
        
        @xAxis = @canvasHeight - (@canvasHeight / @axisLineCount)
        
    initImage: ->
        @image.properties = 
            description: @description
            
        @image.attr
            cursor: 'move'
         
        glow = @initMoveGlow(@image) 
        
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
        
    fire: () ->
        return unless @neuron
        voltage = @xAxis - (@neuron.takeReading() * @scale)
        @firePosition or= 0
        if @firePosition > @canvasWidth
            @voltageContext.clearRect(0, 0, @canvasWidth, @canvasHeight)
            @firePosition = 0

        @voltageContext.beginPath()
        @voltageContext.moveTo(@firePosition, @lastVoltage or @xAxis)
        @firePosition += @xDelta
        @voltageContext.lineTo(@firePosition, voltage)
        @voltageContext.stroke()
        @voltageContext.closePath()
        @lastVoltage = voltage
        
    drawGrid: ->
        @backgroundContext.clearRect(0,0,@canvasWidth,@canvasHeight)
        @backgroundContext.strokeStyle = 'rgba(0, 0, 0, 0.4)'    
        # @backgroundContext.fillStyle = 'rgba(255,255,255,0.4)'    
        # @backgroundContext.font = 'normal 12px sans-serif'    
        @backgroundContext.lineWidth = 1
        @backgroundContext.beginPath()
        
        for y in [1...@canvasHeight] by (@canvasHeight / @axisLineCount)
            @backgroundContext.moveTo(0, y)
            @backgroundContext.lineTo(@canvasWidth, y)

        @backgroundContext.stroke()
        @backgroundContext.closePath()        

        if (threshold = @neuron?.properties?.threshold?.value)
            translatedThreshold = @xAxis - (threshold * @scale)
            @backgroundContext.strokeStyle = '#0C8D28'    
            @backgroundContext.beginPath()
            for x in [0..@canvasWidth] by 10
                @backgroundContext.moveTo(x, translatedThreshold)
                @backgroundContext.lineTo(x + 5, translatedThreshold)
            @backgroundContext.stroke()
            @backgroundContext.closePath()        
        
    attachTo: (@neuron) ->
        $(@neuron).bind 'threshold.change.oscilloscope', => @drawGrid()
        @drawGrid()
        
    unattach: -> 
        $(@neuron).unbind 'threshold.change.oscilloscope'
        @neuron = null
        @voltageContext.clearRect(0, 0, @canvasWidth, @canvasHeight)
        @firePosition = 0
        @drawGrid()