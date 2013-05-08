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
                <h3>#{value}</h3>
            """
            @$('.numbers').append(number)
            @setNumber(number, value)
           
        createRange: (container, magnitude, value) ->
            range = $(document.createElement('DIV'))
            range.addClass('range')
            for i in [1..10]
                do (i) =>
                    index = $(document.createElement('DIV'))
                    index.addClass('index')
                    if i > value
                        index.addClass('icon-circle-blank')
                    else
                        index.addClass('icon-circle')
                    label = $(document.createElement('DIV'))
                    label.addClass('label')
                    label.html("#{i * Math.pow(10, magnitude)}")
                    index.append(label)
                    range.append(index)
                    index.bind 'click', =>
                        alert(i)
            container.append(range)
            
        setNumber: (container, value) ->             
            value = parseInt(value)
            for digit, magnitude in value.toString().match(/\d/g)
                @createRange(container, magnitude, digit)

                
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
    