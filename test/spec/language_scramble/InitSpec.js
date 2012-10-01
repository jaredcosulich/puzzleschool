describe("Init:", function() {
    var game;

    beforeEach(function() {
        game = new languageScramble.ViewHelper({
            el: $('.language_scramble'),
            puzzleData: {levels: {'english_italian': {}}},
            languages: 'english_italian',
            saveProgress: function() {},
            maxLevel: 5
        });
     }); 
        
    describe("first level", function() {
        beforeEach(function() {
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
    
    describe("advanced level", function() {
        var data = { english_italian: { levels: { advanced: { data: [] } } } }
        
        beforeEach(function() {
            game.data = data;
        });
        
        var phrases = [
            {native: 'she has been the belle of the ball several times', foreign: 'lei è stata la reginetta del ballo molte volte'},
            {native: 'it\'s not necessary', foreign: 'non è necessario'},
            {native: 'i was a very shy child', foreign: 'ero un bimbo molto timido'}
        ]
        
        testPhrase = function (phrase) {
            it("should show all of the letters on the screen for " + phrase.native, function() {
                game.data.english_italian.levels.advanced.data = [phrase];
                game.setLevel('advanced');         
                game.newScramble();    
                var letters = $('.scrambled .letter')
                var lastLetter = $(letters[letters.length - 1]);
                var pageBottom = $('.language_scramble').offset().top + $('.language_scramble').offset().height
                expect(lastLetter.offset().top + lastLetter.offset().height).toBeLessThan(pageBottom);
            })                        
        }
        
        for (var i=0; i<phrases.length; ++i) testPhrase(phrases[i]);
        
        it("should not go beyond the max level", function() {
            game.data.english_italian.levels.advanced.data = phrases
            game.data.english_italian.levels.advanced.data.push({native: 'x', foreign: 'y'})
            game.setLevel('advanced');         
            data = game.data.english_italian.levels.advanced.data
            game.puzzleData.levels.english_italian.advanced[data[0].id] = 5;
            game.puzzleData.levels.english_italian.advanced[data[1].id] = 5;
            game.puzzleData.levels.english_italian.advanced[data[2].id] = 5;
            game.puzzleData.levels.english_italian.advanced[data[3].id] = 4;
            game.newScramble();
            expect($('.display_words').html()).toContain('x');
        })
    });
});