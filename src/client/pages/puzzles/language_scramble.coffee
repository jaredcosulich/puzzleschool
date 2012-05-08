soma = require('soma')
wings = require('wings')

soma.chunks
    LanguageScramble:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@levelName}) ->
            @template = @loadTemplate '/build/client/templates/puzzles/language_scramble.html'
            @loadScript '/build/client/pages/puzzles/language_scramble.js'
            @loadScript '/build/client/pages/puzzles/lib/language_scramble.js'
            @loadStylesheet '/build/client/css/puzzles/language_scramble.css'

        build: ->
            languageScramble = require('./lib/language_scramble')
            
            @user = languageScramble.loadUser()
            @levelName = (@user.lastLevelPlayed or 'top10words') unless @levelName && @levelName.length
            @chunkHelper = new languageScramble.ChunkHelper(@levelName)
            
            @html = wings.renderTemplate(@template, 
                title: @chunkHelper.level.title
                subtitle: @chunkHelper.level.subtitle
                data: @chunkHelper.level.data
                levelName: @levelName
                allLevels: @chunkHelper.allLevels()
            )
        
soma.views
    LanguageScramble:
        selector: '#content .language_scramble'
        create: ->
            languageScramble = require('./lib/language_scramble')

            @levelName = @el.data('level_name')
            @user = languageScramble.loadUser()
            @viewHelper = new languageScramble.ViewHelper($(@selector), @user)

            @viewHelper.setLevel(@levelName)
            @viewHelper.bindWindow()
            @viewHelper.bindKeyPress()
            @viewHelper.newScramble()

soma.routes
    '/puzzles/language_scramble': -> new soma.chunks.LanguageScramble