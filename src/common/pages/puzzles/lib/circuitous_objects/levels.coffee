levels = exports ? provide('./lib/xyflyer_objects/levels', {})

levels.WORLDS = [
    {
        stages: [
            {
                name: 'Working Circuits'
                assets: 
                    person: 1
                levels: [
                    {
                        id: 1377808756337
                        challenge: "Draw more wire to complete the circuit and power the lightbulb."
                        instructions: {"components": [{"name": "Battery", "position": "7,10"},{"name": "Lightbulb", "position": "8,6"}],"wires": [["8,10","8,9"],["8,9","8,8"],["8,8","8,7"],["8,7","8,6"],["8,6","7,6"],["7,6","7,7"],["7,7","7,8"]]}
                        hints: [
                            'Click anywhere on the board to draw a wire (click on an existing wire to erase it).'
                            'Complete the wire by connecting the loose end to the positive terminal of the battery.'
                            'The positive terminal is right above the plus sign on the battery.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "7,10"},{"name": "Lightbulb", "position": "8,6"}],"wires": [["8,10","8,9"],["8,9","8,8"],["8,8","8,7"],["8,7","8,6"],["8,6","7,6"],["7,6","7,7"],["7,7","7,8"],["7,8","7,9"],["7,9","7,10"]]}
                        completeValues: [["Battery",1.8],["Lightbulb",1.8]]
                        complete: '''
                            A circuit is not complete until a wire connects the negative terminal to the positive terminal.
                            <br/><br/>
                            When the circuit is complete electricity will flow, powering the lightbulb.
                        '''
                        completeVideo: '<iframe width="300" height="225" src="//www.youtube.com/embed/XRUy1rggIA8?rel=0" frameborder="0" allowfullscreen></iframe>'
                    }
                ]
            }
        ]
    }
]
