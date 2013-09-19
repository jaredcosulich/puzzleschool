battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    dragBuffer:
        top: 15
    
    centerOffset: 
        x: 16
        y: 35
    
    nodes: [
        {x: -16, y: -35, positive: true}    
        {x: 16, y: -35, negative: true}
    ]

    voltage: 9
        
    constructor: ({@recordChange}) ->
        @init()

    init: ->
        
    appendTo: (container) ->
        super(container)
        @setVoltage(@voltage)        

    getInfo: ->
        
    setVoltage: (@voltage) ->
        @recordChange() if @recordChange
        return unless @el
        unless @voltageElement
            @voltageElement = $(document.createElement('DIV'))
            @voltageElement.addClass('voltage')
            @el.append(@voltageElement)
        
        @voltageElement.html("#{@voltage}V")
        