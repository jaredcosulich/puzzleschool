game = exports ? provide('./game', {})

class game.Game
    $: (selector) -> $(selector, @el)

    constructor: ({@el}) ->
        @initBoard()

        #basic instructions
        stimulus = @addObject
            type: 'Stimulus'
            position:
                top: 100
                left: 100
            voltage: 1.5
        
        neuron1 = @addObject
            type: 'Neuron'
            position:
                top: 100
                left: 300
            threshold: 1
            spike: 0.5
                
        stimulus.connectTo(neuron1)
        
        neuron2 = @addObject
            type: 'Neuron'
            position:
                top: 300
                left: 200
            threshold: 1
            spike: 0.5
                
        oscilloscope = @addObject
            type: 'Oscilloscope'
            position:
                top: 80
                left: 340
            container: @$('.oscilloscope')
            
        oscilloscope.attachTo(neuron1)
        

    initBoard: ->
        @board = @$('.board')
        dimensions = @board.offset()
        @paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)
            
    addObject: (data) ->
        data.paper = @paper
        data.id = @nextId()
        data.propertiesArea = @$('.properties')
        data.setProperty = (property, value) =>
            @$(".properties .#{property}").html("#{value}")
        new neurobehav[data.type](data)
            
    nextId: ->
        @currentId = (@currentId or 0) + 1

