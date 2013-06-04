soma = require('soma')
wings = require('wings')

soma.chunks
    LanguageScramble:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@languages, @levelName}) ->
            @template = @loadTemplate '/build/common/templates/puzzles/language_scramble.html'
            @loadScript '/build/common/pages/puzzles/lib/language_scramble.js'
            @loadStylesheet '/build/client/css/puzzles/language_scramble.css'
            
            @puzzleData = {levels: {}}
            if @cookies.get('user')
                @loadData 
                    url: '/api/puzzles/language_scramble'
                    success: (data) =>
                        if data.puzzle? 
                            @puzzleData = data.puzzle
                            for levelName, levelInfo of @puzzleData.levels
                                languages = levelName.split(/\//)[0]
                                level = levelName.split(/\//)[1]
                                @puzzleData.levels[languages] = {} unless @puzzleData.levels[languages]
                                @puzzleData.levels[languages][level] = levelInfo
                                delete @puzzleData.levels[levelName]
                    error: () =>
                        if window?.alert
                            alert('We were unable to load your account information. Please check your internet connection.')

        build: ->
            @setTitle("Language Scramble - The Puzzle School")
            @loadElement("link", {rel: 'img_src', href: 'http://www.puzzleschool.com/assets/images/reviews/language_scramble.jpg'})
            
            @setMeta('og:title', 'Language Scramble - The Puzzle School')            
            @setMeta('og:url', 'http://www.puzzleschool.com/puzzles/language_scramble')
            @setMeta('og:image', 'http://www.puzzleschool.com/assets/images/reviews/language_scramble.jpg')
            @setMeta('og:site_name', 'The Puzzle School')
            @setMeta('og:description', 'Practice vocabulary and common sentences in your favorite foreign language. Much more fun than flash cards.')
            @setMeta('description', 'Practice vocabulary and common sentences in your favorite foreign language. Much more fun than flash cards.')
            

            languageScramble = require('./lib/language_scramble')
            
            @languages = (@puzzleData.lastLanguages or 'english_italian') unless @languages && @languages.length
            @levelName = (@puzzleData.lastLevelPlayed or 'top10words') unless @levelName && @levelName.length
            @puzzleData.levels[@languages] = {} unless @puzzleData.levels[@languages]
            @chunkHelper = new languageScramble.ChunkHelper(@languages, @levelName, @puzzleData)
            
            @html = wings.renderTemplate(@template, 
                puzzleData: JSON.stringify(@puzzleData)
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
            
            @puzzleData = JSON.parse(@el.data('puzzle_data'))
            @languages = @el.data('languages')
            @levelName = @el.data('level_name')

            @viewHelper = new languageScramble.ViewHelper
                el: $(@selector)
                puzzleData: @puzzleData
                languages: @languages
                saveProgress: (puzzleProgress) => @saveProgress(puzzleProgress)
            @viewHelper.setLevel(@levelName)
            @viewHelper.bindWindow()
            @viewHelper.bindKeyPress()
            @viewHelper.newScramble()   
            
        saveProgress: (puzzleProgress, callback) ->
            if @cookies.get('user')
                puzzleUpdates = @getUpdates(puzzleProgress)
                return unless puzzleUpdates
            
                levelUpdates = {}
                for languages, levels of puzzleUpdates.levels
                    for levelName, levelInfo of levels
                        levelUpdates["#{languages}/#{levelName}"] = levelInfo
                delete puzzleUpdates.levels
            
                $.ajaj
                    url: "/api/puzzles/language_scramble/update"
                    method: 'POST'
                    headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                    data: 
                        puzzleUpdates: puzzleUpdates
                        levelUpdates: levelUpdates
                    success: => 
                        @puzzleData = JSON.parse(JSON.stringify(puzzleProgress))
                        callback() if callback
                        
            else if puzzleProgress.levels 
                window.postRegistration.push((callback) => @saveProgress(puzzleProgress, callback))
                    
                @answerCount = 0 if not @answerCount
                @answerCount += 1
                if @answerCount > 7
                    if @answerCount % 8 == 0
                        @showRegistrationFlag()

        compareItem: (current, original) ->
            return current unless original
            if typeof current == 'object'
                return @compareHashes(current, original)

            else if Array.isArray(current)
                return @compareArrays(current, original)
            
            else    
                return current unless current == original
            
        compareHashes: (current, original) ->
            diff = {}
            for key, value of current
                diffValue = @compareItem(value, original[key])
                diff[key] = diffValue if diffValue?
                
            return diff if Object.keys(diff).length > 0
        
        compareArrays: (current, original) ->
            diff = []
            for item, index in current
                diffValue = @compareItem(item, original[index])
                diff.push(diffValue) if diffValue?
                
            return diff if diff.length > 0
                  
        getUpdates: (progress) ->
            @compareHashes(progress, @puzzleData)
            


soma.routes
    '/puzzles/language_scramble/:languages/:levelName': (data) -> 
        new soma.chunks.LanguageScramble
            languages: data.languages
            levelName: data.levelName
    
    '/puzzles/language_scramble/:languages': (data) -> 
        new soma.chunks.LanguageScramble
            languages: data.languages
            
    '/puzzles/language_scramble': -> new soma.chunks.LanguageScramble
            
        