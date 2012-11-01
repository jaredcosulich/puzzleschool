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
        beforeEach(function() {
            editor.selectSquare(game.board.find('.square.index35'));
            editor.addObject('laser_up');
            d = new Date()
            editor.clear();
        });

        it('should clear the board', function() {
            expect(game.board.html()).toNotContain('laser');           
        });
        
        it('should clear the level description field', function() {
            expect(editor.levelDescription.val()).toNotContain('laser');
        });
        
    })
    
    
    describe('the level saving process', function() {
        beforeEach(function() {
            editor.selectSquare(game.board.find('.square.index29'))
            editor.addObject('laser_up')
        });
        
        it('should change the level_description text area to reflect the current state of the board', function() {
            expect(JSON.parse(editor.levelDescription.val())).toEqual({objects: [{type: 'laser_up', index: 29}]});
        })
        
        it('reloads the game after being cleared', function() {
            var description = editor.levelDescription.val();
            editor.clear();
            editor.levelDescription.val(description);
            editor.load();
            expect(game.board.find('.square.index29').html()).toContain('laser_up')
        })
        
    })
    
    
    
        
});