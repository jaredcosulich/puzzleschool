xyflyer = exports ? provide('./lib/xyflyer', {})

for name, fn of require('./xyflyer_objects/index')
    xyflyer[name] = fn
    
class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    
    constructor: ({@el, @equationArea, boardElement, objects, grid, @nextLevel, center}) ->
        @rings = []
        @board = new xyflyer.Board
            boardElement: boardElement, 
            grid: grid, 
            objects: objects
            center: center
            resetLevel: => @resetLevel()
    
        @plane = new xyflyer.Plane
            board: @board
            track: (info) => @trackPlane(info)
            
        @parser = require('./parser')
        @initEquations()
        
    $: (selector) -> $(selector, @el)
    
    plot: (id, data) ->
        [formula, area] = @parser.parse(data)
        @board.plot(id, formula, area)
        
    trackPlane: (info) ->
        allPassedThrough = @rings.length > 0
        for ring in @rings
            ring.highlightIfPassingThrough(info) 
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

    addEquation: (equationFragment, equationAreas) ->
        @equations.add()

    addEquationComponent: (equationFragment, equationAreas) ->
        @equations.addComponent(equationFragment, equationAreas)
        
    resetLevel: ->
        @plane.reset()
        ring.reset() for ring in @rings
    
    completeLevel: ->
        return if @complete
        @complete = true
        @nextLevel()
