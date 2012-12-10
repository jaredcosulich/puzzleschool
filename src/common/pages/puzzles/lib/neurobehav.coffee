neurobehav = exports ? provide('./lib/neurobehav', {})

for name, fn of require('./neurobehav_objects/index')
    neurobehav[name] = fn
    
class neurobehav.ViewHelper
    $: (selector) -> $(selector, @el)
    
    constructor: ({@el}) ->
        @oscilloscopeScreen = @$('.oscilloscope')
        
        @game = new neurobehav.Game
            el: @el
        
        @initGoalDescription()
        @initHints()
        
    initGoalDescription: ->
        goalDescription = @$('.show_goal_description')
        showGoalDescription = =>
            offset = goalDescription.offset()
            @showMoreSidebarContent(@goalDescriptionHtml, offset.top + offset.height + 6)
            goalDescription.one 'click', => 
                @initGoalDescription()
                @hideMoreSidebarContent()
            
        goalDescription.one 'click', => showGoalDescription()
        
    initHints: ->
        hints = @$('.hints')
        showHint = =>
            offset = hints.offset()
            @showMoreSidebarContent('<br/><br/><p style=\'text-align: center;\'>No Hints Yet</p><br/><br/>', offset.top + offset.height + 6)
            hints.one 'click', => 
                @initHints()
                @hideMoreSidebarContent()
            
        hints.one 'click', => showHint()
                    
    showMoreSidebarContent: (html, top) =>
        @moreSidebarContent = @$('.more_info')
        @moreSidebarContent.css
            height: 'auto'
            left: -1000
            top: -1000
            
        content = @moreSidebarContent.find('.content')
        content.html(html)
            
        height = @moreSidebarContent.height()
        content.css(height: height)

        @moreSidebarContent.css
            height: 0
            left: @oscilloscopeScreen.offset().left
            top: top
            
        @moreSidebarContent.animate
            height: height
            duration: 250
            
    hideMoreSidebarContent: ->
        @moreSidebarContent.animate
            height: 0
            duration: 250
            complete: => 
                @moreSidebarContent.css
                    height: 'auto'
                    left: -1000
                    top: -1000

    loadFirstLevel: ->        
        stimulus = @game.addObject
            type: 'Stimulus'
            position:
                top: 100
                left: 100
            voltage: 1.5
            duration: 250

        neuron1 = @game.addObject
            type: 'Neuron'
            position:
                top: 100
                left: 300
            threshold: 1
            spike: 0.5

        stimulus.connectTo(neuron1)

        neuron2 = @game.addObject
            type: 'Neuron'
            position:
                top: 300
                left: 200
            threshold: 1
            spike: 0.5

        oscilloscope = @game.addObject
            type: 'Oscilloscope'
            position:
                top: 80
                left: 340
            container: @oscilloscopeScreen

        oscilloscope.attachTo(neuron1)

        @goalDescriptionHtml = """
            <h4>Get The Heart To Beat</h4>
            <p>Using the red button add enough electricity to the neuron to cause it to exceed it's threshold.</p>
            <p>The threshold line is depicted below in the oscilloscope screen as a dashed green line.</p>
        """
