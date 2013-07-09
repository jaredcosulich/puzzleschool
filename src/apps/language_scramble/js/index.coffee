window.app = 
    initialize: ->
        if not (@width = window.innerWidth or window.landwidth) or not (@height = window.innerHeight or window.landheight)# or @width < @height
            $.timeout 100, -> window.app.initialize()
            return
            
        document.addEventListener('touchmove', ((e) => e.preventDefault()), false)
        languageScramble = require('./lib/language_scramble')
        @selector = $('.language_scramble')
        $('.scramble_content').height(window.innerHeight)

        if AppMobi
            if data = AppMobi.cache.getCookie('data')
                @puzzleData = JSON.parse(data)
        else
            if data = window.localStorage.getItem('data')
                @puzzleData = JSON.parse(data)
                

        if @puzzleData?.version != 1373337874092
            @puzzleData = {version: 1373337874092, levels: {}}

        # @puzzleData = {levels: {}} unless @puzzleData
        
        @puzzleData.nativeLanguage = 'English' unless @puzzleData.nativeLanguage
        
        if not @puzzleData.foreignLanguage
            @puzzleData.menu = 'foreign'
        else if not @puzzleData.levels["#{@puzzleData.nativeLanguage}_#{@puzzleData.foreignLanguage}"]    
            @puzzleData.levels["#{@puzzleData.nativeLanguage}_#{@puzzleData.foreignLanguage}"] = {}

        @viewHelper = new languageScramble.ViewHelper
            el: $(@selector)
            puzzleData: @puzzleData
            dragOffset: 60
            saveProgress: (puzzleProgress) => @saveProgress(puzzleProgress)

        @initMenus()
        @initKeyboard()

        @checkSize(50)
        
        @viewHelper.bindWindow()
        @viewHelper.bindKeyPress()

        @levelName = @puzzleData.lastLevelPlayed
        
        if @levelName and @puzzleData.foreignLanguage
            @viewHelper.setLevel(@levelName)
            @viewHelper.newScramble() 
        else
            @showMenu()
        
    $: (selector) -> @selector.find(selector)    
    
    checkSize: (interval) ->
        if @width != (window.innerWidth or window.landwidth)
            @width = window.innerWidth or window.landwidth
            @height = window.innerHeight or window.landheight
            @sizeElements()            
            @viewHelper.displayScramble()
        $.timeout interval, () => @checkSize(interval * 2)

    saveProgress: (puzzleProgress) ->
        # percentComplete = 0
        # if puzzleProgress.levels[@languages][puzzleProgress.lastLevelPlayed]?.percentComplete
        #     percentComplete = puzzleProgress.levels[@languages][puzzleProgress.lastLevelPlayed].percentComplete
        # @percentComplete.width("#{percentComplete}%")
        puzzleProgress.menu = @puzzleData.menu
        AppMobi.cache.setCookie("data", JSON.stringify(puzzleProgress), -1)
        # AppMobi.device.getRemoteData(
        #     "http://puzzleschool.com/api/puzzles/language_scramble/update", 
        #     "POST", 
        #     {puzzleUpdates: puzzleUpdates, levelUpdates: levelUpdates}, 
        #     () => 
        #         @puzzleData = JSON.parse(JSON.stringify(puzzleProgress))
        #         callback() if callback
        #     () =>
        # )
        
        
    initLevelSelectMenu: (language) ->
        language = language.toLowerCase()
        levelSelect = @$("##{language}_select_menu")
        startPosition = {}
        levelSelect.bind 'touchstart', (e) =>
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
                levelLink.innerHTML = "#{info.title}<br/><small>#{info.subtitle}</small>"
                $(levelLinkDiv).append(levelLink)
                levelsGroup.append(levelLinkDiv)
                
                percentComplete = document.createElement("DIV")
                percentComplete.className = 'percent_complete'
                $(percentComplete).width("#{@puzzleData.levels[languages]?[key]?.percentComplete or 0}%")
                $(levelLinkDiv).append(percentComplete)

                levelProgress = document.createElement("DIV")
                levelProgress.className = 'mini_progress_meter'
                $(levelLinkDiv).append(levelProgress)

                $(levelLinkDiv).bind 'touchstart.select_level', () => showLevel(key)

            levelsAdded += 1

            
            previous = levelSelect.find('.previous')
            next = levelSelect.find('.next')

            startingPoint = parseInt(levelsContainer.css('marginLeft'))
            checkPrevious = (marginLeft=parseInt(levelsContainer.css('marginLeft')))=>
                if marginLeft >= startingPoint
                    previous.animate(opacity: 0, duration: 250)
                else
                    previous.animate(opacity: 1, duration: 250)

            showNext = =>
                next.unbind 'touchstart.next'
                @$('document.body').one 'touchend.next', => next.removeClass('active')
                next.addClass('active') 
                marginLeft = parseInt(levelsContainer.css('marginLeft')) - levelSelect.width() 
                checkPrevious(marginLeft)
                levelsContainer.animate
                    marginLeft: marginLeft
                    duration: 500
                    complete: => next.bind 'touchstart.next', => showNext()            
            next.bind 'touchstart.next', => showNext()

            showPrevious = =>
                previous.unbind 'touchstart.previous'
                @$('document.body').one 'touchend.previous', => previous.removeClass('active')
                previous.addClass('active')
                marginLeft = parseInt(levelsContainer.css('marginLeft')) + levelSelect.width() 
                checkPrevious(marginLeft)
                levelsContainer.animate
                    marginLeft: marginLeft
                    duration: 500
                    complete: => 
                        checkPrevious()
                        previous.bind 'touchstart.previous', => showPrevious()
            previous.bind 'touchstart.previous', => showPrevious()

            checkPrevious()

    showMenu: (name=@puzzleData.menu) ->
        @$('.scramble_content').animate
            opacity: 0.25
            duration: 250
        @viewHelper.hideDictionary()

        @$('.floating_message').css
            top: -10000
            left: -10000
        @puzzleData.menu = name
        @menus[@puzzleData.menu].css
            opacity: 1
            top: (@height - @menus[@puzzleData.menu].height()) / 2
            left: (@width - @menus[@puzzleData.menu].width()) / 2
    
    
    initMenus: ->
        @menus = 
            native: @$('#native_select_menu')
            foreign: @$('#foreign_select_menu')
            italian: @$('#italian_select_menu')
            spanish: @$('#spanish_select_menu')
        
        for name, menu of @menus
            do (menu) =>
                upMenu = menu.find('.up_menu_button')
                upMenu.bind 'touchstart.up_menu', => @showMenu('foreign')
                
                closeMenu = menu.find('.close_menu_button')
                closeMenu.bind 'touchstart.close_menu', =>
                    return if @animatingMenu
                    @animatingMenu = true
                    @$('document.body').one 'touchend.next', => closeMenu.removeClass('active')
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
        menu.bind 'touchstart.menu', =>
            return if @animatingMenu
            @animatingMenu = true
            $.timeout 200, => menu.removeClass('active')
            menu.addClass('active')
            
            menuName = @puzzleData.foreignLanguage?.toLowerCase() or @puzzleData.menu
            @menus[menuName].css(opacity: 0)
            @showMenu(menuName)
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
                $(levelLink).bind 'touchstart.select_level', () => 
                    @viewHelper.setForeignLanguage(language)
                    @showMenu(language.toLowerCase())
                $(levelLinkDiv).append(levelLink)
                foreignGroup.append(levelLinkDiv)
            @initLevelSelectMenu(language)
            
                
                        
    initKeyboard: ->
        keyboard = @$('.keyboard')
        addLetter = (letter) -> 
            color = if letter.match(/&.*;/) then 'red' else 'blue'
            keyboard.append("<a class='letter'><span class='#{color}_button'>#{letter}</span></a>")
        addBreak = -> keyboard.append('<br/>')
        addLetter(letter) for letter in [
            'a','b','c','d','e','f','g','h','i','j','k','l','m','n',
            'o','p','q','r','s','t','u','v','w','x','y','z','&lsaquo;'
        ]
        keyboard.find('.letter').bind 'touchstart.letter', (e) =>
            letter = $(e.currentTarget)
            letter.addClass('active')
            $(document.body).one 'touchend.letter', => letter.removeClass('active')
            @clickLetter(letter)

    clickLetter: (letter) ->
        htmlLetter = letter.find('span').html()
        switch htmlLetter
            when '‹'    
                lastLetterAdded = @viewHelper.lettersAdded.pop()
                guessedLetters = $(".guesses .letter_#{lastLetterAdded}")
                if guessedLetters.length
                    guessedLetter = $(guessedLetters[guessedLetters.length - 1])
                    guessedLetter.trigger('keypress.start')
                    guessedLetter.trigger('keypress.end')
            else    
                @viewHelper.typeLetter(htmlLetter, true)

            
            