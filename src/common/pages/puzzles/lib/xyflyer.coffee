xyflyer = exports ? provide('./lib/xyflyer', {})

class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    baseFolder: '/assets/images/puzzles/xyflyer/'
    maxUnits: 10
    increment: 1
    formulas: {}
    
    constructor: ({@el, boardElement, @objects, @grid}) ->
        @initBoard(boardElement)   
        
    $: (selector) -> $(selector, @el)
    
    addImage: (image, x, y) ->
        width = image.width() * @scale
        height = image.height() * @scale
        @board.image(image.attr('src'), x, y, width, height)

    addIsland: ->
        island = @objects.find('.island img')
        
        width = island.width() * @scale
        height = island.height() * @scale

        if not width or not height
            $.timeout 100, => @addIsland()
            return
            
        @addImage(island, @xAxis - (width/2), @yAxis)
        @movePlane(@xAxis,  @yAxis)

    initBoard: (boardElement) -> 
        dimensions = boardElement.offset()
        @board = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)

        @width = dimensions.width
        @height = dimensions.height        

        @xUnit = @width / (@grid.xMax - @grid.xMin)
        @yUnit = @height / (@grid.yMax - @grid.yMin)

        @xAxis = @width - (@grid.xMax * @xUnit)
        @yAxis = @height + (@grid.yMin * @yUnit)
        
        maxDimension = Math.max(@grid.xMax - @grid.xMin, @grid.yMax - @grid.yMin)
        @scale = 1/(Math.log(Math.sqrt(maxDimension)) - 0.5)
        
        @addIsland()
        @drawGrid()            
            
    drawGrid: ->    
        gridString = """
            M#{@xAxis},0
            L#{@xAxis},#{@height}
            M0,#{@yAxis}
            L#{@width},#{@yAxis}
        """
        
        stroke = 'rgba(255,255,255,0.4)'
        
        xUnits = @width / @xUnit
        xUnits = @maxUnits if xUnits < @maxUnits
        multiple = Math.floor(xUnits / @maxUnits)
        increment = (@xUnit * multiple) 
        start = 0 - (if multiple > @grid.xMin then ((@grid.xMin * @xUnit) % increment) else (increment % (@grid.xMin * @xUnit))) 
        for mark in [start..@width] by increment
            gridString += "M#{mark},#{@yAxis + 10}"
            gridString += "L#{mark},#{@yAxis - 10}"
            unless mark > @width
                text = @board.text(mark + 6, @yAxis - 6, Math.round(@grid.xMin + (mark / @xUnit)))
                text.attr(stroke: stroke, fill: stroke)

        yUnits = @height / @yUnit
        yUnits = @maxUnits if yUnits < @maxUnits
        multiple = Math.floor(yUnits / @maxUnits)
        increment = (@yUnit * multiple) * -1
        start = @height - (if multiple > @grid.yMin then (increment % (@grid.yMin * @yUnit)) else ((@grid.yMin * @yUnit) % increment))
        for mark in [start..0] by increment
            gridString += "M#{@xAxis + 10},#{mark}"
            gridString += "L#{@xAxis - 10},#{mark}"
            unless mark > @height
                text = @board.text(@xAxis + 6, mark - 6, Math.round(@grid.yMax - (mark / @yUnit)))
                text.attr(stroke: stroke, fill: stroke)

        grid = @board.path(gridString)
        grid.attr(stroke: stroke)
        

    movePlane: (x, y, time, next) ->
        if not @plane
            plane = @objects.find('.plane img')
            w = plane.width()
            h = plane.height()
            @plane = @addImage(plane, x - (w/2), y - (h/3))
        else
            w = @plane.attr('width')
            h = @plane.attr('height')
            @plane.animate({x: x - (w/2), y: y - (h/3)}, time, null, next)
        
    launchPlane: ->
        @calculatePlanePath() if not @path or not Object.keys(@path).length
        @planeXPos = (@planeXPos or 0) + @increment
        yPos = @path[@planeXPos]
        if yPos == undefined or @planeXPos > (@grid.xMax * @xUnit)
            $.timeout 1000, => @resetPlane()
            return
            
        dX = (@planeXPos + @xAxis) - @plane.attr('x')
        dY = (@yAxis - yPos) - @plane.attr('y')
        time = (Math.pow(dX, 2) + Math.pow(dY, 2)) / 100
        @movePlane(@planeXPos + @xAxis, @yAxis - yPos, time, => @launchPlane())
            
    calculatePlanePath: ->
        @path = {}
        for xPos in [(@grid.xMin * @xUnit)..(@grid.xMax * @xUnit)] by @increment
            if lastFormula and lastFormula.area(xPos / @xUnit)
                @path[xPos] = lastFormula.formula(xPos / @xUnit) * @yUnit
                continue
                
            for id of @formulas
                continue if not @formulas[id].area(xPos / @xUnit)
                @path[xPos] = @formulas[id].formula(xPos / @xUnit) * @yUnit
                lastFormula = @formulas[id]
                break

    resetPlane: ->
        @path = null
        @planeXPos = null
        @movePlane(@xAxis, @yAxis)
    
    plot: (id, formula, area) ->
        return if not formula
        
        @formulas[id].line.remove() if @formulas[id]
        @formulas[id] = 
            formula: formula
            area: area
            
        @activeFormula = @formulas[id]
    
        brokenLine = 0
        infiniteLine = 0
        pathString = "M0,#{@height}"
        for xPos in [(@grid.xMin * @xUnit)..(@grid.xMax * @xUnit)]
            lastYPos = yPos
            yPos = formula(xPos / @xUnit) * @yUnit
    
            if yPos == Number.NEGATIVE_INFINITY
                yPos = @grid.yMin * @xUnit
                brokenLine += 1
            else if yPos == Number.POSITIVE_INFINITY
                yPos = @grid.yMax * @xUnit
                brokenLine += 1
    
            if lastYPos
                lastSlope = slope
                slope = yPos - lastYPos
                if lastSlope and Math.abs(lastSlope - slope) > Math.abs(lastSlope) and Math.abs(lastYPos - yPos) > Math.abs(lastYPos)
                    pathString += "L#{xPos + @xAxis + 1},#{(if lastSlope > 0 then 0 else @height)}"
                    pathString += "M#{xPos + @xAxis + 1},#{(if lastSlope > 0 then @height else 0)}"
                    brokenLine += 1
                        
            if brokenLine > 0
                pathString += "M#{xPos + @xAxis},#{@yAxis - yPos}"
                brokenLine -= 1
            else
                pathString += "L#{xPos + @xAxis},#{@yAxis - yPos}"
                
        line = @board.path(pathString)
        line.attr(stroke: 'rgba(0,0,0,0.1)', 'stroke-width': 2)

        @formulas[id].line = line
        @resetPlane()

    
    