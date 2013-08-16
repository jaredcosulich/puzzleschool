lightbulb = exports ? provide('./lightbulb', {})
circuitousObject = require('./object')

class lightbulb.Lightbulb extends circuitousObject.Object
    resistance: 5
    centerOffset: 
        x: 0
        y: 25
        
    nodes: [
        {x: 0, y: 39}
    ]
        
    constructor: ({}) ->
        @init()

    init: ->
        
    setCurrent: (@current) ->
        if @current
            @el.css(backgroundColor: 'yellow')
        else
            @el.css(backgroundColor: null)
        
