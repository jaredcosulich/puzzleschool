battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    powerSource: true
    centerOffset: 
        x: 0
        y: 16
    
    negativeTerminals: [
        {x: 0, y: 48}
    ]
    
    positiveTerminals: [
        {x: 0, y: -48}    
    ]

    voltage: 9
        
    constructor: ({}) ->
        @init()

    init: ->
       
    currentTerminals: (type) ->
        for terminal in @["#{type}Terminals"]
            {x: @currentX + terminal.x, y: @currentY + terminal.y}