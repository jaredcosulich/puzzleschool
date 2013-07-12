battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    constructor: ({}) ->
        @init()

    init: ->
        