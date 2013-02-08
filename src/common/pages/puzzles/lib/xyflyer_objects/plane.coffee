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
        @animation.start time, (deltaTime, portion) =>
            portionX = (toX - startX) * portion
            portionY = (toY - startY) * portion
            @move(startX + portionX, startY + portionY, (if portion == 1 then next else null))
    
    fall: ->
        @falling = true
        x = @xPos + @board.xAxis + 20
        y = 1000
        @animate(x, y, 3000, => @reset()) 
    
    launch: (force) ->
        return if @falling or @cancelFlight and not force
        @cancelFlight = false
        timeFactor = 3/@scale
        @path = @board.calculatePath() if not @path or not Object.keys(@path).length
        duration = @path.distance * timeFactor
        distance = Object.keys(@path).length
        unit = distance / duration
        @animation.start duration, (deltaTime, progress, totalTime) =>
            position = @path[Math.round(totalTime / timeFactor)]
            if !position   
                @animation.stop()
                @fall() unless @board.paperY(@currentYPos) > @board.grid.yMax
            else
                @xPos = position.x
                @yPos = position.y
                @move(@xPos + @board.xAxis, @board.yAxis - @yPos)
                        
    reset: ->
        @falling = false
        @cancelFlight = true
        @path = null
        @xPos = Math.round(@board.islandCoordinates.x * @board.xUnit)
        @move(@board.xAxis + (@board.islandCoordinates.x * @board.xUnit), @board.yAxis - (@board.islandCoordinates.y * @board.yUnit))

        