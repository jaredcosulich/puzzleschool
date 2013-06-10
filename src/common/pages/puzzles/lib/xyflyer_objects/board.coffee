board = exports ? provide('./board', {})
xyflyerObject = require('./object')
Animation = require('./animation').Animation

class board.Board extends xyflyerObject.Object
    maxUnits: 10

    constructor: ({@el, @grid, @objects, @islandCoordinates, @resetLevel, hidePlots}) ->
        @init
            el: @el
            grid: @grid
            objects: @objects
            islandCoordinates: @islandCoordinates
            hidePlots: hidePlots
        @load()

    init: ({@el, @grid, @objects, @islandCoordinates, hidePlots}) ->
        @islandCoordinates or= {}
        @islandCoordinates.x = 0 if not @islandCoordinates.x
        @islandCoordinates.y = 0 if not @islandCoordinates.y
        @formulas = {}
        @rings = []
        @ringFronts = []
        @setHidePlots(hidePlots, true)
        @clear()
        @load()
        
    setHidePlots: (hidePlots, force) ->
        if force or @hidePlots != hidePlots
            @hidePlots = hidePlots
            if @hidePlots then @fadePlots() else @showPlots()
        
    load: -> 
        dimensions = @el.offset()
        @paper = Raphael(@el.attr('id'), dimensions.width, dimensions.height) unless @paper 
        
        @width = dimensions.width
        @height = dimensions.height        

        if (@grid.xMax - @grid.xMin) == (@grid.yMax - @grid.yMin)
            if @width != @height
                ratio = @width / @height
                if ratio > 1
                    @grid.xMax = Math.floor(@grid.xMax * ratio)
                    @grid.xMin = Math.ceil(@grid.xMin * ratio)
                else
                    @grid.yMax = Math.floor(@grid.yMax / ratio)
                    @grid.yMin = Math.ceil(@grid.yMin / ratio)

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
        return if @animationCtx
        @animationCtx = [@createCanvas(1), @createCanvas(3)]
        @animationObjects = []

        unless @animation
            @animation = new Animation()
            @animate()
        
    addRing: (ring) -> @rings.push(ring)
        
    addToCanvas: (object, zIndex) ->
        @animationObjects[zIndex] or= []
        @animationObjects[zIndex].push(object)
    
    animate: ->
        @animation.frame() (t) => 
            ctx.clearRect(0,0,@width,@height) for ctx in @animationCtx
            
            for animationSet, i in @animationObjects
                continue unless animationSet
                for object in animationSet
                    ctx = if i <= 2 then @animationCtx[0] else @animationCtx[1]
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
        
        @island.remove() if @island
        
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
                
    moveIsland: (x, y) ->
        if not @island
            $.timeout 100, => @moveIsland(x, y)
            return
            
        relativeX = x - @screenX(@islandCoordinates.x)
        relativeY = y - @screenY(@islandCoordinates.y)

        @islandCoordinates = 
            x: @paperX(x)
            y: @paperY(y)   

        @island.transform("...t#{relativeX},#{relativeY}")       
        
        @islandLabel.attr(text: @islandText())
        return @islandCoordinates
        
    islandText: ->
        "#{if @scale > 0.6 then 'Launching From:\n' else ''}#{@islandCoordinates.x}, #{@islandCoordinates.y}"
        
    offsetX: (e) => (if e.pageX then e.pageX else (e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX)) - @el.offset().left
    offsetY: (e) => (if e.pageY then e.pageY else (e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY)) - @el.offset().top
    
    initClicks: ->
        @el.css(zIndex: 97)
        @el.bind 'mousedown.showxy touchstart.showxy', (e) =>
            return if @clickHandled
            @clickHandled = true
            $.timeout 500, => @clickHandled = false
            result = @findNearestXOnPath(@offsetX(e), @offsetY(e))
            onPath = result.x
            if result.formulas.length
                formula1 = result.formulas[0]
                y = @screenY(formula1.formula(@paperX(result.x)))
                @showXY(result.x, y, true)
            else
                @showXY(@offsetX(e), @offsetY(e))

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
        return if @gridSet
        @gridSet = true
        
        gridString = """
            M#{@xAxis},0
            L#{@xAxis},#{@height}
            M0,#{@yAxis}
            L#{@width},#{@yAxis}
        """

        color = 'rgba(255,255,255,0.5)'

        xUnits = @width / @xUnit
        xUnits = @maxUnits if xUnits < @maxUnits
        multiple = Math.floor(xUnits / @maxUnits)
        increment = (@xUnit * multiple) 
        for direction in [-1,1]
            lastMark = @xAxis 
            for mark in [@xAxis..(@xAxis + (@width * direction))] by (increment * direction)
                gridString += "M#{mark},#{@yAxis + 10}"
                gridString += "L#{mark},#{@yAxis - 10}"
                if 0 <= mark <= @width
                    value = Math.round(@grid.xMin + (mark / @xUnit))
                    offset = if value < 0 then 8 else -8
                    text = @paper.text(mark + offset, @yAxis - 6, value)
                    text.attr(stroke: 'none', fill: color)
                    lastMark = mark

            label = @paper.text(lastMark - (24 * direction), @yAxis + 7, 'X Axis')
            label.attr(stroke: 'none', fill: color)

        yUnits = @height / @yUnit
        yUnits = @maxUnits if yUnits < @maxUnits
        multiple = Math.floor(yUnits / @maxUnits)
        increment = (@yUnit * multiple)
        for direction in [-1,1]
            lastMark = @yAxis
            for mark in [@yAxis..(@yAxis + (@height * direction))] by (increment * direction)
                gridString += "M#{@xAxis + 10},#{mark}"
                gridString += "L#{@xAxis - 10},#{mark}"
                if 0 <= mark <= @height
                    value = Math.round(@grid.yMax - (mark / @yUnit))
                    offset = if value > 0 then 6 else -6
                    text = @paper.text(@xAxis - 8, mark + offset, value)
                    text.attr(stroke: 'none', fill: color)
                    lastMark = mark

            label = @paper.text(@xAxis + 7, lastMark - (24 * direction), 'Y Axis')
            label.attr(stroke: 'none', fill: color, transform: 'r270')

        grid = @paper.path(gridString)
        grid.attr(stroke: color)
        
    fadePlots: ->
        clearTimeout(@fadePlotsTimeout) if @fadePlotsTimeout
        clearTimeout(@showPlotsTimeout) if @showPlotsTimeout
        alpha = 1
        fade = =>
            alpha -= 0.25
            for id, formula of @formulas when formula.plotArea
                opacity = parseFloat(formula.plotArea.canvas.style.opacity or 1)
                formula.plotArea.canvas.style.opacity = alpha if opacity > alpha
                    
            @fadePlotsTimeout = $.timeout 100, => fade() if alpha > 0
            
        fade()
        
    showPlots: ->
        return false if @hidePlots
        clearTimeout(@fadePlotsTimeout) if @fadePlotsTimeout
        clearTimeout(@showPlotsTimeout) if @showPlotsTimeout

        alpha = 0
        fadeIn = =>
            alpha += 0.25
            for id, formula of @formulas when formula.plotArea
                opacity = parseFloat(formula.plotArea.canvas.style.opacity or 0)
                formula.plotArea.canvas.style.opacity = alpha if opacity < alpha
                    
            @showPlotsTimeout = $.timeout 100, => fadeIn() if alpha < 1
            
        fadeIn()
        
    plot: (id, formula, area) ->
        @showPlots()
        @cancelCalculation()
        if (plotArea = @formulas[id]?.plotArea)
            plotArea.clearRect(0,0,@width,@height)

        return if not formula
        
        plotArea = @createCanvas(2) if not plotArea        
        plotArea.canvas.style.opacity = if @hidePlots then 0 else 1
            
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
                plotArea.lineTo(xPos + @xAxis, @height) 
                yPos = @grid.yMin * @yUnit
                brokenLine += 1
            else if yPos == Number.POSITIVE_INFINITY
                plotArea.lineTo(xPos + @xAxis, 0) 
                yPos = @grid.yMax * @yUnit
                brokenLine += 1            

            if lastYPos
                slope = yPos - lastYPos
                if lastSlope and ((lastSlope > 0 and slope < 0) or (lastSlope < 0 and slope > 0))
                    for i in [-1..0] by 0.001
                        testYPos = formula((xPos+i) / @xUnit) * @yUnit
                        if (yPos > @height and testYPos < 0) or (yPos < 0 and testYPos > @height)
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
        @cancelCalculation()
        @calculatedPathTimeout = $.timeout(250, => @calculatedPath = @calculatePath())
            
    cancelCalculation: ->
        clearTimeout(@calculatedPathTimeout) if @calculatedPathTimeout
        @stopCalculation =  true
        
    calculationCancelled: ->
        if @stopCalculation
            @path = null
            @calculatedPath = null
            return true
        return false
        
    calculatePath: ->
        @stopCalculation = false
        significantDigits = 1
        intersection = (@islandCoordinates.x * @xUnit) + (@xUnit * 0.001)
        path = {distance: 0}
        path[0] = 
            x: @islandCoordinates.x * @xUnit
            y: @islandCoordinates.y * @yUnit
        rings = @rings.sort((a,b) -> a.x - b.x)    
        
        addToPath = (x, y, formula) =>
            return if @calculationCancelled()
            return unless @grid.yMin - 50 <= (y / @yUnit) <= @grid.yMax + 50
            formattedFullDistance = Math.ceil(path.distance * Math.pow(10, significantDigits))
            prevPos = path[formattedFullDistance]
            return if prevPos.x == x and prevPos.y == y
            
            if ((y/@yUnit) < @grid.yMin) or ((y/@yUnit) > @grid.yMax)
                distance = 1
            else
                distance = Math.sqrt(Math.pow(prevPos.y - y, 2) + Math.pow(prevPos.x - x, 2))
            
            formattedDistance = Math.ceil(distance * Math.pow(10, significantDigits))
            for d in [1..formattedDistance]
                return if @calculationCancelled()
                incrementalX = prevPos.x + (d*((x - prevPos.x)/formattedDistance))
                path[formattedFullDistance + d] = 
                    formula: formula.id
                    x: incrementalX
                    y: formula.formula(incrementalX / @xUnit) * @yUnit
            
                for ring in rings when ring.inPath(incrementalX/@xUnit, formula.formula)
                    return if @calculationCancelled()
                    path[formattedFullDistance + d].ring = ring
                    
            path.distance += distance
            
        for xPos in [(@islandCoordinates.x * @xUnit)..((@grid.xMax * 1.1) * @xUnit)] by 1
            return if @calculationCancelled()
                
            if lastFormula 
                if lastFormula.area(xPos / @xUnit)
                    yPos = lastFormula.formula(xPos / @xUnit) * @yUnit
                    for id of @formulas when id != lastFormula.id
                        return if @calculationCancelled()
                        
                        continue if not @formulas[id].area(xPos / @xUnit)
                        otherYPos = @formulas[id].formula(xPos / @xUnit) * @yUnit
                        prevYPos = lastFormula.formula((xPos - 1) / @xUnit) * @yUnit
                        otherPrevYPos = @formulas[id].formula((xPos - 1) / @xUnit) * @yUnit

                        if (yPos - otherYPos <= 0 and prevYPos - otherPrevYPos > 0) or
                           (yPos - otherYPos >= 0 and prevYPos - otherPrevYPos < 0)
                            yPos = otherYPos
                            lastFormula = @formulas[id]
                            break

                        findIntersection = (y1, y2, y3, f1, f2) =>
                            return if @calculationCancelled()
                            nextSlope = (y1 - y2)
                            slope = (y2 - y3)                    
                            directionChange = (nextSlope * slope < 0) or (nextSlope * slope == 0 and (nextSlope or slope))
                            return false unless directionChange
                            multiplier = Math.pow(10, significantDigits)
                            unit = 1/multiplier/@xUnit
                            for i in [1..2] by unit
                                return if @calculationCancelled()
                                formula1Y = Math.round(f1.formula((xPos + i) / @xUnit) * multiplier) 
                                formula2Y = Math.round(f2.formula((xPos + i) / @xUnit) * multiplier)
                                return i if formula1Y == formula2Y
                                
                        nextYPos = lastFormula.formula((xPos + 1) / @xUnit) * @yUnit
                        otherNextYPos = @formulas[id].formula((xPos + 1) / @xUnit) * @yUnit                        
                        if (delta = findIntersection(nextYPos, yPos, prevYPos, lastFormula, @formulas[id])) or
                           (delta = findIntersection(otherNextYPos, otherYPos, otherPrevYPos, lastFormula, @formulas[id]))
                            yPos = lastFormula.formula(xPos + delta)
                            lastFormula = @formulas[id]
                            break
                                               
                    addToPath(xPos, yPos, lastFormula)
                    continue
                else
                    intersection = xPos - 1
                    lf = lastFormula
                    lastFormula = null
                    while lf.area(intersection / @xUnit)
                        return if @calculationCancelled()
                        intersectionY = lf.formula(intersection / @xUnit) * @yUnit
                        addToPath(intersection, intersectionY, lf)
                        intersection += (@xUnit * 0.001)
                
            intersection -= (@xUnit * 0.001) if intersection
            
            validPathFound = false
            for id of @formulas
                return if @calculationCancelled()
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
            
            return if @calculationCancelled()
            return path unless validPathFound
            
        return if @calculationCancelled()
        return path
    
    clear: ->
        if @paper
            @paper.remove()
            delete @paper
        @el.find('canvas').remove()
        delete @animationCtx
        delete @gridSet
