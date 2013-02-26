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
            Replace the word "Hi" with the words "Let's get started!'".
        '''
        editors: [
            {
                title: 'Page HTML'
                type: 'html'
                code: '''
                    <html>
                        <body>
                            <h2>Hi</h2>
                        </body>
                    </html>
                '''
            }
        ]
    }
]
