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

        @plane = new xyflyer.Plane
            board: @board
            objects: objects
            track: (info) => @trackPlane(info)

        @initGuidelines(hidePlots)
       
        @parser = require('./parser')
        @initEquations()
        
    reinitialize: ({@equationArea, boardElement, objects, @grid, @islandCoordinates, hidePlots, flip}) ->
        @rings = []
        @setFlip(flip)
        @board.init
            el: boardElement 
            grid: @grid 
            objects: objects
            islandCoordinates: @islandCoordinates
            hidePlots: hidePlots

        @complete = false
        @plane.setBoard(@board)
        
        @initGuidelines(hidePlots)        
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

    moveLaunch: ->    
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
        
    initGuidelines: (hidePlots) ->
        showGuidelines = @el.find('.show_guidelines')
        showGuidelines.unbind('click')
        showGuidelines.bind 'click', => 
            hidePlots = showGuidelines.hasClass('on')
            showGuidelines.removeClass(if hidePlots then 'on' else 'off')
            showGuidelines.addClass(if hidePlots then 'off' else 'on')
            @board.setHidePlots(hidePlots)
            
        if hidePlots
            showGuidelines.trigger('click')
            
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
            $(document.body).one 'mousedown.variable touchstart.variable', ->
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
        
