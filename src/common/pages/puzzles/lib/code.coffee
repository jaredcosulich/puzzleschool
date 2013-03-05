code = exports ? provide('./lib/code', {})

class code.ViewHelper    
    constructor: ({@el, @completeLevel}) ->
        
    $: (selector) -> @el.find(selector)    
        
    initLevel: (@level) ->
        @initChallenge()
        @initDescription()
        @initHints()
        @initTests()
        @initEditors()    
        @setOutput()
        
        window.retest = => @test()
        
    initEditors: ->
        @editors = []
        for editor in @level.editors
            do (editor) =>
                editorContainer = $(document.createElement('DIV'))
                editorContainer.addClass('editor_container')
                editorContainer.html """
                    <div class='editor_header'>
                        <div class='type'>#{editor.type}</div>
                        <div class='title'>#{editor.title}</div>
                    </div>
                    <div class='editor'></div>
                """
                @$('.editors').append(editorContainer)
                editorContainer.find('.editor_header').bind 'click', => @selectEditor(editor)
                
                editor.container = editorContainer
            
                aceEditor = ace.edit(editorContainer.find('.editor')[0])

                aceEditor.getSession().setMode("ace/mode/#{editor.type}")
                aceEditor.setValue(editor.code)
                aceEditor.clearSelection()
                aceEditor.getSession().on 'change', (e) => 
                    @setOutput()
                    @test()
                    
                editor.aceEditor = aceEditor
        
        @selectEditor(@level.editors[0])
            
    selectEditor: (editor) ->
        for editorContainer in @$('.editor_container')
            editorContainer = $(editorContainer)
            editorContainer.removeClass('selected')
            if editorContainer.find('.title').html() == editor.container.find('.title').html()
                editor.container.addClass('selected')
            else
                @$('.editors').prepend(editorContainer)                
    
    initChallenge: ->
        @$('.challenge .text').html("<b>The Challenge</b>: #{@level.challenge}")
            
    initSection: (className) ->        
        link = @$(".links .#{className}")
        content = @$("div.#{className}")
        height = content.height()
        content.css(height: 0, display: 'none')
        
        link.bind 'click', ->
            return if content.css('display') == 'block'
            content.css(display: 'block')
            link.addClass('selected')
            content.animate
                height: height
                duration: 250
                complete: ->
                    $(document.body).one 'click', ->
                        link.removeClass('selected')
                        content.animate
                            height: 0
                            duration: 250
                            complete: ->
                                content.css(display: 'none')
                    content.bind 'click', (e) -> e.stop()
            
    initDescription: -> 
        @$('div.description .inside').html(@level.description)
        @initSection('description')
        
    initHints: ->
        for hint, index in @level.hints
            do (hint) ->
                hintElement = $(document.createElement('DIV'))
                hintElement.addClass('hint')
                hintElement.html """
                    <a class='reveal'>Reveal Hint #{index + 1}</a>
                    <p class='hint_content'>#{hint}</p>
                """
                @$('div.hints .inside').append(hintElement)
                hintElement.find('.reveal').bind 'click', ->
                    hintElement.find('.hint_content').animate
                        opacity: 1
                        duration: 500
        
        @initSection('hints')
            
    initTests: ->
        for testInfo in @level.tests
            do (testInfo) =>
                @$('div.tests .inside').prepend """
                    <p class='test wrong'>#{testInfo.description}</p>
                """
        
        @initSection('tests')
    
    setOutput: ->
        frameDocElement = $(@$('.output')[0].contentDocument.documentElement)
        baseHTML = (editor for editor in @level.editors when editor.type == 'html')[0].aceEditor.getValue()
        frameDocElement.html(baseHTML)
        for editor in @level.editors
            if editor.type == 'javascript'
                script = $(document.createElement('SCRIPT'))
                script.attr('type', 'text/javascript')
                script.html(editor.aceEditor.getValue())
                frameDocElement.find('head').append(script)
            if editor.type == 'css'
                style = $(document.createElement('STYLE'))
                style.attr('type', 'text/css')
                style.attr('rel', 'stylesheet')                
                style.html(editor.aceEditor.getValue())
                frameDocElement.find('head').append(style)
                    
    test: ->
        frame = @$('.output')[0]
        frameDoc = frame.contentDocument || frame.contentWindow.document
        frameBody = $(frameDoc.body)
        cleanHtml = (html) ->
            html.replace(/^\s*/, '').replace(/\s*$/, '').replace(/\s*\n\s*/, ' ').toLowerCase()

        allTestsPassed = true
        for testInfo in @level.tests
            for testElement in @$('.tests .test') when $(testElement).html() == testInfo.description
                if testInfo.test(body: frameBody, cleanHtml: cleanHtml)
                    $(testElement).removeClass('wrong')
                    $(testElement).addClass('correct')
                else
                    allTestsPassed = false
                    $(testElement).removeClass('correct')
                    $(testElement).addClass('wrong')
                
        @completeLevel() if allTestsPassed
        

        