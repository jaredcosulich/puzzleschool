neurobehav = exports ? provide('./lib/neurobehav', {})

for name, fn of require('./neurobehav_objects/index')
    neurobehav[name] = fn
    
class neurobehav.ViewHelper
    $: (selector) -> $(selector, @el)
    
    constructor: ({@el}) ->
        @game = new neurobehav.Game
            el: @el
            objectEditor: @objectEditor
            showExplicitContent: (html) => @showExplicitContent(html)
        
    initGoalDescription: ->
        @initExtraContent(@$('.show_goal_description'), @goalDescriptionHtml)

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
                top: 120
                left: 284
            voltage: 1.5
            duration: 250
            description: @$('.descriptions .stimulus').html()

        neuron1 = @game.addObject
            type: 'Neuron'
            position:
                top: 174
                left: 400
            threshold: 1
            spike: 0.5
            description: @$('.descriptions .neuron').html()
            inhibitoryDescription: @$('.descriptions .inhibitory').html()
            excitatoryDescription: @$('.descriptions .excitatory').html()

        stimulus.connectTo(neuron1)

        neuron2 = @game.addObject
            type: 'Neuron'
            position:
                top: 360
                left: 400
            threshold: 1
            spike: 0.5
            description: @$('.descriptions .neuron').html()
            inhibitoryDescription: @$('.descriptions .inhibitory').html()
            excitatoryDescription: @$('.descriptions .excitatory').html()

        oscilloscope1 = @game.addObject
            type: 'Oscilloscope'
            position:
                top: 106
                left: 514
            board: @game.board
            description: @$('.descriptions .oscilloscope').html()

        oscilloscope1.attachTo(neuron1)


        # oscilloscope2 = @game.addObject
        #     type: 'Oscilloscope'
        #     position:
        #         top: 240
        #         left: 280
        #     board: @game.board
        #     description: @$('.descriptions .oscilloscope').html()
        # 
        # oscilloscope2.attachTo(neuron2)
        
        goal = @game.createGoal
            radius: 210
            interaction: =>
                neuron1.currentVoltage >= neuron1.properties.threshold.value
            test: =>
                neuron1.currentVoltage >= neuron1.properties.threshold.value
            html: """
                <h4>The Goal: Get The Worm To Wiggle</h4>
                <p>Using the stimulus add enough electricity to the neuron to cause it to exceed it's threshold.</p>
                <p>The threshold line is depicted below in the oscilloscope screen as a dashed green line.</p>
                <p>When the neuron reaches its threshold it fires, causing the worm to wiggle.</p>
            """
        
        goal.display()
        
        @initGoalDescription()
        @initHints()
        
