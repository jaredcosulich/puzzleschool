xyflyer = exports ? provide('./lib/xyflyer', {})

for name, fn of require('./xyflyer_objects/index')
    xyflyer[name] = fn
    
class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    
    constructor: ({@el, @equationArea, boardElement, objects, grid}) ->
        @board = new xyflyer.Board
            boardElement: boardElement, 
            grid: grid, 
            objects: objects
    
        @plane = new xyflyer.Plane
            board: @board
            
        @parser = require('./parser')
        @initEquations()
        
    $: (selector) -> $(selector, @el)
    
    plot: (id, data) ->
        [formula, area] = @parser.parse(data)
        @board.plot(id, formula, area)
        
    addRing: (x,y) ->
        new xyflyer.Ring
            board: @board
            x: x
            y: y
    
    initEquations: ->
        @equations = new xyflyer.Equations
            area: @equationArea
            submit: => @plane.launch(true) 

    addEquationComponent: (equationFragment, equationAreas) ->
        @equations.addEquationComponent(equationFragment, equationAreas)
        
    