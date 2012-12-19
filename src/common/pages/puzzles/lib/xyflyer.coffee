xyflyer = exports ? provide('./lib/xyflyer', {})

for name, fn of require('./xyflyer_objects/index')
    xyflyer[name] = fn
    
class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    
    constructor: ({@el, @equationArea, boardElement, objects, grid}) ->
        @rings = []
        @board = new xyflyer.Board
            boardElement: boardElement, 
            grid: grid, 
            objects: objects
    
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
        ring.highlightIfPassingThrough(info) for ring in @rings
            
        
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
        
    