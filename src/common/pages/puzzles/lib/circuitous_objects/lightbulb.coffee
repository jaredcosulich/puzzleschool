lightbulb = exports ? provide('./lightbulb', {})
circuitousObject = require('./object')

class lightbulb.Lightbulb extends circuitousObject.Object
    constructor: ({}) ->
        @init()

    init: ->
