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
            
            @html = wings.renderTemplate(@template, 
                objects: @objects
                level: @levelId
            )
            
        
soma.views
    Xyflyer:
        selector: '#content .xyflyer'
        create: ->
            xyflyer = require('./lib/xyflyer')
            
            @level = @el.data('level')
            if isNaN(parseInt(@level))
                @showMessage('intro')
                return
                
            @data = LEVELS[@level]
            
            if not @data
                @showMessage('exit')
                return
        
            @viewHelper = new xyflyer.ViewHelper
                el: $(@selector)
                boardElement: @$('.board')
                objects: @$('.objects')
                equationArea: @$('.equation_area')
                grid: @data.grid
                islandCoordinates: @data.islandCoordinates
                nextLevel: => @nextLevel()
            
            for equation of @data.equations
                @viewHelper.addEquation(equation, @data.equations[equation].start, @data.variables)    
        
            for ring in @data.rings
                @viewHelper.addRing(ring.x, ring.y)
            
            if @data.fragments
                for fragment in @data.fragments
                    @viewHelper.addEquationComponent(fragment)
            else
                @$('.possible_fragments').hide()
                
                
        centerAndShow: (element, board) ->
            offset = element.offset()
            boardOffset = @$('.board').offset()
            areaOffset = @el.offset()
            
            element.css
                opacity: 0
                top: (boardOffset.top - areaOffset.top) + (boardOffset.height/2) - (offset.height/2)
                left: (boardOffset.left - areaOffset.left) + (boardOffset.width/2) - (offset.width/2)
                
            element.animate
                opacity: 0.9
                duration: 500              
            
        showMessage: (type) ->
            equationArea = @$('.equation_area')
            equationArea.html(@$(".#{type}_message").html())
            equationArea.css(padding: '0 12px', textAlign: 'center')
            equationArea.find('button').bind 'click', =>
                @go('/puzzles/xyflyer/1') 
        
        nextLevel: ->
            complete = @$('.complete')
            @centerAndShow(complete)
            
            complete.find('button').bind 'click', =>
                @go("/puzzles/xyflyer/#{@level + 1}")
                
            @$('.launch').html('Success! Go To The Next Level >')
            @$('.launch').bind 'click', =>
                @go("/puzzles/xyflyer/#{@level + 1}")
                
            
soma.routes
    '/puzzles/xyflyer/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Xyflyer
            classId: classId
            levelId: levelId

    '/puzzles/xyflyer/:levelId': ({levelId}) -> 
        new soma.chunks.Xyflyer
            levelId: levelId
    
    '/puzzles/xyflyer': -> new soma.chunks.Xyflyer

LEVELS = [
    {}
    {
        equations: {
            '2x': {}
        }
        grid:
            xMin: -10
            xMax: 10
            yMin: -10
            yMax: 10
        rings: [
            {x: 1, y: 2}
            {x: 3, y: 6}
        ]
        fragments: [
            '2x'
        ]
    }
    {
        equations: {
            '(1/4)x': {}
        }
        grid:
            xMin: -10
            xMax: 10
            yMin: -10
            yMax: 10
        rings: [
            {x: 2, y: 0.5}
            {x: 4, y: 1}
            {x: 6, y: 1.5}
        ]
        fragments: [
            '4x', '(1/4)x'
        ]
    }
    {
        equations: {
            'x/2': {start: 'x'}
        }
        grid:
            xMin: -10
            xMax: 40
            yMin: -10
            yMax: 40
        rings: [
            {x: 12, y: 6}
            {x: 20, y: 10}
            {x: 31, y: 15.5}
        ]
        fragments: [
            '*3', '*.25', '/2', '/5'
        ]
    }    
    {
        equations: {
            'ax + 3': {start: 'ax + 3'}
        }
        grid:
            xMin: -10
            xMax: 30
            yMin: -10
            yMax: 30
        rings: [
            {x: 2, y: 8}
            {x: 6, y: 18}
            {x: 10, y: 28}
        ]
        islandCoordinates: {x: 0, y: 3}
        variables:
            a:
                start: 0
                min: -10
                max: 10
                increment: 0.5
                solution: 2.5
                
    }    
    {
        equationCount: 1
        grid:
            xMin: -10
            xMax: 30
            yMin: -10
            yMax: 30
        rings: [
            {x: 7.852, y: 4}
            {x: 13.087, y: 6}
            {x: 18.324, y: 4}
        ]
        islandCoordinates: {x: 0, y: 5}
        fragments: [
            'sin(ax)', '+b', '+3.14'
        ]
        variables:
            a:
                start: 1
                min: -10
                max: 10
                increment: 0.2
            b:
                start: 2
                min: -10
                max: 10
                increment: 1
                
    }    
    {
        equations: {
            '-1*x+18': {start: 'x'}
        }
        grid:
            xMin: -10
            xMax: 20
            yMin: -10
            yMax: 20
        rings: [
            {x: 10, y: 8}
            {x: 15, y: 3}
        ]
        islandCoordinates: {x: 4, y: 14}
        fragments: [
            '-1*', '-6', '-12', '-18', '+6', '+12', '+18'
        ]
    }    
    # {
    #     equationCount: 1
    #     grid:
    #         xMin: -10
    #         xMax: 40
    #         yMin: -10
    #         yMax: 40
    #     rings: [
    #         {x: 12, y: 6}
    #         {x: 20, y: 10}
    #         {x: 31, y: 15.5}
    #     ]
    #     islandCoordinates: {x: 10, y: 20}
    #     fragments: [
    #         '-((0.25(x-10))^2)+25'
    #     ]
    # }    
    # {
    #     equationCount: 1
    #     grid:
    #         xMin: -10
    #         xMax: 20
    #         yMin: -10
    #         yMax: 60
    #     rings: [
    #         {x: 3, y: 19.5}
    #         {x: 5, y: 32.5}
    #         {x: 9, y: 58.5}
    #     ]
    #     fragments: [
    #         'ax'
    #     ]
    # }    
    {
        equationCount: 1
        grid:
            xMin: -10
            xMax: 20
            yMin: -10
            yMax: 60
        rings: [
            {x: 3, y: 19.5}
            {x: 5, y: 32.5}
            {x: 9, y: 58.5}
        ]
        startingFragments: ['x']
        fragments: [
            '*2', '*2.5', '*3', '*3.5', '*4', '*4.5', '*5', '*5.5', '*6', '*6.5', '*7', '*7.5', '*8', '*8.5', '*9', '*9.5', '*10'
        ]
    }    
    {
        equationCount: 1
        grid:
            xMin: -10
            xMax: 30
            yMin: -10
            yMax: 30
        rings: [
            {x: 19.25, y: 5.5}
            {x: 14, y: 4}
            {x: 7, y: 2}
        ]
        fragments: [
            'x', '*2', '*2.5', '*3', '*3.5', '*4', '*4.5', '*5', '*5.5', '/2', '/2.5', '/3', '/3.5', '/4', '/4.5', '/5', '/5.5'
        ]
    }    
    {
        equationCount: 1
        grid:
            xMin: -10
            xMax: 40
            yMin: -10
            yMax: 40
        rings: [
            {x: 4, y: 10}
            {x: 8, y: 20}
            {x: 12, y: 30}
        ]
        fragments: [
            'x', '*5', '*3', '/2', '/8'
        ]
    }    
    {
        equationCount: 2
        grid:
            xMin: -10
            xMax: 10
            yMin: -10
            yMax: 10
        rings: [
            {x: .5, y: 1}
            {x: 6, y: 5}
        ]
        fragments: [
            '2x', '.5x', '+2'
        ]
    }    
    {
        equationCount: 2
        grid:
            xMin: -10
            xMax: 10
            yMin: -10
            yMax: 10
        rings: [
            {x: 4, y: 3.41}
            {x: 6.667, y: -2}
        ]
        fragments: [
            'ln(x)', '-3(x)', '+0.14', '+2', '-4', '+6'
        ]
    }
]
    