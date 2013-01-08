game = exports ? provide('./game', {})
ObjectEditor = require('./object_editor').ObjectEditor

class game.Game
    $: (selector) -> $(selector, @el)

    constructor: ({@el, @objectEditor, @showExplicitContent}) ->
        @initBoard()

    initBoard: ->
        @board = @$('.board')
        dimensions = @board.offset()
        @paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)
           
    addObject: (data) ->
        data.paper = @paper
        data.id = @nextId()
        data.objectEditor = @objectEditor
        data.setProperty = (property, value) => @$(".properties .#{property}").html("#{value}")
        data.showExplicitContent = (content) => @showExplicitContent(content)    
                
        new neurobehav[data.type](data)
            
    nextId: ->
        @currentId = (@currentId or 0) + 1

