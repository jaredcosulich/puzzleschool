neurobehav = exports ? provide('./lib/neurobehav', {})

BASE_FOLDER = '/assets/images/puzzles/neurobehav/'
PERIODICITY = 20

class neurobehav.ChunkHelper
    constructor: () ->

class neurobehav.ViewHelper
    baseFolder: BASE_FOLDER

    $: (selector) -> $(selector, @el)

    constructor: ({@el}) ->
        @initBoard()

        #basic instructions
        @stimulus = @addObject
            type: 'Stimulus'
            position:
                top: 100
                left: 100
            voltage: 1.5

        @neuron = @addObject
            type: 'Neuron'
            position:
                top: 100
                left: 300
            threshold: 1
            spike: 0.5
                
        @stimulus.connectTo(@neuron)

        @oscilloscope = @addObject
            type: 'Oscilloscope'
            position:
                top: 80
                left: 340
            container: @$('.oscilloscope')
            
        @oscilloscope.attachTo(@neuron)
        

    initBoard: ->
        @board = @$('.board')
        dimensions = @board.offset()
        @paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)
            
    addObject: (data) ->
        data.paper = @paper
        new neurobehav[data.type](data)
            
        
class neurobehav.Object
    periodicity: PERIODICITY
    baseFolder: BASE_FOLDER
    
    create: ->
        @image = @paper.image(
            "#{@baseFolder}#{@imageSrc}", 
            @position.left, 
            @position.top, 
            @fullWidth or @width, 
            @fullHeight or @height
        )
        
    init: -> raise("no init method for #{@objectType}")

class neurobehav.Stimulus extends neurobehav.Object
    objectType: 'stimulus'
    imageSrc: 'stimulus_button.png' 
    height: 50
    width: 50
    fullWidth: 100
        
    constructor: ({@paper, @position, @voltage}) -> @init()
    
    init: ->
        @create()
        @state = 0
        @setImage()
        @image.click => @toggleState()
        @image.attr(cursor: 'pointer')
        
    toggleState: ->
        @state += 1
        @state = @state % 2
        @setImage()
        @neuron.addVoltage(if @state == 0 then (@voltage * -1) else @voltage)

    setImage: ->
        @image.attr
            'clip-rect': "#{@position.left}, #{@position.top}, #{@width}, #{@height}"
            transform: "t#{-1 * @width * @state},0"

    connectTo: (@neuron) ->
        @connection = @paper.path """
            M#{@position.left + (@width/2)},#{@position.top + (@height/2)}
            L#{@neuron.position.left},#{@neuron.position.top + (@neuron.height/2)}
        """
        @connection.attr('stroke-width': 2, 'arrow-end': 'block-wide-long')
        @connection.toBack()
        @neuron.addVoltage(@voltage * @state)
        
class neurobehav.Neuron extends neurobehav.Object
    objectType: 'neuron'
    imageSrc: 'neuron.png' 
    height: 60
    width: 60

    constructor: ({@paper, @position, @threshold, @spike}) -> @init()
    
    init: -> 
        ## setup parameters and state variables
        @timeSinceStart = 0
        @restTime       = 0                   # initial refractory time
        @timeDelta      = 0.5

        ## LIF properties
        @resistance     = 1                   # resistance (kOhm)
        @capacitance    = 10                  # capacitance (uF)
        @timeConstant   = @resistance * @capacitance
        @refractory     = 16                   # refractory period (msec)

        @voltage = 0
        @currentVoltage = @voltage
        setInterval(
           (=> @setCurrentVoltage()),
           @periodicity
        )
        @create()

    setCurrentVoltage: ->
        @timeSinceStart += @timeDelta
        @lastVoltage = @currentVoltage
        
        if @timeSinceStart > @restTime
            @currentVoltage = @lastVoltage + ((-1 * @lastVoltage) + @voltage * @resistance) / @timeConstant * @timeDelta
        
            if @currentVoltage >= @threshold
                @currentVoltage += @spike
                @restTime = @timeSinceStart + @refractory

        else
            @currentVoltage = 0
        
    takeReading: -> @currentVoltage
    
    addVoltage: (amount) -> @voltage += amount
    
    
    

class neurobehav.Oscilloscope extends neurobehav.Object
    objectType: 'oscilloscope'
    imageSrc: 'oscilloscope.png'
    width: 80
    height: 42
    axisLineCount: 5.0
    xDelta: 1
    scale: 100
    
    constructor: ({@paper, @position, @container, @range, @threshold}) ->
        @init()
        @drawGrid()
        setInterval(
           (=> @fire()),
           @periodicity
        )        
        @create()      
        
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
        
    attachTo: (@neuron) ->
        
    
        




