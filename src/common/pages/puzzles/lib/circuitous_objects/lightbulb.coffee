lightbulb = exports ? provide('./lightbulb', {})
circuitousObject = require('./object')

class lightbulb.Lightbulb extends circuitousObject.Object
    resistance: 5
    centerOffset: 
        x: -12
        y: -15
        
    nodes: [{x: 0, y: 33}]
    soloNode: true
        
    constructor: ({}) ->
        @init()

    init: ->
