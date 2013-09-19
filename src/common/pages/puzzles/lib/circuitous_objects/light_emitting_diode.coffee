lightEmittingDiode = exports ? provide('./light_emitting_diode', {})
circuitousObject = require('./object')

class lightEmittingDiode.LightEmittingDiode extends circuitousObject.Object
    resistance: 5
    centerOffset: 
        x: -16
        y: 25
        
    nodes: [
        {x: 16, y: 39, negative: true}
        {x: -16, y: 39, positive: true}
    ]
        
    constructor: ({@recordChange}) ->
        @init()

    init: ->
        
    setCurrent: (@current) ->
        if @current
            @el.css(backgroundColor: 'yellow')
        else
            @el.css(backgroundColor: null)
        
