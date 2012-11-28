xyflyer = exports ? provide('./lib/xyflyer', {})

class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    baseFolder: '/assets/images/puzzles/xyflyer/'
    maxUnits: 10
    pathContexts: {}
    
    constructor: ({@el, backgroundCanvas, @grid}) ->
        @backgroundCanvas = $(backgroundCanvas)
        if (@backgroundCanvas and @backgroundCanvas[0].getContext) 
            @backgroundContext = @backgroundCanvas[0].getContext('2d')
        
        @initBoard()        
        
    $: (selector) -> $(selector, @el)
    
    loadImage: (name, callback) -> 
        if (image = @$(".image_cache .image_#{name} img")).length
            callback(image)
            return
            
        image = new Image()
        if callback
            $(image).bind 'load', => callback(image)
        image.src = "#{@baseFolder}#{name}.png"
        image.className = "image_#{name}"
        @$('.image_cache').append(image)

    initBoard: ->    
        @width = @backgroundCanvas[0].width = @backgroundCanvas.width()
        @height = @backgroundCanvas[0].height = @backgroundCanvas.height()        

        @xUnit = @width / (@grid.xMax - @grid.xMin)
        @yUnit = @height / (@grid.yMax - @grid.yMin)

        @xAxis = @width - (@grid.xMax * @xUnit)
        @yAxis = @height + (@grid.yMin * @yUnit)
        
        # @scale = 
        
        @loadImage 'island', (island) =>
            @backgroundContext.drawImage(island, @xAxis - ($(island).width() / 2), @yAxis)
            @drawGrid()
            
    drawGrid: ->    
        @backgroundContext.strokeStyle = 'rgba(255,255,255,0.4)'    
        @backgroundContext.fillStyle = 'rgba(255,255,255,0.4)'    
        @backgroundContext.font = 'normal 12px sans-serif'    
        @backgroundContext.lineWidth = 1
        @backgroundContext.beginPath()
        
        @backgroundContext.moveTo(@xAxis, 0)
        @backgroundContext.lineTo(@xAxis, @height)

        @backgroundContext.moveTo(0, @yAxis)
        @backgroundContext.lineTo(@width, @yAxis)
        
        xUnits = @width / @xUnit
        xUnits = @maxUnits if xUnits < @maxUnits
        multiple = Math.floor(xUnits / @maxUnits)
        increment = (@xUnit * multiple) 
        start = 0 - (if multiple > @grid.xMin then ((@grid.xMin * @xUnit) % increment) else (increment % (@grid.xMin * @xUnit))) 
        for mark in [start..@width] by increment
            @backgroundContext.moveTo(mark, @yAxis + 10)
            @backgroundContext.lineTo(mark, @yAxis - 10)
            @backgroundContext.fillText(Math.round(@grid.xMin + (mark / @xUnit)), mark + 3, @yAxis - 3) unless mark < 0

        yUnits = @height / @yUnit
        yUnits = @maxUnits if yUnits < @maxUnits
        multiple = Math.floor(yUnits / @maxUnits)
        increment = (@yUnit * multiple) * -1
        start = @height - (if multiple > @grid.yMin then (increment % (@grid.yMin * @yUnit)) else ((@grid.yMin * @yUnit) % increment))
        for mark in [start..0] by increment
            @backgroundContext.moveTo(@xAxis + 10, mark)
            @backgroundContext.lineTo(@xAxis - 10, mark)
            @backgroundContext.fillText(Math.round(@grid.yMax - (mark / @yUnit)), @xAxis + 3, mark - 3) unless mark > @height

        @backgroundContext.stroke()
        @backgroundContext.closePath()        
        


    plot: (formula, id) ->
        context = @pathContexts[id]
        if context
            context.clearRect(0,0,@width,@height)
        else
            canvas = document.createElement('CANVAS')
            canvas.width = @width
            canvas.height = @height
            @$('.board').append(canvas)
            context = @pathContexts[id] = canvas.getContext('2d')
            
        context.strokeStyle = 'rgba(0,0,0,0.1)'
        context.lineWidth = 2

        xPos = 0
        brokenLine = 1
        plotted = 0

        context.beginPath()

        for xPos in [(@grid.xMin * @xUnit)..(@grid.xMax * @xUnit)]
            yPos = formula(xPos / @xUnit) * @yUnit
            context.lineTo(xPos + @xAxis, @yAxis - yPos)    

        context.stroke()
        context.closePath()

    
    