battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    dragBuffer:
        x: 0
        y: 15
    
    centerOffset: 
        x: 16
        y: 16
    
    nodes: [
        {x: -16, y: -48, positive: true}    
        {x: 16, y: -48, negative: true}
    ]

    voltage: 9
        
    constructor: ({}) ->
        @init()

    init: ->