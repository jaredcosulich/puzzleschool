var debugInfo = false;
describe("Analyzer", function() {
    var html, game, board, adderSquare;
    
    beforeEach(function() {
        html = $('.circuitous').html()
        game = new circuitous.ViewHelper({
            el: $('.circuitous')
        });
        
        board = new circuitous.Board({
            el: $('.board'),
            cellDimension: 32
        })

        battery = createComponent(board, 'Battery')
        onBoard = addToBoard(board, battery, 100, 300);
        expect(onBoard).toBe(true);
        
        if (!debugInfo) $('.circuitous').css({top: -10000});
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
                drawWire(board, start, 0, 3);
                var circuit = board.analyzer.run();
                expect(Object.keys(circuit.components).length).toBeGreaterThan(1);
                expect(circuit.complete).toBe(false); 
            });
            
            describe('completing the circuit', function() {
                beforeEach(function() {
                    var start = board.boardPosition(battery.currentNodes()[1]);
                    var lastNode = drawWire(board, start, 0, 2);
                    lastNode = drawWire(board, lastNode, 12, 0);
                    lastNode = drawWire(board, lastNode, 0, -7);
                    lastNode = drawWire(board, lastNode, -12, 0);
                    drawWire(board, lastNode, 0, 2);                    
                });

                it('should be a complete circuit with infinite amps', function() {
                    var circuit = board.analyzer.run()
                    expect(circuit.complete).toBe(true);
                    expect(circuit.amps).toBe('infinite') 
                });
                
                describe('and a lightbulb', function() {
                    var bulb;
                    
                    beforeEach(function() {
                        bulb = createComponent(board, 'Lightbulb')
                        var node = wireAt(board, 22).nodes[0]
                        var onBoard = addToBoard(board, bulb, node.x, node.y);
                        expect(onBoard).toBe(true);                        
                    });

                    it('should have resistance and non-infinite amps', function() {
                        var circuit = board.analyzer.run();
                        expect(circuit.components[bulb.id]).toBe(true);
                        expect(circuit.complete).toBe(true);
                        expect(circuit.resistance).toBe(5);
                        expect(circuit.amps).toBe(1.8);
                    });
                    
                    describe('with a short circuit', function() {
                        beforeEach(function() {
                            var node = wireAt(board, 5).nodes[0];
                            drawWire(board, node, 0, -7);                            
                        });
                        
                        it('should create a circuit with infinite amps and no lightbulb', function() {
                            var circuit = board.analyzer.run();
                            expect(circuit.complete).toBe(true);
                            expect(circuit.amps).toBe('infinite') ;
                            expect(circuit.components[bulb.id]).toBeUndefined();
                        });
                    });

                    describe('with a parallel lightbulb', function() {
                        var bulb2;
                        
                        beforeEach(function() {
                            var node = wireAt(board, 5).nodes[0]
                            var lastNode = drawWire(board, node, 0, -1);
                            var bulb2Node = drawWire(board, lastNode, 2, 0);
                            lastNode = drawWire(board, bulb2Node, 4, 0);
                            drawWire(board, lastNode, 0, -6)
                            bulb2 = createComponent(board, 'Lightbulb')
                            var onBoard = addToBoard(board, bulb2, bulb2Node.x, bulb2Node.y);
                            expect(onBoard).toBe(true);                                                    
                        });
                        
                        it('should create a complete circuit with twice the amps', function() {
                            var circuit = board.analyzer.run();
                            expect(circuit.complete).toBe(true);
                            expect(circuit.amps).toBe(3.6);
                            expect(circuit.resistance).toBe(2.5);
                        });
                        
                        it('should provide the full amout of amps to each bulb', function() {
                            board.moveElectricity();
                            expect(bulb.current).toEqual(1.8);
                            expect(bulb2.current).toEqual(1.8);
                        });                        
                        
                        describe('and a short circuit', function() {
                            beforeEach(function() {
                                drawWire(board, wireAt(board, 3).nodes[0], 0, -7);
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
                                drawWire(board, wireAt(board, 11).nodes[0], 0, -7);
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
                                    board.removeComponent(bulb2);
                                })
                                
                                it('all wires should have excessive_current class', function() {
                                    board.moveElectricity();
                                    for (wireId in board.wires.all()) {
                                        var wire = board.wires.all()[wireId];
                                        expect(wire.el.hasClass('excessive_current')).toBe(true);
                                    }
                                });

                            })                            
                        });
                        
                    });
                    
                    describe('with a lightbulb in series', function() {
                        var bulb2;
                        
                        beforeEach(function() {
                            var bulb2Node = wireAt(board, 5).nodes[0]
                            bulb2 = createComponent(board, 'Lightbulb')
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
                                drawWire(board, wireAt(board, 3).nodes[0], 0, -7);
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
    });
    
});

addToBoard = function(board, component, x, y) {
    boardOffset = board.el.offset()
    var onBoard = board.addComponent(
        component, 
        boardOffset.left + x - component.centerOffset.x, 
        boardOffset.top + y - component.centerOffset.y
    )
    if (debugInfo) board.addDot(board.boardPosition(component.currentNodes()[0]));
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

drawWire = function(board, from, deltaX, deltaY) {
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