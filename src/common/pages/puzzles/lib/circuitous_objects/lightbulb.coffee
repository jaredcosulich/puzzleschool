lightbulb = exports ? provide('./lightbulb', {})
circuitousObject = require('./object')

class lightbulb.Lightbulb extends circuitousObject.Object
    resistance: 5
    centerOffset: 
        x: -16
        y: 25
        
    nodes: [
        {x: -16, y: 39}
        {x: 16, y: 39}
    ]
        
    constructor: ({}) ->
        @init()

    init: ->
        
    setCurrent: (@current) ->
        if @current > 0
            @el.css(backgroundColor: 'yellow')
        else
            @el.css(backgroundColor: null)
        
