plane = exports ? provide('./plane', {})
xyflyerObject = require('./object')
Animation = require('./animation').Animation

class plane.Plane extends xyflyerObject.Object
    increment: 5
    incrementTime: 6
    
    constructor: ({@board, @track, @objects}) ->
        @animation = new Animation(true)
        @addToBoard()
        @reset()
    
    setBoard: (@board) -> @addToBoard()
        
    addToBoard: -> @board.addToCanvas(@, 2)
        
    draw: (ctx, t) ->
        return if not @image
        @latestTime = t
        @startTime = @latestTime if not @startTime
        
        moveTo = (position) =>
            @xPos = position.x
            @yPos = position.y
            @move(@xPos + @board.xAxis, @board.yAxis - @yPos)
            position.ring.highlight() if position.ring
                    
        if @path 
            position = @path[Math.round((@latestTime-@startTime)/@timeFactor*10)]
            if !position or @path.distance == 0   
                keys = Object.keys(@path)
                lastPosition = @path[keys[keys.length - 2]]
                if @path.distance == 0 or @xPos == lastPosition.x and @yPos == lastPosition.y
                    @fall() unless @board.paperY(@currentYPos) > @board.grid.yMax
                else
                    moveTo(lastPosition)
            else
                moveTo(position)
        
        ctx.drawImage(
            @image[0], 
            @currentXPos - (@width/2), 
            @currentYPos - (@height/2), 
            @width,
            @height
        )
        
    size: ->
        @scale = @board.scale / 1.5
        @width = @image.width() * @scale
        @height = @image.height() * @scale
        @timeFactor = 1.65/@scale
    
    move: (x, y, next) ->
        return if not x or not y
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
        return if @falling
        @falling = true
        @path = null
        x = @xPos + @board.xAxis + 20
        y = @board.height * 1.2
        @animate(x, y, 2000, => @board.resetLevel()) 
    
    launch: (force) ->
        return if @falling or @cancelFlight and not force
        @board.resetLevel()
        @cancelFlight = false
        @startTime = null
        @latestTime = null
        if not @path or not Object.keys(@path).length
            @path = @board.calculatedPath or @board.calculatePath() 
            if not @path?.distance
                @fall
                return        
                        
    reset: ->
        if not (@image = @objects.find('.plane img')).height()
            setTimeout((=>
                @reset()
            ), 50)
            return 
        
        @falling = false
        @cancelFlight = true
        @startTime = null
        @latestTime = null
        @endingX = null
        @endingY = null
        @path = null
        @size()
        @xPos = Math.round(@board.islandCoordinates.x * @board.xUnit)
        @move(@board.xAxis + (@board.islandCoordinates.x * @board.xUnit), @board.yAxis - (@board.islandCoordinates.y * @board.yUnit))
        