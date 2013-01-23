neurobehav = exports ? provide('./lib/neurobehav', {})

for name, fn of require('./neurobehav_objects/index')
    neurobehav[name] = fn
    
class neurobehav.ViewHelper
    $: (selector) -> $(selector, @el)
    
    constructor: ({@el, @nextLevel}) ->
        @game = new neurobehav.Game
            el: @el
            objectEditor: @objectEditor
            showExplicitContent: (html) => @showExplicitContent(html)

    loadLevel: (level) ->
        @["loadLevel#{level}"]()
                        
    loadLevel1: ->        
        stimulus = @game.addObject
            type: 'Stimulus'
            position:
                top: 160
                left: 284
            voltage: 1.5
            duration: 250
            description: @$('.descriptions .stimulus').html()

        neuron1 = @game.addObject
            type: 'Neuron'
            position:
                top: 214
                left: 400
            threshold: 1
            spike: 0.5
            description: @$('.descriptions .neuron').html()
            inhibitoryDescription: @$('.descriptions .inhibitory').html()
            excitatoryDescription: @$('.descriptions .excitatory').html()

        stimulus.connectTo(neuron1)

        oscilloscope1 = @game.addObject
            type: 'Oscilloscope'
            position:
                top: 150
                left: 520
            board: @game.board
            description: @$('.descriptions .oscilloscope').html()

        oscilloscope1.attachTo(neuron1)

        goal = @game.createGoal
            radius: 150
            interaction: =>
                neuron1.currentVoltage >= neuron1.properties.threshold.value
            test: =>
                neuron1.currentVoltage >= neuron1.properties.threshold.value
            html: """
                <h3>The Goal: Get The Worm To Wiggle</h3>
                <br/>
                <p>Using the stimulus add enough electricity to the neuron to cause it to exceed it's threshold.</p>
                <p>The threshold line is depicted below in the oscilloscope screen as a dashed green line.</p>
                <p>When the neuron reaches its threshold it fires, causing the worm's muscle to contract and making the worm wiggle.</p>
                <p>Click anywhere outside this bubble to get started!</p>
            """
            onSuccess: (bubble) =>
                bubble.setHtml """
                    <h3>Success!</h3>
                    <br/>
                    <p>
                        You were able to introduce enough electricity in to the neuron to get it to generate it's 
                        action potential and fire.
                    </p>
                    <p>The motor neuron firing resulted in the worm contracting it's muscles and wiggling!</p>
                    <br/>
                    <h4>Congrats!</h4>
                    <p><a>Continue to the next level ></a></p>
                """
                bubble.show({})
                bubble.htmlContainer.find('a').bind 'click', => 
                    bubble.hide(callback: => @nextLevel())
                    
        setTimeout((=> goal.display()), 500)

    loadLevel2: ->
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
                top: 104
                left: 524
            board: @game.board
            description: @$('.descriptions .oscilloscope').html()

        oscilloscope1.attachTo(neuron1)

        oscilloscope2 = @game.addObject
            type: 'Oscilloscope'
            position:
                top: 306
                left: 174
            connectorPosition:
                top: 390
                left: 410            
            board: @game.board
            description: @$('.descriptions .oscilloscope').html()

        oscilloscope2.attachTo(neuron2)

        goal = @game.createGoal
            radius: 210
            interaction: =>
                neuron2.currentVoltage >= neuron2.properties.threshold.value
            test: =>
                neuron2.currentVoltage >= neuron2.properties.threshold.value
            html: """
                <h3>The Goal: Get The Worm To Wiggle</h3>
                <br/>
                <p>Using the stimulus add enough electricity to both neurons to cause them to exceed their thresholds and fire.</p>
                <p>Click anywhere outside this bubble to get started!</p>
            """
            onSuccess: (bubble) =>
                bubble.setHtml """
                    <h3>Success!</h3>
                    <br/>
                    <p>
                        You were able to introduce enough electricity in to the neuron to get it to cross it's voltage
                        threshold and fire.
                    </p>
                    <p>The neuron firing resulted in the worm wiggling!</p>
                    <br/>
                    <h4>Congrats!</h4>
                    <p>Unfortunately those are all of the levels we have so far.</p>
                """
                bubble.show({})

        setTimeout((=> goal.display()), 500)
    
