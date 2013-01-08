soma = require('soma')
wings = require('wings')

sortLevels = (levels) ->
    levels.sort (level1,level2) ->
        a = level1.difficulty + level1.id
        b = level2.difficulty + level2.id
        return if a == b then 0 else (if a < b then -1 else 1)

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
            
            if @classId
                @loadData 
                    url: "/api/classes/info/#{@classId}"
                    success: (data) =>
                        levels = sortLevels(data.levels)
                        @classLevelId = levels[@levelId - 1].id
                        
                        @loadData 
                            url: "/api/puzzles/levels/#{@classLevelId}"
                            success: (@levelInfo) => 
                            error: () =>
                                if window?.alert
                                    alert('We were unable to load the information for this level. Please check your internet connection.')
                    
                    error: () =>
                        if (@user = @cookies.get('user')) and window?.alert
                            alert('We were unable to load the information for this class. Please check your internet connection.')
                            
            # else
            #     @loadData 
            #         url: "/api/puzzles/levels/#{@levelId}"
            #         success: (@levelInfo) => 
            #         error: () =>
            #             if window?.alert
            #                 alert('We were unable to load the information for this level. Please check your internet connection.')
                        
            @objects = []
            for object in ['island']
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
                class: @classId or 0
                level: @levelId
                classLevel: @classLevelId or 0
                instructions: @levelInfo?.instructions
            )
            
        
soma.views
    Xyflyer:
        selector: '#content .xyflyer'
        create: ->
            xyflyer = require('./lib/xyflyer')
            
            @user = @cookies.get('user')
            
            @classId = @el.data('class')
            @levelId = @el.data('level')
            @classLevelId = @el.data('classlevel')
            
            if isNaN(parseInt(@levelId))
                @showMessage('intro')
                return
                
            if @classId
                if not @user
                    window?.location?.reload()                 
                    return
                    
                try
                    @data = eval("a=" + @$('.level_instructions').html().replace(/\s/g, ''))
                catch e
            else
                @data = LEVELS[@levelId]
                
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
                registerEvent: (eventInfo) => @registerEvent(eventInfo)
            
            for equation of @data.equations
                info = @data.equations[equation]
                @viewHelper.addEquation(equation, info.start, info.solutionComponents, @data.variables)    
        
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
            equationArea.find('.button').attr('href', '/puzzles/xyflyer/1') 
        
        nextLevel: ->
            @registerEvent
                type: 'success'
                info: 
                    time: new Date()
            
            complete = @$('.complete')
            @centerAndShow(complete)
            
            @$('.launch').html('Success! Go To The Next Level >')
            @$('.go').attr('href', "/puzzles/xyflyer/#{if @classId then "#{@classId}/" else ''}#{@levelId + 1}")
            
        registerEvent: ({type, info}) ->
            return unless @user and @user.id and (@classLevelId or @levelId) and @classId
            @pendingEvents or= []
            @pendingEvents.push
                type: type
                info: JSON.stringify(info)
                puzzle: 'xyflyer'
                classId: @classId
                levelId: (@classLevelId or @levelId)

            if not @lastEvent
                @timeBetweenEvents = 0
                @lastEvent = new Date()
            else    
                @timeBetweenEvents += new Date().getTime() - @lastEvent.getTime()
                @lastEvent = new Date()

            @sendEvents(type in ['success', 'challenge'])

        sendEvents: (force) ->
            unless force
                return unless @pendingEvents?.length 
                return if @sendingEvents > 0

            @sendingEvents += 2

            pendingEvents = (event for event in @pendingEvents)
            @pendingEvents = []

            timeBetweenEvents = @timeBetweenEvents
            @timeBetweenEvents = 0

            statUpdates = {
                user: {objectType: 'user', objectId: @user.id, actions: []}
                class: {objectType: 'class', objectId: @classId, actions: []}
                levelClass: {objectType: 'level_class', objectId: "#{(@classLevelId or @levelId)}/#{@classId}", actions: []}
                userLevelClass: {objectType: 'user_level_class', objectId: "#{@user.id}/#{(@classLevelId or @levelId)}/#{@classId}", actions: []}
            }
            statUpdates.user.actions.push(
                attribute: 'levelClasses'
                action: 'add'
                value: ["#{(@classLevelId or @levelId)}/#{@classId}"]
            )
            statUpdates.class.actions.push(
                attribute: 'users'
                action: 'add'
                value: [@user.id]
            )
            statUpdates.levelClass.actions.push(
                attribute: 'users'
                action: 'add'
                value: [@user.id]
            )
            statUpdates.userLevelClass.actions.push(
                attribute: 'duration'
                action: 'add'
                value: timeBetweenEvents
            )
            for event in pendingEvents
                if event.type == 'move'
                    statUpdates.userLevelClass.actions.push(
                        attribute: 'moves'
                        action: 'add'
                        value: 1
                    )
                if event.type == 'hint'
                    statUpdates.userLevelClass.actions.push(
                        attribute: 'hints'
                        action: 'add'
                        value: 1
                    )
                if event.type == 'success'
                    statUpdates.userLevelClass.actions.push(
                        attribute: 'success'
                        action: 'add'
                        value: [JSON.parse(event.info).time]
                    )
                if event.type == 'challenge'
                    statUpdates.userLevelClass.actions.push(
                        attribute: 'challenge'
                        action: 'add'
                        value: [JSON.parse(event.info).assessment]
                    )

            updates = (JSON.stringify(statUpdates[key]) for key of statUpdates)

            completeEventRecording = =>
                @sendingEvents -= 1
                @sendingEvents = 0 if @sendingEvents < 0
                @sendEvents()

            $.ajaj
                url: '/api/events/create'
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: {events: pendingEvents}
                success: () => completeEventRecording()

            $.ajaj
                url: '/api/stats/update'
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: {updates: updates}
                success: => completeEventRecording()
            
                
            
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
        equations: 
            '2x': {}
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
        equations: 
            '(1/4)x': {}
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
        equations: 
            'x/2': {start: 'x'}
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
            '*3', '*(1/4)', '*(1/2)', '*(1/5)'
        ]
    }    
    {
        equations: 
            '2.5x + 3': {start: 'ax + 3'}
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
        equations: 
            '-1*x+18': {start: 'x'}
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
        equations: 
            'x*6.5': {start: 'x'}
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
        fragments: [
            '*2', '*2.5', '*3', '*3.5', '*4', '*4.5', '*5', '*5.5', '*6', '*6.5', '*7', '*7.5', '*8', '*8.5', '*9', '*9.5', '*10'
        ]
    }    
    {
        equations: 
            'x/3.5': {start: 'x'}
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
            '*2', '*2.5', '*3', '*3.5', '*4', '*4.5', '*5', '*5.5', '/2', '/2.5', '/3', '/3.5', '/4', '/4.5', '/5', '/5.5'
        ]
    }    
    {
        equations: 
            'x*5/2': {start: 'x'}
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
            '*5', '*3', '/2', '/8'
        ]
    }    
    {
        equations: 
            'sin(ax+3.14)+b':
                solutionComponents: [
                    {fragment: 'sin(ax)', after: ''},
                    {fragment: '+3.14', after: 'ax'},
                    {fragment: '+b', after: 'sin(ax+3.14)'}
                ]
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
                solution: -0.6
            b:
                start: 2
                min: -10
                max: 10
                increment: 1
                solution: 5
                
    }    
    {
        equations:
            '2x': {}
            '.5x+2': {}
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
        equations:
            'ln(x+0.14)+2': solutionComponents: [
                {fragment: 'ln(x)', after: ''},
                {fragment: '+0.14', after: 'x'},
                {fragment: '+2', after: 'ln(x+0.14)'}
            ]
            '-3(x-4)+6': solutionComponents: [
                {fragment: '-3(x)', after: ''},
                {fragment: '-4', after: 'x'},
                {fragment: '+6', after: '-3(x-4)'}
            ]
            
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
    {
        equations: 
            '2+3x': {}
        grid:
            xMin: -10
            xMax: 20
            yMin: -10
            yMax: 20
        rings: [
            {x: 1, y: 5}
            {x: 3, y: 11}
            {x: 5, y: 17}
        ]
        islandCoordinates: {x: 0, y: 2}
        fragments: [
            '3x', '1+', '2+', '3+'
        ]
    }
    {
        equations: 
            '2-3x': {}
        grid:
            xMin: -20
            xMax: 20
            yMin: -20
            yMax: 20
        rings: [
            {x: -2, y: 8}
            {x: 3, y: -7}
            {x: 5, y: -13}
        ]
        islandCoordinates: {x: -5, y: 17}
        fragments: [
            '3x', '1+', '1-', '2+', '2-'
        ]
    }
    {
        equations: 
            '4+(1/5)x': {start: 'x'}
        grid:
            xMin: -10
            xMax: 10
            yMin: -6
            yMax: 10
        rings: [
            {x: -1, y: 3.8}
            {x: 3, y: 4.6}
            {x: 8, y: 5.6}
        ]
        islandCoordinates: {x: -8, y: 2.4}
        fragments: [
            '4+', '2+', '(1/5)', '1/2', '2'
        ]
    }
    {
        equations: 
            '(3/2)x-4': solutionComponents: [
                {fragment: '(3)x', after: ''},
                {fragment: '/2', after: '3'},
                {fragment: '-4', after: '(3/2)x'}
            ]
        grid:
            xMin: -10
            xMax: 20
            yMin: -10
            yMax: 20
        rings: [
            {x: 3, y: 0.5}
            {x: 8, y: 8}
            {x: 12, y: 14}
        ]
        islandCoordinates: {x: -2, y: -7}
        fragments: [
            '(3)x', '/2', '/4', '*2', '*4', '-2', '-4'
        ]
    }
    {
        equations: 
            '-4-(3/a)x': {}
        grid:
            xMin: -30
            xMax: 30
            yMin: -30
            yMax: 30
        rings: [
            {x: -6, y: 5}
            {x: 2, y: -7 }
            {x: 8, y: -16}
        ]
        islandCoordinates: {x: -12, y: 14}
        fragments: [
            '-(3/a)x', '-4', '-2', '2', '4'
        ]
        variables:
            a:
                start: -10
                min: -10
                max: 10
                increment: 1
                solution: 2
    }         
    {
        equations: 
            'x+4+8': {start: 'x'}
        grid:
            xMin: -30
            xMax: 30
            yMin: -30
            yMax: 30
        rings: [
            {x: 0, y: 12}
            {x: 12, y: 24 }
        ]
        islandCoordinates: {x: -12, y: 0}
        fragments: [
            '+2', '-2', '+4', '-4', '+8', '-8'
        ]
    }         
    {
        equations: 
            'x-5+2': {start: 'x'}
        grid:
            xMin: -30
            xMax: 30
            yMin: -30
            yMax: 30
        rings: [
            {x: 0, y: -3}
            {x: 6, y: 3}
            {x: 15, y: 12}
        ]
        islandCoordinates: {x: -10, y: -13}
        fragments: [
            '+2', '-2', '+5', '-5'
        ]
    }         
    {
        equations: 
            '3-x+4': {start: '-x'}
        grid:
            xMin: -50
            xMax: 50
            yMin: -50
            yMax: 50
        rings: [
            {x: -15, y: 22}
            {x: 0, y: 7}
            {x: 25, y: -18}
        ]
        islandCoordinates: {x: -35, y: 42}
        fragments: [
            '1', '2', '3', '4', '+1', '+2', '+3', '+4'
        ]
    }         
    {
        equations: 
            '-6-4+x': {start: 'x'}
        grid:
            xMin: -30
            xMax: 30
            yMin: -30
            yMax: 30
        rings: [
            {x: 0, y: -10}
            {x: 10, y: 0}
            {x: 20, y: 10}
        ]
        islandCoordinates: {x: -10, y: -20}
        fragments: [
            '-2', '-4', '-6', '-', '+'
        ]
    }         
    {
        equations: 
            '2x+7+8': {start: 'x'}
        grid:
            xMin: -30
            xMax: 30
            yMin: -10
            yMax: 50
        rings: [
            {x: 0, y: 15}
            {x: 5, y: 25}
            {x: 10, y: 35}
        ]
        islandCoordinates: {x: -5, y: 5}
        fragments: [
            '2', '4', '6', '+5', '+6', '+7', '+8'
        ]
    }         
    {
        equations: 
            '-ax+5': {start: 'x'}
        grid:
            xMin: -50
            xMax: 50
            yMin: -50
            yMax: 50
        rings: [
            {x: 0, y: 5}
            {x: 5, y: -10}
            {x: 10, y: -25}
        ]
        islandCoordinates: {x: -10, y: 35}
        fragments: [
            '-a', '+a', '+2', '+5', '-2', '-5'
        ]
        variables:
            a:
                start: 0
                min: 0
                max: 10
                increment: 0.5
                solution: 3        
    }         
    {
        equations: 
            '(a/2)x+6+8-4': {start: 'x'}
        grid:
            xMin: -50
            xMax: 50
            yMin: -50
            yMax: 50
        rings: [
            {x: -8, y: -6}
            {x: 8, y: 26}
            {x: 16, y: 42}
        ]
        islandCoordinates: {x: -24, y: -38}
        fragments: [
            '(a/2)', '+6', '+8', '-4', '-2'
        ]
        variables:
            a:
                start: 0
                min: 0
                max: 10
                increment: 0.5
                solution: 4
    }         
    {
        equations: 
            '(2/3)x-a/2': {start: 'x'}
        grid:
            xMin: -100
            xMax: 100
            yMin: -100
            yMax: 100
        rings: [
            {x: -24, y: -18.5}
            {x: 30, y: 17.5}
            {x: 66, y: 41.5}
        ]
        islandCoordinates: {x: -75, y: -52.5}
        fragments: [
            '(2/3)', '3', '(3/2)', '-a', '/2', '/3'
        ]
        variables:
            a:
                start: 0
                min: -10
                max: 10
                increment: 0.5
                solution: 5
    }         
    {
        equations: 
            '(-4/6)x+(3*a)': 
                start: 'x'
                solutionComponents: [
                    {fragment: '(-4/)', after: ''},
                    {fragment: '6', after: '-4/'},
                    {fragment: '+(a)', after: 'x'},
                    {fragment: '3*', after: '+('}
                ]
        grid:
            xMin: -100
            xMax: 100
            yMin: -100
            yMax: 100
        rings: [
            {x: -30, y: 35}
            {x: 24, y: -1}
            {x: 72, y: -33}
        ]
        islandCoordinates: {x: -75, y: 65}
        fragments: [
            '3*', '4*', '(-3/)', '(3/)', '(-4/)', '(4/)', '+(a)', '5', '6'
        ]
        variables:
            a:
                start: 0
                min: -10
                max: 10
                increment: 1
                solution: 5
    }         
]
