describe("Init:", function() {
    var game;

    beforeEach(function() {
        game = new spaceFractions.ViewHelper({
            el: $('.space_fractions'),
            rows: 10,
            columns: 10
        });
     }); 
        
    it("should create columns * rows squares on the board", function() {
        expect(game.board.find('.square').length).toEqual(100)
    });
    
    describe("with a laser", function() {
        var square, laser;
        
        beforeEach(function() {
            square = game.board.find('.square.index12');
            game.addObjectToBoard('laser_right', square)
            laser = game.board.find('.laser')
        })
        
        it('should display the laser', function() {
            expect(laser.length).toEqual(1)
        })
        
        it('should tie back to the originating square', function() {
            expect(laser.hasClass('laser12')).toBe(true)
        })
        
        it('should be 7 squares long', function() {
            expect(laser.width()).toEqual(square.width() * 7)
        })
        
        it('should start at the right edge of the laser', function() {
            expect(laser.offset().left).toEqual(square.offset().left + square.offset().width)
        })
        
        it('should mark each square the laser passes, but no others', function() {
            expect(game.board.find('.square.index11').hasClass('laser12')).toEqual(false)    
            expect(game.board.find('.square.index12').hasClass('laser12')).toEqual(false)    
            for (var i=13; i<20; ++i) {
                expect(game.board.find('.square.index' + i).hasClass('laser12')).toEqual(true)                
            }
            expect(game.board.find('.square.index21').hasClass('laser12')).toEqual(false)    
        })
        
        it('should not change position if fired again', function() {
            game.fireLaser(square);
            laser = game.board.find('.laser' + square.data('index'))
            expect(laser.offset().left).toEqual(square.offset().left + square.offset().width);
        })
        
        it('should not change position if fired again with a different fraction', function() {
            square.data('denominator', 12);
            game.fireLaser(square);
            laser = game.board.find('.laser.laser' + square.data('index'))
            expect(laser.offset().left).toEqual(square.offset().left + square.offset().width);
        })
        
    })
    
});