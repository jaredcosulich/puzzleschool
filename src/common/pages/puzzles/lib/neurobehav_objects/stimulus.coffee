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
    buttonRadius: 30
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
        
        mousedown = false
        minimumMouseDown = true
        @image.mousedown =>
            return unless minimumMouseDown
            minimumMouseDown = false
            setTimeout((
                => 
                    @setState(false) unless mousedown
                    minimumMouseDown = true
            ), @properties.duration.value)
            
            mousedown = true
            @setState(true)

        @image.mouseup => 
            @setState(false) if minimumMouseDown
            mousedown = false
                    
        @image.attr(cursor: 'pointer')

    draw: ->
        @image = @paper.set()
        @button = @paper.circle(@position.left + @buttonRadius, @position.top + @buttonRadius, @buttonRadius)
        @button.attr('stroke-width': 4, fill: 'white')
        @image.push(@button)
        
        startX = @position.left
        startY = @position.top + @buttonRadius
        voltageConnector = @paper.path """
            M#{startX},#{startY}
            L#{startX-(@buttonRadius/2)},#{startY}
            L#{startX-(@buttonRadius/2)},#{startY + (@buttonRadius*2)}
            L#{startX + (@buttonRadius/2)},#{startY + (@buttonRadius*2)}
            M#{startX + (@buttonRadius/2) + 24},#{startY + (@buttonRadius*2)}
            L#{startX + (@buttonRadius*2)},#{startY + (@buttonRadius*2)}
            L#{startX + (@buttonRadius*2)},#{startY + (@buttonRadius*2.5)}
            M#{startX + (@buttonRadius*2) - 12},#{startY + (@buttonRadius*2.5)}
            L#{startX + (@buttonRadius*2) + 12},#{startY + (@buttonRadius*2.5)}
            M#{startX + (@buttonRadius*2) - 8},#{startY + (@buttonRadius*2.5) + 4}
            L#{startX + (@buttonRadius*2) + 8},#{startY + (@buttonRadius*2.5) + 4}
            M#{startX + (@buttonRadius*2) - 4},#{startY + (@buttonRadius*2.5) + 8}
            L#{startX + (@buttonRadius*2) + 4},#{startY + (@buttonRadius*2.5) + 8}
        """
        voltageConnector.attr('stroke-width': 2)
        
        middleThingy = @paper.path(
            (
                for i in [0...@buttonRadius] by 6
                    height = 8 * (((i/6) % 2) + 1)
                    """
                        M#{startX + (@buttonRadius/2) + i},#{startY + (@buttonRadius*2) + height}
                        L#{startX + (@buttonRadius/2) + i},#{startY + (@buttonRadius*2) - height}
                    """
            ).join('\n')
        )
        middleThingy.attr('stroke-width': 3)
        
    initSlider: ->
        @slider = new Slider
            paper: @paper
            x: @position.left
            y: @position.top + @height + 9
            width: @width/3
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
        @neuron.addVoltage(if @on then @properties.voltage.value else (@properties.voltage.value * -1))

    setSlider: (val) -> @slider.set(val)

    connectTo: (@neuron) ->
        # @connection = @paper.path """
        #     M#{@position.left + (@width/2)},#{@position.top + (@height/2)}
        #     L#{@neuron.position.left},#{@neuron.position.top + (@neuron.height/2)}
        # """
        # @connection.attr('stroke-width': 2, 'arrow-end': 'block-wide-long')
        # @connection.toBack()
        @neuron.addVoltage(@properties.voltage.value * (if @on then 1 else 0))
