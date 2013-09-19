resistor = exports ? provide('./resistor', {})
circuitousObject = require('./object')

class resistor.Resistor extends circuitousObject.Object
    resistance: 10
    
    centerOffset: 
        x: 0
        y: 16
        
    nodes: [
        {x: 0, y: -48}
        {x: 0, y: 48}
    ]
    
    constructor: ({@recordChange}) ->
        @init()

    init: ->
