xyflyer = require('./lib/xyflyer')

window.app = 
    initialize: ->
        if not (@width = window.innerWidth or window.landwidth) or not (@height = window.innerHeight or window.landheight) or @width < @height
            $.timeout 100, -> window.app.initialize()
            return
            
        document.addEventListener('touchmove', ((e) => e.preventDefault()), false)
        
        if data = window.localStorage.getItem('player_data')
            @players = JSON.parse(data)
        
        if not @players
            @players = {}
            for i in [0..3]
                @players[i + 1] = 
                    id: i + 1
                    name: "Player#{i + 1}"
                    attempted: 0
                    completed: 0
                    hand: 'Right'
                
        @el = $('.xyflyer')
        
        @dynamicContent = @el.find('.dynamic_content')

        @el.bind('touchstart', (e) -> e.preventDefault() if e.preventDefault)
        @originalHTML = @dynamicContent.html()

        @worlds = require('./lib/xyflyer_objects/levels').WORLDS
        @level = @worlds[0].stages[0].levels[0]
        
        @puzzleProgress = {}
        @puzzleProgress[@level.id] = {}
        
        @initLevelSelector()
        @initSettings()
        @initWorlds()
        @selectWorld(0)
        
        # @testHints()
        # return
        
        @showMenu(@settings)


    $: (selector) -> $(selector, @el)
        
    clear: ->
        $('svg').remove()        
        @dynamicContent.html(@originalHTML)
        
    load: ->
        @$('.level_selector_menu').bind 'touchstart.menu', =>
            @$('.level_selector_menu').addClass('active')
            @$('.level_selector_menu').one('touchend.menu', => @$('.level_selector_menu').removeClass('active')
            @showMenu(@levelSelector))
            $(document.body).one('touchend.menu', => @$('.level_selector_menu').unbind('touchend.menu'))

        @$('.settings_menu').bind 'touchstart.settings_menu', =>
            @$('.settings_menu').addClass('active')
            @$('.settings_menu').one('touchend.settings_menu', => @$('.settings_menu').removeClass('active')
            @showMenu(@settings))
            $(document.body).one('touchend.settings_menu', => @$('.settings_menu').unbind('touchend.settings_menu'))
        
        assets = {person: 1, island: 1, plane: 1, background: 1}
        assets[asset] = index for asset, index of @worlds[@currentWorld()].assets or {}
        assets[asset] = index for asset, index of @currentStage().assets or {}
        assets[asset] = index for asset, index of @level.assets or {}
        @level.assets = assets
        
        for asset, index of assets 
            if asset == 'background'
                @dynamicContent.css('backgroundImage', @dynamicContent.css('backgroundImage').replace(/\d+\.jpg/, "#{index}.jpg"))
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
                registerEvent: (eventInfo) => 
                    
        @loadLevel()  

    initWorlds: ->
        worldLinks = @$('.world_link')
        worldLinks.bind 'touchstart.select_world', (e) =>
            worldLinks.one 'touchend.select_world', (e) =>
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
        
    loadLevel: ->
        if @level?.fragments
            for fragment in @level.fragments
                @helper.addEquationComponent(fragment)
        else if @level.id != 'editor'
            @$('.possible_fragments').hide()

        for equation, info of @level?.equations or {'': {}}
            @helper.addEquation(equation, info.start, info.solutionComponents, @level?.variables)    
    
        for ring in @level?.rings or []
            @helper.addRing(ring.x, ring.y)
            
        @$('.equation_container .intro, .equation div').css(fontSize: fontSize) if (fontSize = @level?.assets?.font)
        
        @selectWorld(@currentWorld())
                        
            
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
        equationArea.find('.button').bind 'touchstart', => @showMenu(@levelSelector) 
            
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
        setTimeout((=>
            @puzzleProgress[@level.id] or= {}
            @load()
            @puzzleProgress[@level.id].started or= new Date().getTime()
            @savePlayer()
            @populatePlayer()
            
            @setLevelIcon
                id: @level.id, 
                started: true, 
                completed: @puzzleProgress[@level.id]?.completed
        ), 100)

    initLevelSelector: (changedLevelIds) ->
        @levelSelector or= @$('.level_selector')
        @levelSelector.bind 'touchstart', (e) => e.stop()

        previousCompleted = true
        for stageElement in @levelSelector.find('.stage')
            do (stageElement) =>
                stageCompleted = 0
                for levelElement, index in $(stageElement).find('.level')
                    levelElement = $(levelElement)
                    lastLevelId = id
                    id = levelElement.data('id')
                    
                    if not changedLevelIds or not changedLevelIds.length or 
                       changedLevelIds.indexOf(id) > -1 or changedLevelIds.indexOf(lastLevelId) > -1
                        do (levelElement, index) =>
                            levelInfo = @findLevel(id)
        
                            locked = !previousCompleted
                            locked = false if index == 0
                        
                            @setLevelIcon
                                id: id
                                started: @puzzleProgress[id]?.started
                                completed: @puzzleProgress[id]?.completed
                                locked: locked
                        
                            levelElement.unbind 'touchstart.select_level'
                            levelElement.bind 'touchstart.select_level', (e) =>
                                e.stop()
                                unless locked
                                    levelElement.addClass('active')                                
                                    @clear()
                                    @level = levelInfo
                                    @initLevel()
                                
                                levelElement.one 'touchend.select_level', (e) =>
                                    levelElement.removeClass('active')
                                    $(document.body).unbind('touchstart.level_selector')
                                    if locked
                                        alert('This level is locked.')
                                    else
                                        @hideMenu(@levelSelector)        
                        
                            if @puzzleProgress[id]?.completed
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
        @savePlayer()
        @populatePlayer()
        $.timeout 1000, =>
            @initLevelSelector([@level.id])

            for level, index in @$('.stage .level:last-child') when index % 2 == 1
                if parseInt(@level.id) == parseInt($(level).data('id'))
                    @selectWorld(Math.floor(index / 2) + 1)

            @showMenu(@levelSelector, true)

            
    showMenu: (menu, success) ->
        $(document.body).unbind('touchstart.hide_menu')
        if parseInt(menu.css('opacity')) == 1
            @hideMenu(menu)
            return

        # if success
        #     @levelSelector.addClass('success') 
        # else
        #     @levelSelector.removeClass('success') 
        # 
                
        menu.css
            opacity: 1
            top: (@el.height() - menu.height()) / 2
            left: (@el.width() - menu.width()) / 2

        $.timeout 50, =>    
            $(document.body).one 'touchstart.hide_menu', => 
                $(document.body).one 'touchend.hide_menu', => 
                    @hideMenu(menu)

    hideMenu: (menu) ->
        $(document.body).unbind('touchstart.hide_menu touchend.hide_menu')
        menu.css
            opacity: 0
            top: -1000
            left: -1000
    
    
    initSettings: ->
        @settings or= @$('.settings')
        @settings.bind 'touchstart', (e) => e.stop()
        for info in (info for id, info of @players when info.lastPlayed).sort((a,b) -> b.lastPlayed - a.lastPlayed)
            playerName = @settings.find(".player_selection .player#{info.id}")
            playerName.html(info.name)
            @selectPlayer(playerName.closest('.select_player')) unless @selectedPlayer
            
        @settings.find('.select_player').bind 'touchstart.select_player', (e) => 
            @selectPlayer($(e.currentTarget))

        @settings.find('.edit_player').bind 'touchstart.edit_player', (e) => 
            $(e.currentTarget).addClass('active')
            $(e.currentTarget).one 'touchend.edit_player', (e) =>
                $(e.currentTarget).removeClass('active')
            @editPlayer()

        @settings.find('.play_button').bind 'touchstart.play', (e) => 
            $(e.currentTarget).addClass('active')
            $(e.currentTarget).one 'touchend.play', (e) =>
                $(e.currentTarget).removeClass('active')
            @hideMenu(@settings)            
                
        @initKeyboard()
        @initRadios()
        @initActions()        
        @showPlayer()
        
    initActions: ->
        @settings.find('.form .actions .save').bind 'touchstart.save', (e) =>
            button = $(e.currentTarget)
            button.addClass('active')
            button.one 'touchend.save', => button.removeClass('active')
            @selectedPlayer.name = @settings.find('.form .name').html()
            @selectedPlayer.hand = @settings.find('.form .hand input:checked').val()
            @savePlayer()
            @populatePlayer()
            @showPlayer()

        @settings.find('.form .actions .cancel').bind 'touchstart.cancel', (e) =>
            button = $(e.currentTarget)
            button.addClass('active')
            button.one 'touchend.cancel', => button.removeClass('active')
            @showPlayer()    

        
    initRadios: ->
        for direction in ['left', 'right']
            do (direction) =>
                hand = @settings.find(".hand .#{direction}")
                hand.bind 'touchstart.hand', =>
                    @settings.find('.hand input').attr(checked: '')
                    hand.attr(checked: 'checked')
        
    initKeyboard: ->
        keyboard = @settings.find('.keyboard')
        addLetter = (letter) -> 
            color = if letter.match(/&.*;/) then 'red' else 'blue'
            keyboard.append("<a class='letter #{color}_button'>#{letter}</a>")
        addBreak = -> keyboard.append('<br/>')
        addLetter(letter) for letter in ['q','w','e','r','t','y','u','i','o','p','&lsaquo;']
        addBreak()
        addLetter(letter) for letter in ['a','s','d','f','g','h','j','k','l']
        addBreak()
        addLetter(letter) for letter in ['&and;','z','x','c','v','b','n','m','&#95;']
        keyboard.find('.letter').bind 'touchstart.letter', (e) =>
            letter = $(e.currentTarget)
            letter.addClass('active')
            letter.one 'touchend.letter', => @clickLetter(letter)
        @clickLetter($(l)) for l in keyboard.find('.letter') when $(l).html() == '∧'
                        
    clickLetter: (letter) ->
        letters = @settings.find('.keyboard .letter')
        htmlLetter = letter.html()
        
        name = @settings.find('.player_details .form .name') 
        unless htmlLetter == '∨' and htmlLetter == '∧'
            name.html('') if name.html().match(/Player\d/) or name.html() == '&nbsp;'

        switch htmlLetter
            when '_' then name.append(' ')
            when '∧' 
                $(l).html($(l).html().toUpperCase())  for l in letters
                letter.html('&or;')    
            when '∨'
                $(l).html($(l).html().toLowerCase())  for l in letters
                letter.html('&and;')    
            when '‹'    
                name.html(name.html()[0...name.html().length - 1])
            else 
                name.append(htmlLetter)

        if name.html().length <= 0
            name.html('&nbsp;')
        else if htmlLetter != '∨' and htmlLetter != '∧'
            @clickLetter($(l)) for l in letters when $(l).html() == '∨'

        if (name.html() == '&nbsp;' or name.html().match(/\s$/)) and htmlLetter != '∨' and htmlLetter != '∧'
            @clickLetter($(l)) for l in letters when $(l).html() == '∧'

        letter.removeClass('active')
        
        
    selectPlayer: (player) ->          
        @settings.find('.select_player').removeClass('selected')
        player.addClass('selected')
        @selectedPlayer = @players[player.data('id')]
        existingProgressIds = (parseInt(id) for id in Object.keys(@puzzleProgress))
        @puzzleProgress = @selectedPlayer.progress or {}

        @initLevelSelector([existingProgressIds..., (parseInt(id) for id in Object.keys(@puzzleProgress))...])

        startedLevels = ({id: level, started: info.started} for level, info of @puzzleProgress when info.started)
        if startedLevels.length
            lastLevelId = startedLevels.sort((a,b) => b.started - a.started)[0].id
            lastLevel = @findLevel(parseInt(lastLevelId))
            if lastLevel
                @level = lastLevel
        else
            @level = @worlds[0].stages[0].levels[0]
        
        @clear()
        @initLevel()
        @puzzleProgress[@level.id] or= {}
        @populatePlayer()
    
    populatePlayer: ->
        return unless @selectedPlayer
        for key, value of @selectedPlayer
            @settings.find(".player_details .info .#{key}").html("#{value}")    

        started = (id for id, info of @selectedPlayer.progress when info.started or info.completed)
        @settings.find('.player_details .info .attempted').html("#{started.length}")
        
        completed = (id for id, info of @selectedPlayer.progress when info.completed)
        @settings.find('.player_details .info .completed').html("#{completed.length}")
        
        @settings.find('.form .name').html(@selectedPlayer.name)
        @settings.find(".form .hand input.#{@selectedPlayer.hand.toLowerCase()}").attr(checked: 'checked')
        @settings.find(".player_selection .player#{@selectedPlayer.id}").html(@selectedPlayer.name)
            
    savePlayer: ->
        @selectedPlayer.lastPlayed = new Date().getTime()
        @selectedPlayer.progress = @puzzleProgress
        window.localStorage.setItem('player_data', JSON.stringify(@players))
            
    editPlayer: ->
        details = @settings.find('.player_details')
        details.find('.info').hide()
        details.find('.form').show()
        
    showPlayer: ->
        @settings.find('.player_details .form').hide()        
        @settings.find('.player_details .info').show()

    testHints: (levelIndex=0) ->
        @hideMenu(@levelSelector)
        @hideMenu(@settings)
        @nextLevel = =>
            @testHints(levelIndex+1)

        index = 0
        for world in @worlds
            for stage in world.stages
                for level in stage.levels
                    if index == levelIndex
                        if level != @level
                            # console.log("TESTING LEVEL #{level.id}, INDEX: #{levelIndex}")
                            @clear()
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
                                            type: 'touchstart'

                                        $(document.body).trigger('touchstart.hint')
                                        component.element.trigger('touchstart.hint')

                                        $.timeout 1000, =>        
                                            $(document.body).trigger('touchend.hint')
                                            component.move
                                                preventDefault: =>
                                                type: 'touchmove'
                                                clientX: dropAreaElement.offset().left
                                                clientY: dropAreaElement.offset().top + (30 / (window.appScale or 1))

                                            component.endMove
                                                preventDefault: =>
                                                type: 'touchend'
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

                            @$('.hints').trigger('touchstart.hint')
                            @$('.hints').trigger('touchend.hint')

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
                                    launch.trigger('touchend.hint')
                                    launch.trigger('touchstart.launch')
                                    launch.trigger('touchend.launch')
                        return
                    index += 1


        
