circuitousEditor = exports ? provide('./lib/circuitous_editor', {})

class circuitousEditor.EditorHelper
    constructor: ({@el}) ->
        @initOptions()
                                      
    $: (selector) -> $(selector, @el)
    
    initOptions: ->
        @board = new circuitous.Board
            el: @$('.board')
            cellDimension: 32
        
        @options = new circuitous.Options
            el: @$('.options')
            rows: 5
            columns: 4
            board: @board
        
    


