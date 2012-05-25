scrambleKey = (scrambleInfo) -> 
    "#{scrambleInfo.native.replace(/\W/g, '_')}-#{scrambleInfo.foreign.replace(/\W/g, '_')}"

randomIndex = (array) -> Math.floor(Math.random() * array.length)
        
random = (array) ->
    return null unless array 
    return null unless array.length
    return array[0] if array.length == 1
    return array[randomIndex(array)]
        
shuffle = (array) ->
    top = array.length
    return array if not top

    while(top--) 
        current = Math.floor(Math.random() * (top + 1))
        tmp = array[current]
        array[current] = array[top]
        array[top] = tmp
    return array




languageScramble = exports ? provide('./lib/language_scramble', {})

languageScramble.getLevel = (languageData, levelName) ->
    level = languageData.levels[levelName]
    data.id = scrambleKey(data) for data, index in level.data
    return level

class languageScramble.ChunkHelper
    constructor: (@languages, @levelName) ->
        @languageData = languageScramble.data[@languages]
        @level = languageScramble.getLevel(@languageData, @levelName)
    
    allLevels: ->
        info = []
        for levelName, levelData of @languageData.levels
            info.push
                languages: @languages
                id: levelName
                title: levelData.title
                subtitle: levelData.subtitle

        return info

    displayLanguages: -> @languageData.displayName


class languageScramble.ViewHelper
    maxLevel: 7

    constructor: ({@el, puzzleData, @languages, @go, @saveProgress}) ->
        @puzzleData = JSON.parse(JSON.stringify(puzzleData))
        
    $: (selector) -> $(selector, @el)

    setLevel: (@levelName) ->   
        @languageData = languageScramble.data[@languages]
        @level = languageScramble.getLevel(@languageData, @levelName)
        @options = @level.data
        @puzzleData.levels[@languages][@levelName] = {} unless @puzzleData.levels[@languages][@levelName]
        
        @puzzleData.lastLevelPlayed = @levelName
        @puzzleUpdates
        
        @saveProgress(@puzzleData)
        @orderedOptions = []
        @orderedOptionsIndex = null
        @setTitle()
        @setProgress()

    saveLevel: () ->
        @answerTimes.push(new Date())

        lastAnswerDuration = @answerTimes[@answerTimes.length - 1] - @answerTimes[@answerTimes.length - 2]
        if lastAnswerDuration < 2500 * @scrambleInfo.native.length
            @puzzleData.levels[@languages][@levelName][@scrambleInfo.id] += 1

        @saveProgress(@puzzleData)

    setTitle: ->
        if $('.header .level .title').html() != @level.title
            $('.header .level').animate
                opacity: 0
                duration: 300
                complete: () =>
                    $('.header .level .languages').html(@languageData.displayLanguages)
                    $('.header .level .title').html(@level.title)
                    $('.header .level .subtitle').html(@level.subtitle)
                    @positionTitle()
                    $('.header .level').animate
                        opacity: 1
                        duration: 300
        else
            @positionTitle()
            
    positionTitle: ->
        halfWidth = @$('.header').width() / 2 
        h1Space = @$('.header h1').width() + parseInt(@$('.header h1').css('marginLeft'))
        halfTitleWidth = @$('.header .level').width() / 2
        margin = halfWidth - h1Space - halfTitleWidth
        @$('.header .level').css(marginLeft: margin)        

    bindWindow: () ->
        $(window).bind 'keypress', (e) =>
            return if @clickAreaHasFocus or $('.opaque_screen').css('opacity') > 0
            $('#clickarea')[0].focus()
            $('#clickarea').trigger('keypress', e)
        
        moveDrag = (e) =>
            return unless @dragging
            e.preventDefault() if e.preventDefault?
            unless @dragging.css('position') == 'absolute'
                if @dragging[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)?
                    @replaceLetterWithGuess(@dragging)  
                else
                    @replaceLetterWithBlank(@dragging)  
            @dragPathX.push(@clientX(e)) unless @dragPathX[@dragPathX.length - 1] == @clientX(e)
            @dragPathY.push(@clientY(e)) unless @dragPathX[@dragPathY.length - 1] == @clientY(e)
            @dragging.css(position: 'absolute', top: @clientY(e) - @dragAdjustmentY, left: @clientX(e) - @dragAdjustmentX)                
            
        endDrag = (e, force) =>
            if not force and (!@dragPathX or !@dragPathY or @dragPathX.length <= 1 or @dragPathY.length <= 1)
                $.timeout 40, () => endDrag(e, true) if @dragging?
                return
                
            e.preventDefault() if e.preventDefault?

            currentX = @dragPathX.pop()
            currentY = @dragPathY.pop()
            lastX = (x for x in @dragPathX.reverse() when Math.abs(x - currentX) > 10)[0] or currentX + 0.01
            lastY = (y for y in @dragPathY.reverse() when Math.abs(y - currentY) > 10)[0] or currentY - 0.01
            
            guess = @guessInPath(@dragging, lastX, lastY, currentX, currentY)
            @dragging.css(position: 'static')
            if guess?
                @replaceGuessWithLetter(guess, @dragging)
            else    
                @replaceBlankWithLetter(@dragging)
            @dragging = null
            
        
        $(window).bind 'mousemove', moveDrag
        $(window).bind 'mouseup', endDrag

        $(window).bind 'touchmove', moveDrag
        $(window).bind 'touchend', endDrag
        
        
    bindKeyPress: () ->
        @clickAreaHasFocus = false
        $('#clickarea').bind 'focus', () => @clickAreaHasFocus = true    
        $('#clickarea').bind 'blur', () => @clickAreaHasFocus = false    

        $('#clickarea').bind 'keydown', (e) =>
            if e.keyCode == 8
                lastLetterAdded = @lettersAdded.pop()
                guessedLetters = $(".guesses .letter_#{lastLetterAdded}")
                $(guessedLetters[guessedLetters.length - 1]).trigger('click') if guessedLetters.length
                return
            
        lastPress = null
        $('#clickarea').bind 'keypress', (e) =>
            return if lastPress && new Date() - lastPress < 10
            lastPress = new Date()
            openGuess = @$('.guesses .selected')[0] or @$(".guesses .guess")[0]
            return unless openGuess?
            
            try 
                char = String.fromCharCode(e.keyCode).toLowerCase()                
                if char in ['e', 'i', 'u', 'o']  
                    foreignChar = switch char
                        when 'e' then 'è'
                        when 'i' then 'ì'
                        when 'o' then 'ò'
                        when 'u' then 'ù'
                    
                    char = foreignChar if $(openGuess).hasClass("actual_letter_#{foreignChar}")
            
                letter = $(".scrambled .#{@containerClassName(openGuess)} .letter_#{char}")[0]
                if !letter and @activeLevel.match(/Hard/)?
                    if char.match(/\w|[^\x00-\x80]+/)
                        letter = @createLetter(char) 
                        $(".scrambled .#{@containerClassName(openGuess)}").append(letter)
                
                $.timeout 10, () =>
                    $('#clickarea').val('')        
                    $('#clickarea').html('')        
            catch e
                return
                
            return unless letter?
            $(letter).trigger 'click'
            
            
    bindLetter: (letter) ->
        @dragging = null
        @dragAdjustmentX = 0
        @dragAdjustmentY = 0
        @dragPathX = []
        @dragPathY = []

        click = (e) =>
            return if @dragPathX.length > 1 or @dragPathY > 1
            if @dragging && @dragging.css('position') == 'absolute'
                alreadyDragged = true
                @dragging.css(position: 'static')
                @dragging = null

            containerClass = @containerClassName(letter)
            if letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)?
                @replaceLetterWithGuess(letter)
                @replaceBlankWithLetter(letter)
            else
                guess = @$('.guesses .selected')[0] or @$(".guesses .#{containerClass} .guess")[0]
                return unless guess?
                @replaceLetterWithBlank(letter) unless alreadyDragged
                @replaceGuessWithLetter(guess, letter)

        startDrag = (e) =>
            e.preventDefault() if e.preventDefault?
            @dragging = letter
            @dragPathX = []
            @dragPathY = []
            @dragAdjustmentX = @clientX(e) - letter.offset().left + @el.offset().left
            @dragAdjustmentY = @clientY(e) - letter.offset().top + @el.offset().top

        letter = $(letter)
        letter.attr(onclick: 'void(0)', ontouchstart: 'void(0)', ontouchend: 'void(0)', ontouchmove: 'void(0)')
        letter.bind 'click', click
        letter.bind 'touchend', click                
        letter.bind 'mousedown', startDrag   
        letter.bind 'touchstart', startDrag                
            
        
    newScramble: () ->
        @answerTimes or= []
        @answerTimes.push(new Date()) 

        @lettersAdded = []

        @scrambleInfo = @selectOption()
        return unless @scrambleInfo     
        @puzzleData.levels[@languages][@levelName][@scrambleInfo.id] or= 1    

        displayWords = @$('.display_words')
        if @scrambleInfo["#{@displayLevel}Sentence"]? && @scrambleInfo["#{@displayLevel}Sentence"].length 
            sentence = @scrambleInfo["#{@displayLevel}Sentence"]
        else
            sentence = @scrambleInfo[@displayLevel]
        sentence = " #{sentence} "
        highlighted = @scrambleInfo[@displayLevel]
        for boundary in [' ', '?', ',']
            sentence = sentence.replace(" #{highlighted}#{boundary}", " <span class='highlighted'>#{highlighted}</span>#{boundary}")           

        displayWords.html(sentence)

        @createGuesses()
        @createScramble()
    
    selectOption: () ->
        @orderedOptions or= []
        if @orderedOptionsIndex?
            @orderedOptionsIndex += 1
        else
            @orderedOptionsIndex = 0

        if @orderedOptions[@orderedOptionsIndex]?
            @setStage() 
            return @orderedOptions[@orderedOptionsIndex] 
            
        optionsToAdd = [[],[],[],[],[],[],[]]            
        minLevel = @maxLevel
        
        for option in @options
            continue if option in @orderedOptions[-4..-1]
            optionLevel = @puzzleData.levels[@languages][@levelName][option.id] || 1
            optionsToAdd[optionLevel] or= []
            optionsToAdd[optionLevel].push(option)
            minLevel = optionLevel if optionLevel < minLevel

        if minLevel == @maxLevel
            
            incomplete = (option for option in @options when (@puzzleData.levels[@languages][@levelName][option.id] || 1) < @maxLevel)
            if incomplete.length
                @orderedOptions.push(option) for option in incomplete
                return @orderedOptions[@orderedOptionsIndex]
            else
                @nextLevel()
                return false

        possibleLevels = [minLevel, minLevel]
        if optionsToAdd[minLevel].length > 4                
            if optionsToAdd[minLevel].length <  @options.length / (3/2)
                possibleLevels.push(minLevel + 1)

            if optionsToAdd[minLevel].length <  @options.length / 2
                possibleLevels.push(minLevel + i) for i in [0..1]
        
            if optionsToAdd[minLevel].length <  @options.length / 3
                possibleLevels.push(minLevel + i) for i in [0..2]
            
        level = random(possibleLevels)
        if not optionsToAdd[level] or not optionsToAdd[level].length
            level = (level for level, options of optionsToAdd when options.length)[0]  
        
        shuffledOptions = shuffle(optionsToAdd[level])
        @orderedOptions.push(option) for option in shuffledOptions[0...3]                 

        switch level  
            when 6
                @activeLevel = 'foreignHard'
            when 5
                @activeLevel = 'nativeHard'
            when 4
                @activeLevel = 'foreignMedium'
            when 3
                @activeLevel = 'nativeMedium'
            when 2
                @activeLevel = 'foreign'
            when 1
                @activeLevel = 'native'
            else
                @activeLevel = 'foreignHard'
        
        @activeType = @activeLevel.replace(/Medium/, '').replace(/Hard/, '')

        @displayLevel = if @activeType.match(/native/) then 'foreign' else 'native'
        
        @setStage() 
        
        return @orderedOptions[@orderedOptionsIndex]
            
    createGuesses: () ->
        guesses = @$('.guesses')
        @clearContainer(guesses)
        
        wordGroups = @separateIntoWordGroups(@scrambleInfo[@activeType])
        for group, index in wordGroups
            wordGroup = @createWordGroup(index)
            if not container or runningTotal + group.length > 18
                @positionContainer(container) if container
                container = @createContainer() 
                runningTotal = 0

            for letter in group 
                wordGroup.append(if letter.match(/\w|[^\x00-\x80]+/)? then @createGuess(letter) else @createSpace(letter))
            runningTotal += group.length

            container.append(wordGroup)
            guesses.append(container)

            @positionContainer(container) if index == wordGroups.length - 1

    createScramble: () ->
        scrambled = @$('.scrambled')
        @clearContainer(scrambled)

        wordGroups = @separateIntoWordGroups(@scrambleInfo[@activeType])
        for group, index in wordGroups
            wordGroup = @createWordGroup(index)
            if not container or runningTotal + group.length > 18
                @positionContainer(container) if container
                container = @createContainer() 
                runningTotal = 0
            else
                wordGroup.append(@createSpace(' '))
                runningTotal += 1

            for letter in @shuffleWord(@modifyScramble(group.join(''))) 
                wordGroup.append(@createLetter(letter)) if letter.match(/\w|[^\x00-\x80]+/)
            runningTotal += group.length

            container.append(wordGroup)
            scrambled.append(container)

            @positionContainer(container) if index == wordGroups.length - 1

    createContainer: (index) ->
        container = $(document.createElement("DIV"))
        container.addClass('container')

    positionContainer: (container) ->
        container.width(container.width())
        container.css(float: 'none', height: container.height())

    createWordGroup: (index) ->
        wordGroup = $(document.createElement("DIV"))
        wordGroup.addClass('word_group')
        wordGroup.addClass("color#{index + 1}")
        

    clearContainer: (container) -> container.find('.container, .correct, .guess, .letter, .space').remove()

    createGuess: (letter) ->
        guess = $(document.createElement("DIV"))
        guess.addClass('guess')
        guess.addClass("actual_letter_#{letter}")
        guess.bind 'click', () =>
            if guess.hasClass('selected')
                guess.removeClass('selected')
            else
                @$('.guesses .guess').removeClass('selected')
                guess.addClass('selected')

    createSpace: (letter) ->
        space = $(document.createElement("DIV"))
        space.addClass('space')
        space.html(letter)
        
    separateIntoWordGroups: (letters, halfRow=9) ->
        fullRow = halfRow * 2
        groups = [[]]
        for letter in letters
            optimalLetters = if fullRowRemaining then fullRowRemaining else halfRow
            group = groups[groups.length - 1]
            if group.length > optimalLetters && group.join().match(/\s/) 
                groups.push(nextGroup = [])
                nextGroup.push(group.pop()) while !group[group.length - 1].match(/\s/)?
                if fullRowRemaining
                    fullRowRemaining = null
                    if (previousGroup = groups[groups.length - 2])
                        while (firstWord = group.join().split('/\s/')[0]).length != group.length and group.length - firstWord.length > groups[groups.length - 2].length
                            group.replace("#{firstWord} ", '')
                            previousGroup.push(firstWordLetter) for firstWordLetter in firstWord
                else 
                    fullRow - group.length
                group = nextGroup.reverse()
                        
            group.push(letter)                
        return groups
        
    shuffleWord: (word) ->
        top = word.length
        return '' if not top
        return word if top == 1
        return (letter for letter in word).reverse().join('') if top == 2
        
        wordArray = (letter for letter in word)

        while(top--) 
            current = Math.floor(Math.random() * (top + 1))
            tmp = wordArray[current]
            wordArray[current] = wordArray[top]
            wordArray[top] = tmp
        
        shuffled = wordArray.join('')
        shuffled = @shuffleWord(shuffled) if shuffled == word
        return shuffled
        
    createLetter: (letter) ->
        letterContainer = $(document.createElement("DIV"))
        letterContainer.addClass('letter')
        letterContainer.addClass("letter_#{letter}")
        letterContainer.html(letter)
        @bindLetter(letterContainer)
        return letterContainer
        
    replaceLetterWithBlank: (letter) ->
        blankLetter = $(document.createElement("DIV"))
        blankLetter.addClass('blank_letter').addClass(letter.html())
        blankLetter.insertBefore(letter, @$(".scrambled .#{@containerClassName(letter)}"))

    replaceBlankWithLetter: (letter) ->
        containerClass = @containerClassName(letter)
        blankLetter = @$(".scrambled .#{containerClass} .#{letter.html()}")[0]
        return unless blankLetter?
        blankLetter = $(blankLetter)
        letter.remove().insertBefore(blankLetter, @$(".scrambled .#{containerClass}"))
        if letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)?
            letter.removeClass(letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[0])
            letter.removeClass('wrong_letter')
            letter.removeClass('correct_letter')
        blankLetter.remove()
        @bindLetter(letter)

    replaceGuessWithLetter: (guess, letter) ->
        $('.guesses .hidden_message').hide()
        $('.guesses .space').css(visibility: 'visible')

        guess = $(guess)
        letter.remove().insertBefore(guess, @$('.guesses'))
        letter.addClass(guess[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[0])
        guess.remove()
        @bindLetter(letter)
        @lettersAdded.push(letter.html())

        letterPosition = guess[0].className.indexOf('actual_letter_') + 'actual_letter_'.length
        guessLetter = guess[0].className[letterPosition..letterPosition]
        letter.addClass(if letter.html() == guessLetter then 'correct_letter' else 'wrong_letter')

        @next() if @checkCorrectAnswer()

    replaceLetterWithGuess: (letter) ->
        letterAddedIndex = @lettersAdded.indexOf(letter.html())
        @lettersAdded.slice(letterAddedIndex, letterAddedIndex + 1)
        actualLetter = letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[1]
        @createGuess(actualLetter).insertBefore(letter, @$(".guesses .#{@containerClassName(letter)}"))
        if letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)?
            letter.removeClass(letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[0])
            letter.removeClass('wrong_letter')
            letter.removeClass('correct_letter')

    clientX: (e) => e.clientX or (if e.targetTouches[0] then e.targetTouches[0].pageX else null)
    clientY: (e) => e.clientY or (if e.targetTouches[0] then e.targetTouches[0].pageY else null)

    containerClassName: (square) ->
        $(square).closest('.word_group')[0].className.match(/color\d+/)[0]

    guessInPath: (letter, lastX, lastY, currentX, currentY) ->
        letter = $(letter)
        xSlope = currentX - lastX
        ySlope = lastY - currentY
        if Math.abs(xSlope) < Math.abs(ySlope)
            xSlope = xSlope / Math.abs(ySlope)
            ySlope = ySlope / Math.abs(ySlope)
        else
            ySlope = ySlope / Math.abs(xSlope)
            xSlope = xSlope / Math.abs(xSlope)
        guesses = @$(".guesses .#{@containerClassName(letter)} .guess")
        for guess in guesses
            guess = $(guess)
            guessPosition = guess.offset()
            guessDims = guess.dim()
            for i in [2..14]
                x = currentX + (xSlope * (((i % 12) - 2) * 10))
                y = currentY - (ySlope * (((i % 12) - 2) * 10))
                # marker = $(document.createElement("DIV"))
                # marker.css(position: 'absolute', top: y + 2, left: x - 2, width: 4, height: 4, backgroundColor: 'red')
                # @el.append(marker)
                continue if x < guessPosition.left
                continue if x > guessPosition.left + guessDims.width
                continue if y > guessPosition.top + guessDims.height
                continue if y < guessPosition.top
                return guess
        return null

    checkCorrectAnswer: () ->
        @$('.guesses .letter, .guesses .space').map((html) -> $(html).html()).join('') == (@scrambleInfo[@activeType])

    modifyScramble: (word) ->
        return word unless word.length < 6
        commonLetters = (letter for letter in 'etaoinshrdlumkpcd')
        add = (6 - word.length)
        add = 2 if add > 2
        word += (commonLetters[Math.floor(Math.random() * commonLetters.length)]) for i in [0...add]
        return word
            
    setStage: () ->
        @$('.guesses').removeClass('hidden')
        @$('.scrambled').removeClass('hidden') 
        @$('.scramble_content').removeClass('show_keyboard')      
        if @activeLevel.match(/Medium/)? or @activeLevel.match(/Hard/)?
            @$('.guesses').addClass('hidden')
            @$('.guesses .hidden_message').show()

        if @activeLevel.match(/Hard/)?
            @$('.scrambled').addClass('hidden')       
            @$('.scrambled .hidden_message').show()
            @$('.scramble_content').addClass('show_keyboard')
    
    setProgress: ->
        if not @$(".progress_meter .bar .#{@level.data[0].id}").length
            @$('.progress_meter').animate
                opacity: 0
                duration: 300
                complete: () => 
                    @$('.progress_meter .bar .progress_section').remove()
                    for scramble, index in @level.data
                        section = $(document.createElement("DIV"))
                        section.addClass('progress_section')
                        section.addClass(scramble.id)
                        section.css(borderRight: 'none') if (index + 1) == @level.data.length
                        @$('.progress_meter .bar').append(section)
                        @updateProgress()
                        @$('.progress_meter').animate
                            opacity: 1
                            duration: 300
        else
            @updateProgress()
    
    updateProgress: ->
        for scrambleInfo in @level.data
            id = scrambleInfo.id
            level = @puzzleData.levels[@languages][@levelName][id]
            if level
                level = @maxLevel if level > @maxLevel
                @$(".progress_meter .bar .#{id}").css(opacity: 1 - ((1/@maxLevel) * level))
            else
                @$(".progress_meter .bar .#{id}").css(opacity: 1)
    
    next: () ->
        @saveLevel()

        correct = $(document.createElement('DIV'))
        if @scrambleInfo["#{@activeType}Sentence"]? && @scrambleInfo["#{@activeType}Sentence"].length
            correctSentence = @scrambleInfo["#{@activeType}Sentence"] 
        else 
            correctSentence = @scrambleInfo[@activeType]

        correctSentence = " #{correctSentence} "
        highlighted = @scrambleInfo[@activeType]
        for boundary in [' ', '?', ',']
            correctSentence = correctSentence.replace(" #{highlighted}#{boundary}", " <span class='highlighted'>#{highlighted}</span>#{boundary}")           

        correct.html(correctSentence)
        correct.addClass('correct')
        correct.css(opacity: 0)
        scrambled = @$('.scrambled')
        @clearContainer(scrambled)
        @$('.scrambled .hidden_message').hide()
        @$('.scrambled').css(width: null)
        scrambled.append(correct)

        displayedSentence = @$('.display_words').html()

        # @$('.last_answer').animate
        #     opacity: 0
        #     duration: 300

        nextShown = false
        showNext = () =>
            return if nextShown
            @el.unbind 'click'
            @el.unbind 'touchstart'
            $('#clickarea').unbind 'keyup'
            nextShown = true
            @setProgress()
            @$('.foreign_words, .scrambled, .guesses').animate
                opacity: 0
                duration: 500
                complete: () =>
                    @$('.scrambled, .guesses').css(width: null, height: null)
                    @newScramble()
                    @$('.foreign_words, .scrambled, .guesses').animate
                        opacity: 1
                        duration: 300
                        complete: () =>
                            # @$('.last_answer').html("#{displayedSentence} = #{correctSentence}")
                            # @$('.last_answer').animate
                            #     opacity: 1
                            #     duration: 300

        correct.animate
            opacity: 1
            duration: 500
            complete: () =>
                $.timeout 500 + (30 * correctSentence.length), () => showNext()
                @el.bind 'click', () => showNext()
                @el.bind 'touchstart', () => showNext()
                $('#clickarea').bind 'keyup', (e) => showNext()

    nextLevel: () ->        
        nextLevel = @languageData.levels[@level.nextLevel]
        if nextLevel?
            @$('#next_level .next_level_link').html(nextLevel.title)
            message = @$('#next_level')

        resetLevel = () =>
            if confirm('Are you sure you want to reset this level?')
                @$('reset_level_link').unbind 'click'
                @puzzleData.levels[@languages][@levelName] = {}
                @saveProgress(@puzzleData)
                showLevel(@levelName)

        showLevel = (levelName) =>
            @$('#next_level .next_level_link').unbind 'click'
            @setLevel(levelName)
            @$('#next_level').animate
                opacity: 0
                duration: 500
                complete: () =>
                    @newScramble()
                    @$('.scramble_content').animate
                        opacity: 1
                        duration: 500             

        @$('.scramble_content').animate
            opacity: 0
            duration: 500
            complete: () =>
                message.css
                    top: 150
                    left: ($('.language_scramble').width() - @$('#next_level').width()) / 2
                @$('#next_level .reset_level_link').bind 'click', () => resetLevel()
                @$('#next_level .next_level_link').bind 'click', () => showLevel(@level.nextLevel)
                @$('#next_level').animate
                    opacity: 1
                    duration: 1000








languageScramble.data =
    english_italian: 
        displayName: "English - Italian"
        levels:
            top10words: 
                title: 'Top 10 Words'
                subtitle: 'The 10 most frequently used Italian words.'
                nextLevel: 'top10phrases'
                data: [
                    {native: 'not', foreign: 'non', nativeSentence: 'that\'s not necessary', foreignSentence: 'non è necessario'},
                    {native: 'of', foreign: 'di', nativeSentence: 'here is a list of options', foreignSentence: 'ecco un elenco di opzioni'},
                    {native: 'what', foreign: 'che', nativeSentence: 'what luck', foreignSentence: 'che fortuna'},
                    {native: 'is', foreign: 'è', nativeSentence: 'what day is it?', foreignSentence: 'che giorno è?'},
                    {native: 'and', foreign: 'e', nativeSentence: 'big and tall', foreignSentence: 'grande e grosso'},
                    {native: 'the', foreign: 'la', nativeSentence: 'drop the ball now', foreignSentence: 'cadere la palla ora'},
                    {native: 'the', foreign: 'il', nativeSentence: 'how much does the book cost?', foreignSentence: 'quanto costa il libro?'},
                    {native: 'a', foreign: 'un', nativeSentence: 'a little more', foreignSentence: 'un po più'},
                    {native: 'for', foreign: 'per', nativeSentence: 'where is the food for dinner?', foreignSentence: 'dove è il cibo per la cena?'},
                    {native: 'are', foreign: 'sono', nativeSentence: 'there are five houses on this road', foreignSentence: 'ci sono cinque case su questa strada'},
                ]
            top10phrases: 
                title: 'Phrases For The Top 10 Words'
                subtitle: 'Phrases containing the 10 most frequently used Italian words'
                nextLevel: 'top25words'
                data: [
                    {native: 'that\'s not necessary', foreign: 'non è necessario'},
                    {native: 'here is a list of options', foreign: 'ecco un elenco di opzioni'},
                    {native: 'what luck', foreign: 'che fortuna'},
                    {native: 'what day is it?', foreign: 'che giorno è?'},
                    {native: 'big and tall', foreign: 'grande e grosso'},
                    {native: 'drop the ball now', foreign: 'cadere la palla ora'},
                    {native: 'how much does the book cost?', foreign: 'quanto costa il libro?'},
                    {native: 'a little more', foreign: 'un po più'},
                    {native: 'where is the food for dinner?', foreign: 'dove è il cibo per la cena?'},
                    {native: 'there are five houses on this road', foreign: 'ci sono cinque case su questa strada'},
                ]
            top25words:
                title: 'Top 10 - 25 Words'
                subtitle: 'The 10 - 25 most frequently used Italian words'
                nextLevel: 'top25phrases'        
                data: [
                    {native: 'i have', foreign: 'ho', nativeSentence: 'i have twenty dollars', foreignSentence: 'ho venti dollari'},
                    {native: 'but', foreign: 'ma', nativeSentence: 'i was going to but i can not', foreignSentence: 'stavo andando ma non posso'},
                    {native: 'he has', foreign: 'ha', nativeSentence: 'he has a big house', foreignSentence: 'ha una grande casa'},
                    {native: 'with', foreign: 'con', nativeSentence: 'i\'m coming with you', foreignSentence: 'vengo con te'},
                    {native: 'what', foreign: 'cosa', nativeSentence: 'what do you like to do?', foreignSentence: 'cosa ti piace fare?'},
                    {native: 'if', foreign: 'se', nativeSentence: 'what if he wins?', foreignSentence: 'cosa succede se vince?'},
                    {native: 'i', foreign: 'io', nativeSentence: 'i am going to the markets', foreignSentence: 'io vado ai mercati'},
                    {native: 'how', foreign: 'come', nativeSentence: 'how are you?', foreignSentence: 'come stai?'}
                    {native: 'there', foreign: 'ci', nativeSentence: 'there are three friends', foreignSentence: 'ci sono tre amici'},
                    {native: 'this', foreign: 'questo', nativeSentence: 'this is fantastic', foreignSentence: 'questo è fantastico'},
                    {native: 'here', foreign: 'qui', nativeSentence: 'come here', foreignSentence: 'vieni qui'},
                    {native: 'you have', foreign: 'hai', nativeSentence: 'you have ten minutes', foreignSentence: 'hai dieci minuti'},
                    {native: 'six', foreign: 'sei', nativeSentence: 'there are six doors', foreignSentence: 'ci sono sei porte'},
                    {native: 'well', foreign: 'bene', nativeSentence: 'are you well?', foreignSentence: 'stai bene?'},
                    {native: 'yes', foreign: 'sì', nativeSentence: 'yes, you can', foreignSentence: 'sì, è possibile'},
                ]
            top25phrases: 
                title: 'Phrases For The Top 10 - 25 Words'
                subtitle: 'Phrases for 10 - 25 most frequently used Italian words'
                nextLevel: 'top50words'
                data: [
                    {native: 'i have twenty dollars', foreign: 'ho venti dollari'},
                    {native: 'i was going to but i can not', foreign: 'stavo andando ma non posso'},
                    {native: 'he has a big house', foreign: 'ha una grande casa'},
                    {native: 'i\'m coming with you', foreign: 'vengo con te'},
                    {native: 'what do you like to do?', foreign: 'cosa ti piace fare?'},
                    {native: 'what if he wins?', foreign: 'cosa succede se vince?'},
                    {native: 'i am going to the markets', foreign: 'io vado ai mercati'},
                    {native: 'how are you?', foreign: 'come stai?'}
                    {native: 'there are three friends', foreign: 'ci sono tre amici'},
                    {native: 'this is fantastic', foreign: 'questo è fantastico'},
                    {native: 'come here', foreign: 'vieni qui'},
                    {native: 'you have ten minutes', foreign: 'hai dieci minuti'},
                    {native: 'there are six doors', foreign: 'ci sono sei porte'},
                    {native: 'are you well?', foreign: 'stai bene?'},
                    {native: 'yes, you can', foreign: 'sì, è possibile'},
                ]
            top50words:
                title: 'Top 25 - 50 Words'
                subtitle: 'The 25 - 50 most frequently used Italian words'
                nextLevel: 'top50phrases'
                data: [
                    {native: 'more', foreign: 'più', nativeSentence: 'a little more', foreignSentence: 'un po più'},
                    {native: 'my', foreign: 'mio', nativeSentence: 'my child is seven years old', foreignSentence: 'mio figlio ha sette anni'},
                    {native: 'because', foreign: 'perché', nativeSentence: 'because i want to', foreignSentence: 'perché voglio'},
                    {native: 'why', foreign: 'perché', nativeSentence: 'why do you want to go?', foreignSentence: 'perché vuoi andare?'},
                    {native: 'she', foreign: 'lei', nativeSentence: 'she leaves tomorrow', foreignSentence: 'lei parte domani'},
                    {native: 'only', foreign: 'solo', nativeSentence: 'it was only fifteen minutes', foreignSentence: 'era solo quindici minuti'},
                    {native: 'was', foreign: 'era', nativeSentence: 'it was thirty years ago', foreignSentence: 'era trent\'anni fa'},
                    {native: 'all', foreign: 'tutti', nativeSentence: 'all of the king\'s horses', foreignSentence: 'tutti i cavalli del re'},
                    {native: 'so-so', foreign: 'così-così', nativeSentence: 'i am feeling so-so', foreignSentence: 'mi sento così-così'},
                    {native: 'hello', foreign: 'ciao', nativeSentence: 'hello my friend', foreignSentence: 'ciao amico mio'},
                    {native: 'this', foreign: 'questo', nativeSentence: 'this is the best food', foreignSentence: 'questo è il miglior cibo'},
                    {native: 'to do', foreign: 'fare', nativeSentence: 'if you want to do this', foreignSentence: 'se si vuole fare questo'},
                    {native: 'when', foreign: 'quando', nativeSentence: 'when is the show?', foreignSentence: 'quando è lo spettacolo?'},
                    {native: 'now', foreign: 'ora', nativeSentence: 'drop the ball now', foreignSentence: 'cadere la palla ora'},
                    {native: 'you did', foreign: 'hai fatto', nativeSentence: 'you did your best', foreignSentence: 'hai fatto del tuo meglio'},
                    {native: 'to be', foreign: 'essere', nativeSentence: 'i want to be an astronaut', foreignSentence: 'voglio essere un astronauta'},
                    {native: 'never', foreign: 'mai', nativeSentence: 'i have never been to the coast', foreignSentence: 'non sono mai stato alla costa'},
                    {native: 'who', foreign: 'chi', nativeSentence: 'who are you?', foreignSentence: 'chi sei?'},
                    {native: 'or', foreign: 'o', nativeSentence: 'pizza or pasta', foreignSentence: 'pizza o la pasta'},
                    {native: 'all', foreign: 'tutti', nativeSentence: 'he ate all of the cookies', foreignSentence: 'ha mangiato tutti i cookie'},
                    {native: 'very', foreign: 'molto', nativeSentence: 'he is very old', foreignSentence: 'lui è molto vecchio'},
                    {native: 'also', foreign: 'anche', nativeSentence: 'i also need two pencils', foreignSentence: 'ho anche bisogno di due matite'},
                    {native: 'he said', foreign: 'ha detto', nativeSentence: 'he said go left', foreignSentence: 'ha detto andate a sinistra'},
                    {native: 'that', foreign: 'quella', nativeSentence: 'that lady ate my cheese', foreignSentence: 'quella signora mangiato il mio formaggio'},
                    {native: 'nothing', foreign: 'niente', nativeSentence: 'there was nothing there', foreignSentence: 'non c\'era niente'},
                ]
            top50Phrases:
                title: 'Phrases For The Top 25 - 50 Words'
                subtitle: 'Phrases for the 25 - 50 most frequently used Italian words'
                nextLevel: 'top75words'
                data: [
                    {native: 'a little more', foreign: 'un po più'},
                    {native: 'my child is seven years old', foreign: 'mio figlio ha sette anni'},
                    {native: 'because i want to', foreign: 'perché voglio'},
                    {native: 'why do you want to go?', foreign: 'perché vuoi andare?'},
                    {native: 'she leaves tomorrow', foreign: 'lei parte domani'},
                    {native: 'it was only fifteen minutes', foreign: 'era solo quindici minuti'},
                    {native: 'it was thirty years ago', foreign: 'era trent\'anni fa'},
                    {native: 'all of the king\'s horses', foreign: 'tutti i cavalli del re'},
                    {native: 'i am feeling so-so', foreign: 'mi sento così-così'},
                    {native: 'hello my friend', foreign: 'ciao amico mio'},
                    {native: 'this is the best food', foreign: 'questo è il miglior cibo'},
                    {native: 'if you want to do this', foreign: 'se si vuole fare questo'},
                    {native: 'when is the show?', foreign: 'quando è lo spettacolo?'},
                    {native: 'drop the ball now', foreign: 'cadere la palla ora'},
                    {native: 'you did your best', foreign: 'hai fatto del tuo meglio'},
                    {native: 'i want to be an astronaut', foreign: 'voglio essere un astronauta'},
                    {native: 'i have never been to the coast', foreign: 'non sono mai stato alla costa'},
                    {native: 'who are you?', foreign: 'chi sei?'},
                    {native: 'pizza or pasta', foreign: 'pizza o la pasta'},
                    {native: 'he ate all of the cookies', foreign: 'ha mangiato tutti i cookie'},
                    {native: 'he is very old', foreign: 'lui è molto vecchio'},
                    {native: 'i also need two pencils', foreign: 'ho anche bisogno di due matite'},
                    {native: 'he said go left', foreign: 'ha detto andate a sinistra'},
                    {native: 'that lady ate my cheese', foreign: 'quella signora mangiato il mio formaggio'},
                    {native: 'there was nothing there', foreign: 'non c\'era niente'},
                ]
            top75words:
                title: 'Top 50 - 75 Words'
                subtitle: 'The 50 - 75 most frequently used Italian words'
                nextLevel: 'top75phrases'
                data: [
                    {native: 'to him', foreign: 'gli', nativeSentence: 'i will speak to him', foreignSentence: 'gli voglio parlare'},
                    {native: 'everything', foreign: 'tutto', nativeSentence: 'the one who has everything can lose everything', foreignSentence: 'chi ha tutto può perdere tutto'},
                    {native: 'of', foreign: 'della', nativeSentence: 'celebriamo la festa della mamma in onore delle nostre madri', foreignSentence: 'we celebrate mother\'s day in honor of our mothers'},
                    {native: 'so', foreign: 'così', nativeSentence: 'what made her so sad?', foreignSentence: 'cosa l\'ha resa così triste?'},
                    {native: 'mia', foreign: 'my', nativeSentence: 'my mother is older than my father', foreignSentence: 'mia madre è più vecchio di mio padre'},
                    {native: 'neither', foreign: 'ne', nativeSentence: 'he knows neither french nor german', foreignSentence: 'non sa né il francese né il tedesco'},
                    {native: 'this', foreign: 'questa', nativeSentence: 'this house and this land are mine', foreignSentence: 'questa casa e questa terra sono mie'},
                    {native: 'be', foreign: 'fare', nativeSentence: 'you must be careful not to drop the eggs', foreignSentence: 'dovete fare attenzione a non fare cadere le uova'},
                    {native: 'when', foreign: 'quando', nativeSentence: 'when i hear that song i think about when i was young', foreignSentence: 'quando sento quella canzone penso a quando ero piccolo'},
                    {native: 'time', foreign: 'ora', nativeSentence: 'what time does the plane leave?', foreignSentence: 'a che ora decolla l\'aereo?'}
                    {native: 'did', foreign: 'fatto', nativeSentence: 'did you have a good trip?', foreignSentence: 'hai fatto un buon viaggio?'},
                    {native: 'to be', foreign: 'essere', nativeSentence: 'it is never too late to be what you could have been', foreignSentence: 'non è mai troppo tardi per essere ciò che avresti potuto essere.'},
                    {native: 'know', foreign: 'so', nativeSentence: 'i know the answer', foreignSentence: 'non so se avrò il tempo di farlo'},
                    {native: 'never', foreign: 'mai', nativeSentence: 'never give up', foreignSentence: 'mai rinunciare'},
                    {native: 'who', foreign: 'chi', nativeSentence: 'who is it?', foreignSentence: 'chi é?'},
                    {native: 'or', foreign: 'o', nativeSentence: 'don\'t pour hot water in to the glass or it will crack', foreignSentence: 'non versare acqua calda nel bicchiere o si romperà'},
                    {native: 'at the', foreign: 'alla', nativeSentence: 'i bought this book at the bookstore', foreignSentence: 'ho comprato questo libro alla libreria'},
                    {native: 'very', foreign: 'molto', nativeSentence: 'italy is a very beautiful country', foreignSentence: 'l\'italia è un paese molto bello'},
                    {native: 'also', foreign: 'anche', nativeSentence: 'excuse me, we\'re in a hurry also', foreignSentence: 'scusami, ma abbiamo anche noi fretta'},
                    {native: 'said', foreign: 'detto', nativeSentence: 'she may have said so', foreignSentence: 'potrebbe aver detto ciò'},
                    {native: 'that', foreign: 'quello', nativeSentence: 'that\'s not what i heard', foreignSentence: 'quello non è ciò che ho sentito io'},
                    {native: 'goes', foreign: 'va', nativeSentence: 'my father goes to work on a bike', foreignSentence: 'mio padre va a lavorare in bici'},
                    {native: 'nothing', foreign: 'niente', nativeSentence: 'he did nothing wrong', foreignSentence: 'non fece niente di male'},
                    {native: 'thank you', foreign: 'grazie', nativeSentence: 'thank you for your invitation', foreignSentence: 'grazie per il vostro invito'},
                    {native: 'he', foreign: 'lui', nativeSentence: 'he is very tall', foreignSentence: 'lui è molto alto'}
                ]
            top75phrases:
                title: 'Phrases For The Top 50 - 75 Words'
                subtitle: 'Phrases for the 50 - 75 most frequently used Italian words'
                data: [
                    {native: 'i will speak to him', foreign: 'gli voglio parlare'},
                    {native: 'the one who has everything can lose everything', foreign: 'chi ha tutto può perdere tutto'},
                    {native: 'celebriamo la festa della mamma in onore delle nostre madri', foreign: 'we celebrate mother\'s day in honor of our mothers'},
                    {native: 'what made her so sad?', foreign: 'cosa l\'ha resa così triste?'},
                    {native: 'my mother is older than my father', foreign: 'mia madre è più vecchio di mio padre'},
                    {native: 'he knows neither french nor german', foreign: 'non sa né il francese né il tedesco'},
                    {native: 'this house and this land are mine', foreign: 'questa casa e questa terra sono mie'},
                    {native: 'you must be careful not to drop the eggs', foreign: 'dovete fare attenzione a non fare cadere le uova'},
                    {native: 'when i hear that song i think about when i was young', foreign: 'quando sento quella canzone penso a quando ero piccolo'},
                    {native: 'what time does the plane leave?', foreign: 'a che ora decolla l\'aereo?'}
                    {native: 'did you have a good trip?', foreign: 'hai fatto un buon viaggio?'},
                    {native: 'it is never too late to be what you could have been', foreign: 'non è mai troppo tardi per essere ciò che avresti potuto essere.'},
                    {native: 'i know the answer', foreign: 'non so se avrò il tempo di farlo'},
                    {native: 'never give up', foreign: 'mai rinunciare'},
                    {native: 'who is it?', foreign: 'chi é?'},
                    {native: 'don\'t pour hot water in to the glass or it will crack', foreign: 'non versare acqua calda nel bicchiere o si romperà'},
                    {native: 'i bought this book at the bookstore', foreign: 'ho comprato questo libro alla libreria'},
                    {native: 'italy is a very beautiful country', foreign: 'l\'italia è un paese molto bello'},
                    {native: 'excuse me, we\'re in a hurry also', foreign: 'scusami, ma abbiamo anche noi fretta'},
                    {native: 'she may have said so', foreign: 'potrebbe aver detto ciò'},
                    {native: 'that\'s not what i heard', foreign: 'quello non è ciò che ho sentito io'},
                    {native: 'my father goes to work on a bike', foreign: 'mio padre va a lavorare in bici'},
                    {native: 'he did nothing wrong', foreign: 'non fece niente di male'},
                    {native: 'thank you for your invitation', foreign: 'grazie per il vostro invito'},
                    {native: 'he is very tall', foreign: 'lui è molto alto'}
                ]
        

x = [
    {native: 'thanks', foreign: 'grazie', nativeSentence: 'thanks for the help', foreignSentence: 'grazie per l\'aiuto'},
    {native: 'he', foreign: 'lui', nativeSentence: 'he is eighteen years old', foreignSentence: 'lui ha diciotto anni'},
    {native: 'i want', foreign: 'voglio', nativeSentence: 'i want a new car', foreignSentence: 'voglio una macchina nuova'},
    {native: 'we have a house', foreign: 'abbiamo una casa'},
    {native: 'we have a car', foreign: 'abbiamo un auto'},
    {native: 'we have an oven', foreign: 'abbiamo un forno'},
    {native: 'state', foreign: 'stato', nativeSentence: 'the dog was in a state of frenzy', foreignSentence: 'il cane era in uno stato di frenesia'},
    {native: 'in', foreign: 'nel', nativeSentence: 'throw it in the bucket', foreignSentence: 'gettarlo nel secchio'},
    {native: 'his', foreign: 'il suo', nativeSentence: 'his favorite flavor', foreignSentence: 'il suo gusto preferito'},
    {native: 'where', foreign: 'dove', nativeSentence: 'where are my keys', foreignSentence: 'dove sono le mie chiavi'},
    {native: 'i can find', foreign: 'posso trovare'},
    {native: 'i can walk', foreign: 'posso camminare'},
    {native: 'i can live', foreign: 'posso abitare'},
    {native: 'first', foreign: 'prima', nativeSentence: 'she was the first to finish', foreignSentence: 'fu la prima a finire'},
    {native: 'we are', foreign: 'siamo', nativeSentence: 'we are all twins', foreignSentence: 'siamo tutti gemelli'},
    {native: 'your', foreign: 'tuo', nativeSentence: 'your brother is here', foreignSentence: 'tuo fratello è qui'},
    {native: 'they have', foreign: 'hanno', nativeSentence: 'they have seventeen stereos', foreignSentence: 'hanno diciassette impianti stereo'},
    {native: 'ago', foreign: 'fa', nativeSentence: 'they started dating eight years ago', foreignSentence: 'hanno cominciato a frequentarsi otto anni fa'},
    {native: 'two', foreign: 'due', nativeSentence: 'we saw two planes', foreignSentence: 'abbiamo visto due aerei'},
    {native: 'you want', foreign: 'vuoi', nativeSentence: 'you want three slices?', foreignSentence: 'vuoi tre fette?'},
    {native: 'something', foreign: 'qualcosa', nativeSentence: 'there is something wrong', foreignSentence: 'c\'è qualcosa di sbagliato'},
    {native: 'true', foreign: 'vero', nativeSentence: 'is it true?', foreignSentence: 'è vero?'},
    {native: 'home', foreign: 'casa', nativeSentence: 'i am going home', foreignSentence: 'sto andando a casa'},
    {native: 'on', foreign: 'su', nativeSentence: 'the man is standing on a mountain', foreignSentence: 'uomo è in piedi su una montagna'},
    {native: 'your', foreign: 'tuo', nativeSentence: 'what is your favorite movie?', foreignSentence: 'qual è il tuo film preferito?'},
    {native: 'always', foreign: 'sempre', nativeSentence: 'it is always cold', foreignSentence: 'è sempre freddo'},
    {native: 'perhaps', foreign: 'forse', nativeSentence: 'perhaps i can help', foreignSentence: 'forse mi può aiutare'},
    {native: 'to say', foreign: 'dire', nativeSentence: 'i want to say something', foreignSentence: 'voglio dire qualcosa'},
    {native: 'their', foreign: 'loro', nativeSentence: 'their house is beautiful', foreignSentence: 'la loro casa è bella'},
    {native: 'another', foreign: 'un altro', nativeSentence: 'can i have another chocolate?', foreignSentence: 'posso avere un altro cioccolato?'},
    {native: 'you know', foreign: 'sai', nativeSentence: 'do you know his name?', foreignSentence: 'sai il suo nome?'},
    {native: 'i have to walk', foreign: 'devo camminare'},
    {native: 'i have to go', foreign: 'devo andare'},
    {native: 'that', foreign: 'quella', nativeSentence: 'that lady is happy', foreignSentence: 'quella signora è felice'},
    {native: 'life', foreign: 'vita', nativeSentence: 'he lived a fun life', foreignSentence: 'ha vissuto una vita divertente'},
    {native: 'that', foreign: 'quel', nativeSentence: 'that cat is fast', foreignSentence: 'quel gatto è veloce'},
    {native: 'time', foreign: 'tempo', nativeSentence: 'do we have enough time?', foreignSentence: 'abbiamo abbastanza tempo?'},
    {native: 'to go', foreign: 'andare', nativeSentence: 'he wants to go to the movies', foreignSentence: 'vuole andare al cinema'},
    {native: 'sure', foreign: 'certo'},
    {native: 'then', foreign: 'poi', nativeSentence: 'we went to dinner and then went to a concert', foreignSentence: 'siamo andati a cena e poi è andato a un concerto'},
    {native: 'man', foreign: 'uomo', nativeSentence: 'a man stole my purse', foreignSentence: 'un uomo ha rubato la mia borsa'},
    {native: 'sir', foreign: 'signore', nativeSentence: 'excuse me sir', foreignSentence: 'mi scusi signore'},
    {native: 'a little', foreign: 'un po', nativeSentence: 'can we have some candy?', foreignSentence: 'possiamo avere un po \'di caramelle?'},
    {native: 'i can', foreign: 'può', nativeSentence: 'i can talk for hours', foreignSentence: 'può parlare per ore'},
    {native: 'i think', foreign: 'credo', nativeSentence: 'i believe she is correct', foreignSentence: 'credo che sia corretto'},
    {native: 'already', foreign: 'già', nativeSentence: 'he already has three dogs', foreignSentence: 'che ha già tre cani'},
    {native: 'now', foreign: 'adesso', nativeSentence: 'i need to leave now', foreignSentence: 'ho bisogno di partire adesso'},
    {native: 'let\'s go', foreign: 'andiamo', nativeSentence: 'let\'s go to the park', foreignSentence: 'andiamo al parco'},
    {native: 'years', foreign: 'anni', nativeSentence: 'he is twelve years old', foreignSentence: 'lui ha dodici anni'},
    {native: 'seen', foreign: 'visto', nativeSentence: 'have you seen my keys', foreignSentence: 'avete visto le mie chiavi'},
    {native: 'outside', foreign: 'fuori', nativeSentence: 'let\'s go for a hike outside', foreignSentence: 'andiamo a fare una passeggiata fuori'},
    {native: 'only one', foreign: 'solo uno', nativeSentence: 'only one for me', foreignSentence: 'solo uno per me'},
    {native: 'how long', foreign: 'quanto tempo', nativeSentence: 'how long until you graduate?', foreignSentence: 'quanto tempo fino a laurearsi?'},
    {native: 'one time', foreign: 'una volta', nativeSentence: 'i\'ve only seen that movie one time', foreignSentence: 'ho solo visto quel film una sola volta'},
    {native: 'will be', foreign: 'sarà', nativeSentence: 'climbing a mountain will always be a goal', foreignSentence: 'scalare una montagna sarà sempre un obiettivo'},
    {native: 'after', foreign: 'dopo', nativeSentence: 'let\s go to the park after the movie', foreignSentence: 'andiamo al parco dopo il film'},
    {native: 'without', foreign: 'senza', nativeSentence: 'i\'m not leaving without you', foreignSentence: 'non me ne vado senza di te'},
    {native: 'things', foreign: 'cose', nativeSentence: 'too many things can go wrong', foreignSentence: 'troppe cose possono andare storte'},
    {native: 'nobody', foreign: 'nessuno', nativeSentence: 'so nobody heard anything?', foreignSentence: 'quindi nessuno ha sentito niente?'},
    {native: 'day', foreign: 'giorno', nativeSentence: 'every day i learn something new', foreignSentence: 'ogni giorno imparo qualcosa di nuovo'},
    {native: 'best', foreign: 'meglio', nativeSentence: 'do your best', foreignSentence: 'fate del vostro meglio'},
    {native: 'father', foreign: 'padre', nativeSentence: 'my father is sixty years old', foreignSentence: 'mio padre ha sessanta anni'},
    {native: 'you can', foreign: 'puoi', nativeSentence: 'you can do this', foreignSentence: 'puòi fare questo'},
    {native: 'hello', foreign: 'ciao', nativeSentence: 'hello my friend', foreignSentence: 'ciao amico mio'},
    {native: 'you need to', foreign: 'devi', nativeSentence: 'you need to do this for me', foreignSentence: 'è necessario fare questo per me'},
    {native: 'here', foreign: 'ecco', nativeSentence: 'here is the cat', foreignSentence: 'ecco qui il gatto'},
    {native: 'someone', foreign: 'qualcuno', nativeSentence: 'i know someone who can help', foreignSentence: 'conosco qualcuno che può aiutare'},
    {native: 'work', foreign: 'lavoro', nativeSentence: 'i have a lot of work to do', foreignSentence: 'ho un sacco di lavoro da fare'},
    {native: 'he knows', foreign: 'sa', nativeSentence: 'he knows who you are', foreignSentence: 'sa chi sei'},
    {native: 'to', foreign: 'ai', nativeSentence: 'i\'m going to the markets', foreignSentence: 'io vado ai mercati'},
    {native: 'to see', foreign: 'vedere', nativeSentence: 'i\'d like to see that one day', foreignSentence: 'mi piacerebbe vedere che un giorno'},
    {native: 'every', foreign: 'ogni', nativeSentence: 'i think about her every day', foreignSentence: 'ogni giorno penso a lei'},
    {native: 'too much', foreign: 'troppo', nativeSentence: 'how much is too much?', foreignSentence: 'quanto è troppo?'},
    {native: 'i missed you so much', foreign: 'mi sei mancato molto'}
    {native: 'good morning', foreign: 'buongiorno'}
    {native: 'good evening', foreign: 'buona sera'}
    {native: 'how are you?', foreign: 'come stai?'}
    {native: 'goodbye', foreign: 'arrivederci'}    
    {native: 'what a shame', foreign: 'che peccato'}
    {native: 'i can\'t believe it', foreign: 'non ci posso credere'}
    {native: 'what time is it?', foreign: 'che ore sono?'}
    {native: 'can you help me?', foreign: 'mi puoi aiutare?'}
    {native: 'i\'m running late', foreign: 'sono in ritardo'}
    {native: 'how\'s your family?', foreign: 'come sta la tua famiglia?'}
    {native: 'where do you work?', foreign: 'dove lavori?'}
    {native: 'where are you from?', foreign: 'di dove sei?'}
    {native: 'are you from around here?', foreign: 'sei di qui?'}
    {native: 'where do you live?', foreign: 'dove vivi?'}
    {native: 'how old are you?', foreign: 'quanti anni hai?'}
    {native: 'what\'s your phone number?', foreign: 'qual\'è il tuo numero di telefono?'}
    {native: 'what do you like to do?', foreign: 'cosa ti piace fare?'}
    {native: 'i need to use the restroom', foreign: 'devo andare in bagno'}
    {native: 'i\'ll be right back', foreign: 'torno subito'}
    {native: 'please repeat', foreign: 'ripeti, per favore'}
    {native: 'are you kidding?', foreign: 'stai scherzando?'}
    {native: 'just kidding', foreign: 'scherzo'}
    {native: 'talk to you later', foreign: 'ci sentiamo dopo'}
    {native: 'see you soon', foreign: 'a presto'}
    {native: 'the cat loves to sing and dance', foreign: 'il gatto ama cantare e ballare'}
    {native: 'the man walked down the street', foreign: 'l\'uomo camminava per la strada'}
    {native: 'how many apples are there?', foreign: 'quante mele ci sono?'}
    {native: 'i know how to play guitar', foreign: 'so come suonare la chitarra'}
    {native: 'she can run a mile very quickly', foreign: 'lei può eseguire un miglio molto rapidamente'}
    {native: 'that pizza is fantastic', foreign: 'quella pizza è fantastico'}
    {native: 'it\'s a beautiful day outside', foreign: 'è una bella giornata fuori'}
    {native: 'where were you?', foreign: 'dove eravate?'}
    {native: 'bright light', foreign: 'luce brillante'}
    {native: 'red carpet', foreign: 'tappeto rosso'}
    {native: 'heavy door', foreign: 'pesante porta'}
    {native: 'messy bedroom', foreign: 'camera da letto disordinato'}
    {native: 'the bird flew fast', foreign: 'l\'uccello volò veloce'}
    {native: 'be careful with the sharp knife', foreign: 'stare attenti con il coltello affilato'}
    {native: 'eat your vegetables', foreign: 'mangiare le verdure'}
    {native: 'the steak was juicy', foreign: 'la bistecca era succosa'}
    {native: 'i am hungry', foreign: 'ho fame'}
    {native: 'i am tired', foreign: 'sono stanco'}
    {native: 'he was very sleepy', foreign: 'era molto sonno'}
    {native: 'he failed his test', foreign: 'ha fallito la sua prova'}
    {native: 'they are late', foreign: 'sono in ritardo'}
    {native: 'a lot of money', foreign: 'un sacco di soldi'}
    {native: 'exercise is healthy', foreign: 'esercizio è sano'}
    {native: 'where is it?', foreign: 'dov\'è?'}
    {native: 'where are you going?', foreign: 'dove va?'}
    {native: 'when does the museum open?', foreign: 'quando apre il museo?'}
    {native: 'when does the train arrive?', foreign: 'quando arriva il treno?'}
    {native: 'how much is that?', foreign: 'quanto costa?'}
    {native: 'how many are there?', foreign: 'quanti ce ne sono?'}
    {native: 'why is that?', foreign: 'perchè?'}
    {native: 'why not?', foreign: 'perchè no?'}
    {native: 'who\'s there?', foreign: 'chi è?'}
    {native: 'who is it for?', foreign: 'chi è per?'}
    {native: 'which one do you want?', foreign: 'quale vuole?'}
    {native: 'when are the stores open?', foreign: 'quando hanno luogo i negozi aperti?'}
    {native: 'whose is that?', foreign: 'di chi è quello?'}
    {native: 'how would you like to pay?', foreign: 'come desidera pagare?'}
    {native: 'how are you getting here?', foreign: 'come arriva qui?'}
    {native: 'is it free?', foreign: 'è libero?'}
    {native: 'are there any buses going into town?', foreign: 'ci sono autobus per il centro?'}
    {native: 'can i have this?', foreign: 'posso avere questo?'}
    {native: 'can we have that?', foreign: 'possiamo avere quello?'}
    {native: 'can you show me that?', foreign: 'potete mostrarmi quello?'}
    {native: 'can i help you?', foreign: 'posso aiutare?'}
    {native: 'can you help me?', foreign: 'può aiutarmi?'}
    {native: 'how are you?', foreign: 'come sta?'}
    {native: 'whose handbag is that?', foreign: 'di chi borsa è quella?'}
    {native: 'do you speak english?', foreign: 'parla inglese?'}
    {native: 'can you speak more slowly?', foreign: 'può parlare più lentamente?'}
    {native: 'can you repeat that?', foreign: 'può repetere'}
    {native: 'what was that?', foreign: 'cosa ha detto?'}
    {native: 'i understand.', foreign: 'capisco.'}
    {native: 'i don\'t understand.', foreign: 'non capisco.'}
    {native: 'do you understand?', foreign: 'capisce?'}
    {native: 'could you spell it?', foreign: 'come si scrive?'}
    {native: 'can you translate this for me?', foreign: 'può tradurre questo?'}
    {native: 'what does this mean?', foreign: 'cosa significa questo?'}
    {native: 'please write it down.', foreign: 'la scriva per piacere.'}
    {native: 'when is the first flight?', foreign: 'quando parte il primo volo?'}
    {native: 'when is the next flight?', foreign: 'quando parte il prossimo volo?'}
    {native: 'when is the last flight?', foreign: 'quando parte l\'ultimo volo?'}
    {native: 'i\'d like one round-trip ticket', foreign: 'vorrei un di andata e ritorno biglietto'}
    {native: 'i\'d like three one-way tickets', foreign: 'vorrei tre di andata biglietti'}
    {native: 'i\'d like four economy class tickets.', foreign: 'vorrei quattro classe turistica biglietti.'}
    {native: 'i\'d like two business class tickets.', foreign: 'vorrei due business class biglietti.'}
    {native: 'i\'d like one first class ticket.', foreign: 'vorrei un prima classe biglietti.'}
    {native: 'how much is a flight to paris?', foreign: 'quanto costa il volo per parigi?'}
    {native: 'i\'d like to confirm my reservation', foreign: 'vorrei confirmare la mia prenotazione.'}
    {native: 'i\'d like to change my reservation.', foreign: 'vorrei cambiare la mia prenotazione.'}
    {native: 'i\'d like to cancel my reservation.', foreign: 'vorrei anullare la mia prenotazione.'}
    {native: 'what time do i have to check in?', foreign: 'a che ora devo registrare i bagagli?'}
    {native: 'how long is the flight?', foreign: 'quanto dura il volo?'}
    {native: 'what time does the plane leave?', foreign: 'a che ora decolla l\'aereo?'}
    {native: 'what time do we arrive?', foreign: 'a che ora arriveremo?'}
    {native: 'which gate does the flight depart from?', foreign: 'da quale uscita parte il volo?'}
    {native: 'has the flight landed?', foreign: 'è atteratto il volo?'}
    {native: 'how late will the flight be?', foreign: 'di quanto ritarderà il volo?'}
]





###
\d+.\s+(\w+).+\n
: '$1'\n



'The apple is red'
'It is John\'s apple'
'I give John the apple'
'We want to give him the apple'
'He gives it to John'
'She gives it to him'

###
    