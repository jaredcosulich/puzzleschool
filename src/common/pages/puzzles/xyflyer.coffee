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
            
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/levels.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/animation.js'
            @loadScript '/build/common/pages/puzzles/lib/xyflyer_objects/transformer.js'
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
                class: @classId or 0
                level: @levelId
                classLevel: @classLevelId or 0
                instructions: @levelInfo?.instructions
                editor: @levelId == 'editor'
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
            
            @initEncode()
            
            if isNaN(parseInt(@levelId))
                if (instructions = window.location.hash.replace(/\s/g, ''))?.length
                    level = @decode(decodeURIComponent(instructions.replace(/^#/, '')))
                    @data = JSON.parse(level)
                    
                if @levelId == 'editor'
                    xyflyerEditor = require('./lib/xyflyer_editor')
                    @helper = new xyflyerEditor.EditorHelper
                        el: $(@selector)
                        boardElement: @$('.board')
                        equationArea: @$('.equation_area')
                        objects: @$('.objects')
                        grid: @data?.grid
                        islandCoordinates: @data?.islandCoordinates  
                        variables: @data?.variables                      
                        encode: (instructions) => @encode(instructions)
                    @loadLevel()
                    
                else if not @data
                    @showMessage('intro')
            
                return unless @levelId == 'custom' and @data
                
            if @classId
                if not @user
                    window?.location?.reload()                 
                    return
                    
                try
                    @data = eval("a=" + @$('.level_instructions').html().replace(/\s/g, ''))
                catch e
            else if not @data
                @data = LEVELS[@levelId]
                
            if not @data
                @showMessage('exit')
                return
        
            @helper = new xyflyer.ViewHelper
                el: $(@selector)
                boardElement: @$('.board')
                objects: @$('.objects')
                equationArea: @$('.equation_area')
                grid: @data.grid
                islandCoordinates: @data.islandCoordinates
                nextLevel: => @nextLevel()
                registerEvent: (eventInfo) => @registerEvent(eventInfo)
                
            @loadLevel()    
            
            
        loadLevel: ->
            for equation, info of @data?.equations or {'': {}}
                @helper.addEquation(equation, info.start, info.solutionComponents, @data?.variables)    
        
            for ring in @data?.rings or []
                @helper.addRing(ring.x, ring.y)
            
            if @data?.fragments
                for fragment in @data.fragments
                    @helper.addEquationComponent(fragment)
            else if @levelId != 'editor'
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
            path = '/puzzles/xyflyer/1'
            if @isIos()
                equationArea.find('.button').attr('href', path) 
            else
                equationArea.find('.button').bind 'mousedown.go', => @go(path)
                
        isIos: -> navigator.userAgent.match(/(iPad|iPhone|iPod)/i)
            
        nextLevel: ->
            @registerEvent
                type: 'success'
                info: 
                    time: new Date()
            
            complete = @$('.complete')
            @centerAndShow(complete)
            
            @$('.launch').html('Success! Go To The Next Level >')
            path = "/puzzles/xyflyer/#{if @classId then "#{@classId}/" else ''}#{@levelId + 1}"
            if @isIos()
                @$('.go').attr('href', path)
            else
                @$('.launch').unbind 'mousedown.launch touchstart.launch'
                @$('.go').bind 'mousedown.go', => @go(path)
                    
                
        initEncode: ->
            @encodeMap =
                '"equations":': '~a'
                '"rings":': '~b'
                '"grid":': '~c'
                '"islandCoordinates":': '~d'
                '"fragments":': '~e'
                '"variables":': '~f'
                '"x":': '~g'
                '"y":': '~h'
                '"xMin":': '~i'
                '"yMin":': '~j'
                '"xMax":': '~k'
                '"yMax":': '~l'
                '-': '~m'
                '\\+': '~n'
                '\\*': '~o'
                '\\/': '~p'
                '\\(': '~q'
                '\\)': '~r'
                '0': '~s'
                '1': '~t'
                '2': '~u'
                '3': '~v'
                '4': '~w'
                '5': '~x'
                '6': '~y'
                '7': '~z'
                '8': '~A'
                '9': '~B' 
                'min': '~C'
                'max': '~D'
                'increment': '~E'
                'start': '~F'
                '"verified"': '~V'
                
            @extraEncodeMap = 
                ':': '-'
                '"': '*'
                ',': "'"
                '=': '+'
                '{': '('
                '}': ')'

        encode: (json) ->
            for encode in (key for key of @encodeMap).sort((a,b) => b.length - a.length)
                regExp = new RegExp(encode,'g')
                json = json.replace(regExp, @encodeMap[encode])
            for extraEncode of @extraEncodeMap
                regExp = new RegExp('\\' + extraEncode,'g')
                json = json.replace(regExp, @extraEncodeMap[extraEncode])
            return json

        decode: (json) ->
            for extraEncode of @extraEncodeMap
                regExp = new RegExp('\\' + @extraEncodeMap[extraEncode],'g')
                json = json.replace(regExp, extraEncode)
            for encode in (key for key of @encodeMap).sort((a,b) => b.length - a.length)
                regExp = new RegExp(@encodeMap[encode],'g')
                json = json.replace(regExp, encode.replace(/\\/g, ''))
            return json
            
                
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

