xyflyer = require('./lib/xyflyer')

window.app = 
    initialize: ->
        if not (@width = window.innerWidth or window.landwidth) or not (@height = window.innerHeight or window.landheight) or @width < @height
            $.timeout 100, -> window.app.initialize()
            return
            
        document.addEventListener('touchmove', ((e) => e.preventDefault()), false)
        
        @el = $('.xyflyer')
        
        @dynamicContent = @el.find('.dynamic_content')

        @el.bind('touchstart', (e) -> e.preventDefault() if e.preventDefault)
        @originalHTML = @dynamicContent.html()

        @worlds = require('./lib/xyflyer_objects/levels').WORLDS
        # @levelId = 1364229884455
        @level = @worlds[0].stages[0].levels[0]
        
        @puzzleProgress = {}
        @puzzleProgress[@levelId] = {}
        
        @initLevelSelector()
        @initSettings()
        @initWorlds()
        @selectWorld(0)
        
        # @testHints()
        # return
        
        @showMenu(@settings)

        @load()

    $: (selector) -> $(selector, @el)
        
    clear: ->
        $('svg').remove()        
        @dynamicContent.html(@originalHTML)
        
    load: ->
        @$('.level_selector_menu').bind 'touchstart.menu', =>
            @$('.level_selector_menu').one('touchend.menu', => @showMenu(@levelSelector))
            $(document.body).one('touchend.menu', => @$('.level_selector_menu').unbind('touchend.menu'))

        @$('.settings_menu').bind 'touchstart.settings_menu', =>
            @$('.settings_menu').one('touchend.settings_menu', => @showMenu(@settings))
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
        else if @levelId != 'editor'
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
            
            @setLevelIcon
                id: @level.id, 
                started: true, 
                completed: @puzzleProgress[@level.id]?.completed
        ), 100)

    initLevelSelector: (changedLevelId) ->
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
                    
                    if not changedLevelId or changedLevelId == id or changedLevelId == lastLevelId
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
                                    levelElement.addClass('clicking')                                
                                    @clear()
                                    @level = levelInfo
                                    @initLevel()
                                
                                levelElement.one 'touchend.select_level', (e) =>
                                    levelElement.removeClass('clicking')
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
        $.timeout 1000, =>
            @initLevelSelector(@level.id)

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
            top: 45
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
        @settings.find('.edit_player').bind 'touchstart.edit_player', (e) => 
            @settings.find('.edit_player').one 'touchend.edit_player', (e) =>
                @editPlayer()

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


        
