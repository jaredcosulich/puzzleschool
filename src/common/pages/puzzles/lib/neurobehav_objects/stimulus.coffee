stimulus = exports ? provide('./stimulus', {})
neurobehavObject = require('./object')
slider = require('./slider')

class stimulus.Stimulus extends neurobehavObject.Object
    objectType: 'stimulus'
    objectName: 'Stimulus'
    imageSrc: 'stimulus_button.png' 
    height: 50
    width: 50
    fullWidth: 100
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
        @createImage()
        @setImage()
        
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
            
            @showProperties(@slider)
            mousedown = true
            @setState(true)

        @image.mouseup => 
            @setState(false) if minimumMouseDown
            mousedown = false
                    
        @image.attr(cursor: 'pointer')


    initSlider: ->
        @slider = new Slider
            paper: @paper
            x: @position.left
            y: @position.top + @height + 9
            width: @width
            min: 0
            max: @properties.voltage.max
            unit: @properties.voltage.unit
            val: @properties.voltage.value
            
        tempShowProperties = null
        @slider.addListener (val) =>
            @propertiesEditor.show()
            clearTimeout(tempShowProperties) if tempShowProperties
            tempShowProperties = setTimeout((=> @propertiesEditor.hide()), 1000)
            @propertiesEditor.set('voltage', val)
        
    setState: (@on) ->
        @setImage()
        @neuron.addVoltage(if @on then @properties.voltage.value else (@properties.voltage.value * -1))

    setImage: ->
        # this isn't working in firefox
        @image.attr
            'clip-rect': "#{@position.left}, #{@position.top}, #{@width}, #{@height}"
            transform: "t#{-1 * @width * (if @on then 1 else 0)},0"

    connectTo: (@neuron) ->
        @connection = @paper.path """
            M#{@position.left + (@width/2)},#{@position.top + (@height/2)}
            L#{@neuron.position.left},#{@neuron.position.top + (@neuron.height/2)}
        """
        @connection.attr('stroke-width': 2, 'arrow-end': 'block-wide-long')
        @connection.toBack()
        @neuron.addVoltage(@properties.voltage.value * (if @on then 1 else 0))
