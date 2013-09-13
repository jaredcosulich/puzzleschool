circuitous = exports ? provide('./lib/circuitous', {})

for name, fn of require('./circuitous_objects/index')
    circuitous[name] = fn
    
class circuitous.ChunkHelper
    constructor: () ->
    

class circuitous.ViewHelper
    constructor: ({@el, @worlds, @loadLevel}) ->
        @init()
        
    $: (selector) -> $(selector, @el)
        
    init: ->
        @board = new circuitous.Board
            el: @$('.board')

        @selector = new circuitous.Selector
            add: (component) => @addComponent(component, true)
            button: @$('.add_component')
            selectorHtml: '<h2>Add Another Component</h2>' 
            
        @initLevelSelector()
        @initValues()           
        
    addComponent: (component, onBoard=false) ->
        component.appendTo(@board.cells)
        component.setName("#{component.constructor.name} ##{1}")
        img = component.el.find('img')
        component.el.css(left: if onBoard then 10 else -10000)
        img.bind 'load', =>
            component.el.width(img.width())
            component.el.height(img.height())
            $.timeout 10, =>
                component.initCurrent()
                component.initTag(@$('.show_values').hasClass('on')) 
                component.initDrag(
                    component.el, 
                    (component, x, y, stopDrag) => @dragComponent(component, x, y, stopDrag),
                    true,
                    component.dragBuffer
                )
        
    dragComponent: (component, x, y, state) ->
        if state == 'start'
            @board.removeComponent(component)
        else if state == 'stop'
            if not @board.addComponent(component, x, y)
                @board.removeComponent(component)
                component.resetDrag()
        component.tag?.position()
    
    initValues: ->
        showValues = @$('.show_values')
        showValues.bind 'click.toggle_values touchstart.toggle_values', => 
            hideValues = showValues.hasClass('on')
            showValues.removeClass(if hideValues then 'on' else 'off')
            showValues.addClass(if hideValues then 'off' else 'on')
            for cid, component of @board.components
                component.tag[if hideValues then 'hide' else 'show']()
        
    initLevelSelector: ->    
        levelSelector = @$('.level_selector')
        levelSelector.find('.back_to_challenge').bind 'click', => @showLevel()
        
        levelsContainer = levelSelector.find('.levels_container')
        for world, index in @worlds
            worldContainer = $(document.createElement('DIV'))
            worldContainer.addClass('world')
            levelsContainer.append(worldContainer)
            for stage in world.stages
                stageContainer = $(document.createElement('DIV'))
                stageContainer.addClass('stage')
                stageContainer.html("<h2>#{stage.name}</h2>")
                levels = $(document.createElement('DIV'))
                levels.addClass('levels')
                stageContainer.append(levels)
                worldContainer.append(stageContainer)
                lastCompleted = true
                for level, index in stage.levels
                    do (level, index) =>
                        levelElement = $(document.createElement('DIV'))
                        levelElement.addClass('level')
                        levelElement.addClass("level_#{level.id}")
                        levelElement.addClass('completed') if level.completed
                        levelElement.addClass('inactive') unless level.completed or lastCompleted
                        
                        levelInfo = $(document.createElement('DIV'))
                        levelInfo.addClass('level_info')
                        levelInfo.html """
                            <h3>#{level.challenge}</h3>
                            <div class='completed'>
                                <div  class='hints'>
                                    <h3>Hints:</h3>
                                    <ul>
                                        #{("<li>#{hint}</li>" for hint in level.hints).join('')}
                                    </ul>
                                </div>
                                <div class='complete_lesson'>
                                    <h3>Lesson:</h3>
                                    #{level.complete.replace('<br/><br/>', '<br/>')}
                                </div>
                            </div>
                        """
                        levelElement.append(levelInfo)
                        levelElement.prepend(level.completeVideo.replace(/iframe/, 'iframe class=\'completed\''))
                        
                        levelLink = $(document.createElement('A'))
                        if level.completed
                            levelLink.html('Completed - Load Again')
                        else
                            levelLink.html('Load Challenge')
                        levelLink.addClass('level_link')
                        levelLink.bind 'click', => 
                            @loadLevel(level.id)
                            @showLevel()
                        
                        levelElement.append(levelLink)
                            
                        levels.append(levelElement)
                        lastCompleted = level.completed
        
    markLevelCompleted: (levelId) ->
        level = @$(".level_#{levelId}")
        level.addClass('completed')     
        level.find('.level_link').html('Completed - Load Again')
        nextLevel = level.next()
        nextLevel.removeClass('inactive')
        @$('.levels_container').scrollTop(nextLevel.offset().top - @$('.levels_container').offset().top - 200)
        
    showLevelSelector: -> @el.addClass('show_level_selector')
        
    showLevel: -> @el.removeClass('show_level_selector')
        
