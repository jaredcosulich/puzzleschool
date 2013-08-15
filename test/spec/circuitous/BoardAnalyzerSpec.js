var debugInfo = true;
describe("BoardAnalyzer", function() {
    var html, game, board, adderSquare, battery;
    
    beforeEach(function() {
        if (debugInfo) $('.circuitous').css({top: 100});
        html = $('.circuitous').html()
        game = new circuitous.ViewHelper({
            el: $('.circuitous')
        });
        
        board = new circuitous.Board({
            el: $('.board'),
            cellDimension: 32
        })

        battery = createComponent(board, 'Battery')
        onBoard = addToBoard(board, battery, 90, 420);
        expect(onBoard).toBe(true);
    }); 
    
    afterEach(function() {
        $('.circuitous').html(html)
    })
    
    describe('with one battery', function() {
        it('should be an incomplete circuit with just one component', function() {
            var circuit = board.analyzer.run()
            expect(Object.keys(circuit.components).length).toEqual(1);
            expect(circuit.complete).toBe(false);
        });        
        
        describe('and wire', function() {            
            it('should be an incomplete circuit with multiple components/wires when just a little is added', function() {
                var start = board.boardPosition(battery.currentNodes()[1]);
                drawOrEraseWire(board, start, 0, 3);
                var circuit = board.analyzer.run();
                expect(Object.keys(circuit.components).length).toBeGreaterThan(1);
                expect(circuit.complete).toBe(false); 
            });
            
            describe('completing the circuit', function() {
                beforeEach(function() {
                    var start = board.boardPosition(battery.currentNodes()[1]);
                    var lastNode = drawOrEraseWire(board, start, 0, 2);
                    lastNode = drawOrEraseWire(board, lastNode, 12, 0);
                    lastNode = drawOrEraseWire(board, lastNode, 0, -7);
                    lastNode = drawOrEraseWire(board, lastNode, -13, 0);
                    drawOrEraseWire(board, lastNode, 0, 5);
                });

                it('should be a complete circuit with infinite amps', function() {
                    var circuit = board.analyzer.run()
                    expect(circuit.complete).toBe(true);
                    expect(circuit.amps).toBe('infinite') 
                });
                
                describe('and a light emitting diode hooked up the wrong way', function() {
                    var led;
                    
                    beforeEach(function() {
                        led = createComponent(board, 'LightEmittingDiode');
                        var node = wireAt(board, 8).nodes[1];
                        drawOrEraseWire(board, node, 1, 0)
                        var onBoard = addToBoard(board, led, node.x, node.y);
                        expect(onBoard).toBe(true);                                                
                    });
                    
                    it('should not be a complete circuit', function() {
                        var circuit = board.analyzer.run();
                        expect(circuit.complete).toBe(false);
                    });
                    
                    it('should not provide and current to the led', function() {
                        board.moveElectricity();
                        expect(led.current).toEqual(0);
                    });
                })
                
                describe('and a lightbulb', function() {
                    var bulb;
                    
                    beforeEach(function() {
                        bulb = createComponent(board, 'Lightbulb');
                        var node = wireAt(board, 22).nodes[1];
                        var onBoard = addToBoard(board, bulb, node.x, node.y);
                        expect(onBoard).toBe(true);                        
                    });

                    it('should have resistance and non-infinite amps', function() {
                        var componentInfo = board.analyzer.run();
                        var analyzedBulb = componentInfo[bulb.id];
                        expect(analyzedBulb).not.toBe(undefined);
                        expect(analyzedBulb.resistance).toBe(5);
                        expect(analyzedBulb.amps).toBe(1.8);
                    });
                    
                    describe('with a short circuit', function() {
                        beforeEach(function() {
                            var node = wireAt(board, 5).nodes[0];
                            drawOrEraseWire(board, node, 0, -7);                            
                        });
                        
                        it('should create a circuit with infinite amps and no lightbulb', function() {
                            var circuit = board.analyzer.run();
                            expect(circuit.complete).toBe(true);
                            expect(circuit.amps).toBe('infinite') ;
                            expect(circuit.components[bulb.id]).toBeUndefined();
                        });
                    });

                    describe('with a parallel light emitting diode', function() {
                        var bulb2;
                        
                        beforeEach(function() {
                            var node = wireAt(board, 9).nodes[0]
                            var lastNode = drawOrEraseWire(board, node, 0, -1);
                            var bulb2Node = drawOrEraseWire(board, lastNode, -2, 0);
                            lastNode = drawOrEraseWire(board, bulb2Node, -2, 0);
                            lastNode = drawOrEraseWire(board, lastNode, 0, -3);
                            lastNode = drawOrEraseWire(board, lastNode, 5, 0);
                            lastNode = drawOrEraseWire(board, lastNode, 0, -3);
                            
                            bulb2 = createComponent(board, 'LightEmittingDiode');
                            drawOrEraseWire(board, bulb2Node, 1, 0);
                            var onBoard = addToBoard(board, bulb2, bulb2Node.x, bulb2Node.y);
                            expect(onBoard).toBe(true);                                                    
                        });
                        
                        it('should create a complete circuit with twice the amps', function() {
                            var componentInfo = board.analyzer.run();
                            expect(componentInfo[battery.id].amps).toBe(3.6);
                        });
                        
                        it('should provide the full amout of amps to each bulb', function() {
                            board.moveElectricity();
                            expect(bulb.current).toEqual(1.8);
                            expect(bulb2.current).toEqual(1.8);
                        });                        
                        
                        describe('and a short circuit', function() {
                            beforeEach(function() {
                                drawOrEraseWire(board, wireAt(board, 4).nodes[0], 0, -7);
                            });
                            
                            it('should create an complete circuit with infinite amps', function() {
                                var circuit = board.analyzer.run();
                                expect(circuit.complete).toBe(true);
                                expect(circuit.amps).toBe('infinite');
                                expect(circuit.resistance).toBe(0);
                            });

                            it('should provide no amps to either bulb', function() {
                                board.moveElectricity();
                                expect(bulb.current).toBe(0);
                                expect(bulb2.current).toBe(0);
                            });                            
                        });

                        describe('and a short circuit in between bulbs', function() {
                            beforeEach(function() {
                                drawOrEraseWire(board, wireAt(board, 11).nodes[0], 0, -7);
                            });
                            
                            it('should create an complete circuit with infinite amps', function() {
                                var circuit = board.analyzer.run();
                                expect(circuit.complete).toBe(true);
                                expect(circuit.amps).toBe('infinite');
                                expect(circuit.resistance).toBe(0);
                            });

                            it('should provide no amps to either bulb', function() {
                                board.moveElectricity();
                                expect(bulb.current).toBe(0);
                                expect(bulb2.current).toBe(0);
                            });
                            
                            describe('and both bulbs removed', function() {
                                beforeEach(function() {
                                    board.removeComponent(bulb);
                                    drawOrEraseWire(board, board.boardPosition(bulb.currentNodes()[0]), 1, 0);
                                    board.removeComponent(bulb2);
                                    drawOrEraseWire(board, board.boardPosition(bulb2.currentNodes()[0]), 1, 0);
                                })
                                
                                it('all wires should have excessive_current class', function() {
                                    board.moveElectricity();
                                    for (wireId in board.wires.all()) {
                                        var wire = board.wires.all()[wireId];
                                        expect(wire.el.hasClass('excessive_current')).toBe(true);
                                    }
                                });
                            });                            
                        });
                        
                        describe('and another parallel circuit', function() {
                            var bulb3;
                            
                            beforeEach(function() {
                                var lastNode = drawOrEraseWire(board, wireAt(board, 9).nodes[0], 0, 1);
                                lastNode = drawOrEraseWire(board, lastNode, 6, 0);
                                lastNode = drawOrEraseWire(board, lastNode, 0, -9);
                                var bulbNode = drawOrEraseWire(board, lastNode, -2, 0);
                                lastNode = drawOrEraseWire(board, bulbNode, -3, 0);
                                drawOrEraseWire(board, lastNode, 0, 1);
                                
                                bulb3 = createComponent(board, 'LightEmittingDiode');
                                drawOrEraseWire(board, bulbNode, 1, 0);
                                var onBoard = addToBoard(board, bulb3, bulbNode.x, bulbNode.y);
                                expect(onBoard).toBe(true);
                            })
                            
                            it('should have all the correct values', function() {
                                board.moveElectricity();
                                expect(bulb.current).toEqual(1.8);
                                expect(bulb2.current).toEqual(1.8);                                                               
                                expect(bulb3.current).toEqual(1.8);  
                                expect(wireAt(board, 1).current).toEqual(5.4);
                                debugger
                            })
                        })
                        
                    });
                    
                    describe('with a lightbulb in series', function() {
                        var bulb2;
                        
                        beforeEach(function() {
                            var wire = wireAt(board, 5)
                            var bulb2Node = wire.nodes[0];
                            bulb2 = createComponent(board, 'Lightbulb');
                            var onBoard = addToBoard(board, bulb2, bulb2Node.x, bulb2Node.y);
                            expect(onBoard).toBe(true);                                                    
                        });
                        
                        it('should create a complete circuit with half the amps and twice the resistance', function() {
                            var circuit = board.analyzer.run();
                            expect(circuit.complete).toBe(true);
                            expect(circuit.amps).toBe(0.9);
                            expect(circuit.resistance).toBe(10);
                        });
                        
                        it('should provide full amount of amps (half of simple circuit) to bulbs', function() {
                            board.moveElectricity();
                            expect(bulb.current).toEqual(0.9);
                            expect(bulb2.current).toEqual(0.9);                            
                        });
                        
                        describe('and a short circuit', function() {
                            beforeEach(function() {
                                drawOrEraseWire(board, wireAt(board, 3).nodes[0], 0, -7);
                            });
                            
                            it('should create an complete circuit with infinite amps', function() {
                                var circuit = board.analyzer.run();
                                expect(circuit.complete).toBe(true);
                                expect(circuit.amps).toBe('infinite');
                                expect(circuit.resistance).toBe(0);
                            });

                            it('should provide no amps to either bulb', function() {
                                board.moveElectricity();
                                expect(bulb.current).toBe(0);
                                expect(bulb2.current).toBe(0);
                            });                            
                        });
                    });
                    
                });
            });
        });
        
        describe('and a complicated circuit', function() {
            var bulbs;
            
            beforeEach(function() {
                bulbs = [];
                var start = board.boardPosition(battery.currentNodes()[1]);
                var lastNode = drawOrEraseWire(board, start, 0, 1);
                var split1Node = drawOrEraseWire(board, lastNode, 3, 0);
                var bulb1Node = drawOrEraseWire(board, split1Node, 0, -3);

                lastNode = drawOrEraseWire(board, split1Node, 5, 0);
                var bulb2Node = drawOrEraseWire(board, lastNode, 0, -3);
                lastNode = drawOrEraseWire(board, bulb2Node, 1, 0);
                var split3Node = drawOrEraseWire(board, lastNode, 0, -3);

                lastNode = drawOrEraseWire(board, bulb1Node, 1, 0);
                var split2Node = drawOrEraseWire(board, lastNode, 0, -3);
                var bulb3Node = drawOrEraseWire(board, split2Node, 2, 0);
                drawOrEraseWire(board, bulb3Node, 3, 0)    
                
                lastNode = drawOrEraseWire(board, split3Node, 0, -3);
                var bulb4Node = drawOrEraseWire(board, lastNode, -5, 0);
                lastNode = drawOrEraseWire(board, bulb4Node, -5, 0);
                drawOrEraseWire(board, lastNode, 0, 3);
                
                lastNode = drawOrEraseWire(board, split2Node, -5, 0);
                drawOrEraseWire(board, lastNode, 0, 5);
                                    
                var bulbNodes = [bulb1Node, bulb2Node, bulb3Node, bulb4Node];
                for (var i=0; i<bulbNodes.length; ++i) {
                    bulbs.push(createComponent(board, 'Lightbulb'));
                    if (i<2) bulbs[i].resistance = 10;
                    var onBoard = addToBoard(board, bulbs[i], bulbNodes[i].x, bulbNodes[i].y);
                    expect(onBoard).toBe(true);
                }                
            });
            
            it('should have all the correct values', function() {
                board.moveElectricity();
                expect(wireAt(board, 1).current).toEqual(1.62)
                expect(bulbs[0].current).toEqual(0.9)             
                expect(bulbs[1].current).toEqual(0.72)             
                expect(bulbs[2].current).toEqual(0.36)             
                expect(bulbs[3].current).toEqual(0.36)             
            });
            
            describe('and another parallel path', function() {
                beforeEach(function() {
                    var lastNode = drawOrEraseWire(board, wireAt(board, 28).nodes[0], 1, 0);
                    lastNode = drawOrEraseWire(board, lastNode, 0, 8);
                    var bulbNode = drawOrEraseWire(board, lastNode, -6, 0);
                    lastNode = drawOrEraseWire(board, bulbNode, -6, 0);
                    lastNode = drawOrEraseWire(board, lastNode, 0, -8);
                    lastNode = drawOrEraseWire(board, lastNode, 1, 0);

                    var bulb = createComponent(board, 'Lightbulb');
                    bulb.resistance = 10;
                    bulbs.push(bulb);
                    var onBoard = addToBoard(board, bulb, bulbNode.x, bulbNode.y);
                    expect(onBoard).toBe(true);
                    expect(bulbs[4].id).not.toBe(undefined);
                });
                
                it('should have all of the correct values', function() {
                    board.moveElectricity();
                    expect(wireAt(board, 1).current).toEqual(1.65);
                    expect(bulbs[0].current).toEqual(0.9);             
                    expect(bulbs[1].current).toEqual(0.75);             
                    expect(bulbs[2].current).toEqual(0.3);             
                    expect(bulbs[3].current).toEqual(0.3);             
                    expect(bulbs[4].current).toEqual(0.15);    
                });
            })
        });
        
        describe('and a complicated circuit with two batteries', function() {
            var bulbs;
            
            beforeEach(function() {
                battery.voltage = 8;
                
                bulbs = [];
                var start = board.boardPosition(battery.currentNodes()[1]);
                var lastNode = drawOrEraseWire(board, start, 0, 1);
                lastNode = drawOrEraseWire(board, lastNode, -2, 0);
                lastNode = drawOrEraseWire(board, lastNode, 0, -6);
                var split1Node = drawOrEraseWire(board, lastNode, 2, 0);
                lastNode = drawOrEraseWire(board, split1Node, 0, -2);
                var battery2Node = drawOrEraseWire(board, lastNode, 1, 0);
                var battery2 = createComponent(board, 'Battery');
                battery2.voltage = 12;
                onBoard = addToBoard(board, battery2, battery2Node.x + 32, battery2Node.y + 64);
                expect(onBoard).toBe(true);
                var bulb1Node = drawOrEraseWire(board, battery2Node, 3, 0);
                drawOrEraseWire(board, battery2Node, 1, 0);
                
                var bulb1 = createComponent(board, 'Lightbulb');
                bulbs.push(bulb1);
                bulb1.resistance = 4;
                var onBoard = addToBoard(board, bulb1, bulb1Node.x, bulb1Node.y);
                expect(onBoard).toBe(true);
                lastNode = drawOrEraseWire(board, bulb1Node, 2, 0);
                lastNode = drawOrEraseWire(board, lastNode, 0, 4);
                
                lastNode = drawOrEraseWire(board, split1Node, 0, 2);
                var bulb2Node = drawOrEraseWire(board, lastNode, 3, 0);
                var bulb2 = createComponent(board, 'Lightbulb');
                bulbs.push(bulb2);
                bulb2.resistance = 2;
                var onBoard = addToBoard(board, bulb2, bulb2Node.x, bulb2Node.y);
                expect(onBoard).toBe(true);
                lastNode = drawOrEraseWire(board, bulb2Node, 3, 0);
                
                var end = board.boardPosition(battery.currentNodes()[0]);
                lastNode = drawOrEraseWire(board, end, 0, -1);
                lastNode = drawOrEraseWire(board, lastNode, 2, 0);
                lastNode = drawOrEraseWire(board, lastNode, 0, 2);
                var bulb3Node = drawOrEraseWire(board, lastNode, 3, 0);
                var bulb3 = createComponent(board, 'Lightbulb');
                bulbs.push(bulb3);
                bulb3.resistance = 6;
                var onBoard = addToBoard(board, bulb3, bulb3Node.x, bulb3Node.y);
                expect(onBoard).toBe(true);
                lastNode = drawOrEraseWire(board, bulb3Node, 2, 0);
                drawOrEraseWire(board, lastNode, 0, -4);
            });
            
            it('should have all the correct values', function() {
                board.moveElectricity();
                expect(wireAt(board, 1).current).toEqual(1.64);
                expect(bulbs[0].current).toEqual(2.55);             
                expect(bulbs[1].current).toEqual(0.91);             
                expect(bulbs[2].current).toEqual(1.64);
            })
        });
    });
    
});



addToBoard = function(board, component, x, y) {
    boardOffset = board.el.offset()
    var onBoard = board.addComponent(
        component, 
        boardOffset.left + x - component.centerOffset.x, 
        boardOffset.top + y - component.centerOffset.y
    )
    if (debugInfo) {
        var nodes = component.currentNodes();
        for (var i=0; i<nodes.length; ++i) {
            board.addDot(board.boardPosition(nodes[i]));            
        }        
    } 
    return onBoard;
}

createComponent = function(board, type) {
    component = new circuitous[type]()
    component.appendTo($('.options'))
    component.initDrag(
        component.el, 
        function (component, x, y, state) {},
        true
    );
    return component;
}

drawOrEraseWire = function(board, from, deltaX, deltaY) {
    offset = board.el.offset()
    board.el.trigger('mousedown.draw_wire', {clientX: offset.left + from.x, clientY: offset.top + from.y});
    end  = {x: from.x + (deltaX * board.cellDimension), y: from.y + (deltaY * board.cellDimension)}
    board.wires.draw({clientX: offset.left + end.x, clientY: offset.top + end.y});
    $(document.body).trigger('mouseup.draw_wire');
    return end
}

wireAt = function(board, index) {
    return board.wires.all()[Object.keys(board.wires.all())[index]]
}