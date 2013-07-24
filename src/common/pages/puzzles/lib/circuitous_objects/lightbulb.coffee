lightbulb = exports ? provide('./lightbulb', {})
circuitousObject = require('./object')

class lightbulb.Lightbulb extends circuitousObject.Object
    resistance: 5
    centerOffset: 
        x: 0
        y: 31
        
    nodes: [{x: 0, y: 33}]
        
    constructor: ({}) ->
        @init()

    init: ->
        
    setCurrent: (@current) ->
        if @current > 0
            @el.css(backgroundColor: 'yellow')
        else
            @el.css(backgroundColor: null)
        
