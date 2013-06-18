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
                
        @puzzleData = {levels: {}} unless @puzzleData
        
        @languages = "english_italian"
        @puzzleData.levels[@languages] = {} unless @puzzleData.levels[@languages]        

        @levelName = @puzzleData.lastLevelPlayed or "top10words"
        
        @viewHelper = new languageScramble.ViewHelper
            el: $(@selector)
            puzzleData: @puzzleData
            languages: @languages
            dragOffset: 60
            saveProgress: (puzzleProgress) => @saveProgress(puzzleProgress)

        @initProgressMeter()
        @initMenus()
        @initKeyboard()

        @checkSize(50)
        @sizeElements()
        
        @viewHelper.setLevel(@levelName)

        @viewHelper.bindWindow()
        @viewHelper.bindKeyPress()
        @viewHelper.newScramble() 
        
    $: (selector) -> @selector.find(selector)    
    
    checkSize: (interval) ->
        if @width != (window.innerWidth or window.landwidth)
            @width = window.innerWidth or window.landwidth
            @height = window.innerHeight or window.landheight
            @sizeElements()            
            @viewHelper.displayScramble()
        $.timeout interval, () => @checkSize(interval * 2)

    sizeElements: ->
        return
        @progressMeter.css(top: @height - @percentComplete.height())
        levelSelect = @$('#level_select_menu')
        levelSelect.width(@width)
        levelSelect.height(@height)
    
    initProgressMeter: ->
        return
        @progressMeter = @viewHelper.$('.level_progress_meter')
        @percentComplete = @progressMeter.find('.percent_complete')

    saveProgress: (puzzleProgress) ->
        # percentComplete = 0
        # if puzzleProgress.levels[@languages][puzzleProgress.lastLevelPlayed]?.percentComplete
        #     percentComplete = puzzleProgress.levels[@languages][puzzleProgress.lastLevelPlayed].percentComplete
        # @percentComplete.width("#{percentComplete}%")
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
        
        
    initLevelSelectMenu: ->
        levelSelect = @$('#level_select_menu')
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
    
        levelsContainer = levelSelect.find('.levels_container')
        levelsGroup = null
        levelsAdded = 0
        for key of languageScramble.data[@languages].levels
            if levelsAdded % 4 == 0
                levelsGroup = $(document.createElement("DIV"))
                levelsGroup.addClass('levels_group')
                levelsContainer.append(levelsGroup)
                levelsContainer.width(levelsGroup.width() * (1 + (levelsAdded / 4)))
            do (key, levelsGroup, levelsAdded) =>        
                info = languageScramble.data[@languages].levels[key]
                levelLinkDiv = document.createElement("DIV")
                levelLinkDiv.className = 'level'
                levelLinkDiv.id = "level_link_#{key}"
                levelLink = document.createElement("A")
                levelLink.className = 'level_link'
                levelLink.innerHTML = "#{info.title}<br/><small>#{info.subtitle}</small>"
                $(levelLink).bind 'touchstart.select_level', () => showLevel(key)
                $(levelLinkDiv).append(levelLink)
                levelsGroup.append(levelLinkDiv)
                
                percentComplete = document.createElement("DIV")
                percentComplete.className = 'percent_complete'
                $(percentComplete).width("#{@puzzleData.levels[@languages][key]?.percentComplete or 0}%")
                $(levelLinkDiv).append(percentComplete)

                levelProgress = document.createElement("DIV")
                levelProgress.className = 'mini_progress_meter'
                $(levelLinkDiv).append(levelProgress)
            levelsAdded += 1

            
        next = levelSelect.find('.next')
        showNext = =>
            next.unbind 'touchstart.next'
            @$('document.body').one 'touchend.next', => next.removeClass('active')
            next.addClass('active')    
            levelsContainer.animate
                marginLeft: parseInt(levelsContainer.css('marginLeft')) - levelSelect.width()
                duration: 500
                complete: => next.bind 'touchstart.next', => showNext()            
        next.bind 'touchstart.next', => showNext()

        previous = levelSelect.find('.previous')
        showPrevious = =>
            previous.unbind 'touchstart.previous'
            @$('document.body').one 'touchend.previous', => previous.removeClass('active')
            previous.addClass('active')
            levelsContainer.animate
                marginLeft: parseInt(levelsContainer.css('marginLeft')) + levelSelect.width()
                duration: 500
                complete: => previous.bind 'touchstart.previous', => showPrevious()
        previous.bind 'touchstart.previous', => showPrevious()
    
                
        
    
    initMenus: ->
        @activeMenu = 'level'
        @menus = 
            native: @$('#native_select_menu')
            foreign: @$('#foreign_select_menu')
            level: @$('#level_select_menu')
        
        for name, menu of @menus
            do (menu) =>
                closeMenu = menu.find('.close_menu_button')
                closeMenu.bind 'touchstart.close_menu', =>
                    @$('document.body').one 'touchend.next', => closeMenu.removeClass('active')
                    closeMenu.addClass('active')
                    @$('.scramble_content').animate
                        opacity: 1
                        duration: 250

                    menu.animate
                        opacity: 0
                        duration: 500
                        complete: ->
                            menu.css
                                top: -1000
                                left: -1000

        menu = @$('.menu_button')
        menu.bind 'touchstart.menu', =>
            @$('document.body').one 'touchend.next', => menu.removeClass('active')
            menu.addClass('active')
            @$('.scramble_content').animate
                opacity: 0.25
                duration: 250

            @menus[@activeMenu].css
                opacity: 0
                top: (@height - @menus[@activeMenu].height()) / 2
                left: (@width - @menus[@activeMenu].width()) / 2
            @menus[@activeMenu].animate
                opacity: 1
                duration: 500
                
        # @initNativeMenu()
        # @initForeignMenu()
        @initLevelSelectMenu()
        
                        
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

            
            