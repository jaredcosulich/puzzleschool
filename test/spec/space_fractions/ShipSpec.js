describe("A ship", function() {
    var game, shipSquare;

    beforeEach(function() {
        game = new spaceFractions.ViewHelper({
            el: $('.space_fractions'),
            rows: 10,
            columns: 10
        });
        
        shipSquare = game.board.find('.square.index28');
        shipSquare.data('fullNumerator', 1);
        shipSquare.data('fullDenominator', 3);
    }); 
        
    describe('in an empty space', function() {
        beforeEach(function() {
            game.addObjectToSquare('ship_up', shipSquare);
        });

        it('should display the fraction it accepts', function() {
            expect(shipSquare.html()).toContain('1/3'); 
        });
         
        it('should not light up if there is no laser coming in to it', function() {
            expect(shipSquare.find('img').attr('src')).toContain('empty');
        });

        it('should light up if the correct laser amount comes in to it', function() {
            var laserSquare = game.board.find('.square.index58');
            laserSquare.data('numerator', 1);
            laserSquare.data('denominator', 3);
            game.addObjectToSquare('laser_up', laserSquare);
            expect(shipSquare.find('img').attr('src')).toContain('full');
        });

        it('should be overfull if too much laser comes in to it', function() {
            var laserSquare = game.board.find('.square.index58');
            laserSquare.data('numerator', 2);
            laserSquare.data('denominator', 3);
            game.addObjectToSquare('laser_up', laserSquare);
            expect(shipSquare.find('img').attr('src')).toContain('over');            
        });

        it('should be underfull if too little laser comes in to it', function() {
            var laserSquare = game.board.find('.square.index58');
            laserSquare.data('numerator', 1);
            laserSquare.data('denominator', 6);
            game.addObjectToSquare('laser_up', laserSquare);
            expect(shipSquare.find('img').attr('src')).toContain('under');            
        });
        
        it('should go back to empty when the laser is removed', function() {
            var laserSquare = game.board.find('.square.index58');
            laserSquare.data('numerator', 1);
            laserSquare.data('denominator', 3);
            game.addObjectToSquare('laser_up', laserSquare);
            expect(shipSquare.find('img').attr('src')).toContain('full');
            game.removeObjectFromSquare(laserSquare);
            expect(shipSquare.find('img').attr('src')).toContain('empty');                        
        });
        
    });

    describe('in a space occupied by a laser', function() {
        var laserSquare;
        beforeEach(function() {
            laserSquare = game.board.find('.square.index58');
            laserSquare.data('numerator', 1);
            laserSquare.data('denominator', 3);
            game.addObjectToSquare('laser_up', laserSquare);
        })
        
        it('should light up if the it is placed on the correct amount of laser', function() {
            game.addObjectToSquare('ship_up', shipSquare);
            expect(shipSquare.find('img').attr('src')).toContain('full');                        
        });

        it('should block a laser that is not heading in the direction it accepts', function() {
            game.addObjectToSquare('ship_left', shipSquare);
            expect(shipSquare.find('img').attr('src')).toContain('empty');                        
        });
    });
    
    describe('with multiple lasers hitting it', function() {
        var laserSquare, laser2Square;
        
        beforeEach(function() {
            game.addObjectToSquare('ship_up', shipSquare);
            laserSquare = game.board.find('.square.index58');
            laserSquare.data('numerator', 1);
            laserSquare.data('denominator', 3);
            game.addObjectToSquare('laser_up', laserSquare);

            laser2Square = game.board.find('.square.index22');
            laser2Square.data('numerator', 1);
            laser2Square.data('denominator', 2);
            game.addObjectToSquare('laser_right', laser2Square);
        });

        it('should accept the corret laser and ignore the other', function() {
            expect(shipSquare.find('img').attr('src')).toContain('full');
        })
        
        it('should not change state if a non-affecting laser is removed', function() {
            game.removeObjectFromSquare(laser2Square);
            expect(shipSquare.find('img').attr('src')).toContain('full');            
        })
    })
    
});