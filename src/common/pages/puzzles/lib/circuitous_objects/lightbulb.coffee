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
        
    initCurrent: ->
        @currentImage = $(document.createElement('IMG'))
        @currentImage.addClass('current_image')
        @currentImage.attr(src: @image().replace('.png', '_current.png'))
        @currentImage.css(bottom: 0)
        @el.append(@currentImage)
        
    setCurrent: (@current) ->
        if @current
            left = (@el.width()/2) - (@currentImage.width()/2)
            @currentImage.css(left: left) unless parseInt(@currentImage.css('left')) == left
            @currentImage.css(opacity: Math.abs(@current) / 6.0)
        else
            @currentImage.css(opacity: 0)
        
