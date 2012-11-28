soma = require('soma')
wings = require('wings')


soma.chunks
    Xyflyer:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/xyflyer.html"
            @loadScript '/build/common/pages/puzzles/lib/xyflyer.js'
            @loadScript '/build/common/pages/puzzles/lib/tdop.js'
            @loadScript '/assets/third_party/equation_explorer/tokens.js'
            # @loadScript '/assets/third_party/equation_explorer/tdop_math.js'
            # @loadScript '/assets/third_party/equation_explorer/graph.js'
            # @loadScript '/assets/third_party/equation_explorer/ui.js'
            if @levelId == 'editor'
                @loadScript '/build/common/pages/puzzles/lib/xyflyer_editor.js' 
            @loadStylesheet '/build/client/css/puzzles/xyflyer.css'     
            
                      
        build: ->
            @setTitle("XYFlyer - The Puzzle School")
            
            @html = wings.renderTemplate(@template)
            
        
soma.views
    Xyflyer:
        selector: '#content .xyflyer'
        create: ->
            xyflyer = require('./lib/xyflyer')
            @viewHelper = new xyflyer.ViewHelper
                el: $(@selector)
                canvas: @$('.canvas')
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
                
            @tdop = require('./lib/tdop')
            
            @initEquations()

                
        initEquations: ->
            @$('.equation').bind 'keyup', (e) =>
                try
                    @formula = @tdop.compileToJs($(e.currentTarget).val())                
                catch err

                @viewHelper.plot(@formula, 1)


soma.routes
    '/puzzles/xyflyer/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Xyflyer
            classId: classId
            levelId: levelId

    '/puzzles/xyflyer/:levelId': ({levelId}) -> 
        new soma.chunks.Xyflyer
            levelId: levelId
    
    '/puzzles/xyflyer': -> new soma.chunks.Xyflyer

