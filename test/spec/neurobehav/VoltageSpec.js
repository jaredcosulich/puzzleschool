describe("Voltage: ", function() {
    var game, neuron;

    beforeEach(function() {
        game = new neurobehav.Game({
            el: $('.neurobehav')
        });
        
        neuron = game.addObject({
            type: 'Neuron',
            position: {
                top: 100,
                left: 300
            },
            threshold: 1,
            spike: 0.5,
        });
        
    }); 
    
    describe('currentVoltage', function() {
        
        describe('with a light stimulus', function() {
            var lightStimulus;
            beforeEach(function() {
                lightStimulus = game.addObject({
                    type: 'Stimulus',
                    position: {
                        top: 100,
                        left: 100
                    },
                    voltage: 0.8
                });
                lightStimulus.connectTo(neuron);
            });
        
            it('should start at 0', function() {
                expect(neuron.currentVoltage).toEqual(0);
            })

            it('should respond a voltage stimulus', function() {
                lightStimulus.toggleState();
                neuron.setCurrentVoltage();
                expect(neuron.currentVoltage).toBeGreaterThan(0);
            });
        
            it('should not cross the threshold with a light stimulus', function() {
                lightStimulus.toggleState();
                for (var i=0; i<100; ++i) {
                    neuron.setCurrentVoltage();
                    expect(neuron.currentVoltage).toBeLessThan(1);                
                }
            });
        });
        
        describe('with a heavy stimulus', function() {
            var heavyStimulus;
            beforeEach(function() {
                heavyStimulus = game.addObject({
                    type: 'Stimulus',
                    position: {
                        top: 100,
                        left: 100
                    },
                    voltage: 1.5
                });
                heavyStimulus.connectTo(neuron);
            });
            
            it('should spike after crossing threshold', function() {
                heavyStimulus.connectTo(neuron);
                heavyStimulus.toggleState();
                for (var i=0; i<200; ++i) {
                    neuron.setCurrentVoltage();
                    if (neuron.currentVoltage > 1) break; 
                }            
                expect(neuron.currentVoltage).toBeGreaterThan(1.49);                
            });
            
            it('should not affect the voltage', function() {
                heavyStimulus.connectTo(neuron);
                heavyStimulus.toggleState();
                for (var i=0; i<200; ++i) {
                    neuron.setCurrentVoltage();
                    expect(neuron.voltage).toEqual(1.5);                
                }            
            });            
        });
    });
});