ring = exports ? provide('./ring', {})
xyflyerObject = require('./object')

class ring.Ring extends xyflyerObject.Object
    width: 8
    height: 32
    
    constructor: ({board, @x, @y}) ->
        @highlightRadius = 0
        @setBoard(board)        
        @animation = new Animation(true)
        
    setBoard: (@board) ->
        @screenX = @board.screenX(@x)
        @screenY = @board.screenY(@y)
        @scale = @board.scale
        @initCanvas()
        @label = @board.showXY(@screenX, @screenY, false, true)
        
    initCanvas: ->
        @board.addToCanvas(
            {draw: (ctxFunction) => @drawHalfRing(ctxFunction, 1) unless @removed}
            3
        )
    
        @board.addToCanvas(
            {draw: (ctxFunction) => @drawHalfRing(ctxFunction, -1) unless @removed}
            1
        )
        @board.addRing(@)
                
    drawHalfRing: (ctx, xDirection) ->
        for h in [0..@highlightRadius] by Math.floor(@highlightRadius/4) or 1
            ctx.strokeStyle = "rgba(255, 255, 255, #{if @highlightRadius then 1-Math.abs(h/@highlightRadius) else 1})"
            ctx.lineWidth = h || 1
            ctx.beginPath()
            
            xRadius = (@width/2) * @scale
            yRadius = (@height/2) * @scale
            
            ctx.moveTo(@screenX, @screenY - yRadius)
            ctx.bezierCurveTo(
                @screenX + (xRadius * xDirection), @screenY - yRadius, 
                @screenX + (xRadius * xDirection), @screenY + yRadius, 
                @screenX, @screenY + yRadius
            )

            ctx.stroke()
            
    glow: ->
        @animating = true
        radius = 16
        time = 500        
        @animation.start time, (deltaTime, progress, totalTime) =>
           easedProgress = Math.pow(progress, 1/5)
           @highlightRadius = radius * easedProgress
           if progress == 1
               @animation.start time, (deltaTime, progress, totalTime) =>
                   @highlightRadius = radius * (1-progress)
                   if progress == 1
                       @highlightRadius = 0
                       @animating = false      
                
    inPath: (x, formula) ->
        return false unless Math.round(100 * formula(@x)) / 100 == Math.round(100 * @y) / 100
        return true if x >= @x - (1/@board.xUnit)

    highlight: ->
        if not @passedThrough and not @highlighting
            @highlighting = true
            @passedThrough = true
            @glow()

    highlightIfPassingThrough: ({x, y, width, height}) ->
        @highlight if @touches(x,y,width,height)
            
    touches: (x,y,width,height) ->
        @screenX > x - (width/2) and
        @screenX < x + (width/2) and
        @screenY > y - (height/2) and
        @screenY < y + (height/2)        
    
    reset: ->
        @passedThrough = false
        @highlighting = false
        
    remove: ->
        @label.remove()
        @removed = true