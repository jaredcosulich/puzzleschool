plane = exports ? provide('./plane', {})
xyflyerObject = require('./object')
Animation = require('./animation').Animation

class plane.Plane extends xyflyerObject.Object
    increment: 5
    incrementTime: 5
    
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
        setTimeout((=> @track(x: x, y: y, width: @width, height: @height)), 10)
        next() if next
    
    animate: (toX, toY, time, next) ->
        if not time
            @move(toX, toY, next)
            return

        startX = @currentXPos
        startY = @currentYPos            
        @animation.start time, (portion) =>
            if portion >= 1
                @move(toX, toY, next)
                return true
            
            portionX = (toX - startX) * portion
            portionY = (toY - startY) * portion
            @move(startX + portionX, startY + portionY)
            return false
    
    fall: ->
        @falling = true
        x = @xPos + @board.xAxis + @width + (@board.islandCoordinates.x * @board.xUnit)
        y = 1000
        @animate(x, y, 2000, => @reset()) 
    
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
            return
            
        if @xPos % @increment == 0   
            if @lastFormula
                dX = @increment
                dY = @yPos - @path[@xPos - @increment].y
                time = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2)) * @incrementTime

            @lastFormula = formula            
            @animate(@xPos + @board.xAxis, @board.yAxis - @yPos, time, => @launch())
        else
            @launch()
            
    reset: ->
        @falling = false
        @cancelFlight = true
        @path = null
        @xPos = Math.round(@board.islandCoordinates.x * @board.xUnit) - 1
        @lastFormula = null
        @move(@board.xAxis + (@board.islandCoordinates.x * @board.xUnit), @board.yAxis - (@board.islandCoordinates.y * @board.yUnit))

        