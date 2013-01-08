neurobehav = exports ? provide('./lib/neurobehav', {})

for name, fn of require('./neurobehav_objects/index')
    neurobehav[name] = fn
    
class neurobehav.ViewHelper
    $: (selector) -> $(selector, @el)
    
    constructor: ({@el}) ->
        @objectEditor = new ObjectEditor
            el: @$('.object_editor')
        
        @game = new neurobehav.Game
            el: @el
            objectEditor: @objectEditor
            showExplicitContent: (html) => @showExplicitContent(html)
        
    initGoalDescription: ->
        @initExtraContent(@$('.show_goal_description'), @goalDescriptionHtml)
        @objectEditor.showExtraContent(@goalDescriptionHtml)

    initHints: ->
        html = '<br/><br/><p style=\'text-align: center;\'>No Hints Yet</p><br/><br/>'
        @initExtraContent(@$('.hints'), html)
        
    initExtraContent: (link, html) ->
        link.bind 'click', => 
            if @objectEditor.extraContent == html 
                @objectEditor.hideExtraContent()
            else
                @objectEditor.showExtraContent(html)
                
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
            board: @game.board
            description: @$('.descriptions .oscilloscope').html()

        oscilloscope.attachTo(neuron1)

        @goalDescriptionHtml = """
            <h4>The Goal: Get The Heart To Beat</h4>
            <p>Using the red button add enough electricity to the neuron to cause it to exceed it's threshold.</p>
            <p>The threshold line is depicted below in the oscilloscope screen as a dashed green line.</p>
        """
        
        @initGoalDescription()
        @initHints()
        
