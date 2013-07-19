resistor = exports ? provide('./resistor', {})
circuitousObject = require('./object')

class resistor.Resistor extends circuitousObject.Object
    resistance: 10
    
    constructor: ({}) ->
        @init()

    init: ->
