describe("Board: ", function() {
    var board;

    beforeEach(function() {
        board = new xyflyer.Board({
            el: $('.board'), 
            grid: {xMin: -10, xMax: 10, yMin: -10, yMax: 10},
            objects: $('.objects'),
            islandCoordinates: {x: 0, y: 0},
            resetLevel: function(){}
        })        
    }); 

    describe('calculatPath', function() {
        describe('with a simple path', function() {
            beforeEach(function() {
                board.formulas['1'] = {
                    id: '1',
                    area: function(x) {return true},
                    formula: function(x) { return x+2 }
                }
            });
           
            it('should provide the simple formula for all values of x', function() {
                var path = board.calculatePath()
                expect(path.length).toEqual(1)
            });
        });
        
    });
});