###
RESOURCES

https://www.circuitlab.com

https://www.youtube.com/watch?v=a6YyEeqFFDA&feature=youtube_gdata_player&noredirect=1

http://phet.colorado.edu/en/simulation/circuit-construction-kit-dc

https://www.khanacademy.org/science/physics/electricity-and-magnetism/v/circuits--part-1

http://en.wikipedia.org/wiki/Electrical_circuit

http://www.allaboutcircuits.com

https://6002x.mitx.mit.edu

###

soma = require('soma')
wings = require('wings')

soma.chunks
    Circuitous:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/circuitous.html"

            @loadScript '/build/common/pages/puzzles/lib/common_objects/animation.js'
            @loadScript '/build/common/pages/puzzles/lib/common_objects/client.js'
            @loadScript '/build/common/pages/puzzles/lib/common_objects/transformer.js'
            @loadScript '/build/common/pages/puzzles/lib/common_objects/draggable.js'

            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/object.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/tag.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/analyzer.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/wires.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/selector.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/battery.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/resistor.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/toggle_switch.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/light_emitting_diode.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/lightbulb.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/board.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/options.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/menu.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/index.js'
            @loadScript '/build/common/pages/puzzles/lib/circuitous_objects/levels.js'

            @loadScript '/build/common/pages/puzzles/lib/circuitous_editor.js' if @levelId == 'editor'
            @loadScript '/build/common/pages/puzzles/lib/circuitous.js'
            
            @loadStylesheet '/build/client/css/puzzles/circuitous.css'     
            
                      
        build: ->
            @setTitle("Circuitous - The Puzzle School")
            @loadElement("link", {rel: 'img_src', href: 'http://www.puzzleschool.com/assets/images/reviews/xyflyer.jpg'})
            
            @setMeta('og:title', 'Circuitous - The Puzzle School')            
            @setMeta('og:url', 'http://www.puzzleschool.com/puzzles/circuitous')
            @setMeta('og:image', 'http://www.puzzleschool.com/assets/images/reviews/circuitous.jpg')
            @setMeta('og:site_name', 'The Puzzle School')
            @setMeta('og:description', 'Explore circuits through simple challenges you can solve in creative ways.')
            @setMeta('description', 'Explore circuits through simple challenges you can solve in creative ways.')
            
            @html = wings.renderTemplate(@template,
                level_id: @levelId or false,
                editor: @levelId == 'editor'
            )
            
        
soma.views
    Circuitous:
        selector: '#content .circuitous'
        hashReplacements: 
            '~a': '{"components": ['
            '~b': '{"name": "Battery", '
            '~c': '{"name": "Lightbulb", '
            '~d': '"position": '
            '~e': '"wires": [["'
            '~f': '"],["'
            '~g': '","'
            '~h': '"]]}'
            '~i': '{"name": "Resistor", '
            '~j': '"volts": '
            '~k': '"resistance": '
            
        create: ->            
            circuitous = require('./lib/circuitous')
            
            @worlds = require('./lib/xyflyer_objects/levels').WORLDS
            
            @viewHelper = new circuitous.ViewHelper
                el: $(@selector)
                worlds: @worlds
                loadLevel: (levelId) => @loadLevel(levelId)
               
            @levelId = @el.data('level_id')                  
            
            if @levelId == 'editor'
                circuitousEditor = require('./lib/circuitous_editor')
                @editor = new circuitousEditor.EditorHelper
                    el: $(@selector)
                    viewHelper: @viewHelper
                    hashReplacements: @hashReplacements
                    getInstructions: => @getInstructions()

                if (instructions = location.hash).length
                    instructions = instructions.replace(/#/, '')
                    for replace, replaceWith of @hashReplacements
                        instructions = instructions.replace(new RegExp(replace, 'g'), replaceWith) 
                    @loadInstructions(JSON.parse(instructions))            
            else
                @initInfo()
                @initCompleteListener()
                if @levelId
                    @loadLevel(@levelId)
                else
                    @showLevelSelector()                    
                    
            @initInstructions()
        
            setInterval((=>
                return unless @level
                return if location.href.indexOf(@level.id) > -1
                components = location.href.split('/')
                @loadLevel(parseInt(components[components.length - 1]))
            ), 500)
            
        
        initInfo: ->
            @$('.info .challenge').hide()
            @$('.select_level').bind 'click', => @showLevelSelector()
            @$('.all_levels_link').bind 'click', => @viewHelper.showAllLevels()
            @$('.schematic_mode').bind 'click', => alert('This will show the current circuit in standard schematic notation. We\'ll make the button look enabled when it is ready.')
        
        initInstructions: ->
            $('.load_instructions .load button').bind 'click', =>
                instructions = $('.load_instructions .load textarea').val().replace(/\s/g, '')
                @loadInstructions(JSON.parse(instructions)) if instructions.length
            $('.load_instructions .load button').trigger('click')

            @viewHelper.board.addChangeListener => 
                $('.load_instructions .get textarea').val(@getInstructions())
                $('.load_instructions .get_values textarea').val(@getValues())
                    
        loadInstructions: (instructions) ->            
            getCoordinates = (position) =>
                [xCell, yCell] = position.split(',')
                cellDimension = @viewHelper.board.cellDimension
                [parseInt(xCell) * cellDimension, parseInt(yCell) * cellDimension]
            
            for positions in instructions.wires
                nodes = []
                for position in positions
                    [x,y] = getCoordinates(position) 
                    nodes.push(x: x, y: y)
                @viewHelper.board.wires.create(nodes...)
                
            for info in instructions.components
                do (info) =>
                    component = new circuitous[info.name](recordChange: => @viewHelper.recordChange())
                    @viewHelper.addComponent(component)
                    component.setResistance(info.resistance) unless info.resistance is undefined
                    component.setVoltage(info.voltage) unless info.voltage is undefined
                    component.el.find('img').bind 'load', =>
                        setTimeout((=>
                            component.setStartDrag({})
                            [x, y] = getCoordinates(info.position)
                            componentPosition = @viewHelper.board.componentPosition
                                x: x - component.nodes[0].x
                                y: y - component.nodes[0].y
                            @viewHelper.board.addComponent(component, componentPosition.x, componentPosition.y)                            
                        ), 10)
                        
        getInstructions: ->
            instructions = []
            components = []
            
            cells = (node) =>
                cellDimension = @viewHelper.board.cellDimension
                [(node.x / cellDimension),  (node.y / cellDimension)]
            
            for id, component of @viewHelper.board.components
                node = @viewHelper.board.boardPosition(component.currentNodes()[0])
                [xCell, yCell] = cells(node)
                components.push("{\"name\": \"#{component.constructor.name}\", \"position\": \"#{xCell},#{yCell}\"}")
            instructions.push("\"components\": [#{components.join(',')}]")    
            
            wires = []
            for id, wire of @viewHelper.board.wires.all()
                [xCell0, yCell0] = cells(wire.nodes[0])
                [xCell1, yCell1] = cells(wire.nodes[1])
                wires.push("[\"#{xCell0},#{yCell0}\",\"#{xCell1},#{yCell1}\"]")
            instructions.push("\"wires\": [#{wires.join(',')}]")
        
            "{#{instructions.join(',')}}"
        
        getValues: ->
            values = []
            for componentId, component of @viewHelper.board.components
                values.push(JSON.stringify([component.constructor.name, component.current]))
            
            "[#{values.join(',')}]"
            
        initCompleteListener: ->
            @viewHelper.board.addChangeListener =>
                return unless @level.loaded
                componentIds = {}
                componentIds[id] = true for id in Object.keys(@viewHelper.board.components)
                for [componentType, current] in @level.completeValues or []
                    componentFound = false
                    for componentId, component of @viewHelper.board.components when componentIds[componentId]
                        if component.constructor.name == componentType
                            continue unless (
                                (current == 'infinite' and component.current == 'infinite') or
                                (current == undefined and component.current == undefined) or
                                (current == Math.abs(component.current)) or
                                (current == 'used' and Math.abs(component.current) > 0)
                            )
                            componentFound = true
                            delete componentIds[componentId]
                            break
                    return unless componentFound
                @showComplete()
                
        findLevel: (levelId) ->
            for world in @worlds
                for stage in world.stages
                    for level in stage.levels
                        return level if level.id == levelId        
        
        loadLevel: (levelId) ->
            if not levelId
                @level = @worlds[0].stages[0].levels[0]
            else
                @level = @findLevel(levelId)

            if not @level
                @showLevelSelector()
                return
            
            @hideModal()
            @viewHelper.board.clear()
            @showChallenge()
            title = "Circuitous Level #{@level.id}"
            history.pushState(null, title, "/puzzles/circuitous/#{@level.id}") if history.pushState
            document.title = title;
            
        showChallenge: ->
            info = @$('.info')
            @hideInfo =>
                info.find('.intro, .complete').remove()
                challenge = @$('.challenge')
                challenge.find('.description').html(@level.challenge)
                challenge.show()
                @showInfo 
                    height: 150
                    callback: =>
                        info.css(height: null)
                        @showHints()
                        @$('.show_values').addClass(if @level.values then 'on' else 'off')
                        @$('.show_values').removeClass(if @level.values then 'off' else 'on')
                        @loadInstructions(@level.instructions)
                        @level.loaded = new Date().getTime()
                
        showHints: ->
            hintsElement = @$('.challenge .hints')
            hintsElement.html('')
            hintsLinks = $(document.createElement('DIV'))
            hintsLinks.addClass('hints_links')
            for hint, index in @level.hints
                do (hint, index) =>
                    hintLink = $(document.createElement('DIV'))
                    hintLink.addClass('hint_link')
                    hintLink.addClass('hidden')
                    hintLink.addClass('disabled') if index > 1
                    hintLink.html("Hint #{index + 1}")
                
                    hintDiv = $(document.createElement('DIV'))
                    hintDiv.addClass('hint')
                    hintDiv.html("<b>Hint #{index+ 1}</b>: #{hint}")
                    hintsElement.append(hintDiv)
                
                    hintLink.bind 'click', =>
                        return if hintLink.hasClass('disabled')
                        hintLink.addClass('hidden')
                        height = hintDiv.height()
                        hintDiv.addClass('displayed')
                        hintDiv.animate(height: height + 12, marginTop: -24, marginBottom: 24, paddingTop: 12, duration: 250)
                        $(hintsElement.find('.hint_link')[index + 1]).removeClass('disabled')
                        if index == @level.hints.length - 1
                            hintsLinks.remove()
                            solution = $(document.createElement('A'))
                            solution.addClass('solution')
                            solution.html('View An Example Solution')
                            solution.bind 'click', => 
                                @showModal("<img src='/assets/images/puzzles/circuitous/levels/#{@level.id}_solution.png'/>")
                            hintsElement.append(solution)
                
                    hintsLinks.append(hintLink)
                    $.timeout 10, -> 
                        if index > 0
                            hintLink.removeClass('hidden')
                        else 
                            hintLink.trigger('click')
                            
            hintsElement.append(hintsLinks)
            
        
        hideInfo: (callback) ->
            info = @$('.info')
            info.find('iframe').remove() 
            info.addClass('hidden').animate
                height: 0
                duration: 500
                complete: => callback() if callback
            
        showInfo: ({height, callback}) ->
            info = @$('.info') 
            info.animate
                height: height 
                duration: 500
                complete: => 
                    info.removeClass('hidden')
                    callback() if callback
        
        showComplete: ->
            return if @level.completed > @level.loaded
            @level.completed = new Date().getTime()
            @viewHelper.markLevelCompleted(@level.id)
            
            # return
            completeElement = $(document.createElement('DIV'))
            completeElement.addClass('complete')
            youtube = "<img src='http://img.youtube.com/vi/#{@level.completeVideoId}/mqdefault.jpg'/><div class='play_button'><i class='icon-youtube-play'></i></div>"
            completeElement.html """
                <h1>Success</h1>
                <div class='description'>
                    #{@level.complete}
                    <div class='video_thumbnail'>
                        #{if @level.completeVideoId then youtube else 'Video Coming Soon'}
                    </div>
                </div>
                <div class='buttons'><a class='button next_level'>Next Level</a></div>
            """

            info = @$('.info') 
            @hideInfo =>
                if @level.completeVideoId
                    $.timeout 20, =>                            
                        completeElement.find('.video_thumbnail').bind 'click', =>
                            @showModal("<iframe width=\"640\" height=\"480\" src=\"//www.youtube.com/embed/#{@level.completeVideoId}?rel=0&autoplay=1\" frameborder=\"0\" allowfullscreen></iframe>")                
                
                completeElement.find('.next_level').bind 'click', => 
                    selectNext = false
                    for world in @worlds
                        for stage in world.stages
                            for level in stage.levels
                                if selectNext
                                    @loadLevel(level.id) 
                                    return true
                                selectNext = true if level.id == @level.id        
                           
                info.find('.challenge').hide()
                info.append(completeElement)
                @showInfo(height: (info.parent().height() * 0.78))

        showLevelSelector: ->
            levelSelector = $(document.createElement('DIV'))
            levelSelector.addClass('level_selector')
            
            worldsContainer = $(document.createElement('DIV'))
            worldsContainer.addClass('worlds_container')
            levelSelector.append(worldsContainer)
            
            currentWorldIndex = 0
            for world, worldIndex in @worlds
                currentWorldIndex = worldIndex if level?.completed
                worldContainer = $(document.createElement('DIV'))
                worldContainer.addClass('world')
                worldsContainer.append(worldContainer)
                for stage in world.stages
                    stageContainer = $(document.createElement('DIV'))
                    stageContainer.addClass('stage')
                    stageContainer.html("<h3>#{stage.name}</h3>")
                    levels = $(document.createElement('DIV'))
                    levels.addClass('levels')
                    stageContainer.append(levels)
                    worldContainer.append(stageContainer)
                    for level, levelIndex in stage.levels
                        do (level, levelIndex) =>
                            levelLink = $(document.createElement('A'))
                            levelLink.html("Level #{levelIndex + 1}")
                            levelLink.addClass('level')
                            levelLink.addClass('completed') if level.completed
                            levelLink.bind 'click', => 
                                @hideModal => @loadLevel(level.id)

                            levels.append(levelLink)
            
            allLevels = $(document.createElement('A'))
            allLevels.addClass('all_levels_link')
            allLevels.html('All Levels')
            allLevels.bind 'click', => @viewHelper.showAllLevels()
            levelSelector.append(allLevels)

            nextLevels = $(document.createElement('A'))
            nextLevels.addClass('next_levels_link')
            nextLevels.addClass('hidden') if currentWorldIndex >= @worlds.length - 1
            nextLevels.html('Next &nbsp; <i class=\'icon-chevron-sign-right\'></i>')
            nextLevels.bind 'click', => @switchWorld(next: true)
            levelSelector.append(nextLevels)

            prevLevels = $(document.createElement('A'))
            prevLevels.addClass('prev_levels_link')
            prevLevels.addClass('hidden') if currentWorldIndex == 0
            prevLevels.html('<i class=\'icon-chevron-sign-left\'></i> &nbsp; Previous')
            prevLevels.bind 'click', => @switchWorld(next: false)
            levelSelector.append(prevLevels)
            
            @showModal(levelSelector)
            setTimeout((=>
                worldsContainer.css(marginLeft: worldsContainer.find('.world').width() * (currentWorldIndex * -1))
            ), 100)
    
        switchWorld: ({next, worldsContainer}) ->
            worldsContainer or= @$('.worlds_container')
            worldWidth = worldsContainer.find('.world').width()
            direction = (if next then -1 else 1)
            currentMarginLeft = parseInt(worldsContainer.css('marginLeft') or 0)
            newMarginLeft = currentMarginLeft + (worldWidth * direction)
            worldsContainer.animate
                marginLeft: newMarginLeft
                duration: 500
                
            levelSelector = worldsContainer.closest('.level_selector')
            levelSelector.find('.next_levels_link').removeClass('hidden')
            levelSelector.find('.prev_levels_link').removeClass('hidden')
            levelSelector.find('.next_levels_link').addClass('hidden') if (newMarginLeft / worldWidth) * -1 >= @worlds.length - 1
            levelSelector.find('.prev_levels_link').addClass('hidden') if newMarginLeft >= 0
                    
        showModal: (content=null) ->
            if not @modalMenu
                @modalMenu = @$('.modal_menu')
                @modalMenu.find('.close').bind 'click', => @hideModal()
                
            @modalMenu.find('.modal_content').html(content) if content
            
            setTimeout((=>
                if parseInt(@modalMenu.css('left')) < 0
                    @modalMenu.css
                        opacity: 0
                        left: (@el.width()/2) - (@modalMenu.width()/2)
                        top: (@el.height()/2) - (@modalMenu.height()/2) 
                
                    @modalMenu.animate(opacity: 1, duration: 500)
            ), 100)
            
            
        hideModal: (callback) ->
            return unless @modalMenu
            @modalMenu.animate
                opacity: 0
                duration: 500
                complete: =>
                    @modalMenu.find('iframe').attr('src', '')
                    @modalMenu.css
                        left: -10000
                        top: -10000

            setTimeout(callback, 250) if callback
            
            
soma.routes
    '/puzzles/circuitous/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Circuitous
            classId: classId
            levelId: levelId

    '/puzzles/circuitous/:levelId': ({levelId}) -> 
        new soma.chunks.Circuitous
            levelId: levelId
    
    '/puzzles/circuitous': -> new soma.chunks.Circuitous
    
    
    
    

