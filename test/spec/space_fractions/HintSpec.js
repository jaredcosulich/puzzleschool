describe("Hints:", function() {
    var game;

    beforeEach(function() {
        game = new spaceFractions.ViewHelper({
            el: $('.space_fractions'),
            rows: 10,
            columns: 10
            registerEvent: function() {}
        });
        levelDescription = {"objects":[{"type":"turn_up_right","index":11},{"type":"two_split_right_down","index":16}], "verified": true}
        game.loadToPlay(JSON.stringify(levelDescription));
     }); 
        
    it("should highlight an piece in the options area", function() {
        expect(game.solution.objects.length).toBeGreaterThan(0);
        game.showHint();
        expect(game.board.find('.square.highlighted').length).toEqual(0);
        expect(game.options.find('.square.highlighted').length).toEqual(1);
    });
    
    it('should highlight a piece on the board if it is the wrong piece', function() {
        game.addObjectToSquare('turn_up_left', game.board.find('.square.index11'))
        game.showHint();
        expect(game.options.find('.square.highlighted').length).toEqual(0);        
        expect(game.board.find('.square.highlighted').length).toEqual(1);
        expect(game.board.find('.square.highlighted').hasClass('index11')).toBe(true)        
    })
    
    it('should unhighlight the highlighted piece on board once the hint is clicked', function() {
        game.addObjectToSquare('two_split_right_down', game.board.find('.square.index11'))
        game.showHint();
        option = game.board.find('.square.highlighted')
        expect(option.hasClass('index11')).toBe(true);
        option.trigger('mousedown')  
        option.trigger('mousemove')  

        placeHere = game.board.find('.square.highlighted')
        expect(placeHere.length).toEqual(1)
        expect(placeHere.hasClass('index16')).toBe(true)
    })

    it('should highlight another piece on the board if it is the wrong piece and the first piece was the wrong piece', function() {
        game.addObjectToSquare('two_split_right_down', game.board.find('.square.index11'))
        game.addObjectToSquare('turn_up_left', game.board.find('.square.index16'))
        game.showHint();
        expect(game.options.find('.square.highlighted').length).toEqual(0);        
        expect(game.board.find('.square.highlighted').length).toEqual(1);  
        expect(game.board.find('.square.highlighted').hasClass('index16')).toBe(true);      
    })
    
    it('should dehighlight the option space when the option is moved a bit', function() {
        game.addObjectToSquare('two_split_right_down', game.board.find('.square.index11'))
        game.addObjectToSquare('turn_up_left', game.board.find('.square.index16'))
        game.showHint();
        option = game.board.find('.square.highlighted')
        expect(option.hasClass('index16')).toBe(true);
        option.trigger('mousedown')  
        option.trigger('mousemove')  

        expect(game.board.find('.square.highlighted').length).toEqual(0);  
        expect(game.options.find('.square.highlighted').length).toEqual(1);        
    })
    
});