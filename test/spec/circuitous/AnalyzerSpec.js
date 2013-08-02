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
                var circuit = board.analyzer.run()
                expect(Object.keys(circuit.components).length).toBeGreaterThan(1);
                expect(circuit.complete).toBe(false); 
            });
            
            describe('completing the circuit', function() {
                beforeEach(function() {
                    var start = board.boardPosition(battery.currentNodes()[1]);
                    var lastNode = drawWire(board, start, 0, 2);
                    var lastNode = drawWire(board, lastNode, 7, 0);
                    var lastNode = drawWire(board, lastNode, 0, -7);
                    var lastNode = drawWire(board, lastNode, -7, 0);
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
                        var node = wireAt(board, 16).nodes[0]
                        var onBoard = addToBoard(board, bulb, node.x, node.y);
                        expect(onBoard).toBe(true);                        
                    });

                    it('should have resistance and non-infinite amps', function() {
                        var circuit = board.analyzer.run();
                        expect(circuit.components[bulb.id]).toBe(true);
                        expect(circuit.complete).toBe(true);
                        expect(circuit.resistance).toBe(5) ;
                        expect(circuit.amps).toBe(1.8) ;
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
                });
            });
        });
    });
    
});

addToBoard = function(board, component, x, y) {
    boardOffset = board.el.offset()
    return board.addComponent(component, boardOffset.left + x, boardOffset.top + y)
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