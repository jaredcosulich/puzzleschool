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
                            'Click anywhere on the board to draw a wire. Click on an existing wire to erase it.'
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
                        completeVideo: '<iframe width="300" height="225" src="//www.youtube.com/embed/pXxzB1l520E?rel=0" frameborder="0" allowfullscreen></iframe>'
                        values: false
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
                        completeValues: [["Battery",'infinite'],["Lightbulb",0]]
                        complete: '''
                            A short circuit occurs when electrons have a path from the negative terminal of the battery to the positive terminal without any resistance.
                        '''
                        values: false
                    }                    
                    {
                        id: 1378919605524
                        challenge: "Add resistance to the circuit to stop the excessive current from flowing."
                        instructions: {"components": [{"name": "Battery", "position": "8,8"},{"name": "Resistor", "position": "3,3"}],"wires": [["8,8","8,7"],["8,7","7,7"],["7,7","6,7"],["6,7","6,6"],["6,6","6,5"],["11,7","10,7"],["10,7","9,7"],["9,7","9,8"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["7,2","8,2"],["8,2","9,2"],["9,2","10,2"],["11,3","11,4"],["6,5","6,4"],["6,4","6,3"],["6,3","6,2"],["6,2","7,2"],["10,2","11,2"],["11,2","11,3"]]}
                        hints: [
                            'Without any resistance a circuit will overheat and can destroy the battery.'
                            'You\'ll need to erase part of the circuit in order to fit the resistor in. Click and drag over existing wires to erase them.'
                            'Erase a section of the circuit and then drag and drop the resistor in to place so that the wires touch each end of the resistor.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "8,8"},{"name": "Resistor", "position": "6,3"}],"wires": [["8,8","8,7"],["8,7","7,7"],["7,7","6,7"],["6,7","6,6"],["11,7","10,7"],["10,7","9,7"],["9,7","9,8"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["7,2","8,2"],["8,2","9,2"],["9,2","10,2"],["11,3","11,4"],["6,3","6,2"],["6,2","7,2"],["10,2","11,2"],["11,2","11,3"]]}
                        completeValues: [["Battery",0.9],["Resistor",0.9]]
                        complete: '''
                            The resistor adds resistance to the circuit, slowing the flow of electrons enough to prevent any damage to the battery.
                        '''
                        values: false
                    }
                    {
                        id: 1378919614968
                        challenge: "Reduce the current flowing through the circuit to 0.9 amps."
                        instructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Lightbulb", "position": "9,4"}],"wires": [["9,9","9,8"],["9,8","9,7"],["9,7","10,7"],["10,7","11,7"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,7","7,7"],["7,7","8,7"],["8,7","8,8"],["8,8","8,9"],["6,7","6,6"],["6,6","6,5"],["6,5","6,4"]]}
                        hints: [
                            'Both the lightbulb and the resistor add resistance to the circuit, reducing the flow of current.'
                            'The flow of current is constant throughout this circuit.'
                            'Drag and drop both components on to the circuit to reduce the current.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Lightbulb", "position": "9,4"}],"wires": [["9,9","9,8"],["9,8","9,7"],["9,7","10,7"],["10,7","11,7"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,7","7,7"],["8,7","8,8"],["8,8","8,9"],["6,7","6,6"],["6,6","6,5"],["6,5","6,4"],["7,7","8,7"],["6,5","7,5"],["7,5","8,5"],["8,5","9,5"],["9,5","10,5"],["10,5","11,5"]]}
                        completeValues: [["Battery",'infinite'],["Lightbulb",0]]
                        complete: '''
                            A short circuit occurs when electrons have a path from the negative terminal of the battery to the positive terminal without any resistance.
                        '''
                        values: true
                    }
                    {
                        id: 1378789808762
                        challenge: "Reduce the amount of current going to Lightbulb #1, causing it to dim, by adding Lightbulb #2 to the circuit."
                        instructions: {"components": [{"name": "Battery", "position": "8,8"},{"name": "Lightbulb", "position": "13,3"},{"name": "Lightbulb", "position": "7,4"}],"wires": [["9,8","9,7"],["9,7","10,7"],["10,7","10,6"],["10,6","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,4","6,5"],["6,5","6,6"],["6,6","7,6"],["7,6","7,7"],["7,7","8,7"],["8,7","8,8"]]}
                        hints: [
                            'Two lightbulbs placed next to each other in a circuit are said to be in "series".'
                            'Resistors (in this case the lightbulbs) placed in series add more resistance to the circuit.'
                            'Drag Lightbulb #2 anywhere in to the circuit, doubling the resistance and dimming Lightbulb #1.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "8,8"},{"name": "Lightbulb", "position": "7,4"},{"name": "Lightbulb", "position": "10,4"}],"wires": [["9,8","9,7"],["9,7","10,7"],["10,7","10,6"],["10,6","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,4","6,5"],["6,5","6,6"],["6,6","7,6"],["7,6","7,7"],["7,7","8,7"],["8,7","8,8"]]}
                        completeValues: [["Battery",0.9],["Lightbulb",0.9],["Lightbulb",0.9]]
                        complete: '''
                            This is a circuit with two resistors (lightbulbs) placed in series.
                            <br/><br/>
                            Lightbulb #1 dims because the circuit now has twice as much resistance in it.
                        '''
                        values: true
                    }
                ]
            }
        ]
    }
]
