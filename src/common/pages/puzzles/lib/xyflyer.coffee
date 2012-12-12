xyflyer = exports ? provide('./lib/xyflyer', {})

class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    baseFolder: '/assets/images/puzzles/xyflyer/'
    maxUnits: 10
    increment: 5
    planeWidth: 50
    planeHeight: 30
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
        scale = 0.6
        transformation = "t#{x - (@planeWidth/2)},#{y - (@planeHeight/2)}s-#{scale},#{scale}"
        if not @plane
            planePath = 'm45.80125,3.33402c0.61292,0.46928 1.05152,2.94397 1.0285,5.25969c-0.02302,2.31571 0.88025,4.64063 1.80347,4.95859c1.07606,0.47389 -1.08528,0.4524 -4.94019,-0.04909c-4.62682,-0.50918 -7.87342,-0.07825 -9.7398,1.29276c-2.7988,1.97934 -2.64902,2.44402 2.56464,6.04694c10.58017,7.36176 4.70142,8.53851 -7.58,1.46862c-4.45249,-2.51458 -11.06171,-5.51379 -14.75765,-6.4769c-7.85194,-2.23958 -13.64944,-0.88678 -13.51925,-2.07142c1.88137,-3.08462 5.38157,-1.90437 6.92488,-4.45687c1.87412,-1.08561 1.3257,-1.69121 -1.17471,-4.04786c-2.5984,-2.65056 0.64206,-2.46396 6.1737,0.21575c6.14608,2.99462 26.3761,2.57809 28.87842,-0.63936c2.0361,-2.9133 2.80954,-3.06 4.338,-1.50085z'
            @plane = @board.path(planePath)
            @plane.attr(fill: '#000')
            @plane.transform(transformation)
        else
            w = @plane.attr('width')
            h = @plane.attr('height')
            @plane.animate({transform: transformation}, time, 'linear', next)
        
    launchPlane: ->
        @calculatePlanePath() if not @path or not Object.keys(@path).length
        @planeXPos = (@planeXPos or 0) + @increment
        yPos = @path[@planeXPos]
        if yPos == undefined or @planeXPos > (@grid.xMax * @xUnit)
            $.timeout 1000, => @resetPlane()
            return
            
        dX = @increment
        dY = yPos - @path[@planeXPos - @increment]
        time = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2)) * @increment
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

    
    