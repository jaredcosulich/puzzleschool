neuron = exports ? provide('./neuron', {})
neurobehavObject = require('./object')

class neuron.Neuron extends neurobehavObject.Object
    objectType: 'neuron'
    objectName: 'Neuron'
    imageSrc: 'neuron.png' 
    height: 60
    width: 60
    properties: {}
    propertyList: 
        'threshold': {name: 'Threshold', type: 'select', unit: 0.25, max: 3, unitName: 'V', set: 'setThreshold'}
        'spike': {name: 'Spike', type: 'select', unit: 0.25, max: 3, unitName: 'V'}
        # 'resistance': {name: 'Resistance', type: 'select', unit: 0.25, unitName: 'V', set: 'setSlider' }
        # 'capacitance': {name: 'Capacitance', type: 'select', unit: 250, max: 10000, unitName: 'msec'}
        # 'refractory': {name: 'Refractory', type: 'select', unit: 0.25, unitName: 'V', set: 'setSlider' }
    
    
    constructor: ({inhibitoryDescription, excitatoryDescription, threshold, spike}) -> 
        super(arguments...)
        @properties.threshold.value = threshold
        @properties.spike.value = spike
        @inhibitoryProperties = {description: inhibitoryDescription}
        @excitatoryProperties = {description: excitatoryDescription}
        @initProperties()
                
    init: -> 
        @synapses = []
        @synapseSpikes = []
        @activeSynapseSpikes = []
        
        @createImage()
        # @initProperties(@properties)
            
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
        @synapses.push(synapse)
    
    connectSynapse: (synapse, neuron) ->
        return unless neuron.objectType == 'neuron'
        synapse.connection = {
            addSynapseSpike: (spike) => 
                spike = spike * -1 if synapse.synapseType == 'inhibitory'
                neuron.addSynapseSpike(spike)
        }
        
    disconnectSynapse: (synapse) -> synapse.connection = null
