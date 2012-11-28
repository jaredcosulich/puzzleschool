xyflyer = exports ? provide('./lib/xyflyer', {})

class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    baseFolder: '/assets/images/puzzles/xyflyer/'

    constructor: ({@el, canvas, @grid}) ->
        @canvas = $(canvas)
        if (@canvas and @canvas[0].getContext) 
            @context = @canvas[0].getContext('2d')
        
        @initCanvas()
        
    $: (selector) -> $(selector, @el)

    initCanvas: ->    
        @width = @canvas[0].width = @canvas.width()
        @height = @canvas[0].height = @canvas.height()

    plot: (formula) ->
        @initCanvas()
        @context.strokeStyle = '#00ED00'
        @context.lineWidth = 2

        xPos = 0
        brokenLine = 1
        plotted = 0

        @context.beginPath()
        
        xUnit = @xUnit()
        yUnit = @yUnit()
        for xPos in [(@width/-2)..(@width/2)] by 1
            yPos = formula(xPos / xUnit) * yUnit
            @context.lineTo(xPos + (@width / 2), (@height / 2) - yPos)    

        @context.stroke()
        @context.closePath()

    xUnit: -> @width / (@grid.xMax - @grid.xMin)
    yUnit: -> @height / (@grid.yMax - @grid.yMin)
    