describe("Init:", function() {
    var game;

    beforeEach(function() {
        game = new languageScramble.ViewHelper({
            el: $('.language_scramble'),
            puzzleData: {levels: {'english_italian': {}}},
            languages: 'english_italian',
            saveProgress: function() {},
            maxLevel: 5
        })
          
        game.setLevel('top10words');         
        game.newScramble();
    
    });
    
    it("should have a scramble with many letters", function() {
        expect($($('.scrambled .letter')[0]).length).not.toEqual(0)
    });
    
    it("should not cram letters together", function() {
        var letters = $('.scrambled .letter');
        expect($(letters[0]).offset().top).toEqual($(letters[1]).offset().top)
    });
});