window.app = 
    initialize: ->
        if not window.innerWidth or window.landwidth
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
            saveProgress: (puzzleProgress) => @saveProgress(puzzleProgress)
            maxLevel: 5

        @initProgressMeter()
        @initMenuButton()
        
        @viewHelper.setLevel(@levelName)

        @viewHelper.bindWindow()
        @viewHelper.bindKeyPress()
        @viewHelper.newScramble() 

        
    initProgressMeter: ->
        @progressMeter = @viewHelper.$('.level_progress_meter')
        @percentComplete = @progressMeter.find('.percent_complete')
        @progressMeter.css(top: window.innerHeight - @percentComplete.height())

    saveProgress: (puzzleProgress) ->
        percentComplete = 0
        if puzzleProgress.levels[@languages][puzzleProgress.lastLevelPlayed]?.percentComplete
            percentComplete = puzzleProgress.levels[@languages][puzzleProgress.lastLevelPlayed].percentComplete
        @percentComplete.width("#{percentComplete}%")
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
        levelSelect = @selector.find('#level_select_menu')
        levelSelect.width($('.language_scramble').width())
        levelSelect.height($('.language_scramble').height())
        startPosition = {}
        levelSelect.bind 'touchstart', (e) =>
            startPosition = 
                scrollTop: parseInt(levelSelect.scrollTop())
                touch: @viewHelper.clientY(e)
        levelSelect.bind 'touchmove', (e) =>
            levelSelect.scrollTop(startPosition.scrollTop - (@viewHelper.clientY(e) - startPosition.touch))
    
        showLevel = (level) =>
            @viewHelper.setLevel(level)
            @viewHelper.newScramble()
                   
            levelSelect.animate
                opacity: 0
                duration: 500
                complete: ->
                    levelSelect.css
                        top: -1000
                        left: -1000
    
        for key of languageScramble.data[@languages].levels
            do (key) =>
                info = languageScramble.data[@languages].levels[key]
                levelLinkDiv = document.createElement("DIV")
                levelLinkDiv.className = 'level'
                levelLinkDiv.id = "level_link_#{key}"
                levelLink = document.createElement("A")
                levelLink.className = 'level_link'
                levelLink.innerHTML = "#{info.title}<br/><small>#{info.subtitle}</small>"
                $(levelLink).bind 'click', () => showLevel(key)
                $(levelLinkDiv).append(levelLink)
                levelSelect.append(levelLinkDiv)
                levelProgress = document.createElement("A")
                levelProgress.className = 'percent_complete'
                levelProgress.innerHTML = '&nbsp;'
                percentComplete = @puzzleData.levels[@languages][key]?.percentComplete or 0
                $(levelProgress).width("#{percentComplete}%")
                $(levelProgress).bind 'click', () => showLevel(key)
                $(levelLinkDiv).append(levelProgress)
    
        @selector.find('#menu_button').bind 'click', ->
            levelSelect.css
                opacity: 0
                top: ($('.language_scramble').height() - levelSelect.height()) / 2
                left: ($('.language_scramble').width() - levelSelect.width()) / 2
            levelSelect.animate
                opacity: 1
                duration: 500
                
        
        @selector.find('#close_menu_button').bind 'click', ->
            levelSelect.animate
                opacity: 0
                duration: 500
                complete: ->
                    levelSelect.css
                        top: -1000
                        left: -1000
            
            