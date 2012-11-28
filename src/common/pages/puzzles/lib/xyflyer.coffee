xyflyer = exports ? provide('./lib/xyflyer', {})

class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    baseFolder: '/assets/images/puzzles/xyflyer/'

    constructor: ({@el, canvas, @grid}) ->
        @canvas = $(canvas)
        if (@canvas and @canvas[0].getContext) 
            @context = @canvas[0].getContext('2d')
        
        @initGrid()
        
    $: (selector) -> $(selector, @el)

    initGrid: ->    
        @width = @canvas[0].width = @canvas.width()
        @height = @canvas[0].height = @canvas.height()
        @xUnit = @width / (@grid.xMax - @grid.xMin)
        @yUnit = @height / (@grid.yMax - @grid.yMin)
        @maxUnits = 10
        
        @context.strokeStyle = 'rgba(255,255,255,0.4)'    
        @context.fillStyle = 'rgba(255,255,255,0.4)'    
        @context.font = 'normal 12px sans-serif'    
        @context.lineWidth = 1
        @context.beginPath()
        
        yAxis = @height + (@grid.yMin * @yUnit)
        @context.moveTo(0, yAxis)
        @context.lineTo(@width, yAxis)
        
        xAxis = @width + (@grid.xMin * @xUnit)
        @context.moveTo(xAxis, 0)
        @context.lineTo(xAxis, @height)

        xUnits = @width / @xUnit
        xUnits = @maxUnits if xUnits < @maxUnits
        for increment in [0..@width] by (@xUnit * (xUnits / @maxUnits))
            @context.moveTo(increment, yAxis + 10)
            @context.lineTo(increment, yAxis - 10)
            xPos = increment + 3
            xPos = @width - 16 if xPos > @width
            @context.fillText(@grid.xMin + (increment / @xUnit), xPos, yAxis - 3)

        yUnits = @height / @yUnit
        yUnits = @maxUnits if yUnits < @maxUnits
        for increment in [0..@height] by (@yUnit * (yUnits / @maxUnits))
            @context.moveTo(xAxis + 10, increment)
            @context.lineTo(xAxis - 10, increment)
            yPos = increment - 3
            yPos = 12 if yPos < 0
            @context.fillText(@grid.yMax - (increment / @yUnit), xAxis + 3, yPos)

        @context.stroke()
        @context.closePath()
        

    plot: (formula) ->
        @initGrid()
        @context.strokeStyle = '#00ED00'
        @context.lineWidth = 2

        xPos = 0
        brokenLine = 1
        plotted = 0

        @context.beginPath()

        for xPos in [(@width/-2)..(@width/2)] by 1
            yPos = formula(xPos / @xUnit) * @yUnit
            @context.lineTo(xPos + (@width / 2), (@height / 2) - yPos)    

        @context.stroke()
        @context.closePath()

    
    