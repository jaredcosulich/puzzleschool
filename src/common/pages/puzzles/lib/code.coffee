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
        
        @allTestsPassed = false
        window.retest = => @test()
        
        @errors = []
        
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
                # editorContainer.height(@$('.output').height() - (editorContainer.offset().top - @$('.editors').offset().top))
                editorContainer.find('.editor_header').bind 'click', => @selectEditor(editor)
                
                editor.container = editorContainer
            
                aceEditor = ace.edit(editorContainer.find('.editor')[0])

                aceEditor.setValue(editor.code)
                aceEditor.clearSelection()
                aceEditor.setBehavioursEnabled(false)

                session = aceEditor.getSession()
                session.setMode("ace/mode/#{editor.type}")
                session.on 'change', (e) => 
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
                    $(document.body).one 'mouseup', ->
                        link.removeClass('selected')
                        content.animate
                            height: 0
                            duration: 250
                            complete: ->
                                content.css(display: 'none')
                    content.bind 'mouseup', (e) -> e.stop()
            
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
        testArea = @$('.test_area')
        tests = testArea.find('.tests')
        testArea.css(top: @$('.output').offset().top - @el.offset().top)
        for testInfo in @level.tests
            do (testInfo) =>
                tests.append """
                    <p class='test wrong'>#{testInfo.description}</p>
                """
        setTimeout((=>
            @testHeight = tests.height()            
            testArea.find('.run_tests').bind 'click', => 
                if @$('.test_area .tests').height() > 0
                    @hideTests()
                else
                    @showTests()
                    
            testArea.find('.rerun_tests').bind 'click', => @test(true)

            @hideTests()
        ), 1000)
                
    showTests: (callback) ->
        testArea = @$('.test_area')
        tests = testArea.find('.tests')
        if tests.height() == @testHeight
            callback() if callback
        else
            tests.animate
                height: @testHeight
                duration: 500
                complete: => 
                    callback() if callback
                    @test(true)
                    testArea.find('.run_tests').html('Hide Tests')
                    testArea.find('.rerun_tests').show()
                
    hideTests: ->
        testArea = @$('.test_area')
        testArea.find('.tests').animate
            height: 0
            duration: 500
            complete: => 
                testArea.find('.run_tests').html('Run Tests')
                testArea.find('.rerun_tests').hide()
                
    showError: (msg, line) ->
        error = @$('.error')
        error.html("<p>There is an error in your code on line #{line}:<br/><br/>#{msg}</p>")       

        if not @showingError
            @showingError = setTimeout((=>
                elOffset = @el.offset()
                frameOffset = @$('.output').offset()
                height = error.height()
                return if error.css('top') > -1000
                error.css
                    top: frameOffset.top - elOffset.top
                    left: frameOffset.left - elOffset.left + 72
                    height: 0
                error.animate
                    height: height
                    duration: 500
            ), 500)
        
    hideError: ->
        if @showingError
            clearTimeout(@showingError)
            @showingError = null
            
        error = @$('.error')
        error.animate
            height: 0
            duration: 500
            complete: =>
                error.css
                    top: -1000
                    left: -1000
                    height: 'auto'
        
    
    setOutput: ->
        if @errorShown
            setTimeout((=>
                @hideError() unless @errorShown
            ), 50)
        
        @errorShown = false

        frameDoc = @$('.output')[0].contentWindow.document
        frameDoc.open()

        baseHTML = (editor for editor in @level.editors when editor.type == 'html')[0].aceEditor.getValue()
        script = '''
            <script type='text/javascript' charset='utf8'>
                window.onerror = function(msg, url, line) {
                    window.top.sendError(msg, url, line);
                }
            </script>        
        '''
        if baseHTML.indexOf('<head>') > -1
            baseHTML = baseHTML.replace(/\<head\>/i, "<head>#{script}")
        else
            baseHTML = baseHTML.replace(/\<html\>/i, "<html><head>#{script}</head>")
        
        frameDoc.write(baseHTML)
        
        for editor in @level.editors
            if editor.type == 'javascript'
                script = $(document.createElement('SCRIPT'))
                script.attr('type', 'text/javascript')
                script.html(editor.aceEditor.getValue())
                $(frameDoc.head).append(script)
            if editor.type == 'css'
                style = $(document.createElement('STYLE'))
                style.attr('type', 'text/css')
                style.attr('rel', 'stylesheet')                
                style.html(editor.aceEditor.getValue())
                $(frameDoc.head).append(style)

        frameDoc.close()
        
        window.sendError = (msg, url, line) =>
            @errorShown = true
            @showError(msg, line)
                    
    test: (userSubmitted=false) ->
        return if @allTestsPassed
        
        frame = @$('.output')[0]
        frameWindow = frame.contentWindow
        frameDoc = frameWindow.document
        frameBody = $(frameDoc.body)
        cleanHtml = (html) ->
            html.replace(/^\s*/, '').replace(/\s*$/, '').replace(/\s*\n\s*/, ' ').toLowerCase()

        allTestsPassed = true
        for testInfo in @level.tests
            for testElement in @$('.tests .test') when $(testElement).html() == testInfo.description
                success = testInfo.test
                    frameWindow: frame.contentWindow
                    frameBody: frameBody
                    cleanHtml: cleanHtml
                    userSubmitted: userSubmitted
                
                if success
                    $(testElement).removeClass('wrong')
                    $(testElement).addClass('correct')
                else
                    allTestsPassed = false
                    $(testElement).removeClass('correct')
                    $(testElement).addClass('wrong')
                
        if allTestsPassed        
            @allTestsPassed = true
            @showTests => @completeLevel()

        