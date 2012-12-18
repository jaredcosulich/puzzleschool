soma = require('soma')
wings = require('wings')


soma.chunks
    Xyflyer:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/xyflyer.html"
            
            @loadScript '/assets/third_party/equation_explorer/tokens.js'
            @loadScript '/assets/third_party/raphael-min.js'
            
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/tdop.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/parser.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/object.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/board.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/plane.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/ring.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/equation.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/equation_component.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/equations.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/index.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer.js'
            
            @objects = []
            for object in ['island', 'plane']
                @objects.push(
                    name: object
                    image: @loadImage("/assets/images/puzzles/xyflyer/#{object}.png")
                )
            
            if @levelId == 'editor'
                @loadScript '/build/common/pages/puzzles/lib/xyflyer_editor.js' 
            @loadStylesheet '/build/client/css/puzzles/xyflyer.css'     
            
                      
        build: ->
            @setTitle("XYFlyer - The Puzzle School")
            
            @html = wings.renderTemplate(@template, objects: @objects)
            
        
soma.views
    Xyflyer:
        selector: '#content .xyflyer'
        create: ->
            xyflyer = require('./lib/xyflyer')
            @viewHelper = new xyflyer.ViewHelper
                el: $(@selector)
                boardElement: @$('.board')
                objects: @$('.objects')
                equationArea: @$('.equation_area')
                grid:
                    xMin: -10
                    xMax: 10
                    yMin: -10
                    yMax: 10
            
            @viewHelper.addEquation()
            
            @viewHelper.addRing(3, 3)
            @viewHelper.addRing(5, 2)
            
            @viewHelper.addEquationComponent('+3')
            @viewHelper.addEquationComponent('sin(x)')

            
soma.routes
    '/puzzles/xyflyer/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Xyflyer
            classId: classId
            levelId: levelId

    '/puzzles/xyflyer/:levelId': ({levelId}) -> 
        new soma.chunks.Xyflyer
            levelId: levelId
    
    '/puzzles/xyflyer': -> new soma.chunks.Xyflyer

