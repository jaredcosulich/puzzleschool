soma = require('soma')
wings = require('wings')


soma.chunks
    Neurobehav:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/neurobehav.html"
            @loadScript '/build/common/pages/puzzles/lib/neurobehav_objects/game.js'
            @loadScript '/build/common/pages/puzzles/lib/neurobehav_objects/object.js'
            @loadScript '/build/common/pages/puzzles/lib/neurobehav_objects/neuron.js'
            @loadScript '/build/common/pages/puzzles/lib/neurobehav_objects/stimulus.js'
            @loadScript '/build/common/pages/puzzles/lib/neurobehav_objects/oscilloscope.js'
            @loadScript '/build/common/pages/puzzles/lib/neurobehav_objects/index.js'
            @loadScript '/build/common/pages/puzzles/lib/neurobehav.js'
            @loadScript '/assets/third_party/raphael-min.js'
            if @levelId == 'editor'
                @loadScript '/build/common/pages/puzzles/lib/neurobehav.js' 
            @loadStylesheet '/build/client/css/puzzles/neurobehav.css'     
            
        build: ->
            @setTitle("The Neurobiology of Behavior - The Puzzle School")
            
            @html = wings.renderTemplate @template,
                editor: false
        
soma.views
    Neurobehav:
        selector: '#content .neurobehav'
        create: ->
            neurobehav = require('./lib/neurobehav')
            @game = new neurobehav.Game
                el: $(@selector)
                
soma.routes
    '/puzzles/neurobehav/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Neurobehav
            classId: classId
            levelId: levelId

    '/puzzles/neurobehav/:levelId': ({levelId}) -> 
        new soma.chunks.Neurobehav
            levelId: levelId
    
    '/puzzles/neurobehav': -> new soma.chunks.Neurobehav
