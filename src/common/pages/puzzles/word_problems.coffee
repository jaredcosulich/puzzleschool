soma = require('soma')
wings = require('wings')

soma.chunks
    WordProblems:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/word_problems.html"
            
            @loadScript '/build/common/pages/puzzles/lib/common_objects/transformer.js'
            @loadScript '/build/common/pages/puzzles/lib/common_objects/client.js'

            @loadScript '/build/common/pages/puzzles/lib/word_problem_objects/component.js'
            @loadScript '/build/common/pages/puzzles/lib/word_problem_objects/operator.js'
            @loadScript '/build/common/pages/puzzles/lib/word_problem_objects/number.js'
            @loadScript '/build/common/pages/puzzles/lib/word_problem_objects/interaction.js'
            @loadScript '/build/common/pages/puzzles/lib/word_problem_objects/index.js'
            
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
            wordProblems = require('./lib/word_problems')
            @viewHelper = new wordProblems.ViewHelper(el: @el, level: @level)

                
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
    numbers: [
        {label: 'Balloons'}
        {label: 'Green Balloons', colorIndex: 3}
    ]
]
    