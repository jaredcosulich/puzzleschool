// Generated by CoffeeScript 1.3.3
var soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  Xyflyer: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      var object, _i, _len, _ref;
      this.classId = _arg.classId, this.levelId = _arg.levelId;
      this.template = this.loadTemplate("/build/common/templates/puzzles/xyflyer.html");
      this.loadScript('/assets/third_party/equation_explorer/tokens.js');
      this.loadScript('/assets/third_party/raphael-min.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/tdop.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/parser.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/object.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/board.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/plane.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/ring.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equation.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equation_component.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equations.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/index.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer.js');
      this.objects = [];
      _ref = ['island', 'plane'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        this.objects.push({
          name: object,
          image: this.loadImage("/assets/images/puzzles/xyflyer/" + object + ".png")
        });
      }
      if (this.levelId === 'editor') {
        this.loadScript('/build/common/pages/puzzles/lib/xyflyer_editor.js');
      }
      return this.loadStylesheet('/build/client/css/puzzles/xyflyer.css');
    },
    build: function() {
      this.setTitle("XYFlyer - The Puzzle School");
      return this.html = wings.renderTemplate(this.template, {
        objects: this.objects
      });
    }
  }
});

soma.views({
  Xyflyer: {
    selector: '#content .xyflyer',
    create: function() {
      var xyflyer;
      xyflyer = require('./lib/xyflyer');
      this.viewHelper = new xyflyer.ViewHelper({
        el: $(this.selector),
        boardElement: this.$('.board'),
        objects: this.$('.objects'),
        equationArea: this.$('.equation_area'),
        grid: {
          xMin: -10,
          xMax: 10,
          yMin: -10,
          yMax: 10
        }
      });
      this.initEquations();
      this.viewHelper.addEquation();
      this.viewHelper.addRing(3, 3);
      this.viewHelper.addRing(5, 2);
      this.viewHelper.addEquationComponent(' + 3');
      return this.viewHelper.addEquationComponent('sin(x)');
    },
    initEquations: function() {
      var _this = this;
      return this.$('.equation').bind('keyup', function(e) {
        var input;
        input = $(e.currentTarget);
        return _this.viewHelper.plot(input.attr('id'), input.val());
      });
    }
  }
});

soma.routes({
  '/puzzles/xyflyer/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.Xyflyer({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/xyflyer/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.Xyflyer({
      levelId: levelId
    });
  },
  '/puzzles/xyflyer': function() {
    return new soma.chunks.Xyflyer;
  }
});
