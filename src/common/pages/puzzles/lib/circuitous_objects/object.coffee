object = exports ? provide('./object', {})

class object.Object
    baseFolder: '/assets/images/puzzles/circuitous/'
    constructor: -> 
        
    image: ->
        filename = @constructor.name.replace(/(.)([A-Z])/g, '$1_$2').toLowerCase()
        "#{@baseFolder}#{filename}.png"
        
    imageElement: ->
        "<img src='#{@image()}' />"