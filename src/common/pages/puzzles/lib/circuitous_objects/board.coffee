board = exports ? provide('./board', {})
circuitousObject = require('./object')

class board.Board extends circuitousObject.Object
    maxUnits: 10

    constructor: ({@el}) ->
        @init()

    init: ->
        