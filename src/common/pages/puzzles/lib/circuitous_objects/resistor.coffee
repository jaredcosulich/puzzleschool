resistor = exports ? provide('./resistor', {})
circuitousObject = require('./object')

class resistor.Resistor extends circuitousObject.Object
    constructor: ({}) ->
        @init()

    init: ->
