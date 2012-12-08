stimulus = exports ? provide('./stimulus', {})
neurobehavObject = require('./object')

class stimulus.Stimulus extends neurobehavObject.Object
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
        @duration = 3000

    initSlider: ->
        @slider = @paper.set()
        @slider.objectType = @objectType
        @slider.objectName = @objectName
        
        value = 1.5
        unit = 0.25
        range = 3 / unit
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
            @showProperties(@slider)
            deltaX = lastDeltaX + dX
            deltaX = right - left if deltaX > right - left
            deltaX = 0 if deltaX < 0
            deltaX = voltage(deltaX)
            @setProperty('voltage', (voltage(deltaX)/segment)*unit)
            knob.transform("t#{deltaX},#{0}")
            @initPropertiesGlow(@slider)
            @slider.propertiesGlow.show()
            
        onStart = => @slider.noClick = true
        onEnd = =>
            if deltaX
                @setProperty('voltage', (voltage(deltaX)/segment)*unit)
                lastDeltaX = deltaX                
            else
                @slider.noClick = false
            deltaX = 0
            $.timeout 10, => @slider.noClick = false
        
        knob.drag(onDrag, onStart, onEnd)        
            
        @slider.push(guide)
        @slider.push(knob)
        
        properties = 
            'voltage': {name: 'Voltage', type: 'slider', value: '1.5'}
            'duration': {name: 'Duration', type: 'slider', value: '10'}
        
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
