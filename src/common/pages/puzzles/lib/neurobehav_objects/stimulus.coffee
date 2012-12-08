stimulus = exports ? provide('./stimulus', {})
neurobehavObject = require('./object')

class stimulus.Stimulus extends neurobehavObject.Object
    objectType: 'stimulus'
    objectName: 'Stimulus'
    imageSrc: 'stimulus_button.png' 
    height: 50
    width: 50
    fullWidth: 100
    propertyList: 
        'voltage': {name: 'Voltage', unit: 0.25, unitName: 'V'}
        'duration': {name: 'Duration', unit: 1000, max: 10000, unitName: 'msec'}
    
    constructor: ({voltage, duration}) -> 
        @properties = JSON.parse(JSON.stringify(@propertyList))
        @properties.voltage.value = voltage
        @properties.voltage.max = voltage * 2
        @properties.duration.value = duration
        super(arguments...)

    init: ->
        @createImage()
        @setImage()
        
        mousedown = false
        minimumMouseDown = false
        @image.mousedown =>
            @propertiesClick(@slider, true)
            mousedown = true
            @setState(true)

            minimumMouseDown = false
            setTimeout((
                => 
                    @setState(false) unless mousedown
                    minimumMouseDown = true
            ), @properties.duration.value)
            

        @image.mouseup => 
            @setState(false) if minimumMouseDown
            mousedown = false
            
        @image.attr(cursor: 'pointer')

        @initSlider()

    initSlider: ->
        @slider = @paper.set()
        @slider.objectType = @objectType
        @slider.objectName = @objectName
        
        value = @properties.voltage.value
        unit = @properties.voltage.unit
        range = @properties.voltage.max / unit
        offset = 9
        radius = 6
        left = @position.left
        right = @position.left + @width
        top = @position.top + @height + offset
        segment = @width / range

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
        
        lastDeltaX = (segment * value)/unit
        deltaX = 0
        voltage = (dX) -> segment * Math.round(dX/segment)
        knob.transform("t#{lastDeltaX},0")

        onDrag = (dX, dY) =>
            deltaX = lastDeltaX + dX
            deltaX = right - left if deltaX > right - left
            deltaX = 0 if deltaX < 0
            deltaX = voltage(deltaX)
            knob.transform("t#{deltaX},#{0}")
            @initPropertiesGlow(@slider)
            @propertiesClick(@slider, true)
            @propertyUI.set('voltage', (voltage(deltaX)/segment)*unit)
            
        onStart = => @slider.noClick = true
            
        onEnd = =>
            if deltaX
                @propertyUI.set('voltage', (voltage(deltaX)/segment)*unit)
                lastDeltaX = deltaX                
            else
                @slider.noClick = false
            deltaX = 0
            $.timeout 10, => @slider.noClick = false
        
        knob.drag(onDrag, onStart, onEnd)        
            
        @slider.push(guide)
        @slider.push(knob)
                
        @initProperties(@properties, @slider)

    setState: (@on) ->
        @setImage()
        @neuron.addVoltage(if @on then @properties.voltage.value else (@properties.voltage.value * -1))

    setImage: ->
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
