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
        @levelId = 1364229884455
        @level = @worlds[0].stages[0].levels[0]
        
        @puzzleProgress = {}
        @puzzleProgress[@levelId] = {}
        
        @initLevelSelector()
        @selectWorld(0)
        @showLevelSelector(true)

    $: (selector) -> $(selector, @el)
        
    clear: ->
        $('svg').remove()        
        @dynamicContent.html(@originalHTML)
        
    load: ->
        @$('.menu').bind 'touchstart.menu', =>
            @$('.menu').one('touchend.menu', => @showLevelSelector())
            $(document.body).one('touchend.menu', => @$('.menu').unbind('touchend.menu'))
        
        for asset, index of @level.assets or @worlds[@currentWorld()].assets or {}
            if asset == 'background'
                @dynamicContent.css('backgroundImage', @dynamicContent.css('backgroundImage').replace(/\d+\./, "#{index}."))
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
        @$('.world_link').bind 'touchstart', (e) =>
            e.stop()
            worldLink = $(e.currentTarget)
            @selectWorld(parseInt(worldLink.data('world')) - 1)
            
    currentWorld: ->
        return 0 if not @level?.id
        for world, index in @worlds
            for stage in world.stages
                for level in stage.levels
                    return index if level.id == @level.id
        
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
        equationArea.find('.button').bind 'touchstart', => @showLevelSelector() 
            
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
        previousStageProficient = true
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
                            locked = false if index == 0# and previousStageProficient
                        
                            @setLevelIcon
                                id: id
                                started: @puzzleProgress[id]?.started
                                completed: @puzzleProgress[id]?.completed
                                locked: locked
                        
                            levelElement.unbind 'touchstart.select_level'
                            levelElement.bind 'touchstart.select_level', (e) =>
                                e.stop()
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
                                        @hideLevelSelector()        
                        
                            if @puzzleProgress[id]?.completed
                                stageCompleted += 1 
                                previousCompleted = true
                            else
                                previousCompleted = false
                
                previousStageProficient = (stageCompleted >= 3)
                            

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

            @showLevelSelector(true)

            
    showLevelSelector: (success) ->
        $(document.body).unbind('touchstart.level_selector')
        if parseInt(@levelSelector.css('opacity')) == 1
            @hideLevelSelector()
            return

        # if success
        #     @levelSelector.addClass('success') 
        # else
        #     @levelSelector.removeClass('success') 
        # 
                
        @levelSelector.css
            opacity: 1
            top: 30
            left: (@el.width() - @levelSelector.width()) / 2

        $.timeout 10, =>    
            $(document.body).one 'touchstart.level_selector', => 
                $(document.body).one 'touchend.level_selector', => 
                    @hideLevelSelector()

    hideLevelSelector: ->
        $(document.body).unbind('touchend.level_selector')
        @levelSelector.css
            opacity: 0
            top: -1000
            left: -1000
