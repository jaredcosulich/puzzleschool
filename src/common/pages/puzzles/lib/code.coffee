code = exports ? provide('./lib/code', {})

class code.ViewHelper    
    constructor: ({@el}) ->
        @initEditors()
        @initDescription()
        @initHints()
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
            
    initSection: (className) ->        
        link = @$(".links .#{className}")
        content = @$("div.#{className}")
        height = content.height()
        content.css(height: 0, display: 'none')
        
        link.bind 'click', ->
            return if content.css('display') == 'block'
            content.css(display: 'block')
            content.animate
                height: height
                duration: 250
                complete: ->
                    $(document.body).one 'click', ->
                        content.animate
                            height: 0
                            duration: 250
                            complete: ->
                                content.css(display: 'none')
                    content.bind 'click', (e) -> e.stop()
            
    initDescription: -> @initSection('description')
        
    initHints: ->
        @initSection('hints')
        for hint in @$('.hints .hint')
            do (hint) ->
                $(hint).find('.reveal').bind 'click', ->
                    $(hint).find('.hint_content').animate
                        opacity: 1
                        duration: 500
            
    setOutput: ->
        for editor in @editors
            @$('.output').attr('src', "data:text/html;charset=utf-8,#{escape(editor.getValue())}")
            