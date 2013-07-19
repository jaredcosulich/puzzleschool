battery = exports ? provide('./battery', {})
circuitousObject = require('./object')

class battery.Battery extends circuitousObject.Object
    powerSource: true
    centerOffset: 
        x: -13
        y: 0
    
    negativeTerminals: [
        {x: 1, y: 50}
    ]
    
    positiveTerminals: [
        {x: 1, y: -46}    
    ]
        
    constructor: ({}) ->
        @init()

    init: ->
       
    currentTerminals: (type) ->
        for terminal in @["#{type}Terminals"]
            {x: @currentX + terminal.x, y: @currentY + terminal.y}