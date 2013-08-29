lightbulb = exports ? provide('./lightbulb', {})
circuitousObject = require('./object')

class lightbulb.Lightbulb extends circuitousObject.Object
    resistance: 5
    
    dragBuffer:
        left: 5
        right: 5
        bottom: 10
        
    centerOffset: 
        x: 0
        y: 32
        
    nodes: [
        {x: 0, y: 32}
    ]
        
    constructor: ({}) ->
        @init()

    init: ->
        
    setCurrent: (@current) ->
        if not @currentImage
            @currentImage = $(document.createElement('IMG'))
            @currentImage.addClass('current_image')
            @currentImage.bind 'load', =>
                @currentImage.css
                    bottom: 0
                    left: (@el.width()/2) - (@currentImage.width()/2)
            @currentImage.attr(src: @image().replace('.png', '_current.png'))
            @el.append(@currentImage)
                
        if @current
            @currentImage.css(opacity: @current / 6.0)
        else
            @currentImage.css(opacity: 0)
        
