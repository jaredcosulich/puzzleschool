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

            @level = LEVELS[1]
            
                      
        build: ->
            @setTitle("Code Puzzles - The Puzzle School")
            
            @html = wings.renderTemplate(@template, 
                challenge: @level.challenge
                editors: @level.editors
                description: @level.description
                hints: @level.hints
                tests: @level.tests
            )
            
        
soma.views
    Code:
        selector: '#content .code'
        create: ->
            code = require('./lib/code')
        
            @helper = new code.ViewHelper
                el: @el

        nextLevel: ->
            console.log('NEXT LEVEL')
                
            
soma.routes
    '/puzzles/code/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Code
            classId: classId
            levelId: levelId

    '/puzzles/code/:levelId': ({levelId}) -> 
        new soma.chunks.Code
            levelId: levelId
    
    '/puzzles/code': -> new soma.chunks.Code


LEVELS = [
    {},
    {
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
                            <h1>Hi</h1>
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
                You can learn more about the &lt;h1&gt; tag by 
                <a href='https://www.google.com/search?q=h1+tag' target='_blank'>Googling 'h1 tag'</a>.
            </p>
        '''
        hints: [
            {index: 1, content: 'The \'editor\', where you see the words \'Page HTML\' is editable.'}
            {index: 2, content: 'In the editor, change the word \'Welcome\' to \'Hello World\''}
        ]
        tests: [
            {
                description: 'The content contains an &lt;h1&gt; element with html content \'Hello World\'.'
                test: escape("find('h1').html() == 'Hello World'")
            }
        ]
    }
]
