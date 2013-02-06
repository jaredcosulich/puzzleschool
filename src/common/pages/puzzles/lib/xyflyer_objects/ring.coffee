ring = exports ? provide('./ring', {})
xyflyerObject = require('./object')

class ring.Ring extends xyflyerObject.Object
    fullDescription: 'm0.5,19.94043c0,-10.68549 0.34383,-19.44043 2.82518,-19.44043c2.48135,0 3.17027,8.65525 3.17027,19.34073c0,10.68549 -0.68892,19.34074 -3.17027,19.34074c-2.48135,0 -2.82518,-8.55555 -2.82518,-19.24104z'    
    frontDescription: 'm3,19.94043c-2.48135,0 -2.82518,-8.55555 -2.82518,-19.24104c0,-10.68549 0.34383,-19.44043 2.82518,-19.44043'    
    backDescription: 'm-3,-19c2.48135,0 3.17027,8.65525 3.17027,19.34073c0,10.68549 -0.68892,19.34074 -3.17027,19.34074'    
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
                # @animating = true
                # @highlighted.animate({opacity: 0.2}, 250, => @animating = false)
                @passedThrough = true
        else if @highlighting and not @animating
            # @highlighted.animate(
            #     {opacity: 0}, 
            #     500
            # )
            @highlighting = false
            
    touches: (x,y,width,height) ->
        @screenX > x - (width/2) and
        @screenX < x + (width/2) and
        @screenY > y - (height/2) and
        @screenY < y + (height/2)        
    
    reset: ->
        @passedThrough = false