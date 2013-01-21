game = exports ? provide('./game', {})

class game.Game
    $: (selector) -> $(selector, @el)

    constructor: ({@el, @showExplicitContent}) ->
        @initBoard()

    initBoard: ->
        @board = @$('.board')
        dimensions = @board.offset()
        @paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)
           
    createGoal: ({radius, interaction, test}) ->
        new neurobehav.Goal
            paper: @paper
            radius: radius
            interaction: interaction
            test: test
           
    addObject: (data) ->
        data.paper = @paper
        data.id = @nextId()
        data.setProperty = (property, value) => @$(".properties .#{property}").html("#{value}")
        data.showExplicitContent = (content) => @showExplicitContent(content)    
                
        new neurobehav[data.type](data)
            
    nextId: ->
        @currentId = (@currentId or 0) + 1

