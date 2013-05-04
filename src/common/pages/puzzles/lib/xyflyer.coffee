xyflyer = exports ? provide('./lib/xyflyer', {})

for name, fn of require('./xyflyer_objects/index')
    xyflyer[name] = fn
    
class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    
    constructor: ({@el, @equationArea, boardElement, objects, @grid, @islandCoordinates, flip, @nextLevel, @registerEvent}) ->
        @rings = []

        @setFlip(flip)
        
        @board = new xyflyer.Board
            el: boardElement 
            grid: @grid 
            objects: objects
            islandCoordinates: @islandCoordinates
            resetLevel: => @resetLevel()

        @plane = new xyflyer.Plane
            board: @board
            objects: objects
            track: (info) => @trackPlane(info)
       
        @parser = require('./parser')
        @initEquations()
        
    reinitialize: ({@equationArea, boardElement, objects, @grid, @islandCoordinates, flip}) ->
        @rings = []
        @setFlip(flip)
        @board.init
            el: boardElement 
            grid: @grid 
            objects: objects
            islandCoordinates: @islandCoordinates

        @complete = false
        @plane.setBoard(@board)
        @initEquations()
        @resetLevel()
            
    $: (selector) -> $(selector, @el)

    setFlip: (direction) ->
        return if not direction
        @el.removeClass('left')
        @el.removeClass('right')
        @el.addClass(direction)
            
    plot: (id, data) ->
        [formula, area] = @parser.parse(data)
        @board.plot(id, formula, area)
        
    trackPlane: ({x, y, width, height}) ->
        allPassedThrough = @rings.length > 0
        for ring in @rings
            ring.highlightIfPassingThrough(x: x, y: y, width: width, height: height) 
            allPassedThrough = false unless ring.passedThrough
        @completeLevel() if allPassedThrough
        
    addRing: (x,y) ->
        @rings.push(
            new xyflyer.Ring
                board: @board
                x: x
                y: y
        )
    
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
        
