wordProblems = exports ? provide('./lib/word_problems', {})

for name, fn of require('./word_problem_objects/index')
    wordProblems[name] = fn

class wordProblems.ViewHelper    
    constructor: ({@el, @level}) ->
        @initLevel(@level)
        
    $: (selector) -> @el.find(selector)    
    
    initLevel: ->
        @$('.problem').html(@highlightProblem(@level.problem))
        @initNumbers()        
        
    highlightProblem: (problem) ->
        problem.replace(/(\d+)/g, '<span class=\'number\'>$1</span>')
        
    initNumbers: ->
        for number, index in @$('.problem .number')
            number = $(number)
            id = new Date().getTime()
            settings = @level.numbers?[index]
            colorIndex = settings?.colorIndex or index + 1
            number.addClass("color_#{colorIndex}")
            number.addClass("number_#{id}")
            new wordProblems.Number
                container: @$('.numbers')
                problemNumber: @$(".problem .number_#{id}")
                id: id
                value: number.html()
                colorIndex: colorIndex
                label: settings?.label
        
   