describe("Analyzer", function() {
    var analyzer;
    
    beforeEach(function() {
        analyzer = new Analyzer()
    });
    
    it('should instantiate an analyzer', function() {
        expect(analyzer).not.toBe(undefined);
        expect(analyzer.info).not.toBe(undefined);
    });
    
    describe('solving a matrix', function() {
        describe('with a simple circuit', function () {
            beforeEach(function() {
                analyzer.info.matrix = {loops: {"1":{"voltage":9,"start":"section13764261443130.5193100867327303","sections": {"section13764261443130.5193100867327303":{"resistance":5}}}},"currentLoop":1};
                analyzer.solveMatrix();
            });
            
            it('should solve for the current', function() {
                expect(analyzer.info.matrix.loops[1].sections['section13764261443130.5193100867327303'].amps).toEqual(9/5);
            });
        });

        describe('with a two battery circuit', function () {
            beforeEach(function() {
                analyzer.info.matrix = {"loops":{"1":{"voltage":12,"sections":{"section13764524611460.7137672745157033":{"resistance":2},"section13764524611440.2006309200078249":{"resistance":4}},"start":"section13764524611460.7137672745157033","completed":true},"2":{"voltage":0,"sections":{"section13764524611460.7137672745157033":{"resistance":-1},"section13764524611440.2006309200078249":{"resistance":1},"section13764524611420.8093564675655216":{"resistance":-1}}},"3":{"voltage":0,"sections":{"section13764524611460.7137672745157033":{"resistance":1},"section13764524611470.528651462867856":{"resistance":1},"section13764524611440.2006309200078249":{"resistance":-1}}},"4":{"voltage":20,"sections":{"section13764524611470.528651462867856":{"resistance":6},"section13764524611420.8093564675655216":{"resistance":0},"section13764524611440.2006309200078249":{"resistance":4}},"start":"section13764524611470.528651462867856","completed":true}},"currentLoop":4};
                analyzer.solveMatrix();
            });
            
            it('should assign all currents correctly', function() {
                var sections = analyzer.info.matrix.loops[1].sections;
                var currentMap = {2: 0.91, 4: 2.55, 6: 1.64, 0: 1.64};
                for (sid in sections) {
                    expect(sections[sid].amps).toEqual(currentMap[sections[sid].resistance])
                }
            });
        });
    });
});











