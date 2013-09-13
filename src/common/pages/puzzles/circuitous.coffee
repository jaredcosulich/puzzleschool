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
                [(parseInt(xCell) + 0.5) * cellDimension, (parseInt(yCell) + 0.5) * cellDimension]
            
            for positions in instructions.wires
                nodes = []
                for position in positions
                    [x,y] = getCoordinates(position) 
                    nodes.push(x: x, y: y)
                @viewHelper.board.wires.create(nodes...)
                
            for info in instructions.components
                do (info) =>
                    component = new circuitous[info.name]
                    @viewHelper.addComponent(component)
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
                [(node.x / cellDimension) - 0.5,  (node.y / cellDimension) - 0.5]
            
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
                for [componentType, current] in @level.completeValues
                    componentFound = false
                    for componentId, component of @viewHelper.board.components
                        if component.constructor.name == componentType
                            continue unless (
                                (current == 'infinite' and component.current == 'infinite') or
                                (current == undefined and component.current == undefined) or
                                (current == Math.abs(component.current))
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
            
            @viewHelper.board.clear()
            @showChallenge()
            title = "Circuitous Level #{@level.id}"
            history.pushState(null, title, "/puzzles/circuitous/#{@level.id}")
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
            completeElement.html """
                <h1>Success</h1>
                <h3 class='description'>#{@level.complete}</h3>
                <div class='buttons'><a class='button next_level'>Next Level</a></div>
            """

            info = @$('.info') 
            @hideInfo =>
                if @level.completeVideo
                    $.timeout 250, =>                            
                        completeElement.find('.description').append(@level.completeVideo)
                else
                    completeElement.find('.description').append('<div class=\'no_video\'>Video Coming Soon</div>')
                
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
                @showInfo(height: (info.parent().height() * 0.81))

        showLevelSelector: ->
            levelSelector = $(document.createElement('DIV'))
            levelSelector.addClass('level_selector')
            for world, index in @worlds
                worldContainer = $(document.createElement('DIV'))
                worldContainer.addClass('world')
                worldContainer.html("<h2>World #{index + 1}</h2>")
                levelSelector.append(worldContainer)
                for stage in world.stages
                    stageContainer = $(document.createElement('DIV'))
                    stageContainer.addClass('stage')
                    stageContainer.html("<h3>#{stage.name}</h3>")
                    levels = $(document.createElement('DIV'))
                    levels.addClass('levels')
                    stageContainer.append(levels)
                    worldContainer.append(stageContainer)
                    for level, index in stage.levels
                        do (level, index) =>
                            levelLink = $(document.createElement('A'))
                            levelLink.html("Level #{index + 1}")
                            levelLink.addClass('level')
                            levelLink.addClass('completed') if level.completed
                            levelLink.bind 'click', => 
                                @hideModal => @loadLevel(level.id)

                            levels.append(levelLink)

            @showModal(levelSelector)
                    
        showModal: (content=null) ->
            if not @modalMenu
                @modalMenu = @$('.modal_menu')
                @modalMenu.find('.close').bind 'click', => @hideModal()
                
            @modalMenu.find('.content').html(content) if content
            
            if parseInt(@modalMenu.css('left')) < 0
                @modalMenu.css
                    opacity: 0
                    left: (@el.width()/2) - (@modalMenu.width()/2)
                    top: (@el.height()/2) - (@modalMenu.height()/2) 
                
                @modalMenu.animate(opacity: 1, duration: 500)
            
        hideModal: (callback) ->
            return unless @modalMenu
            @modalMenu.animate
                opacity: 0
                duration: 500
                complete: =>
                    @modalMenu.css
                        left: -10000
                        top: -10000

            setTimeout(callback, 250)
            
            
            
soma.routes
    '/puzzles/circuitous/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Circuitous
            classId: classId
            levelId: levelId

    '/puzzles/circuitous/:levelId': ({levelId}) -> 
        new soma.chunks.Circuitous
            levelId: levelId
    
    '/puzzles/circuitous': -> new soma.chunks.Circuitous
    
    
    
    

