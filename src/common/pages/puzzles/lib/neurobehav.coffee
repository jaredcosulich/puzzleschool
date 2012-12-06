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
        data.id = @nextId()
        data.propertiesArea = @$('.properties')
        new neurobehav[data.type](data)
            
    nextId: ->
        @currentId = (@currentId or 0) + 1
        
        
class neurobehav.Object
    periodicity: PERIODICITY
    baseFolder: BASE_FOLDER
    
    constructor: ({@id, @paper, @position, @propertiesArea}) -> @init()
        
    createImage: ->
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

    initMoveGlow: (element) ->
        glow = element.glow(width: 30, fill: true, color: 'yellow')
        glow.attr(opacity: 0, cursor: 'move')
        set = @paper.set()
        set.push(element)
        set.push(glow)
        set.hover(
            () => glow.attr(opacity: 0.04),
            () => glow.attr(opacity: 0)
        )
        glow.toFront()
        element.toFront()
        return glow
        
    initPropertiesGlow: (element=@image) ->
        element.propertiesGlow.remove() if element.propertiesGlow
        element.attr(cursor: 'pointer')
        if element.forEach
            glow = @paper.set()
            element.forEach (e) => glow.push(e.glow(width: 20, fill: true, color: 'red'))
        else
            glow = element.glow(width: 20, fill: true, color: 'red')
        glow.hide()
        
        element.hover(
            () => glow.show(),
            () => glow.hide() unless element.propertiesDisplayed
        )
        element.propertiesGlow = glow
        return glow
            
    initProperties: (properties, element=@image) ->
        element.properties = JSON.parse(JSON.stringify(properties))
        @initPropertiesGlow(element)

        element.click => @propertiesClick(element)
        return element.propertiesGlow
        
    propertiesClick: (element=@image) =>
        return if element.noClick
        if element.propertiesDisplayed
            element.propertiesGlow.hide()
            @hideProperties(element)
        else
            element.propertiesGlow.show()
            @showProperties(element)
            
    showProperties: (element=@image) ->
        return if element.propertiesDisplayed
        element.propertiesDisplayed = true
        @propertiesArea.find('.nothing_selected').hide()
        (ui = @propertiesArea.find('.object_properties')).show()
        ui.html('')
        for property of element.properties
            ui.append("<p>#{property}: #{element.properties[property].value}</p>")
            
    hideProperties: (element=@image) ->
        return unless element.propertiesDisplayed
        element.propertiesDisplayed = false
        @propertiesArea.find('.object_properties').hide()
        @propertiesArea.find('.nothing_selected').show()
            
class neurobehav.Stimulus extends neurobehav.Object
    objectType: 'stimulus'
    objectName: 'Stimulus'
    imageSrc: 'stimulus_button.png' 
    height: 50
    width: 50
    fullWidth: 100
    
    constructor: ({@voltage}) -> super(arguments...)
    
    init: ->
        @createImage()
        @state = 0
        @setImage()
        @image.click => @toggleState()
        @image.attr(cursor: 'pointer')

        @initSlider()

    initSlider: ->
        @slider = @paper.set()
        
        offset = 9
        radius = 6
        left = @position.left
        right = @position.left + @width
        top = @position.top + @height + offset

        guide = @paper.path("M#{left},#{top}L#{right},#{top}")
        guide.attr
            'stroke': "#ccc"
            'stroke-width': 5
            'stroke-linecap': 'round'
        
        knob = @paper.circle(@position.left, @position.top + @height + offset, radius)
        knob.attr
            cursor: 'move'
            stroke: '#555'
            fill: 'r(0.5, 0.5)#ddd-#666'
        
        lastDeltaX = 0
        deltaX = 0
        onDrag = (dX, dY) =>
            @showProperties(@slider)
            deltaX = lastDeltaX + dX
            deltaX = right - left if deltaX > right - left
            deltaX = 0 if deltaX < 0
            knob.transform("t#{deltaX},#{0}")
            @initPropertiesGlow(@slider)
            @slider.propertiesGlow.show()
            
        onStart = => @slider.noClick = true
        onEnd = =>
            if deltaX
                lastDeltaX = deltaX                
            else
                @slider.noClick = false
            deltaX = 0
            $.timeout 10, => @slider.noClick = false
        
        knob.drag(onDrag, onStart, onEnd)        
            
        @slider.push(guide)
        @slider.push(knob)
        
        properties = 
            'Pulse Rate': {type: 'slider', value: '3'}
        
        @initProperties(properties, @slider)

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
    properties: {}
    
    constructor: ({@threshold, @spike}) -> super(arguments...)
    
    init: -> 
        @synapses = []
        @synapseSpikes = []
        @activeSynapseSpikes = []
        
        @createImage()
        @initProperties(@properties)
            
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
        
        if @activeSynapseSpikes.length
            stillActiveSynapseSpikes = []
            for activeSynapseSpike in @activeSynapseSpikes
                activeSynapseSpike.used += 2
                if activeSynapseSpike.used >= 50
                    @voltage -= activeSynapseSpike.voltage
                else
                    voltageDiff = (activeSynapseSpike.voltage / activeSynapseSpike.used)
                    activeSynapseSpike.voltage -= voltageDiff
                    @voltage -= voltageDiff
                    stillActiveSynapseSpikes.push(activeSynapseSpike)
                    
            @activeSynapseSpikes = stillActiveSynapseSpikes  
                
        for synapseSpike in @synapseSpikes
            voltage = @synapseSpikes.shift() * 3
            @activeSynapseSpikes.push(
                used: 2
                voltage: voltage      
            )      
            @voltage += voltage
            
        if @timeSinceStart > @restTime
            @currentVoltage = @lastVoltage + ((-1 * @lastVoltage) + @voltage * @resistance) / @timeConstant * @timeDelta
                        
            if @currentVoltage >= @threshold
                @currentVoltage += @spike
                @restTime = @timeSinceStart + @refractory
                for synapse in @synapses
                    synapse.connection?.addSynapseSpike(@spike)

        else
            @currentVoltage = (@voltage / 4)
        
    takeReading: -> @currentVoltage
    
    addSynapseSpike: (spike) -> @synapseSpikes.push(spike)
    
    addVoltage: (amount) -> @voltage += amount
    
    createSynapse: (type) ->
        xShift = (if type == 'inhibitory' then -12 else 12)
        endX = @position.left + (@width/2) + xShift
        endY = @position.top + @height + 20
        
        synapse = @paper.path """
            M#{@position.left + (@width/2)},#{@position.top + (@height/2)}
            L#{endX},#{endY}
        """
        synapse.attr
            'stroke-width': 2
        synapse.synapseType = type
        synapse.id = "#{@id}/#{@synapses.length}"        
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

        glow = @initMoveGlow(tip)         
           
        lastDX = 0
        lastDY = 0 
        fullDX = 0
        fullDY = 0
        subPath = null;
        onDrag = (dX, dY) =>
            path = synapse.attr('path')
            fullDX = lastDX + dX 
            fullDY = lastDY + dY
            path[1][1] = endX + fullDX
            path[1][2] = endY + fullDY
            synapse.attr('path', path)
            
            subPath.remove() if subPath
            if synapse.getTotalLength() > @width
                subPath = @paper.path synapse.getSubpath(@width, synapse.getTotalLength())
                subPath.toFront()
            
            glow.transform("t#{fullDX},#{fullDY}")
            glow.attr(opacity: 0.04)
            glow.toFront()

            tip.transform("t#{fullDX},#{fullDY}")
            tip.toFront()
            
        onStart = => 
            @disconnectSynapse(synapse)
            glow.attr(opacity: 0.04)
        
        onEnd = =>
            lastDX = fullDX
            lastDY = fullDY
            for element in @paper.getElementsByPoint(endX + fullDX, endY + fullDY)
                @connectSynapse(synapse, element.object) if element.objectType == 'neuron'
                
        tip.drag(onDrag, onStart, onEnd)
        glow.drag(onDrag, onStart, onEnd)
        @synapses.push(synapse)
    
    connectSynapse: (synapse, neuron) ->
        return unless neuron.objectType == 'neuron'
        synapse.connection = {
            addSynapseSpike: (spike) => 
                spike = spike * -1 if synapse.synapseType == 'inhibitory'
                neuron.addSynapseSpike(spike)
        }
        
    disconnectSynapse: (synapse) -> synapse.connection = null
            

class neurobehav.Oscilloscope extends neurobehav.Object
    objectType: 'oscilloscope'
    imageSrc: 'oscilloscope.png'
    width: 80
    height: 42
    axisLineCount: 5.0
    xDelta: 1
    scale: 100
    
    constructor: ({@container, @range, @threshold}) ->
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
    
    unattach: -> 
        @neuron = null
        @voltageContext.clearRect(0, 0, @canvasWidth, @canvasHeight)
        @firePosition = 0
    
        




