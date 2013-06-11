xyflyer = exports ? provide('./lib/xyflyer', {})

for name, fn of require('./xyflyer_objects/index')
    xyflyer[name] = fn
    
class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    
    constructor: ({@el, @equationArea, boardElement, objects, @grid, @islandCoordinates, hidePlots, flip, @nextLevel, @registerEvent}) ->
        @rings = []

        @setFlip(flip)
        
        @board = new xyflyer.Board
            el: boardElement 
            grid: @grid 
            objects: objects
            islandCoordinates: @islandCoordinates
            hidePlots: hidePlots
            resetLevel: => @resetLevel()
        
        # @calculateIslandDistance()

        @plane = new xyflyer.Plane
            board: @board
            objects: objects
            track: (info) => @trackPlane(info)

        @initGuidelines(hidePlots, true)
       
        @parser = require('./parser')
        @initEquations()
        
    reinitialize: ({@equationArea, boardElement, objects, @grid, @islandCoordinates, hidePlots, flip}) ->
        @rings = []
        @setFlip(flip)
        
        showHidePlotsMessage = hidePlots and not @board.hidePlots
        
        @board.init
            el: boardElement 
            grid: @grid 
            objects: objects
            islandCoordinates: @islandCoordinates
            hidePlots: hidePlots

        # @calculateIslandDistance()

        @complete = false
        @plane.setBoard(@board)
        
        @initGuidelines(hidePlots, showHidePlotsMessage)
        @initEquations()
        @resetLevel()
            
    $: (selector) -> $(selector, @el)

    setFlip: (direction) ->
        return if not direction
        @el.removeClass('left')
        @el.removeClass('right')
        @el.addClass(direction)
            
    plot: (id, data) ->
        @plane.fadeClouds()
        [formula, area] = @parser.parse(data)
        return false unless @board.plot(id, formula, area)
        @moveLaunch()
        return true

    # calculateIslandDistance: ->
    #     if not Object.keys(@board.formulas).length
    #         $.timeout 100, => @calculateIslandDistance() 
    #         return
    #         
    #     @islandDistance = @calculateDistance
    #         from: {x: 0, y: 0}
    #         to: @board.islandCoordinates
    #         formula: (f.formula for id, f of @board.formulas)[0]
    #     
    # calculateDistance: ({from, to, formula}) ->
    #     distance = 0
    #     delta = if from.x > to.x then -1 else 1
    #     for i in [from.x..to.x] by delta
    #         distance += Math.sqrt(Math.pow(formula(i + delta) - formula(i), 2) + Math.pow(delta, 2))
    #     return distance

    moveLaunch: ->  
        # if not @islandDistance
        #     $.timeout 100, => @moveLaunch()
        #     return
        #     
        # distance = 0
        # delta = if @board.islandCoordinates.x < 0 then -1 else 1
        # toX = 0
        # formula = (f.formula for id, f of @board.formulas)[0]
        # while distance < @islandDistance
        #     toX += delta
        #     distance += Math.sqrt(Math.pow(formula(toX) - formula(toX - delta), 2) + Math.pow(delta, 2))
        # 
        # islandX = @board.screenX(toX)
        # islandY = @board.screenY(formula(toX))

        islandX = @board.screenX(@board.islandCoordinates.x)
        islandY = @board.screenY((f.formula(@board.islandCoordinates.x) for id, f of @board.formulas)[0])
        @board.moveIsland(islandX, islandY)
        @plane.move(islandX, islandY)
        
    trackPlane: ({x, y, width, height}) ->
        allPassedThrough = @rings.length > 0
        for ring in @rings
            allPassedThrough = false unless ring.passedThrough
        @completeLevel() if allPassedThrough
        
    addRing: (x,y) ->
        @rings.push(
            new xyflyer.Ring
                board: @board
                x: x
                y: y
        )
        
    initGuidelines: (hidePlots, showHidePlotsMessage) ->
        showGuidelines = @el.find('.show_guidelines')
        showGuidelines.unbind('click.guidelines touchstart.guidelines')
        showGuidelines.bind 'click.guidelines touchstart.guidelines', => 
            hidePlots = showGuidelines.hasClass('on')
            showGuidelines.removeClass(if hidePlots then 'on' else 'off')
            showGuidelines.addClass(if hidePlots then 'off' else 'on')
            @board.setHidePlots(hidePlots)
            
        if hidePlots
            showGuidelines.trigger('click.guidelines')
            
            if showHidePlotsMessage
                areaOffset = @$('.equations').offset()
                gameAreaOffset = @el.offset()       
                messageOffset = @equationArea.find('.guidelines').offset()
            
                message = @$('.guidelines_popup')
                message.css
                    opacity: 0
                    top: messageOffset.top - message.height() - gameAreaOffset.top - 6
                    left: messageOffset.left + (messageOffset.width/2) - (message.width()/2) - areaOffset.left
                message.html '''
                    The graph lines are hidden for this level.<br/>
                    Try solving the level without them.<br/>
                    You can turn them back on if you need them.
                '''
            
                message.animate
                    opacity: 1
                    duration: 250
                $(document.body).one 'mousedown.guidelines touchstart.guidelines', ->
                    message.animate
                        opacity: 0
                        duration: 250
                        complete: ->
                            message.css
                                top: -1000
                                left: -1000
        
    
    initEquations: ->
        @equations = new xyflyer.Equations
            el: @equationArea
            gameArea: @el
            plot: (id, data) => @plot(id, data)
            submit: => @plane.launch(true) 
            registerEvent: @registerEvent

    addEquation: (solution, startingFragment, solutionComponents, variables) ->
        @equations.add(solution, startingFragment, solutionComponents, variables)

    addEquationComponent: (equationFragment, side) ->
        @equations.addComponent(equationFragment, side)
        
    resetLevel: ->
        @complete = false
        @plane.reset() if @plane
        ring.reset() for ring in @rings
    
    completeLevel: ->
        return if @complete
        @complete = true
        @nextLevel()
        
