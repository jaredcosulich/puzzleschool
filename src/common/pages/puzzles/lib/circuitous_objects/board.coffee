board = exports ? provide('./board', {})
circuitousObject = require('./object')

class board.Board extends circuitousObject.Object
    cellDimension: 20
    
    constructor: ({@el}) ->
        @init()

    init: ->
        @width = @el.width()
        @height = @el.height()
        @drawGrid()
    
    drawGrid: ->
        rows = @height / @cellDimension
        columns = @width / @cellDimension
        for row in [1..rows]
            for column in [1..columns]
                cell = $(document.createElement('DIV'))
                cell.addClass('cell')
                cell.css(width: @cellDimension-1, height: @cellDimension-1)
                @el.append(cell)