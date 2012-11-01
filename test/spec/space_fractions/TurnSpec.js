describe("A turn", function() {
    var game, laserSquare, turnSquare;

    beforeEach(function() {
        game = new spaceFractions.ViewHelper({
            el: $('.space_fractions'),
            rows: 10,
            columns: 10
        });
        laserSquare = game.board.find('.square.index21');
        laserSquare.data('numerator', 1)
        laserSquare.data('denominator', 3)
        game.addObjectToBoard('laser_right', laserSquare);
        turnSquare = game.board.find('.square.index27')
        game.addObjectToBoard('turn_right_down', turnSquare);
    }); 
    
    it('should stop the laser', function() {
        var laser = game.board.find('.laser.laser21');
        expect(laser.length).toEqual(1);
        expect(laser.find('.beam').offset().width).toEqual(turnSquare.offset().width * 5)
        expect(laser.offset().left + laser.offset().width).toEqual(turnSquare.offset().left)
    });

    it('should not change at all if the laser fires again', function() {
        game.fireLaser(laserSquare);
        var laser = game.board.find('.laser.laser21');
        expect(laser.length).toEqual(1);
        expect(laser.offset().left + laser.offset().width).toEqual(turnSquare.offset().left);
        var laser2 = game.board.find('.laser.laser27')
        expect(laser2.find('.beam').offset().top).toEqual(turnSquare.offset().top + turnSquare.offset().height);
    });
    
    it('should create two lasers, each with the original fraction', function() {
        var lasers = game.board.find('.laser');
        expect(lasers.length).toEqual(2);
        expect($(lasers[0]).data('denominator')).toEqual(3)
        expect($(lasers[1]).data('denominator')).toEqual(3)
    });
    
    it('should send the laser down to the bottom of the board', function() {
        var laser2 = game.board.find('.laser.laser27')
        expect(laser2.find('.beam').offset().top).toEqual(turnSquare.offset().top + turnSquare.offset().height);
        expect(laser2.find('.beam').offset().height).toEqual(laserSquare.height() * 7);
    });
    
    it('should remove markings from previous path', function() {
        var oldPathSquare = game.board.find('.square.index29');
        expect(oldPathSquare[0].className).toNotContain('laser');
    });
        
    describe('when the turn is removed', function() {
        beforeEach(function() {
            game.removeObjectFromBoard(turnSquare);            
        });
        
        it('should remove the split in the laser', function() {
            var laser = game.board.find('.laser');
            expect(laser.length).toEqual(1);
            expect(laser.find('.beam').offset().width).toEqual(laserSquare.offset().width * 8);
        });
    });

    describe('when the turn is replaced with another turn', function() {
        beforeEach(function() {
            game.addObjectToBoard('turn_right_up', turnSquare);
        });
        
        it('should send the laser up to the top of the board', function() {
            var laser2 = $(game.board.find('.laser')[1]);
            expect(laser2.offset().top).toEqual(1);
            expect(laser2.find('.beam').offset().height).toEqual(turnSquare.height() * 2);
        });
    });
    
    describe('when another turn is added', function() {
        it('should redirect again if it accepts a laser from the right direction', function() {
            var anotherTurnSquare = game.board.find('.square.index67')
            game.addObjectToBoard('turn_down_left', anotherTurnSquare);
            var lasers = game.board.find('.laser')
            expect(lasers.length).toEqual(3);
            expect($(lasers[2]).offset().left).toEqual(1)
            expect($(lasers[2]).find('.beam').offset().width).toEqual(anotherTurnSquare.offset().left - 1)
        });
        
        it('should block the laser if it does not accept a laser for the right direction', function() {
            var badTurnSquare = game.board.find('.square.index67')
            game.addObjectToBoard('turn_up_left', badTurnSquare);
            var laser2 = $(game.board.find('.laser')[1]);
            expect(laser2.find('.beam').offset().top).toEqual(turnSquare.offset().top + turnSquare.offset().height);
            expect(laser2.find('.beam').offset().height).toEqual(laserSquare.height() * 3);            
        });
        
        it('should work if the turn goes back to the original path', function() {
            game.addObjectToBoard('turn_down_right', game.board.find('.square.index67'));
            game.addObjectToBoard('turn_right_up', game.board.find('.square.index68'));
            game.addObjectToBoard('turn_up_right', game.board.find('.square.index28'));
            var lasers = game.board.find('.laser');
            expect(lasers.length).toEqual(5);
        })
    })
    
});