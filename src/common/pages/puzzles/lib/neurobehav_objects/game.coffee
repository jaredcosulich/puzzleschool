game = exports ? provide('./game', {})
Properties = require('./properties').Properties

class game.Game
    $: (selector) -> $(selector, @el)

    constructor: ({@el, @propertyEditor}) ->
        @initBoard()

    initBoard: ->
        @board = @$('.board')
        dimensions = @board.offset()
        @paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)
           
    addObject: (data) ->
        data.paper = @paper
        data.id = @nextId()
        data.propertyEditor = @propertyEditor
        data.setProperty = (property, value) =>
            @$(".properties .#{property}").html("#{value}")
        new neurobehav[data.type](data)
            
    nextId: ->
        @currentId = (@currentId or 0) + 1

