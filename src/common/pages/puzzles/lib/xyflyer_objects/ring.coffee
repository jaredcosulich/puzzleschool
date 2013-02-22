ring = exports ? provide('./ring', {})
xyflyerObject = require('./object')
Animation = require('./animation').Animation


class ring.Ring extends xyflyerObject.Object
    fullDescription: 'm0.5,19.94043c0,-10.68549 0.34383,-19.44043 2.82518,-19.44043c2.48135,0 3.17027,8.65525 3.17027,19.34073c0,10.68549 -0.68892,19.34074 -3.17027,19.34074c-2.48135,0 -2.82518,-8.55555 -2.82518,-19.24104z'    
    frontDescription: 'm3,19.94043c-2.48135,0 -2.82518,-8.55555 -2.82518,-19.24104c0,-10.68549 0.34383,-19.44043 2.82518,-19.44043'    
    backDescription: 'm-3,-19c2.48135,0 3.17027,8.65525 3.17027,19.34073c0,10.68549 -0.68892,19.34074 -3.17027,19.34074'    
    width: 8
    height: 32
    
    constructor: ({@board, @x, @y}) ->
        @screenX = @board.screenX(@x)
        @screenY = @board.screenY(@y)
        @scale = 1

        @initCanvas()
        @draw()        
        @label = @board.showXY(@screenX, @screenY, false, true)
        @animation = new Animation()
        
    initCanvas: ->
        @frontCanvas = @board.createCanvas()
        @backCanvas = @board.createCanvas()
        
    clear: (canvas) ->
        canvas.clearRect(0, 0, @board.width, @board.height)
        
    draw: ->
        @clear(@frontCanvas)
        @clear(@backCanvas)
        @drawHalfRing(@frontCanvas, 1)
        @drawHalfRing(@backCanvas, -1)
        
    drawHalfRing: (canvas, xDirection, highlightRadius=0) ->
        for h in [(highlightRadius * -1)..highlightRadius]
            xRadius = (@width/2) + h
            yRadius = (@height/2) + h
            continue if xRadius < 2

            canvas.strokeStyle = "rgba(255, 255, 255, #{if highlightRadius then 1/(2*highlightRadius) else 1})"
            canvas.lineWidth = 1
            canvas.beginPath()
            for yDirection in [-1,1]
                for x in [0..xRadius + 0.1] by 0.1
                    y = Math.sqrt(yRadius * (yRadius - Math.pow(x,2)))
                    if x == 0
                        canvas.moveTo(@screenX + (x * xDirection), @screenY + (y * yDirection))
                    else if x >= xRadius
                        canvas.lineTo(@screenX + (x * xDirection), @screenY)
                    else
                        canvas.lineTo(@screenX + (x * xDirection), @screenY + (y * yDirection))            
            canvas.stroke()
            canvas.closePath()

    glow: ->
        @animating = true
        radius = 8
        time = 400
        canvii = []
        @animation.start time, (deltaTime, progress, totalTime) =>
            easedProgress = Math.pow(progress, 1/5)
            front = @board.createCanvas()
            back = @board.createCanvas()
            @drawHalfRing(front, 1, easedProgress * radius)
            @drawHalfRing(back, -1, easedProgress * radius)            
            canvii.push([front, back]) 
            @draw(radius * easedProgress)      
            if progress == 1
                @animation.start time, (deltaTime, progress, totalTime) =>
                    for i in [0...canvii.length * progress]
                        unless canvii[i][2]
                            @clear(canvii[i][0])
                            @clear(canvii[i][1])    
                            canvii[i].push('cleared')
                            
                    if progress == 1
                        @animating = false      
                
        
    highlightIfPassingThrough: ({x, y, width, height}) ->
        if not @passedThrough and @touches(x,y,width,height)
            if not @highlighting
                @highlighting = true
                @glow()
                @passedThrough = true
            
    touches: (x,y,width,height) ->
        @screenX > x - (width/2) and
        @screenX < x + (width/2) and
        @screenY > y - (height/2) and
        @screenY < y + (height/2)        
    
    reset: ->
        @passedThrough = false