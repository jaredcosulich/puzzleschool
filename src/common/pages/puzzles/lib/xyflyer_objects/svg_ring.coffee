ring = exports ? provide('./ring', {})
xyflyerObject = require('./object')

class ring.Ring extends xyflyerObject.Object
    width: 6
    height: 39
    
    constructor: ({@board, @x, @y}) ->
        
        
        @screenX = @board.screenX(@x)
        @screenY = @board.screenY(@y)
        @scale = 1
        @image = @board.addRing(@)
        @image.attr(stroke: '#FFF')
        @move(@x, @y)
        @label = @board.showXY(@screenX, @screenY, false, true)
        @highlighted = @board.paper.set()
        @image.forEach (half) =>
            @highlighted.push(half.glow(color: 'white'))
        @highlighted.attr(opacity: 0)
        
    move: (@x, @y) ->
        @image.transform("t#{@screenX},#{@screenY}s-#{@scale},#{@scale}")
        
    highlightIfPassingThrough: ({x, y, width, height}) ->
        if not @passedThrough and @touches(x,y,width,height)
            if not @highlighting
                @highlighting = true
                @animating = true
                @highlighted.animate({opacity: 0.2}, 250, => @animating = false)
                @passedThrough = true
        else if @highlighting and not @animating
            @highlighted.animate(
                {opacity: 0}, 
                500
            )
            @highlighting = false
            
    touches: (x,y,width,height) ->
        @screenX > x - (width/2) and
        @screenX < x + (width/2) and
        @screenY > y - (height/2) and
        @screenY < y + (height/2)        
    
    reset: ->
        @passedThrough = false