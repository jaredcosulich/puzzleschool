// Generated by CoffeeScript 1.3.3
var LEVELS, soma, wings;

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
        objects: this.objects,
        level: this.levelId
      });
    }
  }
});

soma.views({
  Xyflyer: {
    selector: '#content .xyflyer',
    create: function() {
      var fragment, i, ring, xyflyer, _i, _j, _k, _len, _len1, _ref, _ref1, _ref2, _results,
        _this = this;
      xyflyer = require('./lib/xyflyer');
      this.level = this.el.data('level');
      if (!isNaN(this.level)) {
        this.data = LEVELS[this.level];
      }
      this.viewHelper = new xyflyer.ViewHelper({
        el: $(this.selector),
        boardElement: this.$('.board'),
        objects: this.$('.objects'),
        equationArea: this.$('.equation_area'),
        grid: this.data.grid,
        nextLevel: function() {
          return _this.nextLevel();
        }
      });
      for (i = _i = 0, _ref = this.data.equationCount; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        this.viewHelper.addEquation();
      }
      _ref1 = this.data.rings;
      for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
        ring = _ref1[_j];
        this.viewHelper.addRing(ring.x, ring.y);
      }
      _ref2 = this.data.fragments;
      _results = [];
      for (_k = 0, _len1 = _ref2.length; _k < _len1; _k++) {
        fragment = _ref2[_k];
        _results.push(this.viewHelper.addEquationComponent(fragment));
      }
      return _results;
    },
    nextLevel: function() {
      var areaOffset, boardOffset, complete, offset,
        _this = this;
      complete = this.$('.complete');
      offset = complete.offset();
      boardOffset = this.$('.board').offset();
      areaOffset = this.el.offset();
      complete.find('a').bind('click', function() {
        return _this.go("/puzzles/xyflyer/" + (_this.level + 1));
      });
      complete.css({
        opacity: 0,
        top: (boardOffset.top - areaOffset.top) + (boardOffset.height / 2) - (offset.height / 2),
        left: (boardOffset.left - areaOffset.left) + (boardOffset.width / 2) - (offset.width / 2)
      });
      return complete.animate({
        opacity: 0.9,
        duration: 500
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

LEVELS = [
  {}, {
    equationCount: 1,
    grid: {
      xMin: -10,
      xMax: 10,
      yMin: -10,
      yMax: 10
    },
    rings: [
      {
        x: 1,
        y: 2
      }, {
        x: 3,
        y: 6
      }
    ],
    fragments: ['2x']
  }, {
    equationCount: 1,
    grid: {
      xMin: -10,
      xMax: 10,
      yMin: -10,
      yMax: 10
    },
    rings: [
      {
        x: 2,
        y: 0.5
      }, {
        x: 4,
        y: 1
      }, {
        x: 6,
        y: 1.5
      }
    ],
    fragments: ['4x', '(1/4)x']
  }, {
    equationCount: 2,
    grid: {
      xMin: -10,
      xMax: 10,
      yMin: -10,
      yMax: 10
    },
    rings: [
      {
        x: .5,
        y: 1
      }, {
        x: 6,
        y: 5
      }
    ],
    fragments: ['2x', '.5x', '+2']
  }
];
