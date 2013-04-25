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
            
            @puzzleData = {levels: {}}

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
                            
            else
                if @cookies.get('user')
                    @loadData 
                        url: '/api/puzzles/xyflyer'
                        success: (data) => @puzzleData = data.puzzle
                        error: () =>
                            if window?.alert
                                alert('We were unable to load your account information. Please check your internet connection.')
                        
            @objects = []
            for object, count of {person: 4, island: 4, plane: 2, background: 5}
                for index in [1..count]
                    filetype = (if object == 'background' then 'jpg' else 'png')
                    @objects.push(
                        name: "#{object}#{index} #{if index == 1 then object else ''}"
                        image: @loadImage("/assets/images/puzzles/xyflyer/#{object}#{index}.#{filetype}")
                    )
            
            if @levelId == 'editor'
                @loadScript '/build/common/pages/puzzles/lib/xyflyer_editor.js' 
            @loadStylesheet '/build/client/css/puzzles/xyflyer.css'     
            
                      
        build: ->
            @setTitle("XYFlyer - The Puzzle School")
            
            worlds = require('./lib/xyflyer_objects/levels').WORLDS
            world.index = index + 1 for world, index in worlds
            
            @html = wings.renderTemplate(@template,     
                puzzleData: JSON.stringify(@puzzleData)
                objects: @objects
                class: @classId or 0
                level: @levelId
                classLevel: @classLevelId or 0
                instructions: @levelInfo?.instructions
                editor: @levelId == 'editor'
                worlds: worlds
                noBackground: @levelId == 'editor' or not @levelId
            )
            
        
soma.views
    Xyflyer:
        selector: '#content .xyflyer'
        create: ->
            xyflyer = require('./lib/xyflyer')
            @worlds = require('./lib/xyflyer_objects/levels').WORLDS
            
            @dynamicContent = @el.find('.dynamic_content')
            @$('.menu').bind 'click', => @showLevelSelector()
            
            @user = @cookies.get('user')
            
            @classId = @el.data('class')
            @classLevelId = @el.data('classlevel')
            @levelId = @el.data('level')
            @level = @findLevel(@levelId)
            
            if (puzzleData = @el.data('puzzle_data'))?.length
                @puzzleData = JSON.parse(puzzleData)
            else
                @puzzleData = {levels: {}}
                
            @puzzleProgress = {}
            @puzzleProgress[@levelId] = {}            

            @originalHTML = @dynamicContent.html()
        
            @initEncode()
            @initLevelSelector()  
            @initWorlds()
            @selectWorld(0)
            
            @testHints()
            return
            
            if isNaN(parseInt(@levelId))
                if (instructions = window.location.hash.replace(/\s/g, ''))?.length
                    level = @decode(decodeURIComponent(instructions.replace(/^#/, '')))
                    @level = JSON.parse(level)
                    
                @level = instructions if (instructions = @loadCoffeeInstructions())
                    
                if @levelId == 'editor'
                    xyflyerEditor = require('./lib/xyflyer_editor')
                    @helper = new xyflyerEditor.EditorHelper
                        el: @dynamicContent
                        boardElement: @$('.board')
                        equationArea: @$('.equation_area')
                        objects: @$('.objects')
                        grid: @level?.grid
                        islandCoordinates: @level?.islandCoordinates  
                        variables: @level?.variables     
                        assets: @level?.assets                 
                        encode: (instructions) => @encode(instructions)
                    @loadLevel()
                    
                else if not @level
                    if Object.keys(@puzzleData.levels).length
                        @showLevelSelector()
                    else
                        @showMessage('intro')
            
                return unless @levelId == 'custom' and @level
                
            if @classId
                if not @user
                    window?.location?.reload()                 
                    return
                    
                try
                    @level = eval("a=" + @$('.level_instructions').html().replace(/\s/g, ''))
                catch e
            else if not @level
                @showLevelSelector()
                return
        
            @initLevel()
        
        initWorlds: ->
            @$('.world_link').bind 'click', (e) =>
                e.stop()
                worldLink = $(e.currentTarget)
                @selectWorld(parseInt(worldLink.data('world')) - 1)
                
        currentWorld: ->
            return 0 if not @level?.id
            for world, index in @worlds
                for stage in world.stages
                    for level in stage.levels
                        return index if level.id == @level.id

        currentStage: ->
            return 0 if not @level?.id
            for stage in @worlds[@currentWorld()].stages
                for level in stage.levels
                    return stage if level.id == @level.id
            
        load: ->
            @dynamicContent.html(@originalHTML)
            
            assets = {person: 1, island: 1, plane: 1, background: 1}
            assets[asset] = index for asset, index of @worlds[@currentWorld()].assets or {}
            assets[asset] = index for asset, index of @currentStage().assets or {}
            assets[asset] = index for asset, index of @level.assets or {}
            
            for asset, index of assets 
                if asset == 'background'
                    if (@dynamicContent.css('backgroundImage') or '').indexOf("background#{index}.jpg") == -1
                        @dynamicContent.css('backgroundImage', "url('/assets/images/puzzles/xyflyer/background#{index}.jpg')")
                else
                    @$(".objects .#{asset}").removeClass(asset)
                    @$(".objects .#{asset}#{index}").addClass(asset)

            if @helper
                @helper.reinitialize
                    boardElement: @$('.board')
                    objects: @$('.objects')
                    equationArea: @$('.equation_area')
                    grid: @level.grid
                    islandCoordinates: @level.islandCoordinates
            else
                @helper = new xyflyer.ViewHelper
                    el: @dynamicContent
                    boardElement: @$('.board')
                    objects: @$('.objects')
                    equationArea: @$('.equation_area')
                    grid: @level.grid
                    islandCoordinates: @level.islandCoordinates
                    nextLevel: => @nextLevel()
                    registerEvent: (eventInfo) => @registerEvent(eventInfo)
                
            @$('.menu').bind 'click', => @showLevelSelector()
                            
            @loadLevel()  
                
                
        loadLevel: ->
            if @level?.fragments
                for fragment in @level.fragments
                    @helper.addEquationComponent(fragment)
            else if @levelId != 'editor'
                @$('.possible_fragments').hide()

            for equation, info of @level?.equations or {'': {}}
                @helper.addEquation(equation, info.start, info.solutionComponents, @level?.variables)    
                
            for ring in @level?.rings or []
                @helper.addRing(ring.x, ring.y)
            
            @selectWorld(@currentWorld())
            if window._gaq and @level
                @level.startTime = new Date()
                _gaq.push(['_trackEvent', 'level', 'started', "xyflyer-#{@level.id}"]) 
                            
                
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
            @$('.board').hide()
            equationArea = @$('.equation_area')
            equationArea.html(@$(".#{type}_message").html())
            equationArea.css(padding: '0 12px', textAlign: 'center')
            equationArea.find('.button').bind 'click', => @showLevelSelector() 
                
        isIos: -> navigator.userAgent.match(/(iPad|iPhone|iPod)/i)
            
        selectWorld: (index) ->
            @$('.world_link').removeClass('selected')
            $(@$('.world_link')[index]).addClass('selected')
                    
            @$('.world').removeClass('selected')
            $(@$('.world')[index]).addClass('selected')
            
        findLevel: (levelId) ->
            for world in @worlds
                for stage in world.stages
                    level = (level for level in stage.levels when level.id == levelId)[0]
                    return JSON.parse(JSON.stringify(level)) if level
                
        initLevel: ->
            @dynamicContent.html(@originalHTML)
            setTimeout((=>
                @puzzleProgress[@level.id] or= (@puzzleData.levels[@level.id] or {})
                @load()
                @puzzleProgress[@level.id].started or= new Date().getTime()
                @saveProgress()

                @setLevelIcon
                    id: @level.id, 
                    started: true, 
                    completed: @puzzleData.levels[@level.id]?.completed

            ), 100)

            @currentLevel = @level.id
            setInterval((=>
                return if location.href.indexOf(@currentLevel) > -1
                components = location.href.split('/')
                if (@level = @findLevel(parseInt(components[components.length - 1])))
                    @initLevel()
                    @hideLevelSelector()
            ), 500)
        
        initLevelSelector: ->
            @levelSelector = @$('.level_selector')
            @levelSelector.bind 'click', (e) => e.stop()

            previousCompleted = true
            for stageElement in @levelSelector.find('.stage')
                do (stageElement) =>
                    stageCompleted = 0
                    for levelElement, index in $(stageElement).find('.level')
                        do (levelElement, index) =>
                            levelElement = $(levelElement)
                            id = levelElement.data('id')
                            levelInfo = @findLevel(id)
            
                            locked = !previousCompleted
                            locked = false if index == 0
                            
                            @setLevelIcon
                                id: id
                                started: @puzzleData.levels[id]?.started
                                completed: @puzzleData.levels[id]?.completed
                                locked: locked
            
                            levelElement.unbind 'click'
                            levelElement.bind 'click', (e) => 
                                e.stop()
                                $(document.body).unbind('click.level_selector')
                                if locked
                                    alert('This level is locked.')
                                else
                                    @level = levelInfo
                                    @initLevel()
                                    history.pushState(null, null, "/puzzles/xyflyer/#{id}")
                                    @hideLevelSelector()        
                            
                            if @puzzleData.levels[id]?.completed
                                stageCompleted += 1 
                                previousCompleted = true
                            else
                                previousCompleted = false
                    
                                

        setLevelIcon: ({id, started, completed, locked}) ->
            return if not id
            level = @$("#level_#{id}")
            level.removeClass('locked').removeClass('completed')
            if locked
                level.addClass('locked')
            else if completed
                level.addClass('completed')


        nextLevel: ->            
            @puzzleProgress[@level.id].completed = new Date().getTime()
            duration = if @level.startTime? then new Date() - @level.startTime else null
            
            $.timeout 500, => 
                _gaq.push(['_trackEvent', 'level', 'completed', "xyflyer-#{@level.id}", duration]) if window._gaq
                @registerEvent
                    type: 'success'
                    info: 
                        time: @puzzleProgress[@level.id].completed

                @saveProgress()
                @initLevelSelector()
                @showLevelSelector(true)
            
                for level, index in @$('.stage .level:last-child') when index % 2 == 1
                    if parseInt(@level.id) == parseInt($(level).data('id'))
                        @selectWorld(Math.floor(index / 2) + 1)         
                
        showLevelSelector: (success) ->
            $(document.body).unbind('click.level_selector')
            if parseInt(@levelSelector.css('opacity')) == 1
                @hideLevelSelector()
                return

            # if success
            #     @levelSelector.addClass('success') 
            # else
            #     @levelSelector.removeClass('success') 
            # 
            @levelSelector.css
                opacity: 0
                top: 60
                left: (@el.width() - @levelSelector.width()) / 2
            @levelSelector.animate
                opacity: 1
                duration: 250

            setTimeout((=>    
                $(document.body).one 'click.level_selector', => @hideLevelSelector()
            ), 10)

        hideLevelSelector: ->
            $(document.body).unbind('click.level_selector')
            @levelSelector.animate
                opacity: 0
                duration: 250
                complete: =>
                    @levelSelector.css
                        top: -1000
                        left: -1000

        saveProgress: (callback) ->
            @mergeProgress(@puzzleProgress)
            if @cookies.get('user')
                $.ajaj
                    url: "/api/puzzles/xyflyer/update"
                    method: 'POST'
                    headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                    data: 
                        puzzleUpdates: {}
                        levelUpdates: @puzzleProgress
                    success: => callback() if callback
            else 
                window.postRegistration.push((callback) => @saveProgress(callback))
                if Object.keys(@puzzleProgress).length % 5 == 4
                    @showRegistrationFlag()


        mergeProgress: (progress, master=@puzzleData.levels) ->
            for key, value of progress
                if typeof value == 'object'
                    master[key] = {}
                    @mergeProgress(value, master[key])
                else
                    master[key] = value


                
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
                'fragment': '~G'
                'solutionComponents': '~H'
                'after': '~I'
                'solution': '~J'
                'assets': '~K'
                'background': '~L'
                'foreground': '~M'
                'island': '~N'
                'person': '~O'
                'plane': '~P'
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
            if window._gaq and @level
                _gaq.push(['_trackEvent', 'level', 'hint', "xyflyer-#{@level.id}"]) 
            
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
        
        testHints: (levelIndex=0) ->
            @hideLevelSelector()
            @nextLevel = =>
                @testHints(levelIndex+1)
                
            index = 0
            for world in @worlds
                for stage in world.stages
                    for level in stage.levels
                        if index == levelIndex
                            if level != @level
                                console.log("TESTING LEVEL #{level.id}, INDEX: #{levelIndex}")
                                @level = level
                                @load()
                            
                            $.timeout 10, =>
                                testHints = (i) => @testHints(i)
                                helper = @helper
                                unless helper.equations.reallyDisplayHint
                                    helper.equations.reallyDisplayHint = @helper.equations.displayHint
                                    helper.equations.reallyDisplayVariable = @helper.equations.displayVariable
                                    
                                    helper.equations.displayHint = (component, dropAreaElement, equation, solutionComponent) ->
                                        helper.equations.reallyDisplayHint(component, dropAreaElement, equation, solutionComponent)
                                        $.timeout 1000, =>
                                            component.mousedown
                                                preventDefault: =>
                                                type: 'mousedown'
                                        
                                            $(document.body).trigger('mousedown.hint')
                                            component.element.trigger('mousedown.hint')
                                        
                                            $.timeout 1000, =>        
                                                $(document.body).trigger('mouseup.hint')
                                                component.move
                                                    preventDefault: =>
                                                    type: 'mousemove'
                                                    clientX: dropAreaElement.offset().left
                                                    clientY: dropAreaElement.offset().top
                                        
                                                component.endMove
                                                    preventDefault: =>
                                                    type: 'mouseup'
                                                    clientX: dropAreaElement.offset().left
                                                    clientY: dropAreaElement.offset().top
                                            
                                                testHints(levelIndex)
                                                
                                    helper.equations.displayVariable = (variable, value) ->
                                        helper.equations.reallyDisplayVariable(variable, value)
                                        for equation in helper.equations.equations
                                            if equation.variables[variable]
                                                equation.variables[variable].set(value)
                                                testHints(levelIndex)
                                                return

                                @$('.hints').trigger('mousedown.hint')
                                @$('.hints').trigger('mouseup.hint')

                                $.timeout 1000, =>
                                    ready = true
                                    for equation in helper.equations.equations
                                        formula = equation.formula()
                                        completedSolution = equation.solution
                                        for variable of equation.variables
                                            info = equation.variables[variable]
                                            completedSolution = completedSolution.replace(variable, info.solution) if info.solution
                                        
                                        ready = false unless completedSolution == formula
                                    
                                    if ready
                                        launch = @$('.launch')
                                        launch.trigger('mouseup.hint')
                                        launch.trigger('click.launch')
                            return
                        index += 1
            
        loadCoffeeInstructions: ->
        
        
            
soma.routes
    '/puzzles/xyflyer/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Xyflyer
            classId: classId
            levelId: levelId

    '/puzzles/xyflyer/:levelId': ({levelId}) -> 
        new soma.chunks.Xyflyer
            levelId: levelId
    
    '/puzzles/xyflyer': -> new soma.chunks.Xyflyer

