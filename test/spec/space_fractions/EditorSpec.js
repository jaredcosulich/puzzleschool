describe("EditorSpec:", function() {
    var game, editor;

    beforeEach(function() {
        game = new spaceFractions.ViewHelper({
            el: $('.space_fractions'),
            rows: 10,
            columns: 10
        });
        
        editor = new spaceFractionsEditor.EditorHelper({
            el: $('.space_fractions'),
            viewHelper: game
        });
    });
    
    it('should not have a laser on it', function() {
        expect(game.board.html()).toNotContain('laser')        
    });
    
    it('the level description should not describe any lasers', function() {
        expect(editor.levelDescription.val()).toNotContain('laser')
    })
    
    describe('adding an object', function() {
       beforeEach(function() {
           editor.selectSquare(game.board.find('.square.index35'))
           editor.addObject('laser_up')           
       });
       
       it('should put the object on the board in the correct place', function() {
          expect(game.board.find('.square.index35').html()).toContain('laser')
       });
    });
    
    
    describe('clearing the editor', function() {
        var selectedSquare;
        beforeEach(function() {
            selectedSquare = game.board.find('.square.index35')
            editor.selectSquare(selectedSquare);
            editor.addObject('laser_up');
            editor.setObjectFraction(1, 3)
            editor.clear();
        });

        it('should clear the board', function() {
            expect(game.board.html()).toNotContain('laser');           
        });
        
        it('should clear data attributes', function () {
            expect(selectedSquare.data('denominator')).toBeNull();
            expect(selectedSquare.data('numerator')).toBeNull();
        })
        
        it('should clear the level description field', function() {
            expect(editor.levelDescription.val()).toNotContain('laser');
        });
        
    })
    
    
    describe('the level saving process', function() {
        beforeEach(function() {
            editor.selectSquare(game.board.find('.square.index89'))
            editor.addObject('laser_up')
            editor.setObjectFraction(1, 3)
        });
        
        it('should change the level_description text area to reflect the current state of the board', function() {
            expect(JSON.parse(editor.levelDescription.val())).toEqual({objects: [{type: 'laser_up', index: 89, numerator: 1, denominator: 3}]});
        })
        
        it('reloads the game after being cleared', function() {
            var description = editor.levelDescription.val();
            editor.clear();
            editor.levelDescription.val(description);
            editor.load();
            expect(game.board.find('.square.index89').html()).toContain('laser_up');
            expect(game.board.find('.square.index89').data('denominator')).toEqual(3);
            expect(JSON.parse(editor.levelDescription.val()).objects.length).toEqual(1);
        })
        
        it('should properly save and be able to load a second object', function () {
            editor.selectSquare(game.board.find('.square.index29'))
            editor.addObject('ship_up')
            editor.setObjectFraction(4, 5)
            
            var description = editor.levelDescription.val();
            editor.clear();
            editor.levelDescription.val(description);
            editor.load();
            
            expect(JSON.parse(editor.levelDescription.val()).objects.length).toEqual(2);

            expect(game.board.find('.square.index89').html()).toContain('laser_up');
            expect(game.board.find('.square.index89').data('denominator')).toEqual(3);

            expect(game.board.find('.square.index29').html()).toContain('ship_up');
            expect(game.board.find('.square.index29').data('fullNumerator')).toEqual(4);
            expect(game.board.find('.square.index29').data('fullDenominator')).toEqual(5);
        })
        
    })
    
    it('should be able to load a complex level', function () {
        levelDescription = {"objects":[{"type":"turn_up_right","index":11},{"type":"two_split_right_down","index":16},{"type":"ship_right","index":18,"fullNumerator":"1","fullDenominator":"10"},{"type":"ship_left","index":50,"fullNumerator":"1","fullDenominator":"20"},{"type":"two_split_down_left","index":56},{"type":"laser_up","index":71,"numerator":"1","denominator":"5"},{"type":"ship_down","index":86,"fullNumerator":"1","fullDenominator":"40"}]}
        editor.levelDescription.val(JSON.stringify(levelDescription));
        editor.load();
        expect(game.board.find('.square.occupied').length).toEqual(levelDescription.objects.length);        
    })
   
    
        
});