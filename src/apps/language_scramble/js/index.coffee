window.app = 
    initialize: ->
        if not (@width = window.innerWidth or window.landwidth) or not (@height = window.innerHeight or window.landheight) or @width < @height
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
        # @puzzleData = {"levels":{"english_italian":{"top10words":{"of-di":5,"percentComplete":92,"and-e":5,"what-che":4,"the-il":5,"are-sono":5,"is-_":5,"not-non":4,"for-per":5,"a-un":5,"the-la":4}}},"lastLevelPlayed":"top10words"}
        # @puzzleData = {levels: {}}
        
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
        @initMenuButton()
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
        
        
    initMenuButton: ->
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
                $(levelLink).bind 'click', () => showLevel(key)
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

            
        levelSelect.find('.next').bind 'click', =>
            levelsContainer.animate
                marginLeft: parseInt(levelsContainer.css('marginLeft')) - levelSelect.width()
                duration: 500

        levelSelect.find('.previous').bind 'click', => 
            levelsContainer.animate
                marginLeft: parseInt(levelsContainer.css('marginLeft')) + levelSelect.width()
                duration: 500
    
        @$('.menu_button').bind 'click', =>
            @$('.scramble_content').animate
                opacity: 0.25
                duration: 250
            
            levelSelect.css
                opacity: 0
                top: (@height - levelSelect.height()) / 2
                left: (@width - levelSelect.width()) / 2
            levelSelect.animate
                opacity: 1
                duration: 500
                
        
        @$('#close_menu_button').bind 'click', =>
            @$('.scramble_content').animate
                opacity: 1
                duration: 250
            
            levelSelect.animate
                opacity: 0
                duration: 500
                complete: ->
                    levelSelect.css
                        top: -1000
                        left: -1000
                        
    initKeyboard: ->
        keyboard = @$('.keyboard')
        addLetter = (letter) -> 
            color = if letter.match(/&.*;/) then 'red' else 'blue'
            keyboard.append("<a class='letter'><span class='#{color}_button'>#{letter}</span></a>")
        addBreak = -> keyboard.append('<br/>')
        addLetter(letter) for letter in ['q','w','e','r','t','y','u','i','o','p','&lsaquo;']
        addBreak()
        addLetter(letter) for letter in ['a','s','d','f','g','h','j','k','l']
        addBreak()
        addLetter(letter) for letter in ['z','x','c','v','b','n','m']
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

            
            