neurobehav = exports ? provide('./lib/neurobehav', {})

BASE_FOLDER = '/assets/images/puzzles/neurobehav/'
PERIODICITY = 100

class neurobehav.ChunkHelper
    constructor: () ->

class neurobehav.ViewHelper
    baseFolder: BASE_FOLDER

    $: (selector) -> $(selector, @el)

    constructor: ({@el}) ->
        @initBoard()
        @initOscillator()

        #basic instructions
        @stimulus = @addObject
            type: 'Stimulus'
            position:
                top: 100
                left: 100

        @neuron = @addObject
            type: 'Neuron'
            position:
                top: 100
                left: 300
            threshold: 10
            amplitude: 100
            delay: 500
                
        @stimulus.connectTo(@neuron)
        
        

    initBoard: ->
        @board = @$('.board')
        dimensions = @board.offset()
        @paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)
        
    initOscillator: ->
        @oscillator = new neurobehav.Oscillator
            container: @$('.oscillator')
            takeReading: => @neuron.takeReading() if @neuron
            
    addObject: (data) ->
        data.paper = @paper
        new neurobehav[data.type](data)
            
        
class neurobehav.Object
    periodicity: PERIODICITY
    baseFolder: BASE_FOLDER
    
    constructor: ({@paper, @position}) -> @init()
    
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
        @neuron.adjustVoltage(if @state == 0 then -10 else 10)

    setImage: ->
        @image.attr
            'clip-rect': "#{@position.left}, #{@position.top}, #{@width}, #{@height}"
            transform: "t#{-1 * @width * @state},0"

    connectTo: (@neuron) ->
        @connection = @paper.path """
            M#{@position.left + (@width/2)},#{@position.top + (@height/2)}
            L#{@neuron.position.left + (@neuron.width/2)},#{@neuron.position.top + (@neuron.height/2)}
        """
        @connection.attr('stroke-width': 2)
        @connection.toBack()
        @neuron.adjustVoltage(10 * @state)
        
class neurobehav.Neuron extends neurobehav.Object
    objectType: 'neuron'
    imageSrc: 'neuron.png' 
    height: 60
    width: 60

    constructor: ({@paper, @position, @threshold, @amplitude, @delay}) -> @init()
    
    init: -> 
        @voltage = 0
        @timeSinceLastSpike = @delay
        @currentVoltage = @voltage
        setInterval(
           (=> @setCurrentVoltage()),
           @periodicity
        )
        @create()

    setCurrentVoltage: ->
        @timeSinceLastSpike += @periodicity
        if @voltage < @threshold or @currentVoltage == @amplitude
            @currentVoltage = @voltage
        else if @timeSinceLastSpike >= @delay
            @currentVoltage = @amplitude
            @timeSinceLastSpike = 0
            
    takeReading: -> @currentVoltage
    
    adjustVoltage: (amount) -> @voltage += amount

class neurobehav.Oscillator
    periodicity: PERIODICITY
    axisLineCount: 5.0
    
    constructor: ({@container, @range, @threshold, @takeReading}) ->
        @init()
        @drawGrid()
        setInterval(
           (=> @fire()),
           @periodicity
        )              
        
    init: ->
        backgroundCanvas = document.createElement('CANVAS')
        @container.append(backgroundCanvas)
        @width = backgroundCanvas.width = $(backgroundCanvas).width()
        @height = backgroundCanvas.height = $(backgroundCanvas).height()   
        @backgroundContext = backgroundCanvas.getContext('2d')

        voltageCanvas = document.createElement('CANVAS')
        @container.append(voltageCanvas)
        voltageCanvas.width = $(voltageCanvas).width()
        voltageCanvas.height = $(voltageCanvas).height()   
        @voltageContext = voltageCanvas.getContext('2d')

        @voltageContext.strokeStyle = 'rgba(255, 92, 92, 1)'    
        @voltageContext.lineWidth = 1
        
        @xAxis = @height - (@height / @axisLineCount)
        
    fire: () ->
        voltage = @xAxis - @takeReading()
        @firePosition or= 0
        if @firePosition > @width
            @voltageContext.clearRect(0, 0, @width, @height)
            @firePosition = 0

        @voltageContext.beginPath()
        @voltageContext.moveTo(@firePosition, @lastVoltage or @xAxis)
        @firePosition += 5
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
        
        for y in [1...@height] by (@height / @axisLineCount)
            @backgroundContext.moveTo(0, y)
            @backgroundContext.lineTo(@width, y)

        @backgroundContext.stroke()
        @backgroundContext.closePath()        
        
    
        




