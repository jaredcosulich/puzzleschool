game = exports ? provide('./game', {})
Properties = require('./properties').Properties

class game.Game
    $: (selector) -> $(selector, @el)

    constructor: ({@el}) ->
        @initBoard()
        @initProperties()        

    initBoard: ->
        @board = @$('.board')
        dimensions = @board.offset()
        @paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)
           
    initProperties: ->
        @propertyUI = new Properties
            el: @$('.properties')
            
    addObject: (data) ->
        data.paper = @paper
        data.id = @nextId()
        data.propertyUI = @propertyUI
        data.setProperty = (property, value) =>
            @$(".properties .#{property}").html("#{value}")
        new neurobehav[data.type](data)
            
    nextId: ->
        @currentId = (@currentId or 0) + 1

