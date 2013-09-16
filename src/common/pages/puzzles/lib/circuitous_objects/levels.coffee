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
                            <p>A circuit is not complete until a wire connects the negative terminal to the positive terminal.</p>
                            <p>When the circuit is complete electricity will flow, powering the lightbulb.</p>
                        '''
                        completeVideo: '<iframe width="300" height="225" src="//www.youtube.com/embed/zSOo2_ophoE?rel=0" frameborder="0" allowfullscreen></iframe>'
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
                            <p>A short circuit occurs when electrons have a path from the negative terminal of the battery to the positive terminal without any resistance.</p>
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
                            <p>The resistor adds resistance to the circuit, slowing the flow of electrons enough to prevent any damage to the battery.</p>
                        '''
                        values: false
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
                            <p>This is a circuit with two resistors (lightbulbs) placed in series.</p>
                            <p>Lightbulb #1 dims because the circuit now has twice as much resistance in it.</p>
                        '''
                        values: true
                    }
                    {
                        id: 1378919614968
                        challenge: "Reduce the current flowing through the circuit to 0.6 amps."
                        instructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Lightbulb", "position": "9,4"},{"name": "Resistor", "position": "2,4"}],"wires": [["9,9","9,8"],["9,8","9,7"],["9,7","10,7"],["10,7","11,7"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,7","7,7"],["7,7","8,7"],["8,7","8,8"],["8,8","8,9"],["6,4","6,5"],["6,5","6,6"],["6,6","6,7"]]}
                        hints: [
                            'The lightbulb creates 5 Ohms of resistance and the resistor creates 10 Ohms.'
                            'If both are added to the circuit there will be 15 Ohms of resistance in the circuit.'
                            'Erase some wire and add the resistor to the circuit to reduce the current to 0.6 Amps.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Lightbulb", "position": "9,4"},{"name": "Resistor", "position": "6,4"}],"wires": [["9,9","9,8"],["9,8","9,7"],["9,7","10,7"],["10,7","11,7"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,7","7,7"],["7,7","8,7"],["8,7","8,8"],["8,8","8,9"]]}
                        completeValues: [["Battery",0.6],["Lightbulb",0.6],["Resistor",0.6]]
                        complete: '''
                            <p>The resistance in this circuit is the resistance of the lightbulb + the resistance of the resistor.</p>
                            <p>The current in the circuit = total voltage / total resistance (9 Volts / 15 Ohms = 0.6 Amps).</p>
                        '''
                        values: true
                    }
                    {
                        id: 1379192008654
                        challenge: "Create a circuit with 0.36 amps of current flowing through it."
                        instructions: {"components": [{"name": "Lightbulb", "position": "11,2"},{"name": "Lightbulb", "position": "13,2"},{"name": "Lightbulb", "position": "15,2"},{"name": "Resistor", "position": "7,0"},{"name": "Resistor", "position": "3,0"},{"name": "Battery", "position": "8,12"},{"name": "Resistor", "position": "5,0"}],"wires": []}
                        hints: [
                            'The resistors create 10 Ohms of resistance, the lightbulbs create 5 Ohms of resistance.'
                            'Resistance (R) = Voltage (V) / Current (I)'
                            'You\'ll need to add 25 Ohms of resistance to the circuit.'
                        ]
                        completeInstructions: {"components": [{"name": "Lightbulb", "position": "13,2"},{"name": "Lightbulb", "position": "15,2"},{"name": "Resistor", "position": "7,0"},{"name": "Battery", "position": "8,12"},{"name": "Resistor", "position": "5,8"},{"name": "Resistor", "position": "12,8"},{"name": "Lightbulb", "position": "9,7"}],"wires": [["8,12","7,12"],["7,12","6,12"],["6,12","5,12"],["5,8","5,7"],["5,7","6,7"],["6,7","7,7"],["7,7","8,7"],["8,7","9,7"],["9,7","10,7"],["10,7","11,7"],["11,7","12,7"],["12,7","12,8"],["12,11","12,12"],["12,12","11,12"],["11,12","10,12"],["10,12","9,12"],["5,11","5,12"]]}
                        completeValues: [["Battery",0.36]]
                        complete: '''
                            <p>Ohm\'s law states that I = V/R or Current = Voltage/Resistance.</p>
                            <p>In this case we need to add 25 Ohms of resistance to the circuit to get 0.36 Amps (9 / 25 = 0.36).</p>
                        '''
                        values: true
                    }
                    
                ]
            }
        ]
    }
]
