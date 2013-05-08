soma = require('soma')
wings = require('wings')

soma.chunks
    WordProblems:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/word_problems.html"
            
            @loadScript '/build/common/pages/puzzles/lib/word_problems.js'
            
            @loadStylesheet '/build/client/css/puzzles/word_problems.css'     
            
        build: ->
            @setTitle("Interactive Word Problems - The Puzzle School")
            
            @html = wings.renderTemplate(@template)
        
soma.views
    WordProblems:
        selector: '#content .word_problems'
        create: ->
            @level = LEVELS[0]
            @initLevel()
        
        initLevel: ->
            @$('.problem').html(@highlightProblem(@level.problem))
            @initNumbers()
            
        highlightProblem: (problem) ->
            problem.replace(/(\d+)/g, '<span class=\'number\'>$1</span>')
            
        initNumbers: ->
            for number, index in @$('.problem .number')
                number = $(number)
                number.addClass("color_#{index + 1}")
                @createNumber(number.html(), index + 1)
                
        createNumber: (value, index) ->
            number = $(document.createElement('DIV'))
            number.addClass('number')
            number.addClass("color_#{index}")
            number.html """
                <div class='settings'>
                    <i class='icon-cog'></i>
                </div>
                <h3 class='value'>#{value}</h3>
                <div class='ranges'></div>
            """
            @$('.numbers').append(number)
            @setNumber(number, value)
           
        createRange: (container, magnitude) ->
            range = $(document.createElement('DIV'))
            range.addClass('range')
            range.addClass("range_#{magnitude}")
            range.data('magnitude', magnitude)
            for i in [1..10]
                do (i) =>
                    index = $(document.createElement('DIV'))
                    index.addClass('index')
                    label = $(document.createElement('DIV'))
                    label.addClass('label')
                    label.html("#{i * Math.pow(10, magnitude)}")
                    index.append(label)
                    range.append(index)
                    index.bind 'click', => 
                        digits = @getDigits(@getNumber(container))
                        changingDigit = digits.length - magnitude - 1
                        digits[changingDigit] = if parseInt(digits[changingDigit]) == i then i - 1 else i
                        if digits[changingDigit] == 0 and parseInt(digits[changingDigit + 1]) == 0 
                            digits[changingDigit + 1] = 9
                        @setNumber(container, digits.join(''))
                        
            container.find('.ranges').prepend(range)
            return range
            
        getNumber: (container) -> container.data('value')    
        getDigits: (number) -> number.toString().match(/\d/g)
            
        setNumber: (container, value) ->             
            value = parseInt(value)
            digits = @getDigits(value)
            for range in container.find('.range')
                $(range).remove() if parseInt($(range).data('magnitude')) >= digits.length
            
            for digit, m in digits
                magnitude = digits.length - m - 1
                unless (range = container.find(".range_#{magnitude}")).length
                    range = @createRange(container, magnitude, digit)

                range.css(fontSize: 50 - (10 * m))

                for index, i in range.find('.index')
                    index = $(index)
                    if (i + 1) > parseInt(digit)
                        index.removeClass('icon-circle')
                        index.addClass('icon-circle-blank') unless index.hasClass('icon-circle-blank')
                    else
                        index.removeClass('icon-circle-blank')
                        index.addClass('icon-circle') unless index.hasClass('icon-circle')
            container.find('.value').html("#{value}")
            container.data('value', value)
                
soma.routes
    '/puzzles/word_problems/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.WordProblems
            classId: classId
            levelId: levelId

    '/puzzles/word_problems/:levelId': ({levelId}) -> 
        new soma.chunks.WordProblems
            levelId: levelId
    
    '/puzzles/word_problems': -> new soma.chunks.WordProblems

LEVELS = [
    id: 1367965328479
    difficulty: 1
    problem: 'Jane has 9 balloons. 6 are green and the rest are blue. How many balloons are blue?'
]
    