object = exports ? provide('./object', {})
Draggable = require('../common_objects/draggable').Draggable

class object.Object extends Draggable
    baseFolder: '/assets/images/puzzles/circuitous/'
    circuitPaths: {}
    constructor: -> 
        
    image: ->
        filename = @constructor.name.replace(/(.)([A-Z])/g, '$1_$2').toLowerCase()
        "#{@baseFolder}#{filename}.png"
        
    imageElement: -> "<img src='#{@image()}' />"
        
    appendTo: (container) -> 
        container.append(@imageElement())
        @el = container.find("img[src=\'#{@image()}\']")

    positionAt: ({x, y}) ->
        @dragTo
            x: x + (@centerOffset?.x or 0)
            y: y + (@centerOffset?.y or 0)
        
    currentNodes: ->
        {x: @currentX + node.x, y: @currentY + node.y} for node in (@nodes or [])
            
    setComingFrom: (circuitId, component) ->
        @circuitPaths[circuitId] = component
        
    comingFrom: (circuitId) -> @circuitPaths[circuitId]
    
    setCurrent: (@current) -> 
        
        