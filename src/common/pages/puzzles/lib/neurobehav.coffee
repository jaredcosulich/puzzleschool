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
        stimulus = @addObject
            type: 'Stimulus'
            position:
                top: 100
                left: 100
            voltage: 1.5

        neuron1 = @addObject
            type: 'Neuron'
            position:
                top: 100
                left: 300
            threshold: 1
            spike: 0.5
                
        stimulus.connectTo(neuron1)

        neuron2 = @addObject
            type: 'Neuron'
            position:
                top: 300
                left: 200
            threshold: 1
            spike: 0.5
                
        oscilloscope = @addObject
            type: 'Oscilloscope'
            position:
                top: 80
                left: 340
            container: @$('.oscilloscope')
            
        oscilloscope.attachTo(neuron1)
        

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
        @image.objectType = @objectType
        @image.object = @
        return @image
        
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
    synapses: []
    synapseSpikes: []

    constructor: ({@paper, @position, @threshold, @spike}) -> @init()
    
    init: -> 
        @create()
            
        ## setup parameters and state variables
        @timeSinceStart = 0
        @restTime       = 0                   # initial refractory time
        @timeDelta      = 0.5

        ## LIF properties
        @resistance     = 1                   # resistance (kOhm)
        @capacitance    = 10                  # capacitance (uF)
        @timeConstant   = @resistance * @capacitance
        @refractory     = 16                  # refractory period (msec)

        @voltage = 0
        @currentVoltage = @voltage
        setInterval(
           (=> @setCurrentVoltage()),
           @periodicity
        )
        
        @createSynapse('excitatory')
        @createSynapse('inhibitory')

    setCurrentVoltage: ->
        @timeSinceStart += @timeDelta
        @lastVoltage = @currentVoltage
        
        synapseSpike = 0
        if @activeSynapseSpike
            @activeSynapseSpike.used += 2
            if @activeSynapseSpike.used >= 50
                @voltage -= @activeSynapseSpike.voltage
                @activeSynapseSpike = null 
            else
                voltageDiff = (@activeSynapseSpike.voltage / @activeSynapseSpike.used)
                @activeSynapseSpike.voltage -= voltageDiff
                @voltage -= voltageDiff
                
        if @synapseSpikes.length and not @activeSynapseSpike
            voltage = @synapseSpikes.shift() * 3
            if voltage < 0
                @voltage += voltage
            else
                @activeSynapseSpike = 
                    used: 2
                    voltage: voltage
                @voltage += @activeSynapseSpike.voltage
            
        if @timeSinceStart > @restTime
            @currentVoltage = @lastVoltage + ((-1 * @lastVoltage) + @voltage * @resistance) / @timeConstant * @timeDelta
        
            # synapseSpike = 0
            # if @activeSynapseSpike
            #     @activeSynapseSpike.used += 1
            #     @activeSynapseSpike = null if @activeSynapseSpike.used >= 40
            # else if @synapseSpikes.length
            #     @activeSynapseSpike = 
            #         used: 10
            #         voltage: @synapseSpikes.shift()
            # 
            # if @activeSynapseSpike
            #     @currentVoltage += (@activeSynapseSpike.voltage / (@activeSynapseSpike.used^2)) 
                
            if @currentVoltage >= @threshold
                @currentVoltage += @spike
                @restTime = @timeSinceStart + @refractory
                for synapse in @synapses
                    if (connection = synapse.connection)
                        connection.addSynapseSpike(@spike)

        else
            @currentVoltage = 0
        
    takeReading: -> @currentVoltage
    
    addSynapseSpike: (spike) -> @synapseSpikes.push(spike)
    
    addVoltage: (amount) -> @voltage += amount
    
    createSynapse: (type) ->
        xShift = (if type == 'inhibitory' then -12 else 12)
        endX = @position.left + (@width/2) + xShift
        endY = @position.top + @height + 20
        
        synapse = @paper.path """
            M#{@position.left + (@width/2) + xShift},#{@position.top + (@height/2)}
            L#{endX},#{endY}
        """
        synapse.attr
            'stroke-width': 2
        synapse.toBack()

        if type == 'inhibitory'
            tip = @paper.circle(endX, endY, 6)
            tip.attr
                'cursor': 'move'
                'fill': '#000'
        else
            tip = @paper.path """
                M#{endX-6},#{endY+6}
                L#{endX+6},#{endY+6}
                L#{endX},#{endY}
                L#{endX-6},#{endY+6}                
            """
            
            tip.attr
                'cursor': 'move'
                'fill': '#000'
           
        lastDX = 0
        lastDY = 0 
        fullDX = 0
        fullDY = 0
        onDrag = (dX, dY) =>
            path = synapse.attr('path')
            fullDX = lastDX + dX 
            fullDY = lastDY + dY
            path[1][1] = endX + fullDX
            path[1][2] = endY + fullDY
            synapse.attr('path', path)
            tip.transform("t#{fullDX},#{fullDY}")
            
        onStart = () =>
        
        onEnd = =>
            lastDX = fullDX
            lastDY = fullDY
            for element in @paper.getElementsByPoint(endX + fullDX, endY + fullDY)
                if element.objectType == 'neuron'
                    synapse.connection = {
                        addSynapseSpike: (spike) => 
                            spike = spike * -1 if type == 'inhibitory'
                            element.object.addSynapseSpike(spike)
                    }
        
        tip.drag(onDrag, onStart, onEnd)
        @synapses.push(synapse)
            

class neurobehav.Oscilloscope extends neurobehav.Object
    objectType: 'oscilloscope'
    imageSrc: 'oscilloscope.png'
    width: 80
    height: 42
    axisLineCount: 5.0
    xDelta: 1
    scale: 100
    
    constructor: ({@paper, @position, @container, @range, @threshold}) ->
        @initGrid()
        @drawGrid()
        @create()      
        @initObject()
        setInterval(
           (=> @fire()),
           @periodicity
        )        
        
    initGrid: ->
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
        
    initObject: ->
        @image.attr
            cursor: 'move'
        
        lastDX = 0
        lastDY = 0 
        fullDX = 0
        fullDY = 0
        onDrag = (dX, dY) =>
            fullDX = lastDX + dX 
            fullDY = lastDY + dY
            @image.transform("t#{fullDX},#{fullDY}")
            
        onStart = ->
        
        onEnd = =>
            lastDX = fullDX
            lastDY = fullDY
            for element in @paper.getElementsByPoint(@position.left + fullDX, (@position.top + @height) + fullDY)
                if element.objectType == 'neuron'
                    @attachTo(element.object)
            
        @image.drag(onDrag, onStart, onEnd)        
        
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
        
    
        




