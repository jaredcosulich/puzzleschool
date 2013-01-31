// Generated by CoffeeScript 1.3.3
var fn, name, xyflyer, _ref;

xyflyer = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/xyflyer', {});

_ref = require('./xyflyer_objects/index');
for (name in _ref) {
  fn = _ref[name];
  xyflyer[name] = fn;
}

xyflyer.ChunkHelper = (function() {

  function ChunkHelper() {}

  return ChunkHelper;

})();

xyflyer.ViewHelper = (function() {

  function ViewHelper(_arg) {
    var boardElement, grid, objects,
      _this = this;
    this.el = _arg.el, this.equationArea = _arg.equationArea, boardElement = _arg.boardElement, objects = _arg.objects, grid = _arg.grid, this.nextLevel = _arg.nextLevel, this.registerEvent = _arg.registerEvent, this.islandCoordinates = _arg.islandCoordinates;
    this.rings = [];
    this.board = new xyflyer.Board({
      boardElement: boardElement,
      grid: grid,
      objects: objects,
      islandCoordinates: this.islandCoordinates,
      resetLevel: function() {
        return _this.resetLevel();
      }
    });
    this.plane = new xyflyer.Plane({
      board: this.board,
      track: function(info) {
        return _this.trackPlane(info);
      }
    });
    this.parser = require('./parser');
    this.initEquations();
  }

  ViewHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  ViewHelper.prototype.plot = function(id, data) {
    var area, formula, _ref1;
    _ref1 = this.parser.parse(data), formula = _ref1[0], area = _ref1[1];
    return this.board.plot(id, formula, area);
  };

  ViewHelper.prototype.trackPlane = function(info) {
    var allPassedThrough, ring, _i, _len, _ref1;
    allPassedThrough = this.rings.length > 0;
    _ref1 = this.rings;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      ring = _ref1[_i];
      ring.highlightIfPassingThrough(info);
      if (!ring.passedThrough) {
        allPassedThrough = false;
      }
    }
    if (allPassedThrough) {
      return this.completeLevel();
    }
  };

  ViewHelper.prototype.addRing = function(x, y) {
    return this.rings.push(new xyflyer.Ring({
      board: this.board,
      x: x,
      y: y
    }));
  };

  ViewHelper.prototype.initEquations = function() {
    var _this = this;
    return this.equations = new xyflyer.Equations({
      el: this.equationArea,
      gameArea: this.el,
      plot: function(id, data) {
        return _this.plot(id, data);
      },
      submit: function() {
        return _this.plane.launch(true);
      },
      registerEvent: this.registerEvent
    });
  };

  ViewHelper.prototype.addEquation = function(solution, startingFragment, solutionComponents, variables) {
    return this.equations.add(solution, startingFragment, solutionComponents, variables);
  };

  ViewHelper.prototype.addEquationComponent = function(equationFragment) {
    return this.equations.addComponent(equationFragment);
  };

  ViewHelper.prototype.resetLevel = function() {
    var ring, _i, _len, _ref1, _results;
    this.plane.reset();
    _ref1 = this.rings;
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      ring = _ref1[_i];
      _results.push(ring.reset());
    }
    return _results;
  };

  ViewHelper.prototype.completeLevel = function() {
    if (this.complete) {
      return;
    }
    this.complete = true;
    return this.nextLevel();
  };

  return ViewHelper;

})();