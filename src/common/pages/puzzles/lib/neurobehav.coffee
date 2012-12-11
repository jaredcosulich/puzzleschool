neurobehav = exports ? provide('./lib/neurobehav', {})

for name, fn of require('./neurobehav_objects/index')
    neurobehav[name] = fn
    
class neurobehav.ViewHelper
    $: (selector) -> $(selector, @el)
    
    constructor: ({@el}) ->
        @oscilloscopeScreen = @$('.oscilloscope')
        
        @propertyEditor = new Properties
            el: @$('.properties')
            initDescription: => @initDescription()
        
        @game = new neurobehav.Game
            el: @el
            propertyEditor: @propertyEditor
        
    initGoalDescription: ->
        @initMoreContent(@$('.show_goal_description'), false, @goalDescriptionHtml)

    initHints: ->
        html = '<br/><br/><p style=\'text-align: center;\'>No Hints Yet</p><br/><br/>'
        @initMoreContent(@$('.hints'), false, html)
        
    initDescription: ->
        @initMoreContent(@$('.read_more_description'), true, @$('.more_description').html())

    initMoreContent: (link, bottom, html) ->
        link.one 'click', => 
            offset = link.offset()
            @showMoreSidebarContent(html, link, bottom)
            $.timeout 10, =>
                $(document.body).one 'click', => 
                    @initMoreContent(link, bottom, html)
                    @hideMoreSidebarContent(bottom)
                
    showMoreSidebarContent: (html, anchor, bottom) =>
        @moreSidebarContent = @$('.more_info')
        @moreSidebarContent.css
            height: 'auto'
            left: -1000
            top: -1000
            
        content = @moreSidebarContent.find('.content')
        content.html(html)
            
        height = Math.min(@moreSidebarContent.offset().height, @oscilloscopeScreen.offset().height)
        content.css(height: height)
        
        offset = anchor.offset()
        if bottom
            top = offset.top - height - 6
        else
            top = offset.top + offset.height + 6
            
        @moreSidebarContent.css
            height: 0
            left: @oscilloscopeScreen.offset().left
            top: (if bottom then offset.top - 6 else top)
            
        @moreSidebarContent.animate
            height: height
            top: top
            duration: 250
            
    hideMoreSidebarContent: (bottom) ->
        offset = @moreSidebarContent.offset()
        @moreSidebarContent.animate
            height: 0
            top: (if bottom then offset.top + offset.height else top)
            duration: 250
            complete: =>
                content = @moreSidebarContent.find('.content')
                content.html('') 
                content.css(height: 'auto')
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
            description: @$('.descriptions .stimulus').html()

        neuron1 = @game.addObject
            type: 'Neuron'
            position:
                top: 100
                left: 300
            threshold: 1
            spike: 0.5
            description: @$('.descriptions .neuron').html()
            inhibitoryDescription: @$('.descriptions .inhibitory').html()
            excitatoryDescription: @$('.descriptions .excitatory').html()

        stimulus.connectTo(neuron1)

        neuron2 = @game.addObject
            type: 'Neuron'
            position:
                top: 300
                left: 200
            threshold: 1
            spike: 0.5
            description: @$('.descriptions .neuron').html()
            inhibitoryDescription: @$('.descriptions .inhibitory').html()
            excitatoryDescription: @$('.descriptions .excitatory').html()

        oscilloscope = @game.addObject
            type: 'Oscilloscope'
            position:
                top: 80
                left: 340
            container: @oscilloscopeScreen
            description: @$('.descriptions .oscilloscope').html()

        oscilloscope.attachTo(neuron1)

        @goalDescriptionHtml = """
            <h4>Get The Heart To Beat</h4>
            <p>Using the red button add enough electricity to the neuron to cause it to exceed it's threshold.</p>
            <p>The threshold line is depicted below in the oscilloscope screen as a dashed green line.</p>
        """
        
        @initGoalDescription()
        @initHints()
        
