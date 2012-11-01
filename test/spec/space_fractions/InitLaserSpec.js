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
            game.addObjectToSquare('laser_right', square)
            laser = game.board.find('.laser')
        })
        
        it('should display the laser', function() {
            expect(laser.length).toEqual(1)
        })
        
        it('should tie back to the originating square', function() {
            expect(laser.hasClass('laser12')).toBe(true)
        })
        
        it('should be 7 squares long', function() {
            expect(laser.find('.beam').width()).toEqual(square.width() * 7)
        })
        
        it('should start at the right edge of the laser', function() {
            expect(laser.find('.beam').offset().left).toEqual(square.offset().left + square.offset().width)
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
            expect(laser.find('.beam').offset().left).toEqual(square.offset().left + square.offset().width);
        })
        
        it('should not change position if fired again with a different fraction', function() {
            square.data('denominator', 12);
            game.fireLaser(square);
            laser = game.board.find('.laser.laser' + square.data('index'))
            expect(laser.find('.beam').offset().left).toEqual(square.offset().left + square.offset().width);
        })
        
    })
    
    describe('loading data for a custom game', function() {
        var shipSquare;
        beforeEach(function() {
            levelDescription = {"objects":[{"type":"turn_up_right","index":11},{"type":"two_split_right_down","index":16},{"type":"ship_right","index":18,"fullNumerator":"1","fullDenominator":"10"},{"type":"ship_left","index":50,"fullNumerator":"1","fullDenominator":"20"},{"type":"two_split_down_left","index":56},{"type":"laser_up","index":71,"numerator":"1","denominator":"5"},{"type":"ship_down","index":86,"fullNumerator":"1","fullDenominator":"40"}]}
            game.loadToPlay(JSON.stringify(levelDescription));
            shipSquare = game.board.find('.square.index18');
        })
        
        it('should load only ships, rocks, and lasers on to the board', function() {
            expect(game.board.find('.square.occupied').length).toEqual(4)
            expect(game.board.find('.square.index11').data('object_type')).toBeUndefined()
        })
        
        it('should load movable objects next to the board', function() {
            expect(game.options.find('.square.occupied').length).toEqual(3);
        })
        
        it('should set numerator/denominator on correct objects', function() {
            expect(shipSquare.data('fullDenominator')).toEqual('10');
        })
        
        it('should display the correct fraction', function() {
            expect(shipSquare.html()).toContain('1/10');
        })
        
    })
    
});