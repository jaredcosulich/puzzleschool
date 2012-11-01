describe("A splitter", function() {
    var game, laserSquare, splitterSquare;

    beforeEach(function() {
        game = new spaceFractions.ViewHelper({
            el: $('.space_fractions'),
            rows: 10,
            columns: 10
        });
        laserSquare = game.board.find('.square.index21');
        laserSquare.data('numerator', 1)
        laserSquare.data('denominator', 3)
        game.addObjectToSquare('laser_right', laserSquare);
        splitterSquare = game.board.find('.square.index27')
        game.addObjectToSquare('two_split_right_down', splitterSquare);
    }); 
    
    it('should create three lasers', function() {
        var lasers = game.board.find('.laser')
        expect(lasers.length).toEqual(3)
    })
    
    it('should stop the full laser', function() {
        var laser = game.board.find('.laser.laser21');
        expect(laser.length).toEqual(1);
        expect(laser.find('.beam').offset().width).toEqual(splitterSquare.offset().width * 5)
        expect(laser.offset().left + laser.offset().width).toEqual(splitterSquare.offset().left)
    });

    it('should not change at all if the laser fires again', function() {
        game.fireLaser(laserSquare);
        var laser = game.board.find('.laser.laser21');
        expect(laser.length).toEqual(1);
        expect(laser.offset().left + laser.offset().width).toEqual(splitterSquare.offset().left);
    });
    
    it('should create two additional lasers, each with half the original fraction', function() {
        var lasers = game.board.find('.laser');
        expect($(lasers[0]).data('denominator')).toEqual(3)
        expect($(lasers[1]).data('denominator')).toEqual(6)
        expect($(lasers[2]).data('denominator')).toEqual(6)
    });

    it('should send a laser completing the original path', function() {
        var laser2 = $(game.board.find('.laser.laser27')[0])
        expect(laser2.find('.beam').offset().width).toEqual(splitterSquare.offset().width * 2)
        expect(laser2.offset().left + laser2.offset().width).toEqual(game.board.offset().width-1)
    });
    
    it('should send a laser down to the bottom of the board', function() {
        var laser3 = $(game.board.find('.laser.laser27')[1])
        expect(laser3.find('.beam').offset().top).toEqual(splitterSquare.offset().top + splitterSquare.offset().height);
        expect(laser3.find('.beam').offset().height).toEqual(laserSquare.height() * 7);
    });
    
    describe('when the turn is removed', function() {
        beforeEach(function() {
            game.removeObjectFromSquare(splitterSquare);            
        });
        
        it('should remove the split in the laser', function() {
            var laser = game.board.find('.laser');
            expect(laser.length).toEqual(1);
            expect(laser.find('.beam').offset().width).toEqual(laserSquare.offset().width * 8);
        });
    });

    describe('when the splitter is replaced with another splitter', function() {
        beforeEach(function() {
            game.addObjectToSquare('two_split_right_up', splitterSquare);
        });

        it('should send a laser completing the original path', function() {
            var laser2 = $(game.board.find('.laser.laser27')[0])
            expect(laser2.find('.beam').offset().width).toEqual(splitterSquare.offset().width * 2)
            expect(laser2.offset().left + laser2.offset().width).toEqual(game.board.offset().width-1)
        });
        
        it('should send the laser up to the top of the board', function() {
            var laser3 = $(game.board.find('.laser')[2]);
            expect(laser3.offset().top).toEqual(1);
            expect(laser3.find('.beam').offset().height).toEqual(splitterSquare.height() * 2);
        });
    });
    
    describe('when another splitter is added', function() {
        it('should split again if it accepts a laser from the right direction', function() {
            var anotherSplitterSquare = game.board.find('.square.index67')
            game.addObjectToSquare('two_split_down_left', anotherSplitterSquare);
            var lasers = game.board.find('.laser')
            expect(lasers.length).toEqual(5);
        });
        
        it('should block the laser if it does not accept a laser for the right direction', function() {
            var badSplitterSquare = game.board.find('.square.index67')
            game.addObjectToSquare('two_split_up_left', badSplitterSquare);
            var lasers = game.board.find('.laser')
            expect(lasers.length).toEqual(3);
            var laser3 = $(game.board.find('.laser.laser27')[1])
            expect(laser3.find('.beam').offset().top).toEqual(splitterSquare.offset().top + splitterSquare.offset().height);
            expect(laser3.find('.beam').offset().height).toEqual(laserSquare.height() * 3);                
        });        
    })
    
});