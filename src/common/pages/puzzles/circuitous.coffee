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
                @editor = new circuitousEditor.EditorHelper()
            
            $('.load_instructions .load button').bind 'click', =>
                instructions = $('.load_instructions .load textarea').val().replace(/\s/g, '')
                @loadInstructions(JSON.parse(instructions)) if instructions.length
            $('.load_instructions .load button').trigger('click')

            $('.load_instructions .get button').bind 'click', =>
                $('.load_instructions .get textarea').val(@getInstructions())

            $('.load_instructions .get_values button').bind 'click', =>
                $('.load_instructions .get_values textarea').val(@getValues())
                    
        loadInstructions: (instructions) ->
            getCoordinates = (position) =>
                [xCell, yCell] = position.split(',')
                cellDimension = @viewHelper.board.cellDimension
                [(parseInt(xCell) + 0.5) * cellDimension, (parseInt(yCell) + 0.5) * cellDimension]
            
            for positions in instructions.wires
                nodes = []
                for position in positions
                    [x,y] = getCoordinates(position) 
                    nodes.push(x: x, y: y)
                @viewHelper.board.wires.create(nodes...)
                
            for info in instructions.components
                do (info) =>
                    component = new circuitous[info.name]
                    @viewHelper.options.addComponent(component)
                    setTimeout(( =>
                        component.el.removeClass('in_options')
                        component.setStartDrag({}, true)
                        [x, y] = getCoordinates(info.position)
                        componentPosition = @viewHelper.board.componentPosition
                            x: x - component.nodes[0].x
                            y: y - component.nodes[0].y
                        @viewHelper.board.addComponent(component, componentPosition.x, componentPosition.y)                            
                    ), 50)                                    
                    
        getInstructions: ->
            instructions = []
            components = []
            
            cells = (node) =>
                cellDimension = @viewHelper.board.cellDimension
                [(node.x / cellDimension) - 0.5,  (node.y / cellDimension) - 0.5]
            
            for id, component of @viewHelper.board.components
                node = @viewHelper.board.boardPosition(component.currentNodes()[0])
                [xCell, yCell] = cells(node)
                components.push("{\"name\": \"#{component.constructor.name}\", \"position\": \"#{xCell},#{yCell}\"}")
            instructions.push("\"components\": [#{components.join(',')}]")    
            
            wires = []
            for id, wire of @viewHelper.board.wires.all()
                [xCell0, yCell0] = cells(wire.nodes[0])
                [xCell1, yCell1] = cells(wire.nodes[1])
                wires.push("[\"#{xCell0},#{yCell0}\",\"#{xCell1},#{yCell1}\"]")
            instructions.push("\"wires\": [#{wires.join(',')}]")
        
            "{#{instructions.join(',')}}"
            
        getValues: ->
            values = {}
            for id, component of @viewHelper.board.components
                values[id] = component.current
            
            return JSON.stringify(values)
                
soma.routes
    '/puzzles/circuitous/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Circuitous
            classId: classId
            levelId: levelId

    '/puzzles/circuitous/:levelId': ({levelId}) -> 
        new soma.chunks.Circuitous
            levelId: levelId
    
    '/puzzles/circuitous': -> new soma.chunks.Circuitous
    
    
    
    

