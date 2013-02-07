plane = exports ? provide('./plane', {})
xyflyerObject = require('./object')
Animation = require('./animation').Animation

class plane.Plane extends xyflyerObject.Object
    increment: 5
    incrementTime: 6
    
    constructor: ({@board, @track, @objects}) ->
        @scale = @board.scale / 2
        @initCanvas()
        @animation = new Animation()
        @reset()

    initCanvas: ->
        if not (@image = @objects.find('.plane img')).height()
            setTimeout((=>
                @initCanvas()
            ), 50)
            return 
        @width = @image.width() * @scale
        @height = @image.height() * @scale
        @canvas = @board.createCanvas()
        
    move: (x, y, next) ->
        if not @canvas
            setTimeout((=>
                @move(x, y, next)
            ), 50)
            return 

        @canvas.clearRect(@currentXPos - @width,@currentYPos - @height,@width*4,@height*4)
        @canvas.drawImage(
            @image[0], 
            x - (@width/2), 
            y - (@height/2), 
            @width,
            @height
        )
        @currentXPos = x
        @currentYPos = y
        setTimeout((=> @track(x: x, y: y, width: @width, height: @height)), 0)
        next() if next
    
    animate: (toX, toY, time, next) ->
        return if toX == @currentXPos and toY == @currentYPos
        if not time
            @move(toX, toY, next)
            return
        
        startX = @endingX or @currentXPos
        startY = @endingY or @currentYPos
        @endingX = toX
        @endingY = toY
        @animation.queueAnimation time, (portion) =>
            portionX = (toX - startX) * portion
            portionY = (toY - startY) * portion
            @move(startX + portionX, startY + portionY)
        
    
    fall: ->
        return
        @falling = true
        x = @xPos + @board.xAxis + 20
        y = 1000
        @animate(x, y, 4000, => @reset()) 
    
    launch: (force) ->
        return if @falling or @cancelFlight and not force
        @cancelFlight = false
        @path = @board.calculatePath(@increment) if not @path or not Object.keys(@path).length

        @xPos += 1
        @yPos = @path[@xPos]?.y
        
        formula = @path[@xPos]?.formula
        if @yPos == undefined or @xPos > ((@board.grid.xMax + @width) * @board.xUnit)
            # Plane Crashed Message
            @fall()
            @animation.start()
            return
            
        if @xPos % @increment == 0
            dX = @increment
            dY = @yPos - (@path[@xPos - @increment]?.y or (@board.yAxis - @currentYPos))
            time = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2)) * @incrementTime
            @animate(@xPos + @board.xAxis, @board.yAxis - @yPos, time)
            
        @launch()
            
    reset: ->
        @falling = false
        @cancelFlight = true
        @path = null
        @xPos = Math.round(@board.islandCoordinates.x * @board.xUnit) - 1
        @move(@board.xAxis + (@board.islandCoordinates.x * @board.xUnit), @board.yAxis - (@board.islandCoordinates.y * @board.yUnit))

        