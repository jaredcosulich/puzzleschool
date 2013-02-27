soma = require('soma')
wings = require('wings')

soma.chunks
    Code:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/code.html"
            
            @loadScript 'http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/ace.js'
            @loadScript '/build/common/pages/puzzles/lib/code.js'

            @loadStylesheet '/build/client/css/puzzles/code.css'     

            if @levelId
                for stage in STAGES
                    @level = (level for level in stage.levels when level.id == @levelId)[0]
                    break if @level
            else
                @level = STAGES[0].levels[0]
            
        build: ->
            @setTitle("Code Puzzles - The Puzzle School")
            
            @html = wings.renderTemplate(@template,
                level: @level.id
                challenge: @level.challenge
                editors: @level.editors
                description: @level.description
                hints: @level.hints
                tests: @level.tests
                stages: STAGES
            )
        
soma.views
    Code:
        selector: '#content .code'
        create: ->
            code = require('./lib/code')
        
            @levelId = @el.data('level')
        
            @helper = new code.ViewHelper
                el: @el
                completeLevel: => @completeLevel()

            @initLevelSelector()

        initLevelSelector: ->
            @levelSelector = @$('.level_selector')
            for level in @levelSelector.find('.level')
                level = $(level)
                level.bind 'click', =>
                    window.location.href = '/puzzles/code/' + level.data('id')
                
        completeLevel: ->
            levelIcon = @$("#level_#{@levelId}").find('img')
            levelIcon.attr('src', levelIcon.attr('src').replace('level', 'level_complete'))
            @showLevelSelector()
            
        showLevelSelector: ->
            @levelSelector.css
                opacity: 0
                top: 100
                left: (@el.width() - @levelSelector.width()) / 2
            @levelSelector.animate
                opacity: 1
                duration: 250
                    
            
soma.routes
    '/puzzles/code/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Code
            classId: classId
            levelId: levelId

    '/puzzles/code/:levelId': ({levelId}) -> 
        new soma.chunks.Code
            levelId: levelId
    
    '/puzzles/code': -> new soma.chunks.Code


STAGES = [
    {
        name: 'Basic HTML'
        levels: [
            {
                id: '1361991179382'
                challenge: '''
                    Figure out how to change the word "Welcome" to the word "Hello World'".
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                                <body>
                                    <h1>Welcome</h1>
                                </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        The code displayed in the 'editor' (where it says 'Page HTML') 
                        is all the code you need to create the simplest website.
                    </p>
                    <p>
                        The &lt;h1&gt; is used to designate important information and so is displayed in
                        bold large text.
                    </p>
                    <p>
                        You can learn more about the &lt;h1&gt; tag by googling:
                        <a href='https://www.google.com/search?q=h1+tag' target='_blank'>'h1 tag'</a>.
                    </p>
                '''
                hints: [
                    {index: 1, content: 'The \'editor\', where you see the words \'Page HTML\' is editable.'}
                    {index: 2, content: 'In the editor, change the word \'Welcome\' to \'Hello World\''}
                ]
                tests: [
                    {
                        description: 'The content contains an &lt;h1&gt; tag with html content \'Hello World\'.'
                        test: escape("frameFind('h1').html() == 'Hello World'")
                    }
                ]
            },
            {
                id: '1361991210187'
                challenge: '''
                    Figure out how to print the words 'html tags are easy' in an &lt;h1&gt; tag.
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                                <body>
                        
                                </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        Here we've removed the tag from the body of the html.
                    </p>
                    <p>
                        You simply need to put it back and don't forget to close the tag.
                    </p>
                '''
                hints: [
                    {index: 1, content: 'Create a new &lt;h1&gt; tag by typing "&lt;h1&gt;" between &lt;body&gt; and &lt;/body&gt;'}
                    {index: 2, content: 'You need to close the &lt;h1&gt; tag with a closing tag.'}
                    {index: 3, content: 'The closing tag looks like &lt;/h1&gt;'}
                ]
                tests: [
                    {
                        description: 'The content contains an &lt;h1&gt; tag with html content \'html tags are easy\'.'
                        test: escape("frameFind('h1').html() == 'html tags are easy'")
                    }
                    {
                        description: 'The &lt;h1&gt; tag is properly closed.'
                        test: escape("frameBody().html().indexOf('</h1>') > -1")
                    }
                ]
            },
            {
                id: '1361997759104'
                challenge: '''
                    Figure out how to change the smallest text to 'this is the smallest header'.
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                                <body>
                                    <h2>This is a header</h2>
                                    <h4>This is a header</h4>
                                    <h6>This is a header</h6>
                                    <h1>This is a header</h1>
                                    <h5>This is a header</h5>
                                    <h3>This is a header</h3>
                                </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        Here is a simply demo of all of the available header tags.
                    </p>
                    <p>
                        As you can see they range in size, designating the intent to show important information.
                    </p>
                '''
                hints: [
                    {index: 1, content: 'The &lt;h4&gt; is smaller than the &lt;h3&gt; tag.'}
                    {index: 2, content: 'Change the text inside the &lt;h6&gt; tag.'}
                ]
                tests: [
                    {
                        description: 'The header with the smallest text size contains the text \'this is the smallest header\'.'
                        test: escape("frameFind('h6').html() == 'this is the smallest header'")
                    }
                ]
            }
        ]
    }
]
