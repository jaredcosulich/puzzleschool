###
RESOURCES

https://www.circuitlab.com

https://www.youtube.com/watch?v=a6YyEeqFFDA&feature=youtube_gdata_player&noredirect=1

http://phet.colorado.edu/en/simulation/circuit-construction-kit-dc

https://www.khanacademy.org/science/physics/electricity-and-magnetism/v/circuits--part-1

http://en.wikipedia.org/wiki/Electrical_circuit

http://www.allaboutcircuits.com

https://6002x.mitx.mit.edu

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
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/analyzer.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/wires.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/selector.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/battery.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/resistor.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/toggle_switch.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/light_emitting_diode.js'
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
            
            window.loadInstructions = (instructions) => @loadInstructions(instructions)
            $('.load_instructions .load button').bind 'click', =>
                @loadInstructions(JSON.parse($('.load_instructions .load textarea').val()))

            window.getInstructions = => @getInstructions()
            $('.load_instructions .get button').bind 'click', =>
                $('.load_instructions .get textarea').val(@getInstructions())
                    
        loadInstructions: (instructions) ->
            @editor.board.wires.create(nodes...) for nodes in instructions.wires
            
            for info in instructions.components
                do (info) =>
                    component = new circuitous[info.name]
                    @editor.options.addComponent(component)
                    setTimeout(( =>
                        component.setStartDrag({}, true)
                        componentPosition = @editor.board.componentPosition(x: info.x, y: info.y)
                        @editor.board.addComponent(component, componentPosition.x, componentPosition.y)                            
                    ), 50)                                    
                    
        getInstructions: ->
            instructions = []
            components = []
            
            for id, component of @editor.board.components
                boardPosition = @editor.board.boardPosition(x: component.currentX, y: component.currentY) 
                components.push("{\"name\": \"#{component.constructor.name}\", \"x\": #{boardPosition.x}, \"y\": #{boardPosition.y}}")
            instructions.push("\"components\": [#{components.join(',')}]")    
            
            wires = []
            for id, wire of @editor.board.wires.all()
                wires.push("[{\"x\": #{wire.nodes[0].x}, \"y\": #{wire.nodes[0].y}}, {\"x\": #{wire.nodes[1].x}, \"y\": #{wire.nodes[1].y}}]")
            instructions.push("\"wires\": [#{wires.join(',')}]")
        
            "{#{instructions.join(',')}}"
soma.routes
    '/puzzles/circuitous/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Circuitous
            classId: classId
            levelId: levelId

    '/puzzles/circuitous/:levelId': ({levelId}) -> 
        new soma.chunks.Circuitous
            levelId: levelId
    
    '/puzzles/circuitous': -> new soma.chunks.Circuitous
    
    
    
    

