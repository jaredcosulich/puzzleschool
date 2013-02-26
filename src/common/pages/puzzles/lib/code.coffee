code = exports ? provide('./lib/code', {})

class code.ViewHelper    
    constructor: ({@el}) ->
        @initEditors()
        @setOutput()
        
        
    $: (selector) -> @el.find(selector)    
        
    initEditors: ->
        @editors = []
        for container in @$('.editors .editor_container')
            editorContainer = $(container)
            editor = ace.edit(editorContainer.find('.editor')[0])

            type = editorContainer.find('.type').html()
            editor.getSession().setMode("ace/mode/#{type}")
            editor.getSession().on 'change', (e) => @setOutput()
            @editors.push(editor)
            
    setOutput: ->
        for editor in @editors
            @$('.output').attr('src', "data:text/html;charset=utf-8,#{escape(editor.getValue())}")
            