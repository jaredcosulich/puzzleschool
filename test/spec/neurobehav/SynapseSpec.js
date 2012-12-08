describe("Synapse: ", function() {
    var game, neuron1, neuron2;

    beforeEach(function() {
        game = new neurobehav.Game({
            el: $('.neurobehav')
        });
        
        neuron1 = game.addObject({
            type: 'Neuron',
            position: {
                top: 400,
                left: 100
            },
            threshold: 1,
            spike: 0.5,
        });
        
        neuron2 = game.addObject({
            type: 'Neuron',
            position: {
                top: 400,
                left: 200
            },
            threshold: 1,
            spike: 0.5,
        });
        
        stimulus = game.addObject({
            type: 'Stimulus',
            position: {
                top: 100,
                left: 100
            },
            voltage: 1.5
        });
        stimulus.connectTo(neuron1);
        stimulus.toggleState();
        
    }); 
    
    describe('connections: ', function() {
        beforeEach(function() {
        });
        
        it('should not affect the synapses of the other neuron when they are connected', function() {
            expect(neuron2.synapses[0].connection).toBeUndefined()
            neuron1.connectSynapse(neuron1.synapses[0], neuron2)
            expect(neuron2.synapses[0].connection).toBeUndefined()
        })
        
        it('neuron2 should not receive synapse potential until neuron1 passes threshold', function() {
            neuron1.connectSynapse(neuron1.synapses[0], neuron2)
            for (var i=0; i<200; ++i) {
                neuron1.setCurrentVoltage();
                neuron2.setCurrentVoltage();
                if (neuron1.currentVoltage > 1) break;   
                expect(neuron2.currentVoltage).toEqual(0)              
            }
            expect(neuron2.currentVoltage).toBeGreaterThan(0)              
        });
        
        it('neuron2 should receive inhibitory synapse potential properly', function() {
            neuron1.connectSynapse(neuron1.synapses[1], neuron2)
            for (var i=0; i<200; ++i) {
                neuron1.setCurrentVoltage();
                neuron2.setCurrentVoltage();
                if (neuron1.currentVoltage < -2) break;   
            }
            expect(neuron2.currentVoltage).toBeGreaterThan(-2)              
        });
        
        it('neuron1 should not be affected by synapse connections from it to neuron2', function() {
            neuron1Voltages = []
            for (var i=0; i<200; ++i) {
                neuron1.setCurrentVoltage();
                neuron1Voltages.push(neuron1.currentVoltage);
            }
            
            stimulus.toggleState()
            resetNeuron(neuron1)
            resetNeuron(neuron2)
            
            neuron1.connectSynapse(neuron1.synapses[0], neuron2)
            neuron1.connectSynapse(neuron1.synapses[1], neuron2)

            stimulus.toggleState()

            for (var i=0; i<200; ++i) {
                neuron1.setCurrentVoltage();
                neuron2.setCurrentVoltage();                
                expect(neuron1.currentVoltage).toEqual(neuron1Voltages[i])
                if (neuron1.currentVoltage != neuron1Voltages[i]) break;
            }
        });

        it('should build on top of each other', function() {
            neuron1.connectSynapse(neuron1.synapses[0], neuron2)
            neuron1.connectSynapse(neuron1.synapses[1], neuron2)
            for (var i=0; i<200; ++i) {
                neuron1.setCurrentVoltage();
                neuron2.setCurrentVoltage();                
                expect(neuron2.currentVoltage).toEqual(0)
            }
        });

    });
});

function resetNeuron(neuron) {
    neuron.voltage = 0
    neuron.currentVoltage = 0
    neuron.lastVoltage = 0
    neuron.activeSynapseSpike = null
    neuron.synapseSpikes = []
}