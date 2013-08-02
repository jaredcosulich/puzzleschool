battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    powerSource: true
    centerOffset: 
        x: 0
        y: 16
    
    nodes: [
        {x: 0, y: -48, positive: true}    
        {x: 0, y: 48, negative: true}
    ]

    voltage: 9
        
    constructor: ({}) ->
        @init()

    init: ->