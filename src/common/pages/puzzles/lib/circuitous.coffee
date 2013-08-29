circuitous = exports ? provide('./lib/circuitous', {})

for name, fn of require('./circuitous_objects/index')
    circuitous[name] = fn
    
class circuitous.ChunkHelper
    constructor: () ->
    

class circuitous.ViewHelper
    constructor: ({@el}) ->
        @init()
        
    $: (selector) -> $(selector, @el)
        
    init: ->
        @board = new circuitous.Board
            el: @$('.board')
        
        @options = new circuitous.Options
            el: @$('.options')
            rows: 5
            columns: 4
            board: @board
        