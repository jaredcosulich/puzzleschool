describe("Hints:", function() {
    var game;

    beforeEach(function() {
        game = new spaceFractions.ViewHelper({
            el: $('.space_fractions'),
            rows: 10,
            columns: 10
        });
        levelDescription = {"objects":[{"type":"turn_up_right","index":11},{"type":"two_split_right_down","index":16},{"type":"ship_right","index":18,"fullNumerator":"1","fullDenominator":"10"},{"type":"ship_left","index":50,"fullNumerator":"1","fullDenominator":"20"},{"type":"two_split_down_left","index":56},{"type":"laser_up","index":71,"numerator":"1","denominator":"5"},{"type":"ship_down","index":86,"fullNumerator":"1","fullDenominator":"40"}], "verified": true}
        game.loadToPlay(JSON.stringify(levelDescription));
     }); 
        
    it("should highlight an piece in the options area", function() {
        expect(game.solution.objects.length).toBeGreaterThan(0);
        game.showHint();
        expect(game.options.find('.square.highlighted').length).toEqual(1);
    });
    
});