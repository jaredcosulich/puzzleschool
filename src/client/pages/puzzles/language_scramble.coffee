soma = require('soma')
wings = require('wings')

loadUser = (user={}) ->
    console.log("LOADING", user)
    user.name = 'guest' unless user.name?
    user.levels = {} unless user.levels?
    return user

soma.chunks
    LanguageScramble:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@languages, @levelName}) ->
            @template = @loadTemplate '/build/client/templates/puzzles/language_scramble.html'
            @loadScript '/build/client/pages/puzzles/language_scramble.js'
            @loadScript '/build/client/pages/puzzles/lib/language_scramble.js'
            @loadStylesheet '/build/client/css/puzzles/language_scramble.css'

        build: ->
            languageScramble = require('./lib/language_scramble')
            
            @user = loadUser(@cookies.get('user'))
            @languages = (@user.lastLanguages or 'english_italian') unless @languages && @languages.length
            @levelName = (@user.lastLevelPlayed or 'top10words') unless @levelName && @levelName.length
            @chunkHelper = new languageScramble.ChunkHelper(@languages, @levelName)
            
            @html = wings.renderTemplate(@template, 
                languages: @languages
                displayLanguages: @chunkHelper.displayLanguages()
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

            @languages = @el.data('languages')
            @levelName = @el.data('level_name')
            # console.log(@languages, @levelName)

            @user = loadUser(@cookies.get('user'))
            @viewHelper = new languageScramble.ViewHelper
                el: $(@selector)
                user: @user
                languages: @languages
                go: @go
                cookies: @cookies

            @viewHelper.setLevel(@levelName)
            @viewHelper.bindWindow()
            @viewHelper.bindKeyPress()
            @viewHelper.newScramble()            
            

soma.routes
    '/puzzles/language_scramble': -> new soma.chunks.LanguageScramble
    
    '/puzzles/language_scramble/:languages': (languages) -> 
        new soma.chunks.LanguageScramble
            languages: languages
            
    '/puzzles/language_scramble/:languages/:levelName': (languages, levelName) -> 
        new soma.chunks.LanguageScramble
            languages: languages
            levelName: levelName
            
        