code = exports ? provide('./lib/code', {})

class code.ViewHelper    
    constructor: ({@el, @completeLevel}) ->
        @initEditors()
        @initDescription()
        @initHints()
        @initTests()
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
            
    initDescription: -> @initSection('description')
        
    initHints: ->
        @tests = {}
        @initSection('hints')
        for hint in @$('.hints .hint')
            do (hint) ->
                $(hint).find('.reveal').bind 'click', ->
                    $(hint).find('.hint_content').animate
                        opacity: 1
                        duration: 500
            
    initTests: ->
        @initSection('tests')
        
        frameBody = =>
            frame = @$('.output')[0]
            frameDoc = frame.contentDocument || frame.contentWindow.document
            $(frameDoc.body)
            
        frameFind = (selector) => 
            frameBody().find(selector)

        for test in @$('.tests .test')
            do (test) =>
                @tests[$(test).html()] = -> 
                    try
                        eval(unescape($(test).data('test')))
                    catch e 
                        alert("A test failed to run: #{e.message}")
        
    setOutput: ->
        for editor in @editors
            $(@$('.output')[0].contentDocument.documentElement).html(editor.getValue())
            
        allTestsPassed = true
        for html, test of @tests
            for testElement in @$('.tests .test') when $(testElement).html() == html
                if test()
                    $(testElement).removeClass('wrong')
                    $(testElement).addClass('correct')
                else
                    allTestsPassed = false
                    $(testElement).removeClass('correct')
                    $(testElement).addClass('wrong')
                
        @success() if allTestsPassed

    success: ->
        setTimeout((=>
            @completeLevel()
        ), 50)
        
        