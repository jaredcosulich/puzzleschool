battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    dragBuffer:
        top: 15
    
    centerOffset: 
        x: 17
        y: 22
    
    nodes: [
        {x: -17, y: -54, positive: true}    
        {x: 15, y: -54, negative: true}
    ]

    voltage: 9
        
    constructor: ({}) ->
        @init()

    init: ->