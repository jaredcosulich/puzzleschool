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
        onBoard = addToBoard(board, battery, 300, 300);
        expect(onBoard).toBe(true);
    }); 
    
    afterEach(function() {
        $('.circuitous').html(html)
    })
    
    describe('with one battery', function() {
        it('should be an incomplete circuit with just one component', function() {
            circuit = board.analyzer.run()
            expect(Object.keys(circuit.components).length).toEqual(1);
            expect(circuit.complete).toBe(false);
        });        
        
        describe('with some wire', function() {
            beforeEach(function() {
                start = board.boardPosition(battery.currentNodes()[1]);
                drawWire(board, start, 0, 3);
            });
            
            it('should be an incomplete circuit with multiple components/wires', function() {
                circuit = board.analyzer.run()
                expect(Object.keys(circuit.components).length).toBeGreaterThan(1);
                expect(circuit.complete).toBe(false); 
            });
        })
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
    start = {clientX: offset.left + from.x, clientY: offset.top + from.y}
    board.el.trigger('mousedown.draw_wire', start);    
    board.wires.draw({clientX: start.clientX + (deltaX * board.cellDimension), clientY: start.clientY + (deltaY * board.cellDimension)});
    $(document.body).trigger('mouseup.draw_wire');
}