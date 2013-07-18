battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    centerOffset: 
        x: 10.5
        y: 2
        
    constructor: ({}) ->
        @init()

    init: ->
        