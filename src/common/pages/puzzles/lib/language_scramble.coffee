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
    constructor: (@languages, @levelName, @puzzleData) ->
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
                percentComplete: @puzzleData.levels?[@languages]?[levelName]?.percentComplete or 0

        return info

    displayLanguages: -> @languageData.displayName


class languageScramble.ViewHelper

    constructor: ({@el, puzzleData, @languages, @saveProgress, @maxLevel}) ->
        @puzzleData = JSON.parse(JSON.stringify(puzzleData))
        @maxLevel or= 7
        @formatLevelLinks()
        
        
    $: (selector) -> $(selector, @el)

    formatLevelLinks: () ->
        for percentComplete in $('.footer .levels .level .percent_complete')
            percentComplete = $(percentComplete)
            height = percentComplete.closest('.level').height() - 2
            percentComplete.css(height: height, marginTop: height * -1)

    setLevel: (@levelName) ->   
        @languageData = languageScramble.data[@languages]
        @level = languageScramble.getLevel(@languageData, @levelName)
        @options = @level.data
        @puzzleData.levels[@languages][@levelName] = {} unless @puzzleData.levels[@languages][@levelName]

        @puzzleData.lastLevelPlayed = @levelName
        
        @saveProgress(@puzzleData)
        @orderedOptions = []
        @orderedOptionsIndex = null
        @setTitle()
        @setProgress()
        

    saveLevel: () ->
        @answerTimes.push(new Date())
        @puzzleData.levels[@languages][@levelName][@scrambleInfo.id] += 1
        progress = @$(".progress_meter .bar .progress_section")
        progressIncrement = 100.0 / progress.length
        leftToGo = 0
        leftToGo += $(progressSection).css('opacity') * progressIncrement for progressSection in progress
        percentComplete = 100 - leftToGo

        if percentComplete > 95
            allComplete = true
            for id of @puzzleData.levels[@languages][@levelName]
                if @puzzleData.levels[@languages][@levelName][id] < @maxLevel
                    allComplete = false
                    break
            percentComplete = 100 if allComplete
        
        @puzzleData.levels[@languages][@levelName].percentComplete = percentComplete        
        $("#level_link_#{@levelName} .percent_complete").width("#{percentComplete}%")
            
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
        $(document.body).bind 'keypress', (e) =>
            return if @initializingScramble
            return if @clickAreaHasFocus or $('.opaque_screen').css('opacity') > 0
            $('#clickarea')[0].focus()
            $('#clickarea').trigger('keypress', e)
        
        moveDrag = (e) =>
            return if @initializingScramble
            return unless @dragging
            e.preventDefault() if e.preventDefault
            unless @dragging.css('position') == 'absolute'
                if @dragging[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)?
                    @replaceLetterWithGuess(@dragging)  
                else
                    @replaceLetterWithBlank(@dragging)  
            @dragPathX.push(@clientX(e)) unless @dragPathX[@dragPathX.length - 1] == @clientX(e)
            @dragPathY.push(@clientY(e)) unless @dragPathX[@dragPathY.length - 1] == @clientY(e)
            @dragging.css(position: 'absolute', top: @clientY(e) - @dragAdjustmentY, left: @clientX(e) - @dragAdjustmentX)                
            
        endDrag = (e, force) =>
            return if @initializingScramble

            if not force and (!@dragPathX or !@dragPathY or @dragPathX.length <= 1 or @dragPathY.length <= 1)
                $.timeout 40, () => endDrag(e, true) if @dragging?
                return

            return if @actionHandled
            @actionHandled = true
            $.timeout 50, () => @actionHandled = false
                
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
            
        
        $(document.body).bind 'mousemove', moveDrag
        $(document.body).bind 'mouseup', endDrag

        $(document.body).bind 'touchmove', moveDrag
        $(document.body).bind 'touchend', endDrag
        document.body.focus()

        
    bindKeyPress: () ->
        @clickAreaHasFocus = false
        $('#clickarea').bind 'focus', () => @clickAreaHasFocus = true    
        $('#clickarea').bind 'blur', () => @clickAreaHasFocus = false    

        $('#clickarea').bind 'keydown', (e) =>
            return if @initializingScramble
            if e.keyCode == 8
                lastLetterAdded = @lettersAdded.pop()
                guessedLetters = $(".guesses .letter_#{lastLetterAdded}")
                $(guessedLetters[guessedLetters.length - 1]).trigger('click') if guessedLetters.length
                return
            
        lastPress = null
        $('#clickarea').bind 'keypress', (e) =>
            return if @initializingScramble
            return if lastPress && new Date() - lastPress < 10
            lastPress = new Date()
            openGuess = @$('.guesses .selected')[0] or @$(".guesses .guess")[0]
            return unless openGuess?
            
            try 
                char = String.fromCharCode(e.keyCode).toLowerCase()
                foreignChar = openGuess.className.match(/actual_letter_(.)/)[1]
                if foreignChar in ['é', 'è', 'ì', 'ò', 'ù', 'à']  
                    nativeChar = switch foreignChar
                        when 'à' then 'a'
                        when 'é' then 'e'
                        when 'è' then 'e'
                        when 'ì' then 'i'
                        when 'ò' then 'o'
                        when 'ù' then 'u'
                
                    char = foreignChar if char == nativeChar
        
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
            return if @initializingScramble
            return if @actionHandled
            @actionHandled = true
            $.timeout 50, () => @actionHandled = false
            
            if @dragging && @dragging.css('position') == 'absolute'
                alreadyDragged = true
                @dragging.css(position: 'static')
                @dragging = null

            containerClass = @containerClassName(letter)
            if letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)? or letter.hasClass('recent_guess')
                @replaceLetterWithGuess(letter)
                @replaceBlankWithLetter(letter)
            else
                guess = @$('.guesses .selected')[0] or @$(".guesses .#{containerClass} .guess")[0]
                return unless guess?
                @replaceLetterWithBlank(letter) unless alreadyDragged
                @replaceGuessWithLetter(guess, letter)
                
                

        startDrag = (e) =>
            return if @initializingScramble
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
        
        handleMove = (e) =>
            return if @initializingScramble 
            e.preventDefault() if e.preventDefault
            unless letter.css('position') == 'absolute'
                if letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)?
                    @replaceLetterWithGuess(letter)  
                else
                    @replaceLetterWithBlank(letter)  
            @dragPathX.push(@clientX(e)) unless @dragPathX[@dragPathX.length - 1] == @clientX(e)
            @dragPathY.push(@clientY(e)) unless @dragPathX[@dragPathY.length - 1] == @clientY(e)
            letter.css(position: 'absolute', top: @clientY(e) - @dragAdjustmentY, left: @clientX(e) - @dragAdjustmentX)  

        letter.bind 'touchmove', handleMove  
            
        touchEnd = (e, force) =>
            return if @initializingScramble
            
            if not force and (!@dragPathX or !@dragPathY or @dragPathX.length <= 1 or @dragPathY.length <= 1)
                $.timeout 40, () => touchEnd(e, true)
                return
                
            return if @actionHandled
            @actionHandled = true
            $.timeout 50, () => @actionHandled = false

            e.preventDefault() if e.preventDefault?

            currentX = @dragPathX.pop()
            currentY = @dragPathY.pop()
            lastX = (x for x in @dragPathX.reverse() when Math.abs(x - currentX) > 10)[0] or currentX + 0.01
            lastY = (y for y in @dragPathY.reverse() when Math.abs(y - currentY) > 10)[0] or currentY - 0.01

            guess = @guessInPath(letter, lastX, lastY, currentX, currentY)
            letter.css(position: 'static')
            if guess?
                @replaceGuessWithLetter(guess, letter)
            else    
                @replaceBlankWithLetter(letter)
                
            
        letter.bind 'touchend', (e) => touchEnd(e)
                          
            
    newScramble: () ->
        @initializingScramble = true
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

        @initScrambleAreas('scrambled')
        @initScrambleAreas('guesses')
        @resize()
        @assignColors('scrambled')
        @assignColors('guesses')
        @scrambleScrambleArea()
        @initializingScramble = false
    
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
                possibleLevels.push(minLevel + 1) unless minLevel >= @maxLevel

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
        
        @activeType = @activeLevel.replace(/Medium/, '').replace(/Hard/, '')

        @displayLevel = if @activeType.match(/native/) then 'foreign' else 'native'
        
        @setStage() 
        
        return @orderedOptions[@orderedOptionsIndex]
            
    initScrambleAreas: (areaClass) ->
        area = @$(".#{areaClass}")
        @clearContainer(area)
        
        sentence = @scrambleInfo[@activeType]
        wordGroups = @separateIntoWordGroups(sentence)
        for group, index in wordGroups
            wordGroup = @createWordGroup()
            if not container
                container = @createContainer() 

            for letter in group 
                wordGroup.append(
                    if letter.match(/\w|[^\x00-\x80]+/)? then (
                        if (areaClass == 'scrambled') then @createLetter(letter) else @createGuess(letter)
                    ) else @createSpace(letter)
                )

            container.append(wordGroup)
            area.append(container)
        
        @sizeLetter($(area.find('.letter')[0])) if areaClass == 'scrambled' 

    assignColors: (areaClass) ->
        colorIndex = 0
        for wordGroup in @$(".#{areaClass} .word_group")
            if wordGroup.offsetTop != offsetTop
                offsetTop = wordGroup.offsetTop
                colorIndex += 1
            wordGroup.className = "word_group color#{colorIndex}"
            
    scrambleScrambleArea: ->
        scrambled = @$('.scrambled')
        wordGroups = {}
        for wordGroup in scrambled.find('.word_group')
            wordGroups[wordGroup.className] or= [] 
            for letter in $(wordGroup).find('.letter')
                wordGroups[wordGroup.className].push($(letter).html())
                    
        containers = []
        scrambled.find('.container').remove()
        for color of wordGroups
            container = @createContainer() 
            wordGroup = @createWordGroup()
            wordGroup[0].className = color
            letters = @shuffleWord(wordGroups[color])
            wordGroup.append(@createLetter(letter)) for letter in letters

            containers.push(container)
            container.append(wordGroup)
            scrambled.append(container)
        @centerContainers(containers)
        
    createContainer: (index) ->
        container = $(document.createElement("DIV"))
        container.addClass('container')
    
    centerContainers: (containers = @$('.container'))->
        for container in containers
            container = $(container)
            containerWidth = container.width() 
            container.width(containerWidth)
            container.css(float: 'none', margin: 'auto')
            
            wordGroups = container.find('.word_group')
            if wordGroups.length > 1
                centerWordGroups = (lg, rg) ->
                    rg = lg if not rg
                    containerRight = container.offset().left + container.offset().width
                    right = rg.offset().left + rg.offset().width
                    if (space = rg.children()[0])
                        right += $(space).width() if space.className.indexOf('space') > -1
                    lg.css(marginLeft: (containerRight - right)/2)
                    
                for wordGroup, index in wordGroups
                    if currentOffsetTop and (currentOffsetTop != wordGroup.offsetTop)
                        centerWordGroups(leftGroup, rightGroup)
                        leftGroup = null
                        rightGroup = null
                        currentOffsetTop = null

                    if not currentOffsetTop
                        leftGroup = $(wordGroup)
                        currentOffsetTop = wordGroup.offsetTop
                    else
                        rightGroup = $(wordGroup)
                        
                centerWordGroups(leftGroup, rightGroup)
                leftGroup = null
                rightGroup = null
                currentOffsetTop = null
            
            container.height(container.height())

        @$('.guesses, .scrambled').find('.guess, .letter, .blank_letter').css
            lineHeight: @letterLineHeight
            height: @letterDim
                
    containerHeights: ->
        total = 0
        for container in @$('.scrambled .container, .guesses .container, .display_words')
            total += $(container).height() + 15
        return total

    resize: ->
        letter = $(@$('.scrambled').find('.letter')[0])
        @letterFontSize = parseInt(letter.css('fontSize'))
        @sizeLetter(letter)
        
        targetHeight =  @$('.scramble_content').height()

        windowWidth = window.innerWidth or window.landwidth
        maxFontSize = windowWidth / 15
        increment = maxFontSize
        
        while increment >= 1
            break if increase and @letterFontSize >= maxFontSize
            increase = @containerHeights() < targetHeight
            increment = increment / 2
            while increase == (@containerHeights() < targetHeight)
                break if increase and @letterFontSize >= maxFontSize
                @letterFontSize += increment * (if increase then 1 else -1)
                @sizeLetter(letter)
        
        if @letterFontSize >= maxFontSize
            @letterFontSize = maxFontSize
            @sizeLetter(letter)

        @centerContainers()

    sizeLetter: (letter) ->
        @$('.guesses, .scrambled').css(fontSize: "#{@letterFontSize}px")
        @$('.display_words').css(fontSize: "#{@letterFontSize + 2}px")
            
        @letterDim = letter.height()
        @letterLineHeight = "#{@letterDim - (@letterDim / 10)}px"
        @$('.guesses, .scrambled').find('.guess, .letter, .blank_letter').css
            width: @letterDim
        @$('.guesses, .scrambled').find('.guess, .blank_letter').css
            height: @letterDim
        @$('.guesses, .scrambled').find('.space').css(width: @letterDim / 2)

    createWordGroup: () ->
        wordGroup = $(document.createElement("DIV"))
        wordGroup.addClass('word_group')
        wordGroup.addClass('color1')
        
    formatLetterOrGuess: (letterOrGuess) -> 
        letterOrGuess.css(height: @letterDim, width: @letterDim, lineHeight: @letterLineHeight) if @letterDim

    clearContainer: (container) -> 
        container.find('.container, .correct, .guess, .letter, .space').remove()
        @letterDim = null
        @letterLineHeight = null
        @letterFontSize = null
        
    createGuess: (letter) ->
        guess = $(document.createElement("DIV"))
        guess.addClass('guess')
        @formatLetterOrGuess(guess)
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
        
    separateIntoWordGroups: (letters) ->
        groups = [[]]
        for letter in letters
            groups.push([]) if letter.match(/\s/) 
            group = groups[groups.length - 1]
            group.push(letter)                
        return groups
        
    shuffleWord: (word) ->
        top = word.length
        return '' if not top
        word = @modifyScramble(word)
        
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
        @formatLetterOrGuess(letterContainer)
        letterContainer.addClass("letter_#{letter}")
        letterContainer.html(letter)
        @bindLetter(letterContainer)
        return letterContainer
        
    replaceLetterWithBlank: (letter) ->
        blankLetter = $(document.createElement("DIV"))
        blankLetter.addClass('blank_letter').addClass(letter.html())
        @formatLetterOrGuess(blankLetter)
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

        letter.removeClass('recent_guess')
        blankLetter.remove()
        @bindLetter(letter)

    replaceGuessWithLetter: (guess, letter) ->
        $('.guesses .hidden_message').hide()
        $('.guesses .space').css(visibility: 'visible')

        guess = $(guess)
        letter.remove().insertBefore(guess, @$('.guesses'))
        letter.addClass(guess[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[0])
        letter.removeClass('recent_guess')
            
        guess.remove()
        @bindLetter(letter)
        @lettersAdded.push(letter.html())

        letterPosition = guess[0].className.indexOf('actual_letter_') + 'actual_letter_'.length
        guessLetter = guess[0].className[letterPosition..letterPosition]
        letter.addClass(if letter.html() == guessLetter then 'correct_letter' else 'wrong_letter')

        @next() if @checkCorrectAnswer()

    replaceLetterWithGuess: (letter) ->
        letter.removeClass('recent_guess')
        letterAddedIndex = @lettersAdded.indexOf(letter.html())
        @lettersAdded.slice(letterAddedIndex, letterAddedIndex + 1)
        actualLetter = letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[1]
        @createGuess(actualLetter).insertBefore(letter, @$(".guesses .#{@containerClassName(letter)}"))
        if letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)?
            letter.removeClass(letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[0])
            letter.removeClass('wrong_letter')
            letter.removeClass('correct_letter')
            letter.addClass('recent_guess')

    clientX: (e) => e.clientX or e.targetTouches[0]?.pageX or e.touches[0]?.pageX
    clientY: (e) => e.clientY or e.targetTouches[0]?.pageY or e.touches[0]?.pageY

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
        word.push(commonLetters[Math.floor(Math.random() * commonLetters.length)]) for i in [0...add]
        return word
            
    setStage: () ->
        @$('.guesses').removeClass('hidden')
        @$('.scrambled').removeClass('hidden') 
        @$('.scramble_content').removeClass('show_keyboard')      
        if @activeLevel.match(/Medium/)? or @activeLevel.match(/Hard/)?
            @$('.guesses').addClass('hidden')
            message = @$('.guesses .hidden_message')
            message.show()
            message.width(message.width())
            message.css('left', (window.innerWidth - message.width()) / 2)

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
        @initializingScramble = true
        correct = $(document.createElement('DIV'))
        if @scrambleInfo["#{@activeType}Sentence"]? && @scrambleInfo["#{@activeType}Sentence"].length
            correctSentence = @scrambleInfo["#{@activeType}Sentence"] 
        else 
            correctSentence = @scrambleInfo[@activeType]

        correctSentence = " #{correctSentence} "
        highlighted = @scrambleInfo[@activeType]
        for boundary in [' ', '?', ',']
            correctSentence = correctSentence.replace(" #{highlighted}#{boundary}", " <span class='highlighted'>#{highlighted}</span>#{boundary}")           

        correctSentence += '<br/><br/><br/><p class=\'small\'>Tap the screen to continue ></p>'

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
            nextShown = true
            $(document.body).unbind 'click'
            $(document.body).unbind 'touchstart'
            $('#clickarea').unbind 'keyup'
            @setProgress()
            @saveLevel()
            @$('.display_words, .scrambled, .guesses').animate
                opacity: 0
                duration: 300
                complete: () =>
                    @$('.scrambled, .guesses').css(width: null, height: null)
                    @newScramble()
                    @$('.display_words, .scrambled, .guesses').animate
                        opacity: 1
                        duration: 300
                        complete: () =>
                            # @$('.last_answer').html("#{displayedSentence} = #{correctSentence}")
                            # @$('.last_answer').animate
                            #     opacity: 1
                            #     duration: 300

        @$('.guesses').animate
            opacity: 0
            height: 0
            duration: 500

        correct.animate
            opacity: 1
            duration: 500
            complete: () =>
                $.timeout 500 + (50 * correctSentence.length), () => showNext()
                $(document.body).bind 'click', () => showNext()
                $(document.body).bind 'touchstart', () => showNext()
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
                        complete: () =>
                            message.css
                                top: -1000
                                left: -1000

        @$('.scramble_content').animate
            opacity: 0
            duration: 500
            complete: () =>
                message.css
                    top: ($('.language_scramble').height() - @$('#next_level').height()) / 2
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
                    {native: 'my', foreign: 'mio', nativeSentence: 'my brother is seven years old', foreignSentence: 'mio fratello ha sette anni'},
                    {native: 'because', foreign: 'perché', nativeSentence: 'because i want to', foreignSentence: 'perché voglio'},
                    {native: 'why', foreign: 'perché', nativeSentence: 'why do you want to go?', foreignSentence: 'perché vuoi andare?'},
                    {native: 'she', foreign: 'lei', nativeSentence: 'she leaves tomorrow', foreignSentence: 'lei parte domani'},
                    {native: 'only', foreign: 'solo', nativeSentence: 'it was only fifteen minutes', foreignSentence: 'era solo quindici minuti'},
                    {native: 'it was', foreign: 'era', nativeSentence: 'it was thirty years ago', foreignSentence: 'era trent\'anni fa'},
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
            top50phrases:
                title: 'Phrases For The Top 25 - 50 Words'
                subtitle: 'Phrases for the 25 - 50 most frequently used Italian words'
                nextLevel: 'top75words'
                data: [
                    {native: 'a little more', foreign: 'un po più'},
                    {native: 'my brother is seven years old', foreign: 'mio fratello ha sette anni'},
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
                    {native: 'of', foreign: 'della', nativeSentence: 'we celebrate mother\'s day in honor of our mothers', foreignSentence: 'celebriamo la festa della mamma in onore delle nostre madri'},
                    {native: 'so', foreign: 'così', nativeSentence: 'what made her so sad?', foreignSentence: 'cosa l\'ha resa così triste?'},
                    {native: 'my', foreign: 'mia', nativeSentence: 'my mother is older than my father', foreignSentence: 'mia madre è più vecchio di mio padre'},
                    {native: 'neither', foreign: 'né', nativeSentence: 'he knows neither french nor german', foreignSentence: 'non sa né il francese né il tedesco'},
                    {native: 'this', foreign: 'questa', nativeSentence: 'this house and this land are mine', foreignSentence: 'questa casa e questa terra sono mie'},
                    {native: 'be', foreign: 'fare', nativeSentence: 'you must be careful not to drop the eggs', foreignSentence: 'dovete fare attenzione a non fare cadere le uova'},
                    {native: 'when', foreign: 'quando', nativeSentence: 'when i hear that song i think about when i was young', foreignSentence: 'quando sento quella canzone penso a quando ero piccolo'},
                    {native: 'time', foreign: 'ora', nativeSentence: 'what time does the plane leave?', foreignSentence: 'a che ora decolla l\'aereo?'}
                    {native: 'did', foreign: 'fatto', nativeSentence: 'did you have a good trip?', foreignSentence: 'hai fatto un buon viaggio?'},
                    {native: 'to be', foreign: 'essere', nativeSentence: 'it is never too late to be what you could have been', foreignSentence: 'non è mai troppo tardi per essere ciò che avresti potuto essere.'},
                    {native: 'know', foreign: 'so', nativeSentence: 'i know how to dance', foreignSentence: 'so ballare'},
                    {native: 'never', foreign: 'mai', nativeSentence: 'never give up', foreignSentence: 'mai rinunciare'},
                    {native: 'who', foreign: 'chi', nativeSentence: 'who is it?', foreignSentence: 'chi é?'},
                    {native: 'or', foreign: 'o', nativeSentence: 'don\'t pour hot water in to the glass or it will crack', foreignSentence: 'non versare acqua calda nel bicchiere o si romperà'},
                    {native: 'at the', foreign: 'alla', nativeSentence: 'i bought this book at the bookstore', foreignSentence: 'ho comprato questo libro alla libreria'},
                    {native: 'very', foreign: 'molto', nativeSentence: 'italy is a very beautiful country', foreignSentence: 'l\'italia è un paese molto bello'},
                    {native: 'also', foreign: 'anche', nativeSentence: 'excuse me, we\'re in a hurry also', foreignSentence: 'scusami, ma abbiamo anche noi fretta'},
                    {native: 'said', foreign: 'detto', nativeSentence: 'she may have said so', foreignSentence: 'potrebbe aver detto ciò'},
                    {native: 'that', foreign: 'quello', nativeSentence: 'that is not what i heard', foreignSentence: 'quello non è ciò che ho sentito io'},
                    {native: 'goes', foreign: 'va', nativeSentence: 'my father goes to work on a bike', foreignSentence: 'mio padre va a lavorare in bici'},
                    {native: 'nothing', foreign: 'niente', nativeSentence: 'he did nothing wrong', foreignSentence: 'non fece niente di male'},
                    {native: 'thank you', foreign: 'grazie', nativeSentence: 'thank you for your invitation', foreignSentence: 'grazie per il vostro invito'},
                    {native: 'he', foreign: 'lui', nativeSentence: 'he is very tall', foreignSentence: 'lui è molto alto'}
                ]
            top75phrases:
                title: 'Phrases For The Top 50 - 75 Words'
                subtitle: 'Phrases for the 50 - 75 most frequently used Italian words'
                nextLevel: 'top100words'
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
                    {native: 'i know how to dance', foreign: 'so ballare'},
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
            top100words:
                title: 'Top 75 - 100 Words'
                subtitle: 'The 75 - 100 most frequently used Italian words'
                nextLevel: 'top100phrases'
                data: [
                    {native: 'he', foreign: 'lui', nativeSentence: 'he is a very shy person', foreignSentence:  'lui è una persona molto timida'},
                    {native: 'want', foreign: 'voglio', nativeSentence: 'i want to go home', foreignSentence: 'voglio andare a casa'},
                    {native: 'we have', foreign: 'abbiamo', nativeSentence: 'we have a big house with three bedrooms', foreignSentence: 'abbiamo una grande casa con tre camere da letto'},
                    {native: 'was', foreign: 'stato', nativeSentence: 'it was a great pleasure to work with him', foreignSentence: 'è stato un grande  piacere lavorare con lui'},
                    {native: 'him', foreign: 'lui', nativeSentence: 'i don\'t know anything about him', foreignSentence: 'non so nulla di lui'},
                    {native: 'in the', foreign: 'nel', nativeSentence: 'there is a big tree in the garden', foreignSentence: 'c\'è un grande albero nel giardino'},
                    {native: 'his', foreign: 'suo', nativeSentence: 'his dog barks all night', foreignSentence: 'il suo cane abbaia tutta la notte'},
                    {native: 'will be', foreign: 'sarà', nativeSentence: 'tomorrow will be different', foreignSentence: 'domani sarà diverso'},
                    {native: 'where', foreign: 'dove', nativeSentence: 'where is my book?', foreignSentence: 'dove è il mio libro?'},
                    {native: 'can', foreign: 'posso', nativeSentence: 'i can dance all night long', foreignSentence: 'posso ballare tutta la notte'},
                    {native: 'oh', foreign: 'oh', nativeSentence: 'oh what a beautiful sunset!', foreignSentence: 'oh che bel tramonto!'},
                    {native: 'before', foreign: 'prima', nativeSentence: 'i always read before going to bed', foreignSentence: 'leggo sempre prima di andare a letto'},
                    {native: 'so', foreign: 'allora',nativeSentence: 'so, how is it going?', foreignSentence: 'allora, come va?'},
                    {native: 'we are', foreign: 'siamo', nativeSentence: 'we are happy to help you', foreignSentence: 'siamo felici di aiutarti'},
                    {native: 'a', foreign: 'uno', nativeSentence: 'i made a mistake', foreignSentence: 'ho fatto uno sbaglio'},
                    {native: 'an', foreign: 'un\'', nativeSentence: 'she is an excellent cook', foreignSentence: 'lei è un\' eccellente cuoca'},
                    {native: 'her', foreign: 'sua', nativeSentence: 'her house is on the hill', foreignSentence: 'la sua casa è sulla collina'},
                    {native: 'your', foreign: 'tuo', nativeSentence: 'what is your job?', foreignSentence: 'quale è il tuo lavoro?'},
                    {native: 'have', foreign: 'hanno', nativeSentence: 'they have a big house', foreignSentence: 'loro hanno una grande casa'},
                    {native: 'we', foreign: 'noi', nativeSentence: 'we love tennis', foreignSentence: 'noi amiamo il tennis'},
                    {native: 'is', foreign: 'sta', nativeSentence: 'who is knocking on my door?', foreignSentence: 'chi sta bussando alla mia porta?'},
                    {native: 'does', foreign: 'fa', nativeSentence: 'he does what he wants', foreignSentence: 'lui fa ciò che vuole'},
                    {native: 'two', foreign: 'due', nativeSentence: 'my house has two bathrooms', foreignSentence: 'la mia casa ha due bagni'},
                    {native: 'want', foreign: 'vuoi', nativeSentence: 'what do you want from me?', foreignSentence: 'cosa vuoi da me?'},
                    {native: 'still', foreign: 'ancora', nativeSentence: 'he is still sleeping', foreignSentence: 'lui sta ancora dormendo'},
                    {native: 'something', foreign: 'qualcosa', nativeSentence: 'there is something to talk about', foreignSentence: 'c\'è qualcosa di cui parlare'},
                ]
            top100phrases:
                title: 'Phrases For The Top 75 - 100 Words'
                subtitle: 'Phrases for the 75 - 100 most frequently used Italian words'
                nextLevel: 'top150words'
                data: [
                    {native: 'he is a very shy person', foreign:  'lui è una persona molto timida'},
                    {native: 'i want to go home', foreign: 'voglio andare a casa'},
                    {native: 'we have a big house with three bedrooms', foreign: 'abbiamo una grande casa con tre camere da letto'},
                    {native: 'it was a great pleasure to work with him', foreign: 'è stato un grande  piacere lavorare con lui'},
                    {native: 'i don\'t know anything about him', foreign: 'non so nulla di lui'},
                    {native: 'there is a big tree in the garden', foreign: 'c\'è un grande albero nel giardino'},
                    {native: 'his dog barks all night', foreign: 'il suo cane abbaia tutta la notte'},
                    {native: 'tomorrow will be different', foreign: 'domani sarà diverso'},
                    {native: 'where is my book?', foreign: 'dove è il mio libro?'},
                    {native: 'i can dance all night long', foreign: 'posso ballare tutta la notte'},
                    {native: 'oh what a beautiful sunset!', foreign: 'oh che bel tramonto!'},
                    {native: 'i always read before going to bed', foreign: 'leggo sempre prima di andare a letto'},
                    {native: 'so, how is it going?', foreign: 'allora, come va?'},
                    {native: 'we are happy to help you', foreign: 'siamo felici di aiutarti'},
                    {native: 'i made a mistake', foreign: 'ho fatto uno sbaglio'},
                    {native: 'she is an excellent cook', foreign: 'lei è un\'eccellente cuoca'},
                    {native: 'her house is on the hill', foreign: 'la sua casa è sulla collina'},
                    {native: 'what is your job?', foreign: 'quale è il tuo lavoro?'},
                    {native: 'they have a big house', foreign: 'loro hanno una grande casa'},
                    {native: 'we love tennis', foreign: 'noi amiamo il tennis'},
                    {native: 'who is knocking on my door?', foreign: 'chi sta bussando alla mia porta?'},
                    {native: 'he does what he wants', foreign: 'lui fa ciò che vuole'},
                    {native: 'my house has two bathrooms', foreign: 'la mia casa ha due bagni'},
                    {native: 'what do you want from me?', foreign: 'cosa vuoi da me?'},
                    {native: 'he is still sleeping', foreign: 'lui sta ancora dormendo'},
                    {native: 'there is something to talk about', foreign: 'c\'è qualcosa di cui parlare'},
                ]
            top125words:
                title: 'Top 100 - 125 Words'
                subtitle: 'The 100 - 125 most frequently used Italian words'
                nextLevel: 'top125phrases'
                data: [
                    {native: 'true', foreign: 'vero', nativeSentence: 'it\'s true!', foreignSentence: 'è vero!'},
                    {native: 'home', foreign: 'casa', nativeSentence: 'home sweet home', foreignSentence: 'casa dolce casa'},
                    {native: 'are', foreign: 'sia', nativeSentence: 'i suppose you are angry', foreignSentence: 'suppongo tu sia arrabbiato'},
                    {native: 'up', foreign: 'su', nativeSentence: 'look up and see the stars', foreignSentence: 'guarda su e vedi le stelle'},
                    {native: 'your', foreign: 'tua', nativeSentence: 'your mother must be proud of you', foreignSentence: 'tua madre deve essere orgogliosa di te'},
                    {native: 'always', foreign: 'sempre', nativeSentence: 'i will always love you', foreignSentence: 'ti amerò per sempre'},
                    {native: 'maybe', foreign: 'forse', nativeSentence: 'maybe we should go home', foreignSentence: 'forse dovremmo andare a casa'},
                    {native: 'tell', foreign: 'dire', nativeSentence: 'it is important to tell the truth', foreignSentence: 'è importante dire la verità'},
                    {native: 'you', foreign: 'vi', nativeSentence: 'your parents love you very much', foreignSentence: 'i vostri genitori vi amano moltissimo'},
                    {native: 'they', foreign: 'loro', nativeSentence: 'they live in london', foreignSentence: 'loro vivono a londra'},
                    {native: 'the', foreign: 'i', nativeSentence: 'the kids are playing in the garden', foreignSentence: 'i bambini stanno giocando in giardino'},
                    {native: 'another', foreign: 'altro', nativeSentence: 'there is another man', foreignSentence: 'c\'è un altro uomo'},
                    {native: 'know', foreign: 'sai', nativeSentence: 'you know the truth', foreignSentence: 'tu sai la verità'},
                    {native: 'are', foreign: 'stai', nativeSentence: 'you are making progress', foreignSentence: 'stai facendo progressi'},
                    {native: 'must', foreign: 'devo', nativeSentence: 'i must go to the bank', foreignSentence: 'devo andare in banca'}, 
                    {native: 'that', foreign: 'quella', nativeSentence: 'that car is old', foreignSentence: 'quella macchina è vecchia'},
                    {native: 'life', foreign: 'vita',nativeSentence: 'i am happy with my life',foreignSentence: 'sono contento della mia vita'},
                    {native: 'that', foreign: 'quel', nativeSentence: 'that guy is very tall', foreignSentence: 'quel tipo è molto alto'},
                    {native: 'of', foreign: 'delle', nativeSentence: 'i am scared of bees', foreignSentence: 'ho paura delle api'},
                    {native: 'time', foreign: 'tempo', nativeSentence: 'it\'s time to go', foreignSentence: 'è tempo di andare via'},                    
                    {native: 'go', foreign: 'andare', nativeSentence: 'i want to go home' , foreignSentence: 'voglio andare    a casa'},
                    {native: 'sure', foreign: 'certo', nativeSentence: 'i am sure you will get the job', foreignSentence:  'sono certo che otterrai il lavoro'},
                    {native: 'then', foreign: 'poi', nativeSentence: 'do your homework now, then you go out', foreignSentence: 'fai i tuoi compiti ora, poi esci'},
                    {native: 'in', foreign: 'nella', nativeSentence: 'i saw a spider in the bedroom', foreignSentence: 'ho visto un ragno nella camera da letto'},
                    {native: 'man', foreign: 'uomo', nativeSentence: 'there is a strange man in front of the house', foreignSentence: 'c\'è uno strano uomo di fronte alla casa'},
                ]
            top125phrases:
                title: 'Phrases For The Top 100 - 125 Words'
                subtitle: 'Phrases for the 100 - 125 most frequently used Italian words'
                nextLevel: 'top150words'
                data: [
                    {native: 'it\'s true!', foreign: 'è vero!'},
                    {native: 'home sweet home', foreign: 'casa dolce casa'},
                    {native: 'i suppose you are angry', foreign: 'suppongo tu sia arrabbiato'},
                    {native: 'look up and see the stars', foreign: 'guarda su e vedi le stelle'},
                    {native: 'your mother must be proud of you', foreign: 'tua madre deve essere orgogliosa di te'},
                    {native: 'i will always love you', foreign: 'ti amerò per sempre'},
                    {native: 'maybe we should go home', foreign: 'forse dovremmo andare a casa'},
                    {native: 'it is important to tell the truth', foreign: 'è importante dire la verità'},
                    {native: 'your parents love you very much', foreign: 'i vostri genitori vi amano moltissimo'},
                    {native: 'they live in london', foreign: 'loro vivono a londra'},
                    {native: 'the kids are playing in the garden', foreign: 'i bambini stanno giocando in giardino'},
                    {native: 'there is another man', foreign: 'c\'è un altro uomo'},
                    {native: 'you know the truth', foreign: 'tu sai la verità'},
                    {native: 'you are making progress', foreign: 'stai facendo progressi'},
                    {native: 'i must go to the bank', foreign: 'devo andare in banca'}, 
                    {native: 'that car is old', foreign: 'quella macchina è vecchia'},
                    {native: 'i am happy with my life',foreign: 'sono contento della mia vita'},
                    {native: 'that guy is very tall', foreign: 'quel tipo è molto alto'},
                    {native: 'i am scared of bees', foreign: 'ho paura delle api'},
                    {native: 'it\'s time to go', foreign: 'è tempo di andare via'},                    
                    {native: 'i want to go home' , foreign: 'voglio andare    a casa'},
                    {native: 'i am sure you will get the job', foreign:  'sono certo che otterrai il lavoro'},
                    {native: 'do your homework now, then you go out', foreign: 'fai i tuoi compiti ora, poi esci'},
                    {native: 'i have seen a spider in the bedroom', foreign: 'ho visto un ragno nella camera da letto'},
                    {native: 'there is a strange man in front of the house', foreign: 'c\'è uno strano uomo di fronte alla casa'},
                ]
            top150words:
                title: 'Top 125 - 150 Words'
                subtitle: 'The 125 - 150 most frequently used Italian words'
                nextLevel: 'top150phrases'
                data: [
                    {native: 'sir', foreign: 'signore', nativeSentence: 'good morning, sir', foreignSentence: 'buongiorno signore'},
                    {native: 'to', foreign: 'ad', nativeSentence: 'give a book to every child', foreignSentence: 'dai un libro ad ogni bambino'},
                    {native: 'little', foreign: 'pò', nativeSentence: 'i am a little sad', foreignSentence: 'sono un pò triste'},
                    {native: 'can', foreign: 'può',  nativeSentence: 'he can do it better than you', foreignSentence: 'lui può farlo meglio di te'},
                    {native: 'believe', foreign: 'credo', nativeSentence: 'i believe in love', foreignSentence: 'credo nell\'amore'},
                    {native: 'you', foreign: 'voi', nativeSentence: 'what do you think about Italy? ', foreignSentence: 'cosa pensate dell\'Italia? '},
                    {native: 'already', foreign: 'già', nativeSentence: 'i have already eaten', foreignSentence: 'ho già mangiato'},
                    {native: 'now', foreign: 'adesso', nativeSentence:  'now come here', foreignSentence: 'adesso vieni qui'},
                    {native: 'go', foreign: 'andiamo', nativeSentence: 'let\'s go home', foreignSentence: 'andiamo a casa'},
                    {native: 'years', foreign: 'anni', nativeSentence: 'i am sixteen years old', foreignSentence: 'ho sedici anni'},
                    {native: 'at', foreign: 'all\' ', nativeSentence: 'he always cancels plans at the last minute', foreignSentence: 'lui cancella sempre i programmi all\'ultimo minuto'},
                    {native: 'seen', foreign: 'visto', nativeSentence: 'i have seen a rat in the garden', foreignSentence: 'ho visto un topo in giardino'},
                    {native: 'out', foreign: 'fuori', nativeSentence: 'the kids are out of control', foreignSentence: 'i bambini sono fuori controllo'},
                    {native: 'just', foreign: 'proprio', nativeSentence: 'that is just what i wanted to say', foreignSentence: 'è proprio quello che volevo dire'},
                    {native: 'part', foreign:  'parte', nativeSentence: 'music is an important part of culture', foreignSentence: 'la musica è una parte importante della cultura'},
                    {native: 'really', foreign: 'davvero', nativeSentence: 'you live in a really beautiful house' , foreignSentence: 'vivi in una casa davvero bella'},
                    {native: 'wants', foreign: 'vuole', nativeSentence: 'he wants to go home', foreignSentence:  'lui vuole andare a casa'},
                    {native: 'them', foreign: 'li', nativeSentence: 'she really loves them', foreignSentence: 'lei li ama veramente'}, 
                    {native: 'of', foreign: 'dell\'', nativeSentence: 'december is the last month of the year', foreignSentence: 'dicembre è l\'ultimo mese dell\'anno'},
                    {native: 'am', foreign: 'sto' , nativeSentence: 'i am waiting for you', foreignSentence: 'ti sto aspettando'},
                    {native: 'how much', foreign: 'quanto', nativeSentence: 'how much does it cost? ', foreignSentence: 'quanto costa? '},
                    {native: 'time', foreign: 'volta', nativeSentence: 'this is the right time', foreignSentence: 'questa è la volta buona'},
                    {native: 'way', foreign: 'via', nativeSentence: 'there is no way out', foreignSentence: 'non c\'è via di scampo'},
                    {native: 'on', foreign: 'sul', nativeSentence: 'there is a spot on the floor', foreignSentence: 'c\'è una macchia sul pavimento'},
                    {native: 'is', foreign: 'è', nativeSentence: 'she is a very beautiful girl', foreignSentence: 'lei è una ragazza molto bella'},
                ]
            top150phrases:
                title: 'Phrases For The Top 125 - 150 Words'
                subtitle: 'Phrases for the 125 - 150 most frequently used Italian words'
                nextLevel: 'top175words'
                data: [
                    {native: 'good morning, sir', foreign: 'buongiorno signore'},
                    {native: 'give a book to every child', foreign: 'dai un libro ad ogni bambino'},
                    {native: 'i am a little sad', foreign: 'sono un pò triste'},
                    {native: 'he can do it better than you', foreign: 'lui può farlo meglio di te'},
                    {native: 'i believe in love', foreign: 'credo nell\'amore'},
                    {native: 'what do you think about Italy? ', foreign: 'cosa pensate dell\'Italia? '},
                    {native: 'i have already eaten', foreign: 'ho già mangiato'},
                    {native:  'now it\'s too late', foreign: 'ora è troppo tardi'},
                    {native: 'let\'s go home', foreign: 'andiamo a casa'},
                    {native: 'i am sixteen years old', foreign: 'ho sedici anni'},
                    {native: 'he always cancels plans at the last minute', foreign: 'lui cancella sempre i programmi all\'ultimo minuto'},
                    {native: 'i have seen a rat in the garden', foreign: 'ho visto un topo in giardino'},
                    {native: 'the kids are out of control', foreign: 'i bambini sono fuori controllo'},
                    {native: 'that is just what i wanted to say', foreign: 'è proprio quello che volevo dire'},
                    {native: 'music is an important part of culture', foreign: 'la musica è una parte importante della cultura'},
                    {native: 'you live in a really beautiful house' , foreign: 'vivi in una casa davvero bella'},
                    {native: 'he wants to go home', foreign:  'lui vuole andare a casa'},
                    {native: 'she really loves them', foreign: 'lei li ama veramente'}, 
                    {native: 'december is the last month of the year', foreign: 'dicembre è l\'ultimo mese dell\'anno'},
                    {native: 'i am waiting for you', foreign: 'ti sto aspettando'},
                    {native: 'how much does it cost? ', foreign: 'quanto costa? '},
                    {native: 'this is the right time', foreign: 'questa è la volta buona'},
                    {native: 'there is no way out', foreign: 'non c\'è via di scampo'},
                    {native: 'there is a spot on the floor', foreign: 'c\'è una macchia sul pavimento'},
                    {native: 'she is a very beautiful girl', foreign: 'lei è una ragazza molto bella'},
                ]
            top175words:
                title: 'Top 150 - 175 Words'
                subtitle: 'The 150 - 175 most frequently used Italian words'
                nextLevel: 'top175phrases'                
                data: [
                    {native: 'god', foreign: 'dio', nativeSentence: 'i believe in god', foreignSentence: 'io credo in dio'},
                    {native: 'later', foreign: 'dopo', nativeSentence: 'i will tell you later', foreignSentence: 'te lo dirò dopo'},
                    {native: 'without', foreign: 'senza', nativeSentence: 'i never go out without my umbrella', foreignSentence: 'non esco mai senza il mio ombrello'},
                    {native: 'things', foreign: 'cose', nativeSentence: 'put your things in the wardrobe', foreignSentence: 'metti le tue cose nell\'armadio'},
                    {native: 'nobody', foreign: 'nessuno', nativeSentence: 'nobody knows the truth', foreignSentence: 'nessuno sa la verità'},
                    {native: 'do', foreign:  'fai', nativeSentence: 'what do you do in your spare time? ', foreignSentence: 'cosa fai nel tuo tempo libero? '},
                    {native: 'day', foreign: 'giorno', nativeSentence: 'what day is today? ', foreignSentence: 'che giorno è oggi? '},
                    {native: 'and', foreign: 'ed', nativeSentence: 'cause and effect', foreignSentence: 'causa ed effetto'}
                    {native: 'better', foreign: 'meglio', nativeSentence: 'better late than never', foreignSentence: 'meglio tardi che mai'},
                    {native: 'father', foreign: 'padre', nativeSentence: 'my father is very strict', foreignSentence: 'mio padre è molto severo'},
                    {native: 'can', foreign: 'puoi', nativeSentence: 'can you do me a favour? ', foreignSentence: 'puoi farmi un favore? '},
                    {native: 'hello', foreign: 'ciao', nativeSentence: 'hello, my name is Mary', foreignSentence: 'ciao, mi chiamo Maria'},
                    {native: 'what', foreign: 'cos\'', nativeSentence: 'what is this? ', foreignSentence: 'cos\'è questo? '},
                    {native: 'must', foreign: 'devi', nativeSentence: 'you must go to work tomorrow', foreignSentence: 'devi andare al lavoro domani'},
                    {native: 'here', foreign: 'ecco', nativeSentence: 'here is my book', foreignSentence: 'ecco il mio libro'},
                    {native: 'someone', foreign: 'qualcuno', nativeSentence: 'someone ate the last piece of cake', foreignSentence: 'qualcuno ha mangiato l\'ultima fetta di torta'},
                    {native: 'from', foreign: 'dal', nativeSentence: 'you can sea the sea from the balcony', foreignSentence: 'puoi vedere il mare dal balcone'},
                    {native: 'job', foreign: 'lavoro', nativeSentence: 'he really loves his job', foreignSentence: 'lui ama veramente il suo lavoro'},
                    {native: 'knows', foreign: 'sa', nativeSentence: 'he knows everything about me', foreignSentence: 'lui sa tutto di me'},
                    {native: 'to', foreign: 'ai', nativeSentence: 'he left a lot of money to his heirs', foreignSentence: 'ha lasciato molto denaro ai suoi eredi'},
                    {native: 'see', foreign: 'vedere', nativeSentence: 'let me see', foreignSentence: 'fammi vedere'},
                    {native: 'every', foreign: 'ogni', nativeSentence: 'every man has a dream', foreignSentence: 'ogni uomo ha un sogno'},
                    {native: 'the', foreign: 'i', nativeSentence: 'the children are watching tv', foreignSentence: 'i bambini stanno guardando la tv'},
                    {native: 'too much', foreign: 'troppo', nativeSentence: 'i ate too much', foreignSentence: 'ho mangiato troppo'}, 
                    {native: 'place', foreign: 'posto',  nativeSentence: 'this it the place for me!', foreignSentence: 'questo  è il posto per me!'},
                ]
            top175phrases:
                title: 'Phrases For The Top 150 - 175 Words'
                subtitle: 'Phrases for the 150 - 175 most frequently used Italian words'
                nextLevel: 'top200words'
                data: [
                    {native: 'i believe in god', foreign: 'io credo in dio'},
                    {native: 'i will tell you later', foreign: 'te lo dirò dopo'},
                    {native: 'i never go out without my umbrella', foreign: 'non esco mai senza il mio ombrello'},
                    {native: 'put your things in the wardrobe', foreign: 'metti le tue cose nell\'armadio'},
                    {native: 'nobody knows the truth', foreign: 'nessuno sa la verità'},
                    {native: 'what do you do in your spare time? ', foreign: 'cosa fai nel tuo tempo libero? '},
                    {native: 'what day is today? ', foreign: 'che giorno è oggi? '},
                    {native: 'cause and effect', foreign: 'causa ed effetto'}
                    {native: 'better late than never', foreign: 'meglio tardi che mai'},
                    {native: 'my father is very strict', foreign: 'mio padre è molto severo'},
                    {native: 'can you do me a favour? ', foreign: 'puoi farmi un favore? '},
                    {native: 'hello, my name is Mary', foreign: 'ciao, mi chiamo Maria'},
                    {native: 'what is this? ', foreign: 'cos\'è questo? '},
                    {native: 'you must go to work tomorrow', foreign: 'devi andare al lavoro domani'},
                    {native: 'here is my book', foreign: 'ecco il mio libro'},
                    {native: 'someone ate the last piece of cake', foreign: 'qualcuno ha mangiato l\'ultima fetta di torta'},
                    {native: 'you can sea the sea from the balcony', foreign: 'puoi vedere il mare dal balcone'},
                    {native: 'he really loves his job', foreign: 'lui ama veramente il suo lavoro'},
                    {native: 'he knows everything about me', foreign: 'lui sa tutto di me'},
                    {native: 'he left a lot of money to his heirs', foreign: 'ha lasciato molto denaro ai suoi eredi'},
                    {native: 'let me see', foreign: 'fammi vedere'},
                    {native: 'every man has a dream', foreign: 'ogni uomo ha un sogno'},
                    {native: 'the children are watching tv', foreign: 'i bambini stanno guardando la tv'},
                    {native: 'i ate too much', foreign: 'ho mangiato troppo'}, 
                    {native: 'this it the place for me!', foreign: 'questo  è il posto per me!'},
                ]
            top200words:
                title: 'Top 175 - 200 Words'
                subtitle: 'The 175 - 200 most frequently used Italian words'
                nextLevel: 'top200phrases'                
                data: [
                    {native: 'whom', foreign: 'cui', nativeSentence: 'Tom is the boy with whom Mary fell in love', foreignSentence: 'Tom è il ragazzo di cui Mary si è innamorata'},
                    {native: 'a lot', foreign: 'tanto', nativeSentence: 'i studied a lot', foreignSentence: 'ho studiato tanto'},
                    {native: 'bad', foreign: 'male', nativeSentence: 'she speaks bad french', foreignSentence: 'lei parla male francese'},
                    {native: 'from the', foreign: 'dai', nativeSentence: 'the warm wind from the seas', foreignSentence: 'il vento caldo dai mari'},
                    {native: 'it', foreign: 'ce', nativeSentence: 'i did it!', foreignSentence: 'ce l\'ho fatta!'},
                    {native: 'need', foreign: 'bisogno', nativeSentence: 'i need to rest', foreignSentence: 'ho bisogno di riposare'},
                    {native: 'mister', foreign: 'signor', nativeSentence: 'mister White is a very generous man', foreignSentence: 'il signor White è un uomo molto generoso'},
                    {native: 'well', foreign: 'beh', nativeSentence: 'well, i think so', foreignSentence: 'beh, penso di si'},
                    {native: 'why', foreign: 'perché', nativeSentence: 'why are you laughing?', foreignSentence: 'perché stai ridendo?'},
                    {native: 'come', foreign: 'vieni', nativeSentence: 'come to my party tomorrow', foreignSentence: 'vieni alla mia festa domani'},
                    {native: 'at', foreign: 'alle', nativeSentence: 'Tom will arrive at 6 pm', foreignSentence: 'Tom arriverà alle 18'},
                    {native: 'from the', foreign: 'dalla', nativeSentence: 'an intense light from the moon', foreignSentence: 'una luce intensa dalla luna'},
                    {native: 'has been', foreign: 'stata', nativeSentence: 'she has been the belle of the ball several times', foreignSentence: 'lei è stata la reginetta del ballo molte volte'},
                    {native: 'between', foreign: 'tra', nativeSentence: 'the city was built between two mountains', foreignSentence: 'la città fu costruita tra due montagne'},
                    {native: 'go', foreign: 'vai', nativeSentence: 'go to the store to buy some milk', foreignSentence: 'vai al negozio a comprare del latte'},
                    {native: 'hey', foreign: 'ehi', nativeSentence: 'hey, come here!', foreignSentence: 'ehi, vieni qui!'},
                    {native: 'my', foreign: 'miei', nativeSentence: 'do you like my new boots?', foreignSentence: 'ti piacciono i miei nuovi stivali?'},
                    {native: 'friend', foreign: 'amico', nativeSentence: 'Tom is my best friend', foreignSentence: 'Tom è il mio migliore amico'},
                    {native: 'tells', foreign: 'dice', nativeSentence: 'he always tells the truth', foreignSentence: 'lui dice sempre la verità'},
                    {native: 'would be', foreign: 'sarebbe', nativeSentence: 'it would be better to go', foreignSentence: 'sarebbe meglio andare'},
                    {native: 'have', foreign: 'avete', nativeSentence: 'you have a very beautiful house', foreignSentence: 'avete una casa molto bella'},
                    {native: 'another', foreign: 'altra', nativeSentence: 'i would like another cup of coffee, please', foreignSentence: 'vorrei un\'altra tazza di caffè, per favore'},
                    {native: 'must', foreign:'deve', nativeSentence:  'he must go to work today', foreignSentence: 'lui deve andare al lavoro oggi'},
                    {native: 'on the', foreign: 'sulla', nativeSentence: 'she kissed me on the cheek', foreignSentence: 'lei mi ha baciato sulla guancia'},
                    {native: 'some', foreign: 'qualche', nativeSentence: 'i need some advice', foreignSentence: 'ho bisogno di qualche consiglio'},
                ]
            top200phrases:
                title: 'Phrases For The Top 175 - 200 Words'
                subtitle: 'Phrases for the 175 - 200 most frequently used Italian words'
                nextLevel: 'top225words'
                data: [
                    {native: 'Tom is the boy with whom Mary fell in love', foreign: 'Tom è il ragazzo di cui Mary si è innamorata'},
                    {native: 'i studied a lot', foreign: 'ho studiato tanto'},
                    {native: 'she speaks bad french', foreign: 'lei parla male francese'},
                    {native: 'the warm wind from the seas', foreign: 'il vento caldo dai mari'},
                    {native: 'i did it!', foreign: 'ce l\'ho fatta!'},
                    {native: 'i need to rest', foreign: 'ho bisogno di riposare'},
                    {native: 'mister White is a very generous man', foreign: 'il signor White è un uomo molto generoso'},
                    {native: 'well, i think so', foreign: 'beh, penso di si'},
                    {native: 'why are you laughing?', foreign: 'perché stai ridendo?'},
                    {native: 'come to my party tomorrow', foreign: 'vieni alla mia festa domani'},
                    {native: 'Tom will arrive at 6 pm', foreign: 'Tom arriverà alle 18'},
                    {native: 'an intense light from the moon', foreign: 'una luce intensa dalla luna'},
                    {native: 'she has been the belle of the ball several times', foreign: 'lei è stata la reginetta del ballo molte volte'},
                    {native: 'the city was built between two mountains', foreign: 'la città fu costruita tra due montagne'},
                    {native: 'go to the store to buy some milk', foreign: 'vai al negozio a comprare del latte'},
                    {native: 'hey, come here!', foreign: 'ehi, vieni qui!'},
                    {native: 'do you like my new boots?', foreign: 'ti piacciono i miei nuovi stivali?'},
                    {native: 'Tom is my best friend', foreign: 'Tom è il mio migliore amico'},
                    {native: 'he always tells the truth', foreign: 'lui dice sempre la verità'},
                    {native: 'it would be better to go', foreign: 'sarebbe meglio andare'},
                    {native: 'you have a very beautiful house', foreign: 'avete una casa molto bella'},
                    {native: 'i would like another cup of coffee, please', foreign: 'vorrei un\'altra tazza di caffè, per favore'},
                    {native:  'he must go to work today', foreign: 'lui deve andare al lavoro oggi'},
                    {native: 'she kissed me on the cheek', foreign: 'lei mi ha baciato sulla guancia'},
                    {native: 'i need some advice', foreign: 'ho bisogno di qualche consiglio'},
                ]
            top225words:
                title: 'Top 200 - 225 Words'
                subtitle: 'The 200 - 225 most frequently used Italian words'
                nextLevel: 'top225phrases'                
                data: [
                    {native: 'seems', foreign: 'sembra', nativeSentence: 'it seems like it is going to rain', foreignSentence: 'sembra che stia per piovere'},
                    {native: 'people', foreign: 'gente', nativeSentence: 'how many people were at the party?', foreignSentence: 'quanta gente c\'era alla festa?'},
                    {native: 'must', foreign: 'dobbiamo', nativeSentence: 'we must be proud of our son', foreignSentence: 'dobbiamo essere orgogliosi di nostro figlio'},
                    {native: 'way', foreign: 'modo', nativeSentence: 'i don\'t like the way you live', foreignSentence: 'non mi piace il modo in cui vivi'},
                    {native: 'three', foreign: 'tre', nativeSentence: 'i have three cats', foreignSentence: 'ho tre gatti'},
                    {native: 'moment', foreign: 'momento', nativeSentence: 'just a moment, please', foreignSentence: 'solo un momento, per favore'},
                    {native: 'please', foreign: 'prego', nativeSentence: 'this way, please', foreignSentence: 'da questa parte, prego'},
                    {native: 'talk', foreign: 'parlare', nativeSentence: 'i must talk to you', foreignSentence: 'ti devo parlare'},    
                    {native: 'mum', foreign: 'mamma', nativeSentence: 'mum, can i have another cup of tea?', foreignSentence: 'mamma, posso avere un\'altra tazza di tè?'},
                    {native: 'look', foreign: 'guarda', nativeSentence: 'look at the blue sky', foreignSentence: 'guarda il cielo blu'},
                    {native: 'lady', foreign: 'signora', nativeSentence: 'who is that lady with a strange hat?', foreignSentence:  'chi è quella signora con uno strano cappello?'},
                    {native: 'big', foreign: 'grande', nativeSentence: 'they live in a big country house', foreignSentence: 'loro vivono in una grande casa di campagna'},
                    {native: 'there', foreign: 'lì', nativeSentence: 'your book is right there', foreignSentence: 'il tuo libro è proprio lì'},
                    {native: 'mother', foreign: 'madre',  nativeSentence: 'my mother is an excellent cook', foreignSentence: 'mia madre è un\'eccellente cuoca'},
                    {native: 'can', foreign: 'possiamo', nativeSentence: 'can we talk about it later?', foreignSentence: 'possiamo parlarne più tardi?'},
                    {native: 'forward', foreign: 'avanti', nativeSentence: 'please, take one step forward', foreignSentence: 'per favore, fai un passo avanti'},
                    {native: 'to have', foreign: 'avere', nativeSentence: 'sleep is essential to have a luminous skin', foreignSentence: 'il sonno è essenziale per avere una pelle luminosa'},
                    {native: 'success', foreign: 'successo', nativeSentence: 'education is the key to success', foreignSentence: 'l\'istruzione è la chiave del successo'},
                    {native: 'was', foreign: 'ero', nativeSentence: 'i was a very shy child', foreignSentence: 'ero un bimbo molto timido'},
                    {native: 'woman', foreign: 'donna', nativeSentence: 'every man needs a woman', foreignSentence: 'ogni uomo ha bisogno di una donna'},
                    {native: 'new', foreign: 'nuovo', nativeSentence: 'there is a new flower in my garden', foreignSentence: 'c\'è un nuovo fiore nel mio giardino'},
                    {native: 'ah', foreign: 'ah', nativeSentence: 'ah, the good old days!', foreignSentence: 'ah, i bei vecchi tempi!'},
                    {native: 'do', foreign: 'faccio', nativeSentence: 'i do what i want', foreignSentence: 'faccio quel che voglio'},
                    {native: 'had', foreign: 'aveva', nativeSentence: 'she had a red old car', foreignSentence: 'lei aveva una vecchia macchina rossa'},
                    {native: 'our', foreign: 'nostro', nativeSentence: 'there is a rat in our garden', foreignSentence: 'c\'è un topo nel nostro giardino'},
                ]
            top225phrases:
                title: 'Phrases For The Top 200 - 225 Words'
                subtitle: 'Phrases for the 200 - 225 most frequently used Italian words'
                nextLevel: 'top250words'
                data: [
                    {native: 'it seems like it is going to rain', foreign: 'sembra che stia per piovere'},
                    {native: 'how many people were at the party?', foreign: 'quanta gente c\'era alla festa?'},
                    {native: 'we must be proud of our son', foreign: 'dobbiamo essere orgogliosi di nostro figlio'},
                    {native: 'i don\'t like the way you live', foreign: 'non mi piace il modo in cui vivi'},
                    {native: 'i have three cats', foreign: 'ho tre gatti'},
                    {native: 'just a moment, please', foreign: 'solo un momento, per favore'},
                    {native: 'this way, please', foreign: 'da questa parte, prego'},
                    {native: 'i must talk to you', foreign: 'ti devo parlare'},    
                    {native: 'mum, can i have another cup of tea?', foreign: 'mamma, posso avere un\'altra tazza di tè?'},
                    {native: 'look at the blue sky', foreign: 'guarda il cielo blu'},
                    {native: 'who is that lady with a strange hat?', foreign:  'chi è quella signora con uno strano cappello?'},
                    {native: 'they live in a big country house', foreign: 'loro vivono in una grande casa di campagna'},
                    {native: 'your book is right there', foreign: 'il tuo libro è proprio lì'},
                    {native: 'my mother is an excellent cook', foreign: 'mia madre è un\'eccellente cuoca'},
                    {native: 'can we talk about it later?', foreign: 'possiamo parlarne più tardi?'},
                    {native: 'please, take one step forward', foreign: 'per favore, fai un passo avanti'},
                    {native: 'sleep is essential to have a luminous skin', foreign: 'il sonno è essenziale per avere una pelle luminosa'},
                    {native: 'education is the key to success', foreign: 'l\'istruzione è la chiave del successo'},
                    {native: 'i was a very shy child', foreign: 'ero un bimbo molto timido'},
                    {native: 'every man needs a woman', foreign: 'ogni uomo ha bisogno di una donna'},
                    {native: 'there is a new flower in my garden', foreign: 'c\'è un nuovo fiore nel mio giardino'},
                    {native: 'ah, the good old days!', foreign: 'ah, i bei vecchi tempi!'},
                    {native: 'i do what i want', foreign: 'faccio quel che voglio'},
                    {native: 'she had a red old car', foreign: 'lei aveva una vecchia macchina rossa'},
                    {native: 'there is a rat in our garden', foreign: 'c\'è un topo nel nostro giardino'},
                ]
            top250words:
                title: 'Top 225 - 250 Words'
                subtitle: 'The 225 - 250 most frequently used Italian words'
                nextLevel: 'top250phrases'                
                data: [
                    {native: 'of the', foreign: 'degli', nativeSentence: 'ambrosia was the food of the gods', foreignSentence: 'l\'ambrosia era il cibo degli dei'},
                    {native: 'these', foreign: 'questi', nativeSentence: 'it\'s been raining a lot these days', foreignSentence: 'è piovuto molto in questi giorni'},
                    {native: 'are', foreign: 'siete', nativeSentence: 'are you sure about that?', foreignSentence: 'sieti sicuri di ciò?'},
                    {native: 'force', foreign: 'forza', nativeSentence: 'she is a force of nature', foreignSentence: 'lei è una forza della natura'},
                    {native: 'like', foreign: 'piace', nativeSentence: 'i like chocolate', foreignSentence: 'mi piace il cioccolato'},
                    {native: 'beautiful', foreign: 'bella', nativeSentence: 'she is the most beautiful girl in town', foreignSentence: 'lei è la più bella ragazza in città'},
                    {native: 'where', foreign: 'dov\'', nativeSentence: 'where is my hat?', foreignSentence: 'dov\'è il mio cappello?'},
                    {native: 'money', foreign: 'soldi', nativeSentence: 'it takes money to make money', foreignSentence: 'ci vogliono soldi per fare soldi'},
                    {native: 'had', foreign: 'avevo', nativeSentence: 'once i had a parrot named Bob', foreignSentence: 'una volta avevo un pappagallo chiamato Bob'},
                    {native: 'favour', foreign: 'favore', nativeSentence: 'can you do me a favour?', foreignSentence: 'puoi farmi un favore?'},
                    {native: 'were',  foreign: 'fosse', nativeSentence: 'oh that it were so!', foreignSentence: 'magari fosse così!'},
                    {native: 'other', foreign: 'altri', nativeSentence: 'Mary likes to play with other children', foreignSentence: 'a Mary piace giocare con altri bambini'},
                    {native: 'sorry', foreign: 'dispiace', nativeSentence: 'i am sorry to disturb you', foreignSentence: 'mi dispiace disturbarti'},
                    {native: 'immediately', foreign: 'subito', nativeSentence: 'let\'s start immediately', foreignSentence: 'cominciamo subito'},
                    {native: 'inside', foreign: 'dentro', nativeSentence: 'the ring is inside the box', foreignSentence: 'l\'anello è dentro la scatola'},
                    {native: 'today', foreign: 'oggi', nativeSentence: 'today, it\'s a wonderful day', foreignSentence: 'oggi, è una meravigliosa giornata'},
                    {native: 'agree', foreign: 'accordo', nativeSentence: 'i agree with him', foreignSentence: 'sono d\'accordo con lui'},
                    {native: 'whole', foreign: 'tutta', nativeSentence: 'you don\'t know the whole story', foreignSentence: 'tu non sai tutta la storia'},
                    {native: 'name', foreign: 'nome', nativeSentence: 'i don\'t know his name', foreignSentence: 'non so il suo nome'},
                    {native: 'ok', foreign: 'ok', nativeSentence: 'it\'s ok', foreignSentence: 'è ok'},
                    {native: 'night', foreign:'notte', nativeSentence: 'rome is a magical city at night', foreignSentence: 'roma è una città magica di notte'},
                    {native: 'these', foreign: 'queste', nativeSentence: 'these are my favourite shoes', foreignSentence: 'queste sono le mie scarpe preferite'},
                    {native: 'son', foreign: 'figlio', nativeSentence: 'my son is a doctor', foreignSentence: 'mio figlio è un dottore'},
                    {native: 'world', foreign: 'mondo', nativeSentence: 'i would like to travel all over the world', foreignSentence: 'vorrei viaggiare in tutto il mondo'},
                    {native: 'our', foreign: 'nostra', nativeSentence: 'our car needs repair', foreignSentence: 'la nostra auto ha bisogno di riparazioni'},
                ]
            top250phrases:
                title: 'Phrases For The Top 225 - 250 Words'
                subtitle: 'Phrases for the 225 - 250 most frequently used Italian words'
                nextLevel: 'top275words'
                data: [
                    {native: 'ambrosia was the food of the gods', foreign: 'l\'ambrosia era il cibo degli dei'},
                    {native: 'it\'s been raining a lot these days', foreign: 'è piovuto molto in questi giorni'},
                    {native: 'are you sure about that?', foreign: 'sieti sicuri di ciò?'},
                    {native: 'she is a force of nature', foreign: 'lei è una forza della natura'},
                    {native: 'i like chocolate', foreign: 'mi piace il cioccolato'},
                    {native: 'she is the most beautiful girl in town', foreign: 'lei è la più bella ragazza in città'},
                    {native: 'where is my hat?', foreign: 'dov\'è il mio cappello?'},
                    {native: 'it takes money to make money', foreign: 'ci vogliono soldi per fare soldi'},
                    {native: 'once i had a parrot named Bob', foreign: 'una volta avevo un pappagallo chiamato Bob'},
                    {native: 'can you do me a favour?', foreign: 'puoi farmi un favore?'},
                    {native: 'oh that it were so!', foreign: 'magari fosse così!'},
                    {native: 'Mary likes to play with other children', foreign: 'a Mary piace giocare con altri bambini'},
                    {native: 'i am sorry to disturb you', foreign: 'mi dispiace disturbarti'},
                    {native: 'let\'s start immediately', foreign: 'cominciamo subito'},
                    {native: 'the ring is inside the box', foreign: 'l\'anello è dentro la scatola'},
                    {native: 'today, it\'s a wonderful day', foreign: 'oggi, è una meravigliosa giornata'},
                    {native: 'i agree with him', foreign: 'sono d\'accordo con lui'},
                    {native: 'you don\'t know the whole story', foreign: 'tu non sai tutta la storia'},
                    {native: 'i don\'t know his name', foreign: 'non so il suo nome'},
                    {native: 'it\'s ok', foreign: 'è ok'},
                    {native: 'rome is a magical city at night', foreign: 'roma è una città magica di notte'},
                    {native: 'these are my favourite shoes', foreign: 'queste sono le mie scarpe preferite'},
                    {native: 'my son is a doctor', foreign: 'mio figlio è un dottore'},
                    {native: 'i would like to travel all over the world', foreign: 'vorrei viaggiare in tutto il mondo'},
                    {native: 'our car needs repair', foreign: 'la nostra auto ha bisogno di riparazioni'},
                ]
        

                    

after150 = [                    
    {native: 'to know', foreign: 'sapere', nativeSentence: 'it is important to know the truth', foreignSentence: 'è importante sapere la verità'},
    {native: 'go', foreign: 'vado', nativeSentence: 'i go to the church every day', foreignSentence: 'vado in chiesa ogni giorno'},
    {native: 'all', foreign: 'tutte', nativeSentence: 'all the women were dressed in blue', foreignSentence: 'tutte le donne erano vestite di blu'},
    {native: 'wait', foreign: 'aspetta', nativeSentence: 'wait a moment, please', foreignSentence: 'aspetta un attimo, per favore'},
    {native: 'to love', foreign: 'amare', nativeSentence: 'i need somebody to love', foreignSentence: 'ho bisogno di qualcuno da amare'},
    {native: 'wife', foreign: 'moglie', nativeSentence: 'he really loves his wife', foreignSentence: 'lui ama veramente sua moglie'},
    {native: 'sure', foreign: 'sicuro', nativeSentence: 'you can never be sure of anything', foreignSentence: 'non puoi mai essere sicuro di nulla'}
    {native: 'her', foreign: 'suoi', nativeSentence: 'I like her new boots', foreignSentence: 'mi piacciono I suoi nuovi stivali'},
    {native: 'think', foreign: 'penso', nativeSentence: ' I always think about you',  foreignSentence: 'ti penso sempre'},
    {native: 'fright', foreign: 'paura', nativeSentence: 'what a fright!', foreignSentence: 'che paura!'},
    {native: 'idea', foreign: 'idea', nativeSentence: 'I think it is a good idea', foreignSentence: 'penso che sia una buona idea'},
    {native: 'head', foreign: 'testa', nativeSentence: 'he has his head in the clouds', foreignSentence: 'ha la testa tra le nuvole'},
    {native: 'dad', foreign: 'papà', nativeSentence: 'my dad is very protective of me', foreignSentence: 'il mio papà è molto protettivo con me'},
    {native: 'right', foreign: 'giusto', nativeSentence: 'to be in the right place at the right time', foreignSentence: 'essere al posto giusto al momento giusto'},
    {native: 'eh', foreign: 'eh', nativeSentence: 'eh, that’s life!', foreignSentence: 'eh, questa è la vita!'},
    {native: 'would like', foreign: 'vorrei', nativeSentence: 'I would like a piece of cake', foreignSentence: 'vorrei una fetta di torta'},
    {native: 'hear', foreign: 'senti', nativeSentence: 'don’t you hear strange noises?', foreignSentences: 'non senti strani rumori?'},
    {native: 'early', foreign: 'presto', nativeSentence: 'I always wake up early in the morning', foreignSentence: 'mi sveglio sempre presto al mattino'},
    {native: 'men', foreign: 'uomini', nativeSentence: 'men must be brave and strong', foreignSentence: 'gli uomini devono essere coraggiosi e forti'},
    {native: 'the', foreign: 'il', nativeSentence: 'the sea is rough today', foreignSentence: 'il mare è agitato oggi'},
    {native: 'stop', foreign: 'basta', nativeSentence: 'stop talking', foreignSentence: 'basta parlare'},
    {native: 'might', foreign: 'potrebbe', nativeSentence: 'she might be wrong', foreignSentence: 'lei potrebbe sbagliarsi'},
    {native: 'same', foreign: 'stesso', nativeSentence: 'she is wearing the same dress as yesterday', foreignSentence: 'lei indossa lo stesso abito di ieri'},
    {native: 'had', foreign: 'avuto', nativeSentence: 'I had no time to say goodbye', foreignSentence: 'non ho avuto tempo di salutare'},
    {native: 'door', foreign: 'porta', nativeSentence: 'please, close the door', foreignSentence: 'per favore, chiudi la porta'},
    {native:'were', foreign: 'erano', nativeSentence: 'they were bored with the game', foreignSentence: 'erano annoiati dal gioco'},
    {native: 'to be', foreign: 'stare', nativeSentence: 'you can not be in two places at once', foreignSentence: 'non puoi stare in due posti contemporaneamente'},
    {native: 'good', foreign:'buona', nativeSentence: 'any excuse is good for him', foreignSentence: 'ogni scusa è buona per lui'},
    {native: 'therefore', foreign: 'quindi', nativeSentence: 'I think, therefore I am', foreignSentence: 'penso, quindi sono'},
    {native: 'do it', foreign: 'farlo', nativeSentence: 'we must do it as soon as possible', foreignSentence: 'dobbiamo farlo il più presto possibile'},
    {native: 'just', foreign: 'appena', nativeSentence: 'he has just arrived in town', foreignSentence: 'lui è appena arrivato in città'},
    {native: 'have', foreign: 'abbia', nativeSentence: 'she is the prettiest girl I have ever seen', foreignSentence: 'è la ragazza più carina che abbia mai visto'},
    {native: 'reason', foreign: 'ragione', nativeSentence: 'you have no reason to complain', foreignSentence: 'non hai ragione di lamentarti'},
    {native: 'heard', foreign:'sentito', nativeSentence: 'I heard you are leaving your job', foreignSentence: 'ho sentito che lascerai il tuo lavoro'},
    {native: 'boys', foreign: 'ragazzi', nativeSentence: 'boys like to watch sports on tv', foreignSentence: 'ai ragazzi piace guardare lo sport in tv'},
    {native: 'tomorrow', foreign: 'domani', nativeSentence: 'I am going to the cinema tomorrow', foreignSentence: 'andrò al cinema domani'},
    {native: 'girl', foreign: 'ragazza', nativeSentence: 'that girl has a great sense of humor', foreignSentence: 'quella ragazza ha un gran senso dell’umorismo'},
    {native: 'boy', foreign: 'ragazzo', nativeSentence: 'that boy is so boring', foreignSentence: 'quel ragazzo è così noioso'},
    {native: 'together', foreign: 'insieme', nativeSentence: 'they are always together', foreignSentence: 'stanno sempre insieme'},
    {native: 'under', foreign: 'sotto', nativeSentence: 'the cat is under the table', foreignSentence: 'il gatto è sotto al tavolo'},
    {native: 'wanted', foreign: 'volevo', nativeSentence: 'I wanted to be alone', foreignSentence: 'volevo stare solo'},
    {native: 'ready', foreign: 'pronto', nativeSentence: 'are you ready?', foreignSentence: 'sei pronto?'},
    {native: 'in the', foreign: 'nei', nativeSentence: 'I met a bear in the woods', foreignSentence: 'ho incontrato un orso nei boschi'},
    {native: 'that', foreign: 'ciò', nativeSentence: 'that is all I can say', foreignSentence: 'è tutto ciò che posso dire'},
    {native: 'times', foreign: 'volte', nativeSentence: 'I have been to Italy many times', foreignSentence: 'sono stato in Italia molte volte'},
    {native: 'understood', foreign: 'capito', nativeSentence: 'have you understood?', foreignSentence: 'hai capito?'},
    {native: 'happens', foreign: 'succede', nativeSentence: 'sometimes something unexpected happens', foreignSentence: 'a volte succede qualcosa di inaspettato'},
    {native: 'taken', foreign: 'preso', nativeSentence: 'I have taken notes', foreignSentence: 'ho preso appunti'},
    {native: 'doing', foreign: 'facendo', nativeSentence: 'what are you doing?', foreignSentence: 'cosa stai facendo?'},
    {native: 'nice', foreign: 'piacere', nativeSentence: 'nice to meet you', foreignSentence: 'piacere di conoscerla'},
    {native: 'dead', foreign: 'morto', nativeSentence: 'he is dead to us', foreeignSentence: 'lui è morto per noi'},
    {native: 'your', foreign: 'tuoi', nativeSentence: 'claim your rights', foreignSentence: 'rivendica I tuoi diritti'},
    {native: 'captain', foreign: 'capitano', nativeSentence: 'the captain abandoned the ship', foreignSentence: 'il capitano ha abbandonato la nave'},
    {native: 'bed', foreign: 'letto', nativeSentence: 'it is time to go to bed', foreignSentence: 'è ora di andare a letto'},
    {native: 'story', foreign: 'storia', nativeSentence: 'it is always the same old story', foreignSentence: 'è sempre la solita vecchia storia'},
    {native: 'case', foreign: 'caso', nativeSentence: 'call me in case of emergency', foreignSentence: 'chiamami in caso di emergenza'},
    {native: 'found', foreign: 'trovato', nativeSentence: 'I found a ring on the street', foreignSentence: 'ho trovato un anello per strada'},
    {native: 'friends', foreign: 'amici', nativeSentence: 'they are my best friends', foreignSentence: 'loro sono I miei migliori amici'},
    {native: 'to come', foreign: 'venire', nativeSentence: 'the best is yet to come', foreignSentence: 'il meglio deve ancora venire'},
    {native: 'say', foreign: 'dico', nativeSentence: 'every night I say a prayer', foreignSentence: 'ogni sera dico una preghiera'},
    {native: 'understand', foreign: 'capisco', nativeSentence: 'I understand what you mean', foreeignSentence: 'capisco ciò che vuoi dire'},
    {native: 'problem', foreign: 'problema', nativeSentence: 'you need to solve the problem', foreignSentence: 'hai bisogno di risolvere il problema'},
    {native: 'until', foreign: 'fino', nativeSentence: 'I will be busy until tomorrow night', foreignSentence: 'sarò impegnato fino a domani sera'},
    {native: 'guy', foreign: 'tipo', nativeSentence: 'who is that guy?', foreignSentence: 'chi è quell tipo?'},
    {native: 'there', foreign: 'là', nativeSentence: 'go over there', foreignSentence: 'vai là'},
    {native: 'here', foreign: 'qua', nativeSentence: 'come here!', foreignSentence: 'vieni qua!'},
    {native: ' have', foreign: 'aver', nativeSentence: 'have no fear!', foreignSentence: 'non aver paura!'},
    {native: 'days', foreign: 'giorni', nativeSentence: 'I am working a lot these days', foreignSentence: 'sto lavorando molto in questi giorni'},
    {native: 'fuck', foreign: 'cazzo', nativeSentence: 'what the fuck do you want?', foreignSentence: 'che cazzo vuoi?'},
    {native: 'okay', foreign: 'okay', nativeSentence: 'is everything okay?', foreignSentence: 'è tutto okay?'},
    {native: 'nothing', foreign: 'nulla', nativeSentence: 'there is nothing to do', foreignSentence: 'non c’è nulla da fare'},
    {native: 'beautiful', foreign: 'bello', nativeSentence: 'your new coat is very beautiful', foreeignSentence: 'il tuo cappotto nuovo è molto bello'},
    {native: 'people', foreign: 'persone', nativeSentence: 'they are nice people', foreignSentence: 'sono persone simpatiche'},
    {native: 'good', foreign: 'buon', nativeSentence: 'good morning!', foreignSentence: 'buon giorno!'},
    {native: 'earth', foreign: 'terra', nativeSentence: 'pollutionis destroying the earth', foreignSentence: 'l’inquinamento sta distruggendo la terra'},
    {native: 'gave', foreign: 'dato', nativeSentence: 'the teacher gave the whole class one hour detention', foreignSentence: 'l’insegnante ha dato un’ora di punizione a tutta la classe'},
    {native: 'second', foreign: 'secondo', nativeSentence: 'I will be back in a second', foreignSentence: 'torno tra un secondo'},
    {native: 'movie', foreign: 'film', nativeSentence: 'the movie was about a love story', foreignSentence: 'il film riguardava una storia d’amore'},    
    {native: 'in the', foreign: 'nell’', nativeSentence: 'there is something in the air', foreignSentence: 'c’è qualcosa nell’aria'},
    {native: 'hand', foreign: 'mano', nativeSentence: 'give me your hand', foreignSentence: 'dammi la mano'},
    {native: 'do', foreign: 'facciamo', nativeSentence: 'we are what we do', foreignSentence: 'siamo quell che facciamo'},
    {native: 'see', foreign: 'vediamo', nativeSentence: 'we see her every day at school', foreignSentence: 'la vediamo a scuola tutti i giorni'},
    {native: 'see', foreign: 'vedo', nativeSentence: 'I see a shadow behind the window', foreignSentence: 'vedo un’ombra dietro la finestra'},
    {native: 'are', foreign: 'stanno', nativeSentence: 'the books are on the table', foreignSentence: 'I libri stanno sul tavolo'},
    {native: 'have', foreign: 'avrei', nativeSentence: 'I should have studied harder', foreignSentence: 'avrei dovuto studiare di più'},
    {native: 'to take', foreign: 'prendere', nativeSentence: 'you have to take the medicin', foreignSentence: 'devi prendere la medicina'},
    {native: 'say', foreign: 'dici', nativesentence: 'you always say the right thing', foreignSentence: 'dici sempre la cosa giusta'},
    {native: 'need', foreign: 'serve', nativeSentence: 'there is no need for anger', foreignSentence: 'non serve arrabbiarsi'},
    {native: 'dead', foreign: 'morte', nativeSentence: 'four people are dead after a car accident yesterday', foreignSentence: 'quattro persone sono morte dopo un incidente d’auto ieri'},
    {native: 'less', foreign: 'meno', nativeSentence: 'it is less complicated then you think', foreignSentence: 'è meno complicato di quanto pensi'},
    {native: 'city', foreign: 'città', nativeSentence: 'living in a big city is stressful', foreignSentence: 'vivere in una grande città è stressante'},
    {native: 'eyes', foreign: 'occhi', nativeSentence: 'I can not keep my eyes open', foreignSentence: 'non riesco a tenere gli occhi aperti'},
    {native: 'end', foreign: 'fine', nativeSentence: 'from beginning to end', foreignSentence: 'dall’inizio alla fine'},
    {native: 'mr', foreign: 'sig', nativeSentence: 'mr Smith has two children', foreignSentence: 'il sig Smith ha due figli'},
    {native: 'darling', foreign: 'tesoro', nativeSentence: 'I miss you darling', foreignSentence: 'mi manchi tesoro'},
    {native: 'excuse', foreign: 'scusi', nativeSentence: 'excuse me, what time is it?', foreignSentence: 'scusi, che ora è?'},
    {native: 'first', foreign: 'primo', nativeSentence: 'Armstrong was the first man to walk on the moon', foreignSentence: 'Armstrong fu il primo uomo a camminare sulla luna'},
    {native: 'think', foreign: 'credi', nativeSentence: 'do as you think best', foreignSentence: 'fai come meglio credi'},
    {native: 'hi', foreign: 'salve', nativeSentence: 'hi everybody!', foreignSentence: 'salve a tutti!'},
    {native: 'ship', foreign: 'nave', nativeSentence: 'rats leave a sinking ship', foreignSentence: 'I topi abbandonano una nave che affonda'},
    {native: 'are', foreign: 'stiamo', nativeSentence: 'we are looking for a new house', foreignSentence: 'stiamo cercando una nuova casa'},
    {native: 'evening', foreign: 'sera', nativeSentence: 'I am leaving on Saturday evening', foreignSentence: 'partirò sabato sera'},
    {native: 'slow', foreign: 'piano', nativeSentence: 'please slow down', foreignSentence: 'per favore vai più piano'},
    {native: 'hear', foreign: 'sento', nativeSentence: 'I hear the church bells', foreignSentence: 'sento le campane della chiesa'},
    {native: 'car', foreign: 'macchina', nativeSentence: 'my brother has a vintage car', foreignSentence: 'mio fratello ha una  macchina d’epoca'},
    {native: 'your', foreign: 'vostro', nativeSentence: 'your dog is very aggressive', foreignSentence: 'il vostro cane è molto aggressivo'},
    {native: 'hands', foreign: 'mani', nativeSentence: 'you are in good hands', foreignSentence: 'sei in buone mani'},
    {native: 'either', foreign: 'neanche', nativeSentence: 'I can not do it either', foreignSentence: 'neanche io posso farlo'},
    {native: 'from the', foreign: 'dall’', nativeSentence: 'the station is not far from the hotel', foreignSentence: 'la stazione non è lontana dall’albergo'},
    {native: 'doctor', foreign: 'dottore', nativeSentence: 'I went to the doctor yesterday', foreignSentence: 'ieri sono andato dal dottore'},
    {native: 'what', foreign: 'quale', nativeSentence: 'what is your favourite book?', foreignSentence: 'quale è il tuo libro preferito?'},
    {native: 'enough', foreign: 'abbastanza', nativeSentence: 'have you got enough chocolate for the cake?', foreignSentence: 'hai abbastanza cioccolato per la torta?'},
    {native: 'late', foreign: 'tardi', nativeSentence: 'it is getting late', foreignSentence: 'si sta facendo tardi'},
    {native: 'fine', foreign: 'bel', nativeSentence: 'what a fine weather we have today!', foreignSentence: 'che bel tempo c’è oggi!'},
    {native: 'heart', foreign: 'cuore', nativeSentence: 'follow your heart', foreignSentence: 'segui il tuo cuore'},
    {native: 'family', foreign: 'famiglia', nativeSentence: 'sunday is family day', foreignSentence: 'la domenica è il giorno della famiglia'},
    {native: 'to do', foreign: 'far', nativeSentence: 'it’s time to do something', foreignSentence: 'è tempo di far qualcosa'},
    {native: 'have been', foreign: 'stati', nativeSentence: 'all items have been shipped', foreignSentence: 'tutti gli articoli sono stati spediti'},
    {native: 'help', foreign: 'aiuto', nativeSentence: 'call me if you need help', foreignSentence: 'chiamami se hai bisogno di aiuto'},
    {native: 'devil', foreign: 'diavolo', nativeSentence: 'speak of the devil and he doth appear', foreignSentence: 'parli del diavolo e spuntano le corna'},
    {native: 'our', foreign: 'nostri', nativeSentence: 'our kids love to paint', foreignSentence: 'ai nostril figli piace dipingere'},
    {native: 'with', foreign: 'col', nativeSentence: 'if you play with fire you get burned', foreignSentence: 'se giochi col fuoco ti scotti'},
    {native: 'almost', foreign: 'quasi', nativeSentence: 'it’s almost ten o’clock', foreignSentence: 'sono quasi le dieci'},
    {native: 'police', foreign: 'polizia', nativeSentence: 'the police arrested a thief', foreignSentence: 'la polizia ha arrestato un ladro'},
    {native: 'boss', foreign: 'capo', nativeSentence: 'my boss gave me a promotion', foreignSentence: 'il mio capo mi ha dato una promozione'},
    {native: 'would have', foreign: 'avrebbe', nativeSentence: 'who would have tought it?', foreignSentence: 'chi l’avrebbe pensato?'},
    {native: 'those', foreign: 'quei', nativeSentence: 'put those books in the bookcase', foreignSentence: 'metti quei libri nello scaffale'},
    {native: 'my', foreign: 'mie', nativeSentence: 'please accept my apologies', foreignSentence: 'per favore accetta le mie scuse'},
    {native: 'to go back', foreign: 'tornare', nativeSentence: 'I have to go back home', foreignSentence: 'devo tornare a casa'},
    {native: 'but', foreign: 'però', nativeSentence: 'she is not pretty but she is nice', foreignSentence: 'lei non è carina però è simpatica'},
    {native: 'against', foreign: 'contro', nativeSentence: 'we are against racism', foreignSentence: 'noi siamo contro il razzismo'},
    {native: 'comes', foreign: 'viene', nativeSentence: 'where does he come from?', foreignSentence: 'da dove viene?'},
    {native: 'while', foreign: 'mentre', nativeSentence: 'I fell asleep while watching tv', foreignSentence: 'mi sono addormentato mentre guardavo la tv'},
    {native: 'sorry', foreign: 'scusa', nativeSentence: 'sorry for the delay', foreignSentence: 'scusa il ritardo'},
    {native: 'lonely', foreign: 'sola', nativeSentence: 'I often feel lonely', foreignSentence: 'mi sento spesso sola'},
    {native: 'hope', foreign: 'spero', nativeSentence: 'I hope to see you soon', foreignSentence: 'spero di vederti presto'},
    {native: 'those', foreign: 'quelle', nativeSentence: 'those pink roses are so beautiful!', foreignSentence: 'quelle rose rosa sono così belle!'},
    {native: 'to find', foreign: 'trovare', nativeSentence: 'it’s not easy to find a good job', foreignSentence: 'non è facile trovare un buon lavoro'},
    {native: 'walk', foreign: 'giro', nativeSentence: 'let’s go for a walk', foreignSentence: 'facciamo un giro', },
    {native: 'too', foreign: 'anch’', nativeSentence: 'I love you too', foreignSentence: 'anch’io ti amo'},
    {native: 'war', foreign: 'guerra', nativeSentence: 'my grandfather fought in the war', foreignSentence: 'mio nonno ha combattuto in guerra'},
    {native: 'her', foreign: 'sue', nativeSentence: 'she lives with her sisters', foreignSentence: 'lei vive con le sue sorelle'},
    {native: 'child', foreign: 'bambino', nativeSentence: 'he is a child prodigy', foreignSentence: 'è un bambino prodigio'},
    {native: 'street', foreign: 'strada', nativeSentence: 'this street has four lanes', foreignSentence: 'questa strada ha quattro corsie'},
    {native: 'old', foreign: 'vecchio', nativeSentence: 'he is getting old', foreignSentence: 'sta diventando vecchio'},
    {native: 'brother', foreign: 'fratello', nativeSentence: 'I have an older brother', foreignSentence: 'ho un fratello maggiore'},
    {native: 'water', foreign: 'acqua', nativeSentence: 'please bring me some water', foreignSentence: 'per favore portami dell’acqua'},
    {native: 'tonight', foreign: 'stasera', nativeSentence: 'I’m going to the cinema tonight', foreignSentence: 'vado al cinema stasera'},
    {native: 'thought', foreign: 'pensavo', nativeSentence:'I thought you would come', foreignSentence: 'pensavo che saresti venuto'},
    {native: 'call', foreign: 'chiama', nativeSentence: 'call you parents if you’re going to be late', foreignSentence: 'chiama I tuoi genitori se farai tardi'},
    {native: 'person', foreign: 'persona', nativeSentence: 'she is a very nice person', foreignSentence: 'è una persona molto simpatica'},
    {native: 'see', foreign: 'vedi', nativeSentence: 'tell me what you see', foreignSentence: 'dimmi cosa vedi'},
    {native: 'was', foreign: 'fu', nativeSentence: 'my father was a hero', foreignSentence: 'mio padre fu un eroe'},
    {native: 'year', foreign: 'anno', nativeSentence: 'next year I will go to the university', foreignSentence: 'il prossimo anno andrò all’università'},
    {native: 'your', foreign: 'vostra', nativeSentence: 'your house is bigger than mine', foreignSentence: 'la vostra casa è più grande della mia'},
    {native: 'really', foreign: 'veramente', nativeSentence: 'I really enjoyed the movie', foreignSentence: 'ilfilm mi è veramente piaciuto'},
    {native: 'over', foreign: 'finito', nativeSentence: 'the game is over', foreignSentence: 'il gioco è finito'},
    {native: 'husband', foreign: 'marito', nativeSentence: 'my husband works in the business district', foreignSentence: 'mio marito lavora nel distretto finanziario'},
    {native: 'minutes', foreign: 'minuti', nativeSentence: 'I’ll be back in five minutes', foreignSentence: 'torno tra cinque minuti'},
    {native: 'down', foreign: 'giù', nativeSentence: 'he was walking up and down the room', foreignSentence: 'andava su e giù per la stanza'},
    {native: 'women', foreign: 'donne', nativeSentence: 'women take care of their beauty', foreignSentence: 'le donne hanno cura della loro bellezza'},
    {native: 'good', foreign: 'bravo', nativeSentence: 'he is a good pupil', foreignSentence: 'è un bravo allievo'},
    {native: 'children', foreign: 'bambini', nativeSentence: 'education is important for children', foreignSentence: 'l’istruzione è importante per I bambini'},
    {native: 'remember', foreign: 'ricordi', nativeSentence: 'do you remember your childhood?', foreignSentence: 'ricordi la tua infanzia?'},
    {native: 'those', foreign: 'quelli', nativeSentence: 'true friends are those who share', foreignSentence: 'I veri amici sono quelli che condividono'},
    {native: 'stay', foreign: 'state', nativeSentence: 'stay there, don’t move', foreignSentence: 'state lì, non muovetevi'},
    {native: 'hours', foreign: 'ore', nativeSentence: 'I’ve been sitting here for hours', foreignSentence: 'sono seduto qui da ore'},
    {native: 'was', foreign: 'stavo', nativeSentence: 'I was lying on the sofa', foreignSentence: 'stavo sdraiato sul divano'},
    {native: 'had', foreign: 'dovuto', nativeSentence: 'I had to learn to forgive', foreignSentence: 'ho dovuto imparare a perdonare'},
    {native: 'not even', foreign: 'nemmeno', nativeSentence: 'she did not even try to explain', foreignSentence: 'lei non ha nemmeno provato a spiegare'},
    {native: 'came', foreign: 'venuto', nativeSentence: 'he came by bus', foreignSentence: 'è venuto in autobus'},
    {native: 'back', foreign: 'indietro', nativeSentence: 'look forward, not back', foreignSentence: 'guarda avanti, non indietro'},
    {native: 'same', foreign: 'stessa', nativeSentence: 'we were in the same class', foreignSentence: 'eravamo nella stessa classe'},
    {native: 'care', foreign: 'importa', nativeSentence: 'I don’t care what they say', foreignSentence: 'non m’importa di ciò che dicono'},
    {native: 'no', foreign: 'nessun', nativeSentence: 'sorry, no seats available', foreignSentence: 'spiacenti, nessun posto disponibile'},
    {native: 'point', foreign: 'punto', nativeSentence: 'the water reached the boiling point', foreignSentence: 'l’acqua ha raggiunto il punto d’ebollizione'},
    {native: 'instead', foreign: 'invece', nativeSentence : 'could I have tea instead of coffee?', foreignSentence: 'potrei avere del tè invece del caffè?'},
    {native: 'lost', foreign: 'perso', nativeSentence: 'I have lost my keys', foreignSentence: 'ho perso le mie chiavi'},
    {native: 'possible', foreign: 'possibile', nativeSentence: 'reply as soon as possible', foreignSentence: 'rispondi il prima possibile'},
    {native: 'killed', foreign: 'ucciso', nativeSentence: 'a man was killed by a gunshot', foreignSentence: 'un uomo è stato ucciso da una fucilata'},
    {native: 'strong', foreign: 'forte', nativeSentence: 'he is a strong man', foreignSentence: 'è un uomo forte'},
    {native: 'tought', foreign: 'pensato', nativeSentence: 'I thought of a solution for the problem', foreignSentence: 'ho pensato ad una soluzione al problema'},
    {native: 'should', foreign: 'dovrebbe', nativeSentence: 'every kid should play a sport', foreignSentence: 'ogni bambino dovrebbe praticare uno sport'},
    {native: 'think', foreign: 'pensa', nativeSentence: 'think before you speak', foreignSentence: 'pensa prima di parlare'},
    {native: 'little', foreign: 'poco', nativeSentence: 'little by little', foreignSentence: 'a poco a poco'},
    {native: 'speak', foreign: 'parla', nativeSentence: 'speak up!', foreignSentence: 'parla più forte'},
    {native: 'will do', foreign: 'farò', nativeSentence: 'I will do my best', foreignSentence: 'farò del mio meglio'},
    {native: 'seeking', foreign: 'cercando', nativeSentence: 'the detective is seeking clues to solve the crime', foreignSentence: 'l’investigatore sta cercando indizi per risolvere il crimine'},
    {native: 'the', foreign: 'l’', nativeSentence: 'the bird flies high in the sky', foreignSentence: 'l’uccello vola alto nel cielo'},
    {native: 'truth', foreign: 'verità', nativeSentence: 'truth makes men free', foreignSentence: 'la verità rende gli uomini liberi'},
    {native: 'went', foreign: 'andato', nativeSentence: 'I went to the zoo yesterday', foreignSentence: 'sono andato allo zoo ieri'},
    {native: 'that', foreign: 'quell’', nativeSentence: 'how old is that tree?', foreignSentence: 'quanto è vecchio quell’albero?'},
    {native: 'king', foreign: 're', nativeSentence: 'to live like a king', foreignSentence: 'vivere come un re'},
    {native: 'do', foreign: 'fanno', nativeSentence: 'mothers do anything for their children', foreignSentence: 'le madri fanno tutto per i propri figli'},
    {native: 'could', foreign: 'potrei', nativeSentence: 'could I have some more wine?', foreignSentence: 'potrei avere dell’altro vino?'},
    {native: 'important', foreign: 'importante', nativeSentence: 'a good education is important for our kids', foreignSentence: 'una buona istruzione è importante per I nostri figli'},
    {native: 'this', foreign: 'quest’', nativeSentence: 'this water is too cold', foreignSentence: 'quest’acqua è troppo fredda'},
    {native: 'love', foreign: 'amo', nativeSentence: 'I love my husband', foreignSentence: 'amo mio marito'},
    {native: 'asked', foreign: 'chiesto', nativeSentence: 'I asked her to leave', foreignSentence: 'le ho chiesto di andarsene'},
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
'i give John the apple'
'We want to give him the apple'
'He gives it to John'
'She gives it to him'

###
    