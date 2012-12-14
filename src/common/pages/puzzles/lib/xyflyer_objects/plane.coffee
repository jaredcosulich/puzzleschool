plane = exports ? provide('./plane', {})
xyflyerObject = require('./object')

class plane.Plane extends xyflyerObject.Object
    increment: 5
    width: 50
    height: 30

    constructor: ({@board}) ->
        @scale = 0.6
        @description = 'm45.80125,3.33402c0.61292,0.46928 1.05152,2.94397 1.0285,5.25969c-0.02302,2.31571 0.88025,4.64063 1.80347,4.95859c1.07606,0.47389 -1.08528,0.4524 -4.94019,-0.04909c-4.62682,-0.50918 -7.87342,-0.07825 -9.7398,1.29276c-2.7988,1.97934 -2.64902,2.44402 2.56464,6.04694c10.58017,7.36176 4.70142,8.53851 -7.58,1.46862c-4.45249,-2.51458 -11.06171,-5.51379 -14.75765,-6.4769c-7.85194,-2.23958 -13.64944,-0.88678 -13.51925,-2.07142c1.88137,-3.08462 5.38157,-1.90437 6.92488,-4.45687c1.87412,-1.08561 1.3257,-1.69121 -1.17471,-4.04786c-2.5984,-2.65056 0.64206,-2.46396 6.1737,0.21575c6.14608,2.99462 26.3761,2.57809 28.87842,-0.63936c2.0361,-2.9133 2.80954,-3.06 4.338,-1.50085z'
        @image = @board.addPlane(@)
        @image.attr(fill: '#000')
        @reset()
        
    move: (x, y, time, next) ->
        transformation = "t#{x - (@width/2)},#{y - (@height/2)}s-#{@scale},#{@scale}"
        w = @image.attr('width')
        h = @image.attr('height')
        @image.animate({transform: transformation}, time, 'linear', next)

    launch: (force) ->
        return if @cancelFlight and not force
        @cancelFlight = false
        @path = @board.calculatePath(@increment) if not @path or not Object.keys(@path).length
        @xPos = (@xPos or 0) + @increment
        @yPos = @path[@xPos]
        if @yPos == undefined or @xPos > (@board.grid.xMax * @board.xUnit)
            $.timeout 1000, => @reset()
            return

        dX = @increment
        dY = @yPos - @path[@xPos - @increment]
        time = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2)) * @increment
        @move(@xPos + @board.xAxis, @board.yAxis - @yPos, time, => @launch())

    reset: ->
        @cancelFlight = true
        @path = null
        @xPos = null
        @move(@board.xAxis, @board.yAxis)

        