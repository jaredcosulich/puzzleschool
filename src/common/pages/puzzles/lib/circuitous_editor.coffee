circuitousEditor = exports ? provide('./lib/circuitous_editor', {})

class circuitousEditor.EditorHelper
    constructor: ({@el, @viewHelper, @getInstructions, @hashReplacements}) ->
        @init()
        
    $: (selector) -> $(selector, @el)  
        
    init: ->
        @options = new circuitous.Options
            el: @$('.options')
            rows: 5
            columns: 4
            board: @viewHelper.board
        
        @viewHelper.board.addChangeListener => @changeHash()
        
    changeHash: ->
        instructions = @getInstructions()
        escape = (string) -> string.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
        for replaceWith, replace of @hashReplacements
            instructions = instructions.replace(new RegExp(escape(replace), 'g'), replaceWith) 
        location.hash = instructions
        
#{"components": [{"name": "Battery", "position": "9,7"},{"name": "Lightbulb", "position": "10,4"}],"wires": [["10,7","10,6"],["10,6","10,5"],["10,5","10,4"],["10,4","9,4"],["9,4","9,5"],["9,5","9,6"]]}                                      
        
    


