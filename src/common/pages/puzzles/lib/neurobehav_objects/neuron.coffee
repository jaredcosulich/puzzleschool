neuron = exports ? provide('./neuron', {})
neurobehavObject = require('./object')

class neuron.Neuron extends neurobehavObject.Object
    objectType: 'neuron'
    objectName: 'Neuron'
    height: 60
    width: 60
    centerOffset: 30
    properties: {}
    propertyList: 
        'threshold': {name: 'Threshold', type: 'slider', unit: 0.25, max: 3, unitName: 'V', set: 'setThreshold'}
        'spike': {name: 'Spike', type: 'slider', unit: 0.25, max: 3, unitName: 'V'}
        # 'resistance': {name: 'Resistance', type: 'select', unit: 0.25, unitName: 'V', set: 'setSlider' }
        # 'capacitance': {name: 'Capacitance', type: 'select', unit: 250, max: 10000, unitName: 'msec'}
        # 'refractory': {name: 'Refractory', type: 'select', unit: 0.25, unitName: 'V', set: 'setSlider' }
    
    
    constructor: ({@inhibitoryDescription, @excitatoryDescription, threshold, spike}) -> 
        super(arguments...)
        @properties.threshold.value = threshold
        @properties.spike.value = spike
        @initProperties()
                
    init: -> 
        @image = @paper.set()
        @synapses = []
        @synapseSpikes = []
        @activeSynapseSpikes = []
        
        @draw()
            
        ## setup parameters and state variables
        @timeSinceStart = 0
        @restTime       = 0                   # initial refractory time
        @timeDelta      = 0.5

        ## LIF properties
        @resistance     = 1                   # resistance (kOhm)
        @capacitance    = 10                  # capacitance (uF)
        @timeConstant   = @resistance * @capacitance
        @refractory     = 1                  # refractory period (msec)

        @voltage = 0
        @currentVoltage = @voltage
        setInterval(
           (=> @setCurrentVoltage()),
           @periodicity
        )
        
        @createSynapse('excitatory')
        @createSynapse('inhibitory')

    draw: ->
        circle = @paper.circle(@position.left + (@width/2), @position.top + (@height/2), @width/2)
        circle.attr(stroke: '#2B4590', fill: 'r(0.35, 0.35)#8CA0CF-#2B4590')        
        @image.push(circle)
        @tendril(230, (@height/2.5))
        @tendril(260, (@height/3))
        @tendril(320, (@height/2.25))
        @tendril(50, (@height/3.5))
        @tendril(120, (@height/2.5))
        super()
        
    tendril: (angle, length) ->
        rad = angle * Math.PI/180
        radius = @width/2
        centerX = @position.left + radius
        centerY = @position.top + radius
        slope = Math.tan(rad)
        
        xDelta = if angle > 180 then -1 else 1
        yDelta = xDelta / slope
        distance = Math.sqrt(Math.pow(xDelta,2) + Math.pow(yDelta,2))
        units = (radius-6)/distance
        lengthUnits = length/distance
        
        startX = centerX + (xDelta * units)
        startY = centerY - (yDelta * units) 

        perpYDelta = xDelta * slope
        perpDistance = Math.sqrt(Math.pow(xDelta,2) + Math.pow(perpYDelta,2))
        perpUnits = (length/6)/perpDistance
        
        tendril = @paper.path """
            M#{startX + (xDelta*perpUnits)},#{startY + (perpYDelta*perpUnits)}
            L#{startX + (xDelta*lengthUnits) + (xDelta*perpUnits/2)},#{startY - (lengthUnits*yDelta) + (perpYDelta * (perpUnits/2))}
            L#{startX + (xDelta*lengthUnits) - (xDelta*perpUnits/2)},#{startY - (lengthUnits*yDelta) - (perpYDelta * (perpUnits/2))}
            L#{startX - (xDelta*perpUnits)},#{startY - (perpYDelta*perpUnits)}
        """
        tendril.attr(stroke: '#2B4590', fill: "#{360-angle}-#8CA0CF-#2B4590-#8CA0CF")
        @image.push(tendril)

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
                        
            if @currentVoltage >= @properties.threshold.value
                @currentVoltage += @properties.spike.value
                @restTime = @timeSinceStart + @refractory
                for synapse in @synapses
                    synapse.connection?.addSynapseSpike(@properties.spike.value)

        else
            @currentVoltage = (@voltage / 4)
            
    setThreshold: -> $(@).trigger('threshold.change')        
        
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
               
        bbox = tip.getBBox()
        descriptionBubble = new Bubble
            paper: @paper, 
            x: bbox.x + bbox.width
            y: bbox.y + (bbox.height/2)
            width: 240
            height: 240
            position: 'right'
            html: @["#{type}Description"]

        tip.click => 
            if descriptionBubble.visible
                descriptionBubble.hide()
            else
                descriptionBubble.show()
                
        @synapses.push(synapse)
    
    connectSynapse: (synapse, neuron) ->
        return unless neuron.objectType == 'neuron'
        synapse.connection = {
            addSynapseSpike: (spike) => 
                spike = spike * -1 if synapse.synapseType == 'inhibitory'
                neuron.addSynapseSpike(spike)
        }
        
    disconnectSynapse: (synapse) -> synapse.connection = null
