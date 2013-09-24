lightbulb = exports ? provide('./lightbulb', {})
circuitousObject = require('./object')
Tag = require('./tag').Tag

class lightbulb.Lightbulb extends circuitousObject.Object
    resistance: 5
    
    dragBuffer:
        left: 27
        right: 21

    centerOffset: 
        x: -17
        y: 30
        
    nodes: [
        {x: -15, y: 34}
        {x: 17, y: 34}
    ]
        
    constructor: ({@recordChange}) ->
        
    initCurrent: ->
        @currentImage = $(document.createElement('div'))
        @currentImage.addClass('current_image')
        @currentImage.css
            width: 150
            height: 150
            backgroundImage: "url('#{@image().replace('.png', '_current_spritesheet.png')}')"
            backgroundPosition: '0 0'
            bottom: 0
        
        @el.append(@currentImage)
        @setCurrent(0)
                
    setCurrent: (@current, permanent=false) ->
        super(@current)
        return unless @currentImage
        @current or= 0
        left = (@el.width()/2) - (@currentImage.width()/2)
        @currentImage.css(left: left) unless parseInt(@currentImage.css('left')) == left
        currentStep = 0.45
        spriteIndex = Math.floor(Math.abs(@current) / currentStep)
        spriteIndex = 9 if spriteIndex > 9
        if @spriteIndex != spriteIndex
            @spriteIndex = spriteIndex if (@spriteIndex is undefined) or permanent
            @spriteIndex += (if spriteIndex > @spriteIndex then 1 else -1) unless spriteIndex == @spriteIndex
            @currentImage.css
                backgroundPosition: "-#{@spriteIndex * @currentImage.width()}px 0"
                opacity: 1.0 - (0.6 / (@spriteIndex or 1))
        
    getInfo: ->
        