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
                            'Complete the wire by connecting the loose end to the positive node.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "7,10"},{"name": "Lightbulb", "position": "8,6"}],"wires": [["8,10","8,9"],["8,9","8,8"],["8,8","8,7"],["8,7","8,6"],["8,6","7,6"],["7,6","7,7"],["7,7","7,8"],["7,8","7,9"],["7,9","7,10"]]}
                        completeValues: [["Battery",1.8],["Lightbulb",1.8]]
                        complete: '''
                            In order for a circuit to provide power to a lightbulb the circuit must provide a connection from 
                            the negative terminal of a battery, to the lightbulb, and back to the positive terminal.
                        '''
                    }
                ]
            }
        ]
    }
]
