window.app = 
    initialize: ->
        languageScramble = require('./lib/language_scramble')
        @selector = $('.scramble_content')
        @puzzleData = JSON.parse(window.localStorage.getItem('data')) or {levels: {}}
        @puzzleData = {"levels":{"english_italian":{"top10words":{"is-_":1,"and-e":2,"percentComplete":14.285714285714278,"the-il":2,"of-di":1,"a-un":2,"not-non":2,"are-sono":2}}},"lastLevelPlayed":"top10words"}        
        @languages = "english_italian"
        @levelName = "top10words"
        @puzzleData.levels[@languages] = {} unless @puzzleData.levels[@languages]        
        @viewHelper = new languageScramble.ViewHelper
            el: $(@selector)
            puzzleData: @puzzleData
            languages: @languages
            saveProgress: (puzzleProgress) => @saveProgress(puzzleProgress)

        @initProgressMeter()
        @viewHelper.setLevel(@levelName)
        @viewHelper.bindWindow()
        @viewHelper.bindKeyPress()
        @viewHelper.newScramble() 

        
    initProgressMeter: ->
        @progressMeter = @viewHelper.$('.level_progress_meter')
        @percentComplete = @progressMeter.find('.percent_complete')
        @progressMeter.css(top: window.innerHeight - @percentComplete.height())

    saveProgress: (puzzleProgress) ->
        if puzzleProgress.levels[@languages][@levelName]?.percentComplete
            @percentComplete.width("#{puzzleProgress.levels[@languages][@levelName].percentComplete}%")
        window.localStorage.setItem("data", JSON.stringify(puzzleProgress))
        