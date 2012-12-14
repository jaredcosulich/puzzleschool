xyflyer = exports ? provide('./lib/xyflyer', {})

for name, fn of require('./xyflyer_objects/index')
    xyflyer[name] = fn
    
class xyflyer.ChunkHelper
    constructor: () ->
    

class xyflyer.ViewHelper
    
    constructor: ({@el, boardElement, objects, grid}) ->
        @board = new xyflyer.Board
            boardElement: boardElement, 
            grid: grid, 
            objects: objects
    
        @plane = new xyflyer.Plane
            board: @board
            
        @parser = require('./parser')
        
    $: (selector) -> $(selector, @el)
    
    plot: (id, data) ->
        [formula, area] = @parser.parse(data)
        @board.plot(id, formula, area)
        
    launchPlane: -> @plane.launch(true) 


    
    