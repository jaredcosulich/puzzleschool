board = exports ? provide('./board', {})
xyflyerObject = require('./object')
Animation = require('./animation').Animation

class board.Board extends xyflyerObject.Object
    maxUnits: 10

    constructor: ({@el, @grid, @objects, @islandCoordinates, @resetLevel}) ->
        @islandCoordinates or= {}
        @islandCoordinates.x = 0 if not @islandCoordinates.x
        @islandCoordinates.y = 0 if not @islandCoordinates.y
        @formulas = {}
        @rings = []
        @ringFronts = []
        @init()

    init: -> 
        dimensions = @el.offset()
        @paper = Raphael(@el.attr('id'), dimensions.width, dimensions.height)
        
        
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
        @initClicks()
        @initAnimation()
    
    initAnimation: ->
        @animationCtx1 = @createCanvas(1)
        @animationCtx2 = @createCanvas(3)
        @animation = new Animation()
        @animationObjects = []
        @animate()
        
    addRing: (ring) -> @rings.push(ring)
        
    addToCanvas: (object, zIndex) ->
        @animationObjects[zIndex] or= []
        @animationObjects[zIndex].push(object)
    
    animate: ->
        @animation.frame() (t) => 
            @animationCtx1.clearRect(0,0,@width,@height)
            @animationCtx2.clearRect(0,0,@width,@height)
            for animationSet, index in @animationObjects
                continue unless animationSet
                for object in animationSet
                    ctx = if index <= 2 then @animationCtx1 else @animationCtx2
                    object.draw(ctx, t)
            @animate()
        
    createCanvas: (zIndex) ->
        canvas = $(document.createElement('CANVAS'))
        canvas.css
            top: 0
            left: 0
            height: @el.height()
            width: @el.width()
            zIndex: zIndex
        canvas.attr(height: @el.height(), width: @el.width())            
        @el.append(canvas)            
        return canvas[0].getContext('2d')

    addImage: (image, x, y) ->
        width = image.width() * @scale
        height = image.height() * @scale
        @paper.image(image.attr('src'), x, y, width, height)

    addIsland: ->
        person = @objects.find('.person img')
        personWidth = person.width() * @scale
        personHeight = person.height() * @scale
        
        island = @objects.find('.island img')
        islandWidth = island.width() * @scale
        islandHeight = island.height() * @scale

        if not personWidth or not personHeight or not islandWidth or not islandHeight
            $.timeout 100, => @addIsland()
            return
        
        @island = @paper.set()    
            
        planeX = @xAxis + (@islandCoordinates.x * @xUnit)
        planeY = @yAxis - (@islandCoordinates.y * @yUnit)

        personX = planeX - personWidth + (15 * @scale)
        personY = planeY - (17 * @scale)

        islandX = planeX - (islandWidth/2) - (personWidth/4)
        islandY = planeY + personHeight + islandHeight - (576*@scale)

        @island.push(@addImage(island, islandX, islandY))
        @island.push(@addImage(person, personX, personY))
        
        text = @islandText()
        @islandLabel = @paper.text(
            islandX + (islandWidth/2) - (12*@scale)
            islandY + islandHeight - (57*@scale)
            text
        ).attr(fill: '#ddd', stroke: 'none', 'font-size': 9+(2*@scale)).toFront()
        
        @island.push(@islandLabel)
        
    islandText: ->
        "#{if @scale > 0.6 then 'Launching From:\n' else ''}#{@islandCoordinates.x}, #{@islandCoordinates.y}"
        
    initClicks: ->
        @el.css(zIndex: 97)
        @el.bind 'mousedown.showxy touchstart.showxy', (e) =>
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
    paperY: (y,precision=3) -> Math.round(Math.pow(10,precision) * (@yAxis - y) / @yUnit) / Math.pow(10,precision)
    screenX: (x) -> (x * @xUnit) + @xAxis
    screenY: (y) -> @yAxis - (y * @yUnit) 

    showXY: (x, y, onPath=false, permanent=false) ->
        paperX = @paperX(x)
        paperY = @paperY(y)

        string = "#{paperX}, #{paperY}"
        width = (string.length * 6) + 2
        height = 18
        radius = 3

        unless permanent
            dot = @paper.circle(x, y, 0)
            dot.attr(opacity: 0)
            dot.animate({r: radius, opacity: 1}, 100)

        xyTip = @paper.rect(x+(width/2)+(radius*2), y, 0, 0, 6)
        xyTip.attr(fill: '#FFF', opacity: 0)
        text = @paper.text(x+(width/2)+(radius*2), y, string)
        text.attr(fill: '#000', stroke: 'none', opacity: 0)
        xyTip.animate({width: width, height: height, x: x+(radius*2), y: y-(height/2)}, 100)
        
        opacity = (if permanent then 0.75 else 1)
        xyTip.animate({opacity: opacity}, 250)
        text.animate({opacity: opacity}, 250)
        
        xy = @paper.set()
        xy.push(xyTip, text, dot)
        
        unless permanent
            $.timeout 2000, =>
                xyTip.animate({opacity: 0}, 100)
                text.animate({opacity: 0}, 100)
                removeTip = =>
                    xy.remove()
                xyTip.animate({width: 0, height: 0, x: x+(radius*2), y: y}, 250)
                dot.animate({r: 0, opacity: 0}, 250, null, removeTip)
        return xy

    drawGrid: ->    
        gridString = """
            M#{@xAxis},0
            L#{@xAxis},#{@height}
            M0,#{@yAxis}
            L#{@width},#{@yAxis}
        """

        color = 'rgba(255,255,255,0.4)'

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
                text.attr(stroke: 'none', fill: color)

        label = @paper.text(24, @yAxis + 6, 'X Axis')
        label.attr(stroke: 'none', fill: color)
        label = @paper.text(@width - 24, @yAxis + 6, 'X Axis')
        label.attr(stroke: 'none', fill: color)

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
                text.attr(stroke: 'none', fill: color)
                if mark == 0       
                    label = @paper.text(@xAxis + 6, mark - 6, 'Y Axis')
                    label.attr(stroke: 'none', fill: color)
                
        label = @paper.text(@xAxis - 6, 24, 'Y Axis')
        label.attr(stroke: 'none', fill: color, transform: 'r270')
        label = @paper.text(@xAxis - 6, @height - 24, 'Y Axis')
        label.attr(stroke: 'none', fill: color, transform: 'r270')

        grid = @paper.path(gridString)
        grid.attr(stroke: color)
        
    plot: (id, formula, area) ->
        if (plotArea = @formulas[id]?.plotArea)
            plotArea.clearRect(0,0,@width,@height)

        return if not formula
        
        plotArea = @createCanvas(2) if not plotArea
        
        plotArea.strokeStyle = 'rgba(0,0,0,0.25)'
        plotArea.lineWidth = 1

        plotArea.beginPath()

        brokenLine = 0
        infiniteLine = 0
        for xPos in [(@grid.xMin * @xUnit)..(@grid.xMax * @xUnit)] by 0.1
            lastYPos = yPos
            lastSlope = slope
            yPos = formula(xPos / @xUnit) * @yUnit
            continue if isNaN(yPos)

            if yPos == Number.NEGATIVE_INFINITY
                console.log("NEGATIVE INFINITY")
                plotArea.lineTo(xPos + @xAxis, @height)
                yPos = @grid.yMin * @yUnit
                brokenLine += 1
            else if yPos == Number.POSITIVE_INFINITY
                console.log("POSITIVE INFINITY")
                plotArea.lineTo(xPos + @xAxis, 0)
                yPos = @grid.yMax * @yUnit
                brokenLine += 1            

            if lastYPos
                slope = yPos - lastYPos
                if lastSlope and ((lastSlope > 0 and slope < 0) or (lastSlope < 0 and slope > 0))
                    for i in [-1..0] by 0.001
                        testYPos = formula((xPos+i) / @xUnit) * @yUnit
                        if (yPos > 0 and testYPos < 0) or (yPos < @height and testYPos > @height)
                            #This was removed to get tan(x) working if adding back please test tan(x)
                            #plotArea.lineTo(xPos + @xAxis + i, @yAxis - testYPos)
                            newYPos = (if testYPos < 0 then 0 else @height)
                            plotArea.moveTo(xPos + @xAxis + i, newYPos)
                            slope = yPos - (@yAxis - newYPos)
                            break

            if brokenLine > 0
                plotArea.moveTo(xPos + @xAxis, @yAxis - yPos)
                brokenLine -= 1
            else
                plotArea.lineTo(xPos + @xAxis, @yAxis - yPos)

        plotArea.stroke()
        plotArea.closePath()

        @formulas[id] = 
            id: id
            area: area
            formula: formula
            plotArea: plotArea

        @resetLevel()
            
        
    calculatePath: ->
        intersection = (@islandCoordinates.x * @xUnit) + (@xUnit * 0.001)
        path = {distance: 0}
        path[0] = 
            x: @islandCoordinates.x * @xUnit
            y: @islandCoordinates.y * @yUnit
            
        addToPath = (x, y, formula) =>
            return unless @grid.yMin - 50 <= (y / @yUnit) <= @grid.yMax + 50
            significantDigits = 1
            formattedFullDistance = Math.ceil(path.distance * Math.pow(10, significantDigits))
            prevPos = path[formattedFullDistance]
            return if prevPos.x == x and prevPos.y == y
            distance = Math.sqrt(Math.pow(prevPos.y - y, 2) + Math.pow(prevPos.x - x, 2))
            formattedDistance = Math.ceil(distance * Math.pow(10, significantDigits))
            for d in [1..formattedDistance]
                incrementalX = prevPos.x + (d*((x - prevPos.x)/formattedDistance))
                path[formattedFullDistance + d] = 
                    formula: formula.id
                    x: incrementalX
                    y: formula.formula(incrementalX / @xUnit) * @yUnit
            
                for ring in @rings when ring.inPath(incrementalX/@xUnit, formula.formula)
                    path[formattedFullDistance + d].ring = ring
                    
            path.distance += distance
            
        for xPos in [(@islandCoordinates.x * @xUnit)..((@grid.xMax * 1.1) * @xUnit)] by 1
            # xPos = Math.round(xPos)
            if lastFormula 
                if lastFormula.area(xPos / @xUnit)
                    yPos = lastFormula.formula(xPos / @xUnit) * @yUnit
                    for id of @formulas when id != lastFormula.id
                        continue if not @formulas[id].area(xPos / @xUnit)
                        otherYPos = @formulas[id].formula(xPos / @xUnit) * @yUnit
                        prevYPos = lastFormula.formula((xPos - 1) / @xUnit) * @yUnit
                        otherPrevYPos = @formulas[id].formula((xPos - 1) / @xUnit) * @yUnit
                        if (yPos - otherYPos <= 0 and prevYPos - otherPrevYPos > 0) or
                           (yPos - otherYPos >= 0 and prevYPos - otherPrevYPos < 0)  
                            yPos = otherYPos
                            lastFormula = @formulas[id]
                            break
                    
                    addToPath(xPos, yPos, lastFormula)
                    continue
                else
                    intersection = xPos - 1
                    lf = lastFormula
                    lastFormula = null
                    while lf.area(intersection / @xUnit)
                        intersectionY = lf.formula(intersection / @xUnit) * @yUnit
                        addToPath(intersection, intersectionY, lf)
                        intersection += (@xUnit * 0.001)
                
            intersection -= (@xUnit * 0.001) if intersection
            
            validPathFound = false
            for id of @formulas
                continue if not @formulas[id].area(xPos / @xUnit)
                if intersection?
                    intersectionY = @formulas[id].formula(intersection / @xUnit) * @yUnit
                    continue if Math.abs(path[Math.floor(path.distance)].y - intersectionY) / @yUnit > 0.05
                    
                y = @formulas[id].formula(xPos / @xUnit) * @yUnit
                continue if isNaN(y)
                validPathFound = true
                
                lastFormula = @formulas[id]
                addToPath(xPos, y, lastFormula)                    
                break
            
            return path unless validPathFound
        
        return path
    
    clear: ->
        @paper.clear()
        @el.find('canvas').remove()