levels = exports ? provide('./lib/xyflyer_objects/levels', {})

levels.WORLDS = [
    {
        stages: [
            {
                name: 'Circuit Basics'
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
                        completeVideoId: 'XnKQkonpkIU'
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
                        completeVideoId: '23meTsVdTco'
                        values: false
                    }                    
                    {
                        id: 1378919605524
                        challenge: "Add resistance to the circuit to stop the excessive current from flowing and destroying the battery."
                        instructions: {"components": [{"name": "Battery", "position": "8,8"},{"name": "Resistor", "position": "3,3"}],"wires": [["8,8","8,7"],["8,7","7,7"],["7,7","6,7"],["6,7","6,6"],["6,6","6,5"],["11,7","10,7"],["10,7","9,7"],["9,7","9,8"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["7,2","8,2"],["8,2","9,2"],["9,2","10,2"],["11,3","11,4"],["6,5","6,4"],["6,4","6,3"],["6,3","6,2"],["6,2","7,2"],["10,2","11,2"],["11,2","11,3"]]}
                        hints: [
                            'You\'ll need to erase part of the circuit in order to fit the resistor in.'
                            'Click and drag over existing wires to erase them.'
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
                        id: 1379359682379
                        challenge: "Stop current from flowing to Lightbulb #2 by adding a path for current to bypass it that has no resistance."
                        instructions: {"components": [{"name": "Battery", "position": "9,9"},{"name": "Lightbulb", "position": "13,5"},{"name": "Lightbulb", "position": "6,5"}],"wires": [["14,5","14,6"],["14,6","14,7"],["5,5","5,6"],["5,6","5,7"],["10,9","11,9"],["11,9","12,9"],["12,9","13,9"],["13,9","14,9"],["14,9","14,8"],["14,8","14,7"],["14,5","13,5"],["13,5","12,5"],["12,5","11,5"],["11,5","10,5"],["10,5","9,5"],["9,5","8,5"],["8,5","7,5"],["7,5","6,5"],["6,5","5,5"],["5,7","5,8"],["7,9","8,9"],["9,9","8,9"],["7,9","6,9"],["5,9","6,9"],["5,9","5,8"]]}
                        hints: [
                            'A path without any components on it will not provide any resistance for the electrons.'
                            'You need to create a path from the negative terminal to Lightbulb #1 that does not touch Lightbulb #2.'
                            'Draw more wire from just after the negative terminal to just after Lightbulb #2.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "9,9"},{"name": "Lightbulb", "position": "13,5"},{"name": "Lightbulb", "position": "6,5"}],"wires": [["14,5","14,6"],["14,6","14,7"],["5,5","5,6"],["5,6","5,7"],["10,9","11,9"],["11,9","12,9"],["12,9","13,9"],["13,9","14,9"],["14,9","14,8"],["14,8","14,7"],["14,5","13,5"],["13,5","12,5"],["12,5","11,5"],["11,5","10,5"],["10,5","9,5"],["9,5","8,5"],["8,5","7,5"],["7,5","6,5"],["6,5","5,5"],["5,7","5,8"],["7,9","8,9"],["9,9","8,9"],["7,9","6,9"],["5,9","6,9"],["5,9","5,8"],["11,9","11,8"],["11,8","11,7"],["11,7","11,6"],["11,6","11,5"]]}
                        completeValues: [["Battery",1.8],["Lightbulb",0],["Lightbulb",1.8]]
                        complete: '''
                            <p>Current will flow between two paths based on the amount of resistance in each path.</p>
                            <p>Adding wire to the circuit bypassing Lightbulb #2 diverts almost all of the current down the new path.</p>
                        '''
                        values: false
                    }
                    {
                        id: 1379364502530
                        challenge: "Draw wire to create a circuit that contains both the lightbulb and the resistor."
                        instructions: {"components": [{"name": "Battery", "position": "9,8"},{"name": "Lightbulb", "position": "11,4"},{"name": "Resistor", "position": "7,4"}],"wires": []}
                        hints: [
                            'A complete circuit must connect from the negative to the positive terminal of the battery with enough resistance to avoid damaging the battery.'
                            'Draw wire from the battery through the lightbulb to the resistor and back to the battery.'
                            'Be sure not to draw wire all the way through the resistor. Draw to one end of the resistor and then start from the other end.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "9,8"},{"name": "Lightbulb", "position": "11,4"},{"name": "Resistor", "position": "7,4"}],"wires": [["10,8","11,8"],["11,8","12,8"],["12,8","12,7"],["12,7","12,6"],["12,6","12,5"],["12,5","12,4"],["12,4","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,7","7,8"],["7,8","8,8"],["8,8","9,8"]]}
                        completeValues: [["Battery",0.6],["Lightbulb",0.6],["Resistor",0.6]]
                        complete: '''
                            <p>You\'ve created a simple circuit with multiple components.</p>
                        '''
                        values: false
                    }
                ]
            },{
                name: 'Ohm\'s Law'
                levels: [
                    {
                        id: 1379374713401
                        challenge: "Create a circuit that has 0.9 Amps of current flowing through it."
                        instructions: {"components": [{"name": "Battery", "position": "9,8"},{"name": "Resistor", "position": "3,3"}],"wires": [["10,8","11,8"],["11,8","12,8"],["12,8","13,8"],["13,8","13,7"],["13,7","13,6"],["13,6","13,5"],["13,5","13,4"],["13,4","13,3"],["13,3","13,2"],["13,2","12,2"],["12,2","11,2"],["11,2","10,2"],["10,2","9,2"],["9,2","8,2"],["8,2","7,2"],["7,2","6,2"],["6,8","7,8"],["7,8","8,8"],["8,8","9,8"],["6,2","6,3"],["6,3","6,4"],["6,4","6,5"],["6,5","6,6"],["6,6","6,7"],["6,7","6,8"]]}
                        hints: [
                            'You can calculate the amount of current in a circuit using <a href=\'http://en.wikipedia.org/wiki/Ohm%27s_law\' target=\'blank\'>Ohm\'s law</a>: I = V / R <br/> (current = voltage / resistance)'
                            'The battery provides 9 Volts of electricity. The resistor provides 10 Ohms of resistance.'
                            'With the resistor added to the circuit there will be 0.9 Amps of electricity (9 / 10 = 0.9).'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "9,8"},{"name": "Resistor", "position": "6,3"}],"wires": [["10,8","11,8"],["11,8","12,8"],["12,8","13,8"],["13,8","13,7"],["13,7","13,6"],["13,6","13,5"],["13,5","13,4"],["13,4","13,3"],["13,3","13,2"],["13,2","12,2"],["12,2","11,2"],["11,2","10,2"],["10,2","9,2"],["9,2","8,2"],["8,2","7,2"],["7,2","6,2"],["6,8","7,8"],["7,8","8,8"],["8,8","9,8"],["6,2","6,3"],["6,6","6,7"],["6,7","6,8"]]}
                        completeValues: [["Battery",0.9]]
                        complete: '''
                            <p>Adding the resistor to the circuit creates 10 Ohms of resistance.</p>
                            <p><a href=\'http://en.wikipedia.org/wiki/Ohm%27s_law\'>Ohm\'s law</a> tells us that with 10 Ohms of resistance and 9 Volts of power we get 0.9 Amps of current.</p>
                        '''
                        values: true                        
                    }
                    {
                        id: 1379375996057
                        challenge: "Create a circuit that has 1.8 Amps of current flowing through it."
                        instructions: {"components": [{"name": "Battery", "position": "9,8"},{"name": "Resistor", "position": "3,3"},{"name": "Lightbulb", "position": "16,5"}],"wires": [["10,8","11,8"],["11,8","12,8"],["12,8","13,8"],["13,8","13,7"],["13,7","13,6"],["13,6","13,5"],["13,5","13,4"],["13,4","13,3"],["13,3","13,2"],["13,2","12,2"],["12,2","11,2"],["11,2","10,2"],["10,2","9,2"],["9,2","8,2"],["8,2","7,2"],["7,2","6,2"],["6,8","7,8"],["7,8","8,8"],["8,8","9,8"],["6,2","6,3"],["6,6","6,7"],["6,7","6,8"],["6,3","6,4"],["6,4","6,5"],["6,5","6,6"]]}
                        hints: [
                            'The resistor provides 10 Ohms of resistance while the lightbulb provides 5 Ohms of resistance.'
                            'Use Ohm\'s law (I = V / R) to figure out how many amps the circuit will have by adding the lightbulb or the resistor.'
                            'Add only the lightbulb to the circuit to create 0.9 Amps of current.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "9,8"},{"name": "Resistor", "position": "3,3"},{"name": "Lightbulb", "position": "13,2"}],"wires": [["10,8","11,8"],["11,8","12,8"],["12,8","13,8"],["13,8","13,7"],["13,7","13,6"],["13,6","13,5"],["13,5","13,4"],["13,4","13,3"],["13,3","13,2"],["13,2","12,2"],["12,2","11,2"],["11,2","10,2"],["10,2","9,2"],["9,2","8,2"],["8,2","7,2"],["7,2","6,2"],["6,8","7,8"],["7,8","8,8"],["8,8","9,8"],["6,2","6,3"],["6,6","6,7"],["6,7","6,8"],["6,3","6,4"],["6,4","6,5"],["6,5","6,6"]]}
                        completeValues: [["Battery",1.8]]
                        complete: '''
                            <p>Using Ohm\'s law we know that the lightbulb, with 5 Ohms of resistance, will create a circuit with 1.8 Amps of current.</p>
                            <p>The resistor, with 10 Ohms of resistance, would have created 0.9 Amps of current.</p>
                        '''
                        values: true                        
                    }
                    {
                        id: 1379377585229
                        challenge: "Create a circuit that has 0.9 Amps of current flowing through it."
                        instructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Lightbulb", "position": "11,3"},{"name": "Resistor", "position": "5,5"}],"wires": []}
                        hints: [
                            'The amount of current in a circuit is inversely proportional to the amount of resistance.'
                            'The resistor provides more resistance (10 Ohms), so it will reduce the amount of currrent by more than the lightbulb (5 Ohms).'
                            'Draw wire to include the resistor but not the lightbulb in the circuit.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Resistor", "position": "5,5"},{"name": "Lightbulb", "position": "11,3"}],"wires": [["9,9","10,9"],["10,9","11,9"],["11,9","12,9"],["12,9","12,8"],["12,5","12,4"],["12,4","11,4"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,4","5,4"],["5,4","5,5"],["5,8","5,9"],["5,9","6,9"],["6,9","7,9"],["7,9","8,9"],["12,5","12,6"],["12,6","12,7"],["12,7","12,8"]]}
                        completeValues: [["Battery",0.9]]
                        complete: '''
                            <p>Using Ohm\'s law we know that the resistor, with 10 Ohms of resistance, will create a circuit with 0.9 Amps of current.</p>
                            <p>With more resistance from the resistor, the circuit will have less current.</p>
                        '''
                        values: true                        
                    }
                    {
                        id: 1379386664250
                        challenge: "With a battery that has 12 Volts, create a circuit that has 2.4 Amps of current flowing through it."
                        instructions: {"components": [{"name": "Battery", "position": "8,9", "voltage": 12},{"name": "Resistor", "position": "3,5"},{"name": "Lightbulb", "position": "14,7"}],"wires": [["9,9","10,9"],["10,9","11,9"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,4","5,4"],["5,4","5,5"],["8,9","7,9"],["7,9","6,9"],["6,9","5,9"],["5,9","5,8"],["11,4","12,4"],["12,4","12,5"],["12,5","12,6"],["12,6","12,7"],["12,7","12,8"],["12,8","12,9"],["12,9","11,9"],["5,5","5,6"],["5,6","5,7"],["5,7","5,8"]]}
                        hints: [
                            'The battery in this case has more voltage, so the current will increase as well.'
                            'With 12 Volts you need to provide 5 Ohms of resistance to have 2.4 Amps of current (12 / 5 = 2.4).'
                            'Add the lightbulb (5 Ohms of resistance) to the circuit.'
                        ]
                        completeInstructions: {"components": [{"name": "Battery", "position": "8,9"},{"name": "Resistor", "position": "3,5"},{"name": "Lightbulb", "position": "11,4"}],"wires": [["9,9","10,9"],["10,9","11,9"],["11,4","10,4"],["10,4","9,4"],["9,4","8,4"],["8,4","7,4"],["7,4","6,4"],["6,4","5,4"],["5,4","5,5"],["8,9","7,9"],["7,9","6,9"],["6,9","5,9"],["5,9","5,8"],["11,4","12,4"],["12,4","12,5"],["12,5","12,6"],["12,6","12,7"],["12,7","12,8"],["12,8","12,9"],["12,9","11,9"],["5,5","5,6"],["5,6","5,7"],["5,7","5,8"]]}
                        completeValues: [["Battery",2.4]]
                        complete: '''
                            <p>A battery with 9 Volts and a lightbulb with 5 Ohms of resistance would have created 1.8 Amps of current.</p>
                            <p>With a 12 Volt battery and the same lightbulb, the circuit has 2.4 Amps of current.
                        '''
                        values: true                        
                    }
                    # {
                    #     id: 1379386664250
                    #     challenge: "With a battery that has 6 Volts, create a circuit that has 0.6 Amps of current flowing through it."
                    #     instructions: {"components": [{"name": "Battery", "position": "8,8"},{"name": "Resistor", "position": "4,4"},{"name": "Lightbulb", "position": "13,6"}],"wires": []}
                    #     hints: [
                    #         'The battery in this case has more voltage, so the current will increase as well.'
                    #         'With 12 Volts you need to provide 5 Ohms of resistance to have 2.4 Amps of current (12 / 5 = 2.4).'
                    #         'Add the lightbulb (5 Ohms of resistance) to the circuit.'
                    #     ]
                    #     completeInstructions: {"components": [{"name": "Battery", "position": "8,8"},{"name": "Lightbulb", "position": "13,6"},{"name": "Resistor", "position": "6,4"}],"wires": [["9,8","10,8"],["10,8","11,8"],["11,8","11,7"],["11,7","11,6"],["11,6","11,5"],["11,5","11,4"],["11,4","11,3"],["11,3","10,3"],["8,3","7,3"],["7,3","6,3"],["6,3","6,4"],["10,3","9,3"],["9,3","8,3"],["6,7","6,8"],["6,8","7,8"],["7,8","8,8"]]}
                    #     completeValues: [["Battery",0.6]]
                    #     complete: '''
                    #         <p>A battery with 9 Volts and a lightbulb with 5 Ohms of resistance would have created 1.8 Amps of current.</p>
                    #         <p>With a 12 Volt battery and the same lightbulb, the circuit has 2.4 Amps of current.
                    #     '''
                    #     values: true                        
                    # }
                ]
            }
        ]
    }, {
        stages: [
            {
                name: 'Series Circuits'
                levels: [
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
                            <p>The two lightbulbs in this circuit create twice as much resistance as one lightbulb did.</p>
                            <p>The current is constant throughout the circuit so both lightbulbs dim to half the intensity that one lightbulb had.</p>
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
                            <p>The current = total voltage / total resistance (9 Volts / 15 Ohms = 0.6 Amps).</p>
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
                            <p><a href=\'http://en.wikipedia.org/wiki/Ohm's_law\' target=\'blank\'>Ohm\'s law</a> states that I = V/R or Current = Voltage/Resistance.</p>
                            <p>In this case we need to add 25 Ohms of resistance to the circuit to get 0.36 Amps (9 / 25 = 0.36).</p>
                        '''
                        values: true
                    }
                    
                ]
            }
        ]
    }
]
