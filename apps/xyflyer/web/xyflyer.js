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
    var boardElement, flip, hidePlots, objects,
      _this = this;
    this.el = _arg.el, this.equationArea = _arg.equationArea, boardElement = _arg.boardElement, objects = _arg.objects, this.grid = _arg.grid, this.islandCoordinates = _arg.islandCoordinates, hidePlots = _arg.hidePlots, flip = _arg.flip, this.nextLevel = _arg.nextLevel, this.registerEvent = _arg.registerEvent;
    this.rings = [];
    this.setFlip(flip);
    this.board = new xyflyer.Board({
      el: boardElement,
      grid: this.grid,
      objects: objects,
      islandCoordinates: this.islandCoordinates,
      hidePlots: hidePlots,
      resetLevel: function() {
        return _this.resetLevel();
      }
    });
    this.plane = new xyflyer.Plane({
      board: this.board,
      objects: objects,
      track: function(info) {
        return _this.trackPlane(info);
      }
    });
    this.initGuidelines(hidePlots, true);
    this.parser = require('./parser');
    this.initEquations();
  }

  ViewHelper.prototype.reinitialize = function(_arg) {
    var boardElement, flip, hidePlots, objects, showHidePlotsMessage;
    this.equationArea = _arg.equationArea, boardElement = _arg.boardElement, objects = _arg.objects, this.grid = _arg.grid, this.islandCoordinates = _arg.islandCoordinates, hidePlots = _arg.hidePlots, flip = _arg.flip;
    this.rings = [];
    this.setFlip(flip);
    showHidePlotsMessage = hidePlots && !this.board.hidePlots;
    this.board.init({
      el: boardElement,
      grid: this.grid,
      objects: objects,
      islandCoordinates: this.islandCoordinates,
      hidePlots: hidePlots
    });
    this.complete = false;
    this.plane.setBoard(this.board);
    this.initGuidelines(hidePlots, showHidePlotsMessage);
    this.initEquations();
    return this.resetLevel();
  };

  ViewHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  ViewHelper.prototype.setFlip = function(direction) {
    if (!direction) {
      return;
    }
    this.el.removeClass('left');
    this.el.removeClass('right');
    return this.el.addClass(direction);
  };

  ViewHelper.prototype.plot = function(id, data) {
    var area, formula, _ref1;
    this.plane.fadeClouds();
    _ref1 = this.parser.parse(data), formula = _ref1[0], area = _ref1[1];
    if (!this.board.plot(id, formula, area)) {
      return false;
    }
    return true;
  };

  ViewHelper.prototype.moveLaunch = function() {
    var f, id, islandX, islandY;
    islandX = this.board.screenX(this.board.islandCoordinates.x);
    islandY = this.board.screenY(((function() {
      var _ref1, _results;
      _ref1 = this.board.formulas;
      _results = [];
      for (id in _ref1) {
        f = _ref1[id];
        _results.push(f.formula(this.board.islandCoordinates.x));
      }
      return _results;
    }).call(this))[0]);
    this.board.moveIsland(islandX, islandY);
    return this.plane.move(islandX, islandY);
  };

  ViewHelper.prototype.trackPlane = function(_arg) {
    var allPassedThrough, height, ring, width, x, y, _i, _len, _ref1;
    x = _arg.x, y = _arg.y, width = _arg.width, height = _arg.height;
    allPassedThrough = this.rings.length > 0;
    _ref1 = this.rings;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      ring = _ref1[_i];
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

  ViewHelper.prototype.initGuidelines = function(hidePlots, showHidePlotsMessage) {
    var areaOffset, gameAreaOffset, message, messageOffset, showGuidelines,
      _this = this;
    showGuidelines = this.el.find('.show_guidelines');
    showGuidelines.unbind('click.guidelines touchstart.guidelines');
    showGuidelines.bind('click.guidelines touchstart.guidelines', function() {
      hidePlots = showGuidelines.hasClass('on');
      showGuidelines.removeClass(hidePlots ? 'on' : 'off');
      showGuidelines.addClass(hidePlots ? 'off' : 'on');
      return _this.board.setHidePlots(hidePlots);
    });
    if (hidePlots) {
      showGuidelines.trigger('click.guidelines');
      if (showHidePlotsMessage) {
        areaOffset = this.$('.equations').offset();
        gameAreaOffset = this.el.offset();
        messageOffset = this.equationArea.find('.guidelines').offset();
        message = this.$('.guidelines_popup');
        message.css({
          opacity: 0,
          top: messageOffset.top - message.height() - gameAreaOffset.top - 6,
          left: messageOffset.left + (messageOffset.width / 2) - (message.width() / 2) - areaOffset.left
        });
        message.html('The graph lines are hidden for this level.<br/>\nTry solving the level without them.<br/>\nYou can turn them back on if you need them.');
        message.animate({
          opacity: 1,
          duration: 250
        });
        return $(document.body).one('mousedown.guidelines touchstart.guidelines', function() {
          return message.animate({
            opacity: 0,
            duration: 250,
            complete: function() {
              return message.css({
                top: -1000,
                left: -1000
              });
            }
          });
        });
      }
    }
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

  ViewHelper.prototype.addEquationComponent = function(equationFragment, side) {
    return this.equations.addComponent(equationFragment, side);
  };

  ViewHelper.prototype.resetLevel = function() {
    var ring, _i, _len, _ref1, _results;
    this.complete = false;
    if (this.plane) {
      this.plane.reset();
    }
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
