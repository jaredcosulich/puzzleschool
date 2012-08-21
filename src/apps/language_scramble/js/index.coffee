window.app = 
    initialize: ->
        document.addEventListener('touchmove', ((e) => e.preventDefault()), false)
        languageScramble = require('./lib/language_scramble')
        @selector = $('.language_scramble')
        $('.scramble_content').height(window.innerHeight)

        @puzzleData = JSON.parse(window.localStorage.getItem('data')) or {levels: {}}
        #@puzzleData = {"levels":{"english_italian":{"top10words":{"of-di":5,"percentComplete":92,"and-e":5,"what-che":4,"the-il":5,"are-sono":5,"is-_":5,"not-non":4,"for-per":5,"a-un":5,"the-la":4}}},"lastLevelPlayed":"top10words"}
        #@puzzleData = {levels: {}}

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
        window.localStorage.setItem("data", JSON.stringify(puzzleProgress))
        