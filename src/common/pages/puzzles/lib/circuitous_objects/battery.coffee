battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    powerSource: true
    centerOffset: 
        x: -13
        y: 0
    
    powerNodes: [
        {x: 1, y: 50}
    ]
        
    constructor: ({}) ->
        @init()

    init: ->
        