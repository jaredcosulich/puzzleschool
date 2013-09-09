levels = exports ? provide('./lib/xyflyer_objects/levels', {})

levels.WORLDS = [
    {
        stages: [
            {
                name: 'Circuit Basics'
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
                    {
                        id: 1378413019525
                        challenge: "Stop electricity flowing to the light by creating a short circuit."
                        instructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Lightbulb", "position": "9,4"}],"wires": [["9,9","9,8"],["9,8","9,7"],["9,7","10,7"],["10,7","11,7"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,7","7,7"],["7,7","8,7"],["8,7","8,8"],["8,8","8,9"],["6,7","6,6"],["6,6","6,5"],["6,5","6,4"]]}
                        hints: [
                            'A short circuit is a path from the negative to the positive terminal of the battery with no resistance.'
                            'In this circuit the lightbulb creates resistance.'
                            'Draw a path for the electrons to take from the positive to the negative terminal that does not touch the lightbulb.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Lightbulb", "position": "9,4"}],"wires": [["9,9","9,8"],["9,8","9,7"],["9,7","10,7"],["10,7","11,7"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,7","7,7"],["8,7","8,8"],["8,8","8,9"],["6,7","6,6"],["6,6","6,5"],["6,5","6,4"],["7,7","8,7"],["6,5","7,5"],["7,5","8,5"],["8,5","9,5"],["9,5","10,5"],["10,5","11,5"]]}
                        completeValues: [["Battery",'infinity'],["Lightbulb",null]]
                        complete: '''
                            A short circuit occurs when electrons have a path from the negative terminal of the battery to the positive terminal without any resistance.
                        '''
                        completeVideo: '<iframe width="300" height="225" src="//www.youtube.com/embed/XRUy1rggIA8?rel=0" frameborder="0" allowfullscreen></iframe>'
                    }
                ]
            }
        ]
    }
]
