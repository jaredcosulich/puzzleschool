circuitousEditor = exports ? provide('./lib/circuitous_editor', {})

class circuitousEditor.EditorHelper
    constructor: ({@el}) ->
        @initOptions()
                                      
    $: (selector) -> $(selector, @el)
    
    initOptions: ->
        @options = new circuitous.Options
            el: @$('.options')
            rows: 5
            columns: 4
        
    


