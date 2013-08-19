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
                initMatrix(analyzer, {"loops":{"section13765946458540.7231298091355711":{"voltage":-9,"sections":{"section13765946458540.7231298091355711":{"resistance":-5}},"path":["section13765946458540.7231298091355711"],"start":"section13765946458540.7231298091355711","completed":true,"id":"section13765946458540.7231298091355711"}},"sections":["section13765946458540.7231298091355711"],"pathsAnalyzed":{},"totalLoops":1,"currentLoop":{"voltage":-9,"sections":{"section13765946458540.7231298091355711":{"resistance":-5}},"path":["section13765946458540.7231298091355711"],"start":"section13765946458540.7231298091355711","completed":true,"id":"section13765946458540.7231298091355711"}});
                analyzer.solveMatrix();
            });
            
            it('should solve for the current', function() {
                expect(analyzer.info.sections['section13765946458540.7231298091355711'].amps).toEqual(9/5);
            });
        });

        describe('with a two battery circuit', function () {
            beforeEach(function() {
                initMatrix(analyzer, {"loops":{"section13765948167660.7938740598037839__section13765948167680.11242776503786445__section13765948167690.7465420099906623":{"voltage":0,"sections":{"section13765948167660.7938740598037839":{"resistance":1},"section13765948167680.11242776503786445":{"resistance":1},"section13765948167690.7465420099906623":{"resistance":-1}},"completed":true,"id":"section13765948167660.7938740598037839__section13765948167680.11242776503786445__section13765948167690.7465420099906623"},"section13765948167660.7938740598037839__section13765948167690.7465420099906623":{"voltage":-20,"sections":{"section13765948167690.7465420099906623":{"resistance":-6},"section13765948167660.7938740598037839":{"resistance":-4}},"path":["section13765948167690.7465420099906623","section13765948167660.7938740598037839"],"start":"section13765948167690.7465420099906623","completed":true,"id":"section13765948167660.7938740598037839__section13765948167690.7465420099906623"},"section13765948167680.11242776503786445__section13765948167690.7465420099906623":{"voltage":-8,"sections":{"section13765948167690.7465420099906623":{"resistance":-6},"section13765948167680.11242776503786445":{"resistance":-2}},"path":["section13765948167690.7465420099906623","section13765948167680.11242776503786445"],"start":"section13765948167690.7465420099906623","completed":true,"id":"section13765948167680.11242776503786445__section13765948167690.7465420099906623"}},"sections":["section13765948167660.7938740598037839","section13765948167680.11242776503786445","section13765948167690.7465420099906623"],"pathsAnalyzed":{},"totalLoops":6,"currentLoop":{"voltage":-8,"sections":{"section13765948167690.7465420099906623":{"resistance":-6},"section13765948167680.11242776503786445":{"resistance":-2}},"path":["section13765948167690.7465420099906623","section13765948167680.11242776503786445"],"start":"section13765948167690.7465420099906623","completed":true,"id":"section13765948167680.11242776503786445__section13765948167690.7465420099906623"}});
                analyzer.solveMatrix();
            });
            
            it('should assign all currents correctly', function() {
                var currentMap = {2: -0.91, 4: 2.55, 6: 1.64, 0: 1.64};
                for (sectionId in analyzer.info.sections) {
                    var section = analyzer.info.sections[sectionId];
                    expect(section.amps).toBeCloseTo(currentMap[section.resistance]);                       
                }
            });
        });
    });
});


function initMatrix(analyzer, matrix) {
    analyzer.info.matrix = matrix;
    for (var i=0; i<matrix.sections.length; ++i) {
        analyzer.info.sections[matrix.sections[i]] = {resistance: 0};
        for (var loopId in analyzer.info.matrix.loops) {
            var loopInfo = analyzer.info.matrix.loops[loopId];
            if (loopInfo.identity) continue;
            for (var sectionId in loopInfo.sections) {
                if (sectionId != matrix.sections[i]) continue;
                var section = loopInfo.sections[sectionId];
                if (section.resistance) analyzer.info.sections[matrix.sections[i]].resistance = Math.abs(section.resistance);
            }
        }
    }
}








