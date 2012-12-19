board = exports ? provide('./board', {})
xyflyerObject = require('./object')

class board.Board extends xyflyerObject.Object
    maxUnits: 10

    constructor: ({boardElement, @grid, @objects, @resetLevel}) ->
        @formulas = {}
        @rings = []
        @ringFronts = []
        @init(boardElement)

    init: (boardElement) -> 
        dimensions = boardElement.offset()
        @paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height)

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
        @initClicks(boardElement)

    addImage: (image, x, y) ->
        width = image.width() * @scale
        height = image.height() * @scale
        @paper.image(image.attr('src'), x, y, width, height)

    addIsland: ->
        island = @objects.find('.island img')

        width = island.width() * @scale
        height = island.height() * @scale

        if not width or not height
            $.timeout 100, => @addIsland()
            return

        @addImage(island, @xAxis - (width/2), @yAxis)
        
    addRing: (ring) ->
        front = @paper.path(ring.frontDescription)
        front.toFront()
        back = @paper.path(ring.backDescription)
        back.toBack()
        ringSet = @paper.set()
        ringSet.push(front, back)
        @ringFronts.push(front)
        @rings.push(ringSet)
        return ringSet    
    
    setRingFronts: ->
        ringFront.toFront() for ringFront in @ringFronts
    
    addPlane: (@plane) -> @paper.path(@plane.description)
        
    initClicks: (boardElement) ->
        boardElement.css(zIndex: 9999)
        boardElement.bind 'click', (e) =>
            result = @findNearestXOnPath(e.offsetX, e.offsetY)
            onPath = result.x
            if result.formulas.length
                formula1 = result.formulas[0]
                y = @screenY(formula1.formula(@paperX(result.x)))
                @showXY(result.x, y, true)
            else
                @showXY(e.offsetX, e.offsetY)

    findNearestXOnPath: (x, y, formulas=@formulas, precision=0) ->
        distances = {}
        factor = Math.pow(10, precision)
        distance = 0.5 / factor
        result = {formulas: [], distance: distance*factor, x: x}
        for d in [0..distance] by distance/10
            for side in [-1,1]
                continue if side == -1 and not d
                dx = side * d
                goodFormulas = []
                for id, formula of formulas
                    formulaY = formula.formula(@paperX(x)+dx)
                    distanceY = Math.abs(@paperY(y) - formulaY)
                    if distanceY <= (distance * factor)
                        goodFormulas.push(formula)                    
                        if !result.intersectionDistance and distanceY < result.distance
                            result.distance = distanceY
                            result.x = @screenX(@paperX(x) + dx)
                            result.formulas = [formula]


                intersectionDistance = -1
                for formula, index in goodFormulas
                    formulaY = formula.formula(@paperX(x)+dx)

                    index2 = 0
                    avgDistance = -1
                    for formula2 in goodFormulas
                        continue if formula == formula2
                        formula2Y = formula2.formula(@paperX(x)+dx)
                        distance2Y = Math.abs(formulaY - formula2Y)
                        avgDistance = ((avgDistance * index2) + distance2Y) / (index2 + 1)
                        index2 += 1

                    intersectionDistance = ((intersectionDistance * index) + avgDistance) / (index + 1)  

                if (-1 < intersectionDistance and (!result.intersectionDistance or result.intersectionDistance > intersectionDistance))
                    result.intersectionDistance = intersectionDistance
                    result.x = @screenX(@paperX(x) + dx)
                    result.formulas = goodFormulas

        if precision < 4
            result.x = @findNearestXOnPath(result.x, y, formulas, precision+1).x

        return result        

    paperX: (x,precision=3) -> Math.round(Math.pow(10,precision) * (x - @xAxis) / @xUnit) / Math.pow(10,precision)
    paperY: (y,precision=3) -> Math.round(Math.pow(10,precision) * (@height - y - @yAxis) / @yUnit) / Math.pow(10,precision)
    screenX: (x) -> (x * @xUnit) + @xAxis
    screenY: (y) -> -1 * ((y * @yUnit) + @xAxis - @height)

    showXY: (x, y, onPath=false) ->
        width = 75
        height = 24
        radius = 3
        dot = @paper.circle(x, y, 0)
        dot.attr(opacity: 0)
        dot.animate({r: radius, opacity: 1}, 100)
        xyTip = @paper.rect(x+(width/2)+(radius*2), y, 0, 0, 6)
        xyTip.attr(fill: '#FFF', opacity: 0)
        paperX = @paperX(x)
        paperY = @paperY(y)
        text = @paper.text(x+(width/2)+(radius*2), y, "#{paperX}, #{paperY}")
        text.attr(opacity: 0)
        xyTip.animate({width: width, height: height, x: x+(radius*2), y: y-(height/2)}, 100)
        xyTip.animate({opacity: 1}, 250)
        text.animate({opacity: 1}, 250)
        $.timeout 2000, =>
            xyTip.animate({opacity: 0}, 100)
            text.animate({opacity: 0}, 100)
            removeTip = =>
                xyTip.remove()
                text.remove()
                dot.remove()
            xyTip.animate({width: 0, height: 0, x: x+(radius*2), y: y}, 250)
            dot.animate({r: 0, opacity: 0}, 250, null, removeTip)

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
                text = @paper.text(mark + 6, @yAxis - 6, Math.round(@grid.xMin + (mark / @xUnit)))
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
                text = @paper.text(@xAxis + 6, mark - 6, Math.round(@grid.yMax - (mark / @yUnit)))
                text.attr(stroke: stroke, fill: stroke)

        grid = @paper.path(gridString)
        grid.attr(stroke: stroke)
        
    plot: (id, formula, area) ->
        @formulas[id].line.remove() if @formulas[id]
        return if not formula

        @formulas[id] = 
            id: id
            formula: formula
            area: area

        @resetLevel()

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

        line = @paper.path(pathString)
        line.attr(stroke: 'rgba(0,0,0,0.1)', 'stroke-width': 2)

        @formulas[id].line = line
        @resetLevel()
        @setRingFronts()
        
    calculatePath: (increment) ->
        path = {}
        for xPos in [(@grid.xMin * @xUnit)..((@grid.xMax * 1.1) * @xUnit)] by increment
            if lastFormula and lastFormula.area(xPos / @xUnit)
                path[xPos] = 
                    formula: lastFormula.id
                    y: lastFormula.formula(xPos / @xUnit) * @yUnit
                continue

            for id of @formulas
                continue if not @formulas[id].area(xPos / @xUnit)
                path[xPos] = 
                    formula: id
                    y: @formulas[id].formula(xPos / @xUnit) * @yUnit
                lastFormula = @formulas[id]
                break
        return path

