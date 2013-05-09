wordProblems = exports ? provide('./lib/word_problems', {})

for name, fn of require('./word_problem_objects/index')
    wordProblems[name] = fn

class wordProblems.ViewHelper    
    constructor: ({@el, @level}) ->
        @operators = []
        @numbers = []
        @interactions = []
        @addInteraction()
        @initLevel(@level)
        @initOperators()
        
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
            @numbers.push(new wordProblems.Number
                id: id
                value: number.html()
                colorIndex: colorIndex
                label: settings?.label
                problemNumber: @$(".problem .number_#{id}")
                container: @$('.numbers')
                drag: (component, x, y, final) => @dragComponent(component, x, y, final)
            )
        
    dragComponent: (number, x, y, final) ->
        @el.addClass('dragging') unless @el.hasClass('dragging')
        @el.removeClass('dragging') if final
        
        for interaction in @interactions when interaction.over(x, y, true)
            interaction.accept(number) if final
            
    addInteraction: ->
        @interactions.push(new wordProblems.Interaction
            container: @$('.interactions')
        )
        
    initOperators: ->
        for operator in ['+', '-', '/', '*', '?']
            @operators.push(new wordProblems.Operator
                value: operator
                container: @$('.numbers')
                drag: (component, x, y, final) => @dragComponent(component, x, y, final)
            )