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
            
            @setMeta(name: 'og:title', property: 'og:title', content: 'Language Scramble - The Puzzle School')            
            @setMeta(name: 'og:url', property: 'og:url', content: 'http://www.puzzleschool.com/puzzles/language_scramble')
            @setMeta(name: 'og:image', property: 'og:image', content: 'http://www.puzzleschool.com/assets/images/reviews/language_scramble.jpg')
            @setMeta(name: 'og:description', property: 'og:description', content: 'Practice vocabulary and common sentences in your favorite foreign language. Much more fun than flash cards.')
            @setMeta('description', 'Practice vocabulary and common sentences in your favorite foreign language. Much more fun than flash cards.')
            
            languageScramble = require('./lib/language_scramble')
    
            @languages = (@puzzleData.lastLanguages or 'english_italian') unless @languages && @languages.length
            @levelName = (@puzzleData.lastLevelPlayed or 'top10nouns') unless @levelName && @levelName.length
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
            
            @puzzleData.nativeLanguage = 'English' unless @puzzleData.nativeLanguage

            if not @puzzleData.foreignLanguage
                @puzzleData.menu = 'foreign'
            else if not @puzzleData.levels["#{@puzzleData.nativeLanguage}_#{@puzzleData.foreignLanguage}"]    
                @puzzleData.levels["#{@puzzleData.nativeLanguage}_#{@puzzleData.foreignLanguage}"] = {}

            @viewHelper = new languageScramble.ViewHelper
                el: $(@selector)
                puzzleData: @puzzleData
                saveProgress: (puzzleProgress) => @saveProgress(puzzleProgress)
            
            @levelName = @puzzleData.lastLevelPlayed
    
            @initMenus()
            @viewHelper.bindWindow()
            @viewHelper.bindKeyPress()

            if @levelName and @puzzleData.foreignLanguage
                @viewHelper.setLevel(@levelName)
                @viewHelper.newScramble() 
            else
                $.timeout 100, => @showMenu()
            
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
                        
        initLevelSelectMenu: (language) ->
            language = language.toLowerCase()
            levelSelect = @$("##{language}_select_menu")
            startPosition = {}
            levelSelect.bind 'mousedown', (e) =>
                startPosition = 
                    scrollTop: parseInt(levelSelect.scrollTop())
                    touch: @viewHelper.clientY(e)
            levelSelect.bind 'touchmove', (e) =>
                levelSelect.scrollTop(startPosition.scrollTop - (@viewHelper.clientY(e) - startPosition.touch))

            showLevel = (level) =>
                @viewHelper.$('#next_level').css
                    opacity: 0

                @viewHelper.$('.scramble_content').css
                    opacity: 1

                @viewHelper.setLevel(level)
                @viewHelper.newScramble()

                levelSelect.animate
                    opacity: 0
                    duration: 500
                    complete: ->
                        levelSelect.css
                            top: -1000
                            left: -1000

            languages = "#{@puzzleData.nativeLanguage.toLowerCase()}_#{language.toLowerCase()}"
            levelsContainer = levelSelect.find('.levels_container')
            levelsGroup = null
            levelsAdded = 0
            for key of languageScramble.data[languages].levels
                if levelsAdded % 4 == 0
                    levelsGroup = $(document.createElement("DIV"))
                    levelsGroup.addClass('levels_group')
                    levelsContainer.append(levelsGroup)
                    levelsContainer.width(levelsGroup.width() * (1 + (levelsAdded / 4)))
                do (key, levelsGroup, levelsAdded) =>        
                    info = languageScramble.data[languages].levels[key]
                    levelLinkDiv = document.createElement("DIV")
                    levelLinkDiv.className = 'level'
                    levelLinkDiv.id = "level_link_#{key}"
                    levelLink = document.createElement("A")
                    levelLink.className = 'level_link'
                    levelLink.innerHTML = info.title
                    $(levelLink).bind 'mousedown.select_level', () => showLevel(key)
                    $(levelLinkDiv).append(levelLink)
                    levelsGroup.append(levelLinkDiv)

                    percentComplete = document.createElement("DIV")
                    percentComplete.className = 'percent_complete'
                    $(percentComplete).width("#{@puzzleData.levels[languages]?[key]?.percentComplete or 0}%")
                    $(levelLinkDiv).append(percentComplete)

                    levelProgress = document.createElement("DIV")
                    levelProgress.className = 'mini_progress_meter'
                    $(levelLinkDiv).append(levelProgress)
                levelsAdded += 1


            next = levelSelect.find('.next')
            showNext = =>
                next.unbind 'mousedown.next'
                @$('document.body').one 'mouseup.next', => next.removeClass('active')
                next.addClass('active')    
                levelsContainer.animate
                    marginLeft: parseInt(levelsContainer.css('marginLeft')) - levelSelect.width()
                    duration: 500
                    complete: => next.bind 'mousedown.next', => showNext()            
            next.bind 'mousedown.next', => showNext()

            previous = levelSelect.find('.previous')
            showPrevious = =>
                previous.unbind 'mousedown.previous'
                @$('document.body').one 'mouseup.previous', => previous.removeClass('active')
                previous.addClass('active')
                levelsContainer.animate
                    marginLeft: parseInt(levelsContainer.css('marginLeft')) + levelSelect.width()
                    duration: 500
                    complete: => previous.bind 'mousedown.previous', => showPrevious()
            previous.bind 'mousedown.previous', => showPrevious()

        showMenu: (name=@puzzleData.menu) ->
            gameAreaOffset = @el.offset()
            contentOffset = @$('.scramble_content').offset()
            @$('.floating_message').css
                top: -10000
                left: -10000
            @puzzleData.menu = name
            @menus[@puzzleData.menu].css
                opacity: 1
                top: (contentOffset.top - gameAreaOffset.top) + ((contentOffset.height - @menus[@puzzleData.menu].height()) / 2)
                left: ((contentOffset.width - @menus[@puzzleData.menu].width()) / 2) 

        initMenus: ->
            @menus = 
                native: @$('#native_select_menu')
                foreign: @$('#foreign_select_menu')
                italian: @$('#italian_select_menu')
                spanish: @$('#spanish_select_menu')

            for name, menu of @menus
                do (menu) =>
                    upMenu = menu.find('.up_menu_button')
                    upMenu.bind 'mousedown.up_menu', => @showMenu('foreign')

                    closeMenu = menu.find('.close_menu_button')
                    closeMenu.bind 'mousedown.close_menu', =>
                        return if @animatingMenu
                        @animatingMenu = true
                        @$('document.body').one 'mouseup.next', => closeMenu.removeClass('active')
                        closeMenu.addClass('active')
                        @$('.scramble_content').animate
                            opacity: 1
                            duration: 250

                        menu.animate
                            opacity: 0
                            duration: 500
                            complete: =>
                                @animatingMenu = false
                                menu.css
                                    top: -10000
                                    left: -10000

            menu = @$('.menu_button')
            menu.bind 'mousedown.menu', =>
                return if @animatingMenu
                @animatingMenu = true
                $.timeout 200, => menu.removeClass('active')
                menu.addClass('active')

                @$('.scramble_content').animate
                    opacity: 0.25
                    duration: 250
                @viewHelper.hideDictionary()

                menuName = @puzzleData.foreignLanguage?.toLowerCase() or @puzzleData.menu
                @menus[menuName].css
                    opacity: 0
                    top: (@height - @menus[menuName].height()) / 2
                    left: (@width - @menus[menuName].width()) / 2
                @menus[menuName].animate
                    opacity: 1
                    duration: 500
                    complete: => @animatingMenu = false

            # @initNativeMenu()
            @initForeignMenu()

        initForeignMenu: ->
            foreignGroup = @$('#foreign_select_menu .levels_container .levels_group')

            for language in ['Italian', 'Spanish']
                do (language) =>        
                    levelLinkDiv = document.createElement("DIV")
                    levelLinkDiv.className = 'level'
                    levelLink = document.createElement("A")
                    levelLink.className = 'level_link'
                    levelLink.innerHTML = language
                    $(levelLink).bind 'mousedown.select_level', () => 
                        @viewHelper.setForeignLanguage(language)
                        @showMenu(language.toLowerCase())
                    $(levelLinkDiv).append(levelLink)
                    foreignGroup.append(levelLinkDiv)
                @initLevelSelectMenu(language)
                        

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
            
        