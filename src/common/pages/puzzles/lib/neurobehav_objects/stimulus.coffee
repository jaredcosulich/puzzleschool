stimulus = exports ? provide('./stimulus', {})
neurobehavObject = require('./object')
slider = require('./slider')

class stimulus.Stimulus extends neurobehavObject.Object
    objectType: 'stimulus'
    objectName: 'Stimulus'
    imageSrc: 'stimulus_button.png' 
    width: 180
    height: 120
    connectionLength: 60
    centerOffset: 30
    propertyList: 
        'voltage': {name: 'Voltage', type: 'slider', unit: 0.25, unitName: 'V', set: 'setSlider' }
        'duration': {name: 'Duration', type: 'slider', unit: 250, max: 10000, unitName: 'msec'}
    
    constructor: ({voltage, duration}) -> 
        super(arguments...)
        @properties.voltage.value = voltage
        @properties.voltage.max = voltage * 2
        @properties.duration.value = duration
        @initProperties()
        @initSlider()

    init: ->
        @draw()
        
        mouseIsDown = false
        minimumMouseDown = true
        @image.mousedown =>
            return unless minimumMouseDown
            minimumMouseDown = false
            setTimeout((
                => 
                    @setState(false) unless mouseIsDown
                    minimumMouseDown = true
            ), @properties.duration.value)
            
            mouseIsDown = true
            @setState(true)

        @image.mouseup => 
            @setState(false) if minimumMouseDown
            mouseIsDown = false
                 
        @image.attr(cursor: 'pointer')

    draw: ->
        @image = @paper.set()
        @button = @paper.circle(@position.left + @centerOffset + 2, @position.top + @centerOffset - 5, @centerOffset)
        @button.attr('stroke-width': 2, fill: 'white')
        @buttonGlow = @paper.circle(@position.left + @centerOffset, @position.top + @centerOffset, @centerOffset)
        @buttonGlow.attr('stroke-width': 1, stroke: '#555', fill: '#555')
        @image.push(@buttonGlow)
        @image.push(@button)
        
        lightStartX = @position.left + (@centerOffset*0.8) + 2
        lightStartY = @position.top + (@centerOffset/2) - 5
        @lightningBolt = @paper.path """
            M#{lightStartX},#{lightStartY}
            L#{lightStartX + (@centerOffset*0.4)},#{lightStartY}}
            L#{lightStartX + (@centerOffset*0.3)},#{lightStartY + (@centerOffset*0.3)}
            L#{lightStartX + (@centerOffset*0.6)},#{lightStartY + (@centerOffset*0.3)}
            L#{lightStartX + (@centerOffset*0.15)},#{lightStartY + (@centerOffset*1.15)}
            L#{lightStartX + (@centerOffset*0.15)},#{lightStartY + (@centerOffset*0.6)}
            L#{lightStartX - (@centerOffset*0.15)},#{lightStartY + (@centerOffset*0.6)}
            L#{lightStartX},#{lightStartY}
        """
        @lightningBolt.attr(fill: 'yellow')
        @image.push(@lightningBolt)
        
        startX = @position.left
        startY = @position.top + @centerOffset
        voltageConnector = @paper.path """
            M#{startX},#{startY}
            L#{startX-(@centerOffset/2)},#{startY}
            L#{startX-(@centerOffset/2)},#{startY + (@centerOffset*2)}
            L#{startX + (@centerOffset/2)},#{startY + (@centerOffset*2)}
            M#{startX + (@centerOffset/2) + 24},#{startY + (@centerOffset*2)}
            L#{startX + (@centerOffset*2)},#{startY + (@centerOffset*2)}
            L#{startX + (@centerOffset*2)},#{startY + (@centerOffset*2.5)}
            M#{startX + (@centerOffset*2) - 12},#{startY + (@centerOffset*2.5)}
            L#{startX + (@centerOffset*2) + 12},#{startY + (@centerOffset*2.5)}
            M#{startX + (@centerOffset*2) - 8},#{startY + (@centerOffset*2.5) + 4}
            L#{startX + (@centerOffset*2) + 8},#{startY + (@centerOffset*2.5) + 4}
            M#{startX + (@centerOffset*2) - 4},#{startY + (@centerOffset*2.5) + 8}
            L#{startX + (@centerOffset*2) + 4},#{startY + (@centerOffset*2.5) + 8}
        """
        voltageConnector.attr('stroke-width': 2)
        
        middleThingy = @paper.path(
            (
                for i in [0...@centerOffset] by 6
                    height = 8 * (((i/6) % 2) + 1)
                    """
                        M#{startX + (@centerOffset/2) + i},#{startY + (@centerOffset*2) + height}
                        L#{startX + (@centerOffset/2) + i},#{startY + (@centerOffset*2) - height}
                    """
            ).join('\n')
        )
        middleThingy.attr('stroke-width': 3)
        @image.push(middleThingy)
        
        
        startingX = startX + @centerOffset*2
        startingY = startY
        connectionSegment = @connectionLength/10
        slope = ((@position.top + (@height/1.5)) - startingY) / ((startingX + (connectionSegment*4)) - (startingX + (@connectionLength)))
        
        endX = startingX + (connectionSegment*5)
        endY = startingY - (slope * connectionSegment)
        connection = @paper.path """
            M#{startingX},#{startingY}
            L#{startingX + (connectionSegment*4)},#{startingY}
            L#{endX},#{endY}
        """
        connection.attr('stroke-width': 2)
        @image.push(connection)
        
        @needle = @paper.path """
            M#{endX - 5},#{endY - (5*(1/slope))}
            L#{(startingX + (@connectionLength))}, #{@position.top + (@height/1.5)}
            L#{endX + 5},#{endY + (5*(1/slope))}
            L#{endX - 5},#{endY - (5*(1/slope))}
        """
        @needle.attr(fill: 'white')
        @image.push(@needle)
        
        innerNeedle = @paper.path """
            M#{endX - 3},#{endY - (3*(1/slope))}
            L#{(startingX + (@connectionLength))}, #{@position.top + (@height/1.5)}
            L#{endX + 3},#{endY + (3*(1/slope))}
        """
        innerNeedle.attr(stroke: '#ccc')
        @image.push(innerNeedle)
        
        super()
        
    initSlider: ->
        @slider = new Slider
            paper: @paper
            x: @position.left
            y: @position.top + @height + 9
            width: @centerOffset*2
            min: 0
            max: @properties.voltage.max
            unit: @properties.voltage.unit
        @slider.set(@properties.voltage.value)    
            
        tempShowProperties = null
        @slider.addListener (val) =>
            @propertiesEditor.show()
            clearTimeout(tempShowProperties) if tempShowProperties
            tempShowProperties = setTimeout((=> @propertiesEditor.hide()), 1500)
            @propertiesEditor.set('voltage', val)
        
    setState: (@on) ->
        if @on
            @buttonGlow.hide()
            @button.attr(fill: 'orange')
            @button.transform('t-2,5')
            @lightningBolt.transform('t-2,5')
        else
            @buttonGlow.show()
            @button.attr(fill: 'white')
            @button.transform('')
            @lightningBolt.transform('')
            
        @neuron.addVoltage(if @on then @properties.voltage.value else (@properties.voltage.value * -1))

    setSlider: (val) -> @slider.set(val)

    connectTo: (@neuron) ->
        @image.toFront()
        @neuron.addVoltage(@properties.voltage.value * (if @on then 1 else 0))
