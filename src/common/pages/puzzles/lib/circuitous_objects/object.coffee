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
        @el.bind 'dragstart', (e) => e.preventDefault()

    generateId: (namespace) -> "#{(if n = namespace then n else '')}#{new Date().getTime()}#{Math.random()}"

    positionAt: ({x, y}) ->
        @dragTo
            x: x + (@centerOffset?.x or 0)
            y: y + (@centerOffset?.y or 0)
        
    currentNodes: (type) ->
        for node in (@nodes or [])
            continue if type and not node[type]
            info = JSON.parse(JSON.stringify(node))
            info.x = @currentX + node.x
            info.y = @currentY + node.y
            info
    
    setCurrent: (@current) ->
        
     
        
        
        