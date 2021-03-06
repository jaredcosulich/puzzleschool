object = exports ? provide('./object', {})
Draggable = require('../common_objects/draggable').Draggable

class object.Object extends Draggable
    baseFolder: '/assets/images/puzzles/circuitous/'
    circuitPaths: {}
    constructor: -> 
        
    image: ->
        filename = @constructor.name.replace(/(.)([A-Z])/g, '$1_$2').toLowerCase()
        "#{@baseFolder}#{filename}.png"
        
    imageElement: -> "<div class='component'><img src='#{@image()}' /></div>"
        
    appendTo: (container) -> 
        container.append(@imageElement())
        @el = container.find('.component').last()
        @el.bind 'dragstart', (e) => e.preventDefault()

    generateId: (namespace) -> "#{(if n = namespace then n else '')}#{new Date().getTime()}#{Math.random()}"

    positionAt: ({x, y}) ->
        @dragTo
            x: x + (@centerOffset?.x or 0) + (@offset or 0)
            y: y + (@centerOffset?.y or 0) + (@offset or 0)
        
    currentNodes: (type) ->
        for node in (@nodes or [])
            continue if type and not node[type]
            info = JSON.parse(JSON.stringify(node))
            info.x = @currentX + node.x - (@offset or 0)
            info.y = @currentY + node.y - (@offset or 0)
            info
    
    initCurrent: ->
        
    setCurrent: (@current) -> 
        @tag?.setInfo
            name: @name
            voltage: @voltage
            current: @current or 0
            resistance: @resistance or 0
            
    initTag: (show=false) -> @tag = new Tag(object: @, show: show)
     
    setName: (@name) ->    
        
    setResistance: (@resistance) -> @recordChange() if @recordChange
        
    setVoltage: (@voltage) -> @recordChange() if @recordChange
        
        
        
    
        