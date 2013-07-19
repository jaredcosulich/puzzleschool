###
RESOURCES

https://www.circuitlab.com

https://www.youtube.com/watch?v=a6YyEeqFFDA&feature=youtube_gdata_player&noredirect=1

http://phet.colorado.edu/en/simulation/circuit-construction-kit-dc

https://www.khanacademy.org/science/physics/electricity-and-magnetism/v/circuits--part-1

http://en.wikipedia.org/wiki/Electrical_circuit

###

soma = require('soma')
wings = require('wings')

soma.chunks
    Circuitous:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/circuitous.html"

            @loadScript '/build/common/pages/puzzles/lib/common_objects/animation.js'
            @loadScript '/build/common/pages/puzzles/lib/common_objects/client.js'
            @loadScript '/build/common/pages/puzzles/lib/common_objects/transformer.js'
            @loadScript '/build/common/pages/puzzles/lib/common_objects/draggable.js'

            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/object.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/selector.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/battery.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/resistor.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/toggle_switch.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/lightbulb.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/board.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/options.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/menu.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/index.js'

            @loadScript '/build/common/pages/puzzles/lib/circuitous_editor.js' if @levelId == 'editor'
            @loadScript '/build/common/pages/puzzles/lib/circuitous.js'
            
            @loadStylesheet '/build/client/css/puzzles/circuitous.css'     
            
                      
        build: ->
            @setTitle("Circuitous - The Puzzle School")
            @loadElement("link", {rel: 'img_src', href: 'http://www.puzzleschool.com/assets/images/reviews/xyflyer.jpg'})
            
            @setMeta('og:title', 'Circuitous - The Puzzle School')            
            @setMeta('og:url', 'http://www.puzzleschool.com/puzzles/circuitous')
            @setMeta('og:image', 'http://www.puzzleschool.com/assets/images/reviews/circuitous.jpg')
            @setMeta('og:site_name', 'The Puzzle School')
            @setMeta('og:description', 'Explore circuits through simple challenges you can solve in creative ways.')
            @setMeta('description', 'Explore circuits through simple challenges you can solve in creative ways.')
            
            @html = wings.renderTemplate(@template,
                level_id: @levelId
            )
            
        
soma.views
    Circuitous:
        selector: '#content .circuitous'
        create: ->
            circuitous = require('./lib/circuitous')
            @viewHelper = new circuitous.ViewHelper
                el: $(@selector)
               
            @levelId = @el.data('level_id')                  
            
            if @levelId == 'editor'
                circuitousEditor = require('./lib/circuitous_editor')
                @editor = new circuitousEditor.EditorHelper
                    el: $(@selector)

            
soma.routes
    '/puzzles/circuitous/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Circuitous
            classId: classId
            levelId: levelId

    '/puzzles/circuitous/:levelId': ({levelId}) -> 
        new soma.chunks.Circuitous
            levelId: levelId
    
    '/puzzles/circuitous': -> new soma.chunks.Circuitous

