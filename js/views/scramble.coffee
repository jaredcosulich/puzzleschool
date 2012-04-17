(($) ->
    views = require('views')
                   
    class views.Scramble extends views.Page
        prepare: ({@level}) ->
            @template = @_requireTemplate('templates/scramble.html')
            @setLevels()

        renderView: () ->
            @el.html(@template.render())   
            @bindWindow()
            @bindKeyPress()
            @setOptions()
            @newScramble()

        setLevels: () ->
            @level = 0

            users = $.cookie('users') or {}
            names = (user.toLowerCase() for user, level of users)
            @user = prompt("What is your name?#{if names.length then "\n\nExisting: #{names.join(', ')}" else ''}","")
            @user = @user.toLowerCase if @user
            if @user in names
                @level = users[@user].level
                @nativeLevel = users[@user].nativeLevel
                @foreignLevel = users[@user].foreignLevel
                @nativeMediumLevel = users[@user].nativeMediumLevel
                @foreignMediumLevel = users[@user].foreignMediumLevel
                @nativeHardLevel = users[@user].nativeHardLevel
                @foreignHardLevel = users[@user].foreignHardLevel
                
            else if @user and @user.length > 0
                users[@user] = level: @level
                $.cookie('users', users)
                
            for dataType in ['native', 'foreign']
                @["#{dataType}Level"] = 1 unless @["#{dataType}Level"]
                levels = @["#{dataType}Levels"] = {}
                levels.maxLevel = 0 

                copiedData = localData.slice(0)
                for scrambleInfo in copiedData
                    copiedData.push(
                        native: scrambleInfo.nativeSentence
                        foreign: scrambleInfo.foreignSentence
                        nativeSentence: scrambleInfo.nativeSentence
                        foreignSentence: scrambleInfo.foreignSentence
                    ) if scrambleInfo.nativeSentence and scrambleInfo.native != scrambleInfo.nativeSentence
                    
                sortedData = copiedData.sort((a,b) -> b[dataType].length - a[dataType].length)
            
                while sortedData.length
                    if !levels["level#{levels.maxLevel}"] or levels["level#{levels.maxLevel}"].length >= 6
                        levels.maxLevel += 1
                        levels["level#{levels.maxLevel}"] = []
                
                    level = levels["level#{levels.maxLevel}"]
                    scrambleInfo = sortedData.pop()
                    level.push(scrambleInfo) if sortedData.length
                    
                    for effort in ['Medium', 'Hard']
                        if not (effortLevels = @["#{dataType}#{effort}Levels"])
                            @["#{dataType}#{effort}Level"] = 1 
                            effortLevels = @["#{dataType}#{effort}Levels"] = {}
                            effortLevels.maxLevel = 0

                        if !effortLevels["level#{effortLevels.maxLevel}"] or effortLevels["level#{effortLevels.maxLevel}"].length >= 6
                            effortLevels.maxLevel += 1
                            effortLevels["level#{effortLevels.maxLevel}"] = []

                        effortLevels["level#{effortLevels.maxLevel}"].push(scrambleInfo)
                     
                        
                            
        takeABreak: () ->
            @break = (@break or 0) + 3
            @breakAdjustment = (@breakAdjustment or 0) + 9
            @setOptions
            
        setOptions: () -> 
            level = @level
            
            grouping = Math.floor(level / 18)
            mod = level % 18
            if grouping > 15 or mod >= (15 - grouping)
                if grouping > 12 && mod - 12 >= (15 - grouping)
                    @activeLevel = 'foreignHard'
                else if grouping > 9 && mod - 9 >= (15 - grouping)
                    @activeLevel = 'nativeHard'
                else if grouping > 6 && mod - 6 >= (15 - grouping)
                    @activeLevel = 'foreignMedium'
                else if grouping > 3 && mod - 3 >= (15 - grouping)
                    @activeLevel = 'nativeMedium'
                else
                    @activeLevel = 'foreign'
            else
                @activeLevel = 'native'
                
            @activeType = @activeLevel.replace(/Medium/, '').replace(/Hard/, '')

            @displayLevel = if @activeType.match(/native/) then 'foreign' else 'native'
            
            activeLevel = @["#{@activeLevel}Level"]
            activeLevel -= @breakAdjustment if @break? && @break > 0
            activeLevel = 1 if activeLevel <= 0
                
            console.log(@level, @activeLevel, activeLevel)
                
            @options = @["#{@activeLevel}Levels"]["level#{activeLevel}"]
            
            $('.guesses').removeClass('hidden')
            $('.scrambled').removeClass('hidden')       
            if @activeLevel.match(/Medium/)? or @activeLevel.match(/Hard/)?
                $('.guesses').addClass('hidden')
                $('.guesses .hidden_message').show()
                
            if @activeLevel.match(/Hard/)?
                $('.scrambled').addClass('hidden')       
                $('.scrambled .hidden_message').show()


        randomIndex: (array) -> Math.floor(Math.random() * array.length)
            
        random: (array) ->
            return null unless array 
            return null unless array.length
            return array[0] if array.length == 1
            return array[@randomIndex(array)]
            
        newScramble: () ->
            @lastScrambles or= []
            @lettersAdded = []
            @checkLevel()
            
            for i in [0...4]
                break if @scrambleInfo && @scrambleInfo.native not in @lastScrambles[-4..-1].map((s) -> s.native)
                @scrambleInfo = @random(@options)
                  
            @lastScrambles.push(@scrambleInfo)
            displayWords = @$('.display_words')
            if @scrambleInfo["#{@displayLevel}Sentence"]? && @scrambleInfo["#{@displayLevel}Sentence"].length 
                sentence = @scrambleInfo["#{@displayLevel}Sentence"]
            else
                sentence = @scrambleInfo[@displayLevel]
            sentence = " #{sentence} "
            highlighted = @scrambleInfo[@displayLevel]
            sentence = sentence.replace(" #{highlighted} ", " <span class='highlighted'>#{highlighted}</span> ")           
            sentence = sentence.replace(" #{highlighted}?", " <span class='highlighted'>#{highlighted}</span>?")           
            displayWords.html(sentence)
            
            @createGuesses()
            @createScramble()
            @startHelpTimer()
            
        startHelpTimer: () ->
            return
            clearTimeout(@helpTimeout)
            @helpTimeout = setTimeout((() =>  
                return unless (firstMissingGuess = $('.guesses .guess')[0])?                
                letterPosition = firstMissingGuess.className.indexOf('letter_') + 'letter_'.length
                letter = firstMissingGuess.className[letterPosition..letterPosition + 1]
                $(firstMissingGuess).trigger('click')
                $(@$(".scrambled .#{@containerClassName(firstMissingGuess)} .letter_#{letter}")[0]).trigger('click')
                if @checkCorrectAnswer() then @next() else @startHelpTimer()                    
            ), 15000)
            
        checkLevel: () ->
            @answerTimes or= []

            if @break? && @break > 0
                @break--
                @breakAdjustment--
                if @break == 0
                    @breakAdjustment = 0 
                    @answerTimes.push(new Date())
                @setOptions()
                return
                
            @level += 1

            @answerTimes.push(new Date())    

            return if @answerTimes.length == 1

            lastAnswerDuration = @answerTimes[@answerTimes.length - 1] - @answerTimes[@answerTimes.length - 2]
            if lastAnswerDuration < 3000
                @["#{@activeLevel}Level"] += 4
            else if lastAnswerDuration < 6000
                @["#{@activeLevel}Level"] += 3
            else if lastAnswerDuration < 9000
                @["#{@activeLevel}Level"] += 2
            else if lastAnswerDuration < 20000
                @["#{@activeLevel}Level"] += 1                
            else if lastAnswerDuration > 30000
                @takeABreak()
            
            @setOptions()
            if @user and @user.length
                users = $.cookie('users')
                users[@user].level = @level
                users[@user]["#{@activeLevel}Level"] = @["#{@activeLevel}Level"]
                $.cookie('users', users)
                
                
        createGuesses: () ->
            guesses = @$('.guesses')
            @clearContainer(guesses)
            for group, index in @separateIntoWordGroups(@scrambleInfo[@activeType])
                container = $(document.createElement("DIV"))
                container.addClass('container')
                container.addClass("color#{index + 1}")
                guesses.append(container)

                for letter in group 
                    container.append(if letter.match(/\w|[^\x00-\x80]+/)? then @createGuess(letter) else @createSpace(letter)) 

                container.width(container.width())
                container.css(float: 'none', height: container.height())

            
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
            
        separateIntoWordGroups: (letters) ->
            groups = [[]]
            for letter in letters
                group = groups[groups.length - 1]
                if group.length == 18
                    groups.push(nextGroup = [])
                    nextGroup.push(group.pop()) while !group[group.length - 1].match(/\s/)?
                    group = nextGroup.reverse()
                            
                group.push(letter)                
            return groups
            
        shuffle: (word) ->
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
            shuffled = @shuffle(shuffled) if shuffled == word
            return shuffled
            
        createLetter: (letter) ->
            letterContainer = $(document.createElement("DIV"))
            letterContainer.addClass('letter')
            letterContainer.addClass("letter_#{letter}")
            letterContainer.html(letter)
            @bindLetter(letterContainer)
            return letterContainer
            
        createScramble: () ->
            scrambled = @$('.scrambled')
            @clearContainer(scrambled)

            for group, index in @separateIntoWordGroups(@scrambleInfo[@activeType])
                container = $(document.createElement("DIV"))
                container.addClass('container')
                container.addClass("color#{index + 1}")
                scrambled.append(container)

                for letter in @shuffle(@modifyScramble(group.join(''))) 
                    container.append(@createLetter(letter)) if letter.match(/\w|[^\x00-\x80]+/)

                container.width(container.width())
                container.css(float: 'none', height: container.height())


        modifyScramble: (word) ->
            return word unless word.length < 6
            commonLetters = (letter for letter in 'etaoinshrdlumkpcd')
            add = (6 - word.length)
            add = 2 if add > 2
            word += (commonLetters[Math.floor(Math.random() * commonLetters.length)]) for i in [0...add]
            return word
            
        bindKeyPress: () ->
            setInterval((() => $('#clickarea')[0].focus()), 100)
            $('#clickarea').bind 'keydown', (e) =>
                if e.keyCode == 8
                    lastLetterAdded = @lettersAdded.pop()
                    guessedLetters = $(".guesses .letter_#{lastLetterAdded}")
                    $(guessedLetters[guessedLetters.length - 1]).trigger('click') if guessedLetters.length
                    return
                
            $('#clickarea').bind 'keypress', (e) =>
                openGuess = @$('.guesses .selected')[0] or @$(".guesses .guess")[0]
                return unless openGuess?
                
                char = String.fromCharCode(e.keyCode)
                try
                    letter = $(".scrambled .#{@containerClassName(openGuess)} .letter_#{char}")[0]
                    if !letter and @activeLevel.match(/Hard/)?
                        if char.match(/\w|[^\x00-\x80]+/)
                            letter = @createLetter(char) 
                            $(".scrambled .#{@containerClassName(openGuess)}").append(letter)
                catch e
                    return
                    
                return unless letter?
                $(letter).trigger 'click'
                
        containerClassName: (square) ->
            $(square).closest('.container')[0].className.match(/color\d+/)[0]
            
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
        
        clientX: (e) => e.clientX or (if e.targetTouches[0] then e.targetTouches[0].pageX else null)
        clientY: (e) => e.clientY or (if e.targetTouches[0] then e.targetTouches[0].pageY else null)
        
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
                
                @startHelpTimer()
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
                @startHelpTimer()
                @dragPathX = []
                @dragPathY = []
                @dragAdjustmentX = @clientX(e) - letter.offset().left
                @dragAdjustmentY = @clientY(e) - letter.offset().top
                
            letter = $(letter)
            letter.attr(onclick: 'void(0)', ontouchstart: 'void(0)', ontouchend: 'void(0)', ontouchmove: 'void(0)')
            letter.bind 'click', click
            letter.bind 'touchend', click                
            letter.bind 'mousedown', startDrag   
            letter.bind 'touchstart', startDrag                
 
        bindWindow: () ->
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
                if not force and (@dragPathX.length <= 1 or @dragPathY.length <= 1)
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
                    
        checkCorrectAnswer: () ->
            @$('.guesses .letter, .guesses .space').map((html) -> $(html).html()).join('') == (@scrambleInfo[@activeType])
            
        next: () ->
            correct = $(document.createElement('DIV'))
            if @scrambleInfo["#{@activeType}Sentence"]? && @scrambleInfo["#{@activeType}Sentence"].length
                correctSentence = @scrambleInfo["#{@activeType}Sentence"] 
            else 
                correctSentence = @scrambleInfo[@activeType]
                
            correctSentence = " #{correctSentence} "
            highlighted = @scrambleInfo[@activeType]
            correctSentence = correctSentence.replace(" #{highlighted} ", " <span class='highlighted'>#{highlighted}</span> ")           
            correctSentence = correctSentence.replace(" #{highlighted}?", " <span class='highlighted'>#{highlighted}</span>?")                       
            correct.html(correctSentence)
            correct.addClass('correct')
            correct.css(opacity: 0)
            scrambled = @$('.scrambled')
            @clearContainer(scrambled)
            @$('.scrambled .hidden_message').hide()
            @$('.scrambled').css(width: null)
            scrambled.append(correct)
            correct.animate
                opacity: 1
                duration: 500
                complete: () =>
                    $.timeout 200 + (30 * correctSentence.length), () =>
                        @$('.foreign_words, .scrambled, .guesses').animate
                            opacity: 0
                            duration: 500
                            complete: () =>
                                @$('.scrambled, .guesses').css(width: null, height: null)
                                @newScramble()
                                @$('.foreign_words, .scrambled, .guesses').animate
                                    opacity: 1
                                    duration: 300
                        
        clearContainer: (container) -> container.find('.container, .correct, .guess, .letter, .space').remove()
            
    $.route.add
        'scramble': () ->
            $('#content').view
                name: 'Scramble'
                data: { level: 1 }
                
        'scramble/:level': (level) ->
            $('#content').view
                name: 'Scramble'
                data: { level: parseInt(level) }

)(ender)



localData = [
    {native: 'not', foreign: 'non', nativeSentence: 'that\'s not necessary', foreignSentence: 'non è necessario'},
    {native: 'of', foreign: 'di', nativeSentence: 'memories of a cat', foreignSentence: 'memorie di un gatto'},
    {native: 'what', foreign: 'che', nativeSentence: 'what luck', foreignSentence: 'che fortuna'},
    {native: 'is', foreign: 'è', nativeSentence: 'that bird is fat', foreignSentence: 'quell\'uccello è grasso'},
    {native: 'and', foreign: 'e', nativeSentence: 'big and tall', foreignSentence: 'grande e grosso'},
    {native: 'for', foreign: 'per', nativeSentence: 'the drinks are for the party', foreignSentence: 'le bevande sono per il partito'},
    {native: 'are', foreign: 'sono', nativeSentence: 'there are five quotes', foreignSentence: 'ci sono cinque citazioni'},
    {native: 'i have three blue shirts', foreign: 'ho tre maglie azzurre'},
    {native: 'i have twenty dollars', foreign: 'ho venti dollari'},
    {native: 'but', foreign: 'ma', nativeSentence: 'i was going to but i can not', foreignSentence: 'stavo andando ma non posso'},
    {native: 'he has a big house', foreign: 'ha una grande casa'},
    {native: 'with', foreign: 'con', nativeSentence: 'i\'m coming with you', foreignSentence: 'vengo con te'},
    {native: 'if', foreign: 'se', nativeSentence: 'what if he wins?', foreignSentence: 'cosa succede se vince?'},
    {native: 'there', foreign: 'ci', nativeSentence: 'there are three friends', foreignSentence: 'ci sono tre amici'},
    {native: 'this', foreign: 'questo', nativeSentence: 'this is great', foreignSentence: 'questo è fantastico'},
    {native: 'here', foreign: 'qui', nativeSentence: 'come here', foreignSentence: 'vieni qui'},
    {native: 'you have', foreign: 'hai', nativeSentence: 'you have ten minutes', foreignSentence: 'hai dieci minuti'},
    {native: 'six', foreign: 'sei', nativeSentence: 'there are six doors', foreignSentence: 'ci sono sei porte'},
    {native: 'well', foreign: 'bene', nativeSentence: 'are you well?', foreignSentence: 'stai bene?'},
    {native: 'yes', foreign: 'sì'},
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
    {native: 'thanks', foreign: 'grazie', nativeSentence: 'thanks for the help', foreignSentence: 'grazie per l\'aiuto'},
    {native: 'he', foreign: 'lui', nativeSentence: 'he is eighteen years old', foreignSentence: 'lui ha diciotto anni'},
    {native: 'i want a new car', foreign: 'voglio una macchina nuova'},
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