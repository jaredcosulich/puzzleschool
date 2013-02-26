code = exports ? provide('./lib/code', {})

class code.ViewHelper    
    constructor: ({@el}) ->
        @initEditors()
        
    $: (selector) -> @el.find(selector)    
        
    initEditors: ->
        for container in @$('.editors .editor_container')
            editorContainer = $(container)
            editor = ace.edit(editorContainer.find('.editor')[0])

            type = editorContainer.find('.type').html()
            console.log(type)
            editor.getSession().setMode("ace/mode/#{type}")
            