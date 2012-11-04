describe("Adder", function() {
    var game, laserSquare, adderSquare;

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
        adderSquare = game.board.find('.square.index24')
        game.addObjectToSquare('add_left_right_down', adderSquare);
    }); 
    
    it('should stop the laser, not letting it continue with just one laser coming in', function() {
        var laser = game.board.find('.laser');
        expect(laser.length).toEqual(1);
        expect(laser.find('.beam').offset().width).toEqual(adderSquare.offset().width * 2)
        expect(laser.offset().left + laser.offset().width).toEqual(adderSquare.offset().left)
    });
    
    it('should not accept a laser with a different denominator', function() {
        var laser2Square = game.board.find('.square.index28');
        laser2Square.data('numerator', 1)
        laser2Square.data('denominator', 4)
        game.addObjectToSquare('laser_left', laser2Square);
        var lasers = game.board.find('.laser');
        expect(lasers.length).toEqual(2);
    });
    
    describe('when a second laser is accepted with the same denominator', function() {
        var laser2Square;
        beforeEach(function() {
            laser2Square = game.board.find('.square.index28');
            laser2Square.data('numerator', 2)
            laser2Square.data('denominator', 3)
            game.addObjectToSquare('laser_left', laser2Square);            
        })
        
        it('should result in three lasers', function() {
            var lasers = game.board.find('.laser');
            expect(lasers.length).toEqual(3);            
        })

        it('should fire a laser that adds up the incoming lasers and goes down', function() {
            var downLaser = game.board.find('.laser.laser24');
            expect(downLaser.data('numerator')).toEqual(3);
            expect(downLaser.data('denominator')).toEqual(3);
            expect(downLaser.offset().top + downLaser.height()).toEqual(game.board.height() - 1)
        });
    })
        
    
});