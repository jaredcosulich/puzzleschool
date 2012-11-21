soma = require('soma')
wings = require('wings')


sortLevels = (levels) ->
    levels.sort (level1,level2) ->
        a = level1.difficulty + level1.name
        b = level2.difficulty + level2.name
        return if a == b then 0 else (if a < b then -1 else 1)

soma.chunks
    SpaceFractions:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/space_fractions.html"
            @loadScript '/build/common/pages/puzzles/lib/space_fractions.js'
            if @levelId == 'editor'
                @loadScript '/build/common/pages/puzzles/lib/space_fractions_editor.js' 
            @loadStylesheet '/build/client/css/puzzles/space_fractions.css'     
            
            if @levelId and not isNaN(@levelId)
                @loadData 
                    url: "/api/puzzles/levels/#{@levelId}"
                    success: (@levelInfo) => 
                    error: () =>
                        if window?.alert
                            alert('We were unable to load the information for this level. Please check your internet connection.')
            
            if @classId
                @loadData 
                    url: "/api/classes/info/#{@classId}"
                    success: (data) =>
                        @classInfo = data
                        level.classId = @classInfo.id for level in @classInfo.levels
                        @classInfo.levels = sortLevels(@classInfo.levels)
                    error: () =>
                        if window?.alert
                            alert('We were unable to load the information for this class. Please check your internet connection.')

                      
        build: ->
            @setTitle("Light It Up - The Puzzle School")
            
            rows = ({columns: [0...10]} for row in [0...10])
            @html = wings.renderTemplate(@template,
                levelId: (@levelId or 0)
                classId: (@classId or 0)
                custom: @levelId == 'custom'
                editor: @levelId == 'editor'
                rows: rows
                instructions: @levelInfo?.instructions
                isClass: (if @classInfo then true else false)
                levels: @classInfo?.levels
            )
            
        
soma.views
    SpaceFractions:
        selector: '#content .space_fractions'
        create: ->
            spaceFractions = require('./lib/space_fractions')
            @viewHelper = new spaceFractions.ViewHelper
                el: $(@selector)
                rows: 10
                columns: 10
                registerEvent: (eventInfo) => @registerEvent(eventInfo)
                
            @user = @cookies.get('user')
            
            @initEncode()

            @classId = @el.data('class_id')
            @classId = null if @classId and (isNaN(@classId) and not @classId.length)
                
            if @classId
                if not @user
                    $('#base').data().base.showRegistration()

            @levelId = @el.data('level_id')
            @levelId = null if @levelId and (isNaN(@levelId) and not @levelId.length)
            
            if not @levelId
                introMessage = @$('.intro')
                introMessage.css
                    top: ($.viewport().height / 2) - (introMessage.height() / 2) + (window.scrollY)
                    left: ($.viewport().width / 2) - (introMessage.width() / 2)
                
                introMessage.animate
                    opacity: 1
                    duration: 500
                
            else if @levelId == 'editor'
                spaceFractionsEditor = require('./lib/space_fractions_editor')
                @editor = new spaceFractionsEditor.EditorHelper
                    el: $(@selector)
                    viewHelper: @viewHelper
                    encodeMethod: (json) => @encode(json)
                @$('.load_custom_level_data').bind 'click', => 
                    @$('.level_editor').css(height: 'auto')
                    @$('.load_custom_level_data').hide()
                    
            else if @levelId == 'custom'
                @currentHash = window.location.hash.toString()
                existingHashChange = window.onhashchange
                window.onhashchange = =>
                    return if window.location.hash.toString() == @currentHash
                    if  @decode(decodeURIComponent(window.location.hash.replace(/^#/, '')))[0] == '{'
                        window.location.reload()
                    else
                        existingHashChange()
                        window.location.hash = @currentHash
                        
                    
                @$('.load_custom_level_data').bind 'click', => 
                    @$('.custom_level').css(height: 'auto')
                    @$('.load_custom_level_data').hide()
                    
                @$('.load_to_play').bind 'click', =>
                    @viewHelper.loadToPlay(@$('.level_description').val())
            
            @loadLevelData(window.location.hash or @$('.level_instructions').html())
            
            @initInstructions()
            
            @sendingEvents = 0
            
            @initLevelSelector()
                    
            @initChallengeAssessment()        
                    
        loadLevelData: (instructions) ->
            instructions = instructions.replace(/\s/g, '')
            return if not instructions?.length
            level = @decode(decodeURIComponent(instructions.replace(/^#/, '')))
            return unless level[0] == '{'
            if @levelId == 'editor'
                @editor.levelDescription.val(level)
                @editor.load()
            else
                @$('.level_description').val(level)
                @viewHelper.loadToPlay(level)

        initInstructions: ->
            @$('.instructions_link').bind 'click', =>
                instructions = @$('.instructions')
                instructions.css
                    top: ($.viewport().height / 2) - (instructions.height() / 2) + (window.scrollY)
                    left: ($.viewport().width / 2) - (instructions.width() / 2)

                instructions.animate
                    opacity: 1
                    duration: 500
                    
                $.timeout 10, ->
                    $(document.body).one 'click', -> 
                        instructions.animate
                            opacity: 0
                            duration: 500
                            complete: ->
                                instructions.css
                                    top: -1000
                                    left: -1000
                                    
        initLevelSelector: ->
            @$('.show_level_selector').bind 'click.level_selector', =>
                @$('.success').animate
                    opacity: 0
                    duration: 500

                intro = @$('.intro')
                intro.addClass('only_levels') unless intro.hasClass('only_levels')
                intro.css
                    top: @el.offset().top + (@el.height() / 2) - (intro.height() / 2)
                    left: @el.offset().left + (@el.width() / 2) - (intro.width() / 2)

                intro.animate
                    opacity: 1
                    duration: 250
            
                @viewHelper.board.one 'click.level_selector', =>
                    intro.animate
                        opacity: 0
                        duration: 250
                        complete: =>
                            intro.css
                                top: -1000
                                left: -1000
                
        initChallengeAssessment: ->
            if @levelId == 'custom'
                @$('.success .challenge_assessment').hide()
                @$('.success .next_level').css(opacity: 1)                
            else
                @$('.success .next_level').hide()                
                @$('.success .challenge_assessment a').one 'click', (e) =>
                    link = $(e.currentTarget)
                    @registerEvent
                        type: 'challenge'
                        info: 
                            assessment: link[0].className
                            time: new Date()
                    challengeAssessment = link.closest('.challenge_assessment')
                    challengeAssessment.animate
                        opacity: 0
                        duration: 250
                        complete: =>
                            challengeAssessment.hide()
                            nextLevel = link.closest('.success').find('.next_level')
                            nextLevel.css
                                display: 'block'
                            nextLevel.animate
                                opacity: 1
                                duration: 250
                        
        
        initEncode: ->
            @encodeMap =
                '"objects"': '~o'
                '"type"': '~t'
                '"index"': '~i'
                '"numerator"': '~n'
                '"denominator"': '~d'
                '"fullNumerator"': '~fN'
                '"fullDenominator"': '~fD'
                '"verified"': '~v'
                'true': '~u'
                'false': '~f'
            for object of @viewHelper.objects
                @encodeMap['"' + object + '"'] = "!#{object.split(/_/ig).map((section) -> return section[0]).join('')}"
            
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
            for encode in (key for key of @encodeMap).sort((a,b) => b.length - a.length)
                regExp = new RegExp(@encodeMap[encode],'g')
                json = json.replace(regExp, encode)
            for extraEncode of @extraEncodeMap
                regExp = new RegExp('\\' + @extraEncodeMap[extraEncode],'g')
                json = json.replace(regExp, extraEncode)
            return json
            
        registerEvent: ({type, info}) ->
            return unless @user and @user.id and @levelId and @classId
            @pendingEvents or= []
            @pendingEvents.push
                type: type
                info: JSON.stringify(info)
                puzzle: 'fractions'
                classId: @classId
                levelId: @levelId
                
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
                levelClass: {objectType: 'level_class', objectId: "#{@levelId}/#{@classId}", actions: []}
                userLevelClass: {objectType: 'user_level_class', objectId: "#{@user.id}/#{@levelId}/#{@classId}", actions: []}
            }
            statUpdates.user.actions.push(
                attribute: 'levelClasses'
                action: 'add'
                value: ["#{@levelId}/#{@classId}"]
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
    '/puzzles/space_fractions/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.SpaceFractions
            classId: classId
            levelId: levelId

    '/puzzles/space_fractions/:levelId': ({levelId}) -> 
        new soma.chunks.SpaceFractions
            levelId: levelId
    
    '/puzzles/space_fractions': -> new soma.chunks.SpaceFractions

    '/puzzles/light_it_up/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.SpaceFractions
            classId: classId
            levelId: levelId

    '/puzzles/light_it_up/:levelId': ({levelId}) -> 
        new soma.chunks.SpaceFractions
            levelId: levelId
    
    '/puzzles/light_it_up': -> new soma.chunks.SpaceFractions
            
