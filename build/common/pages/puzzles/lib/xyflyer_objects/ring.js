// Generated by CoffeeScript 1.3.3
var ring, xyflyerObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ring = typeof exports !== "undefined" && exports !== null ? exports : provide('./ring', {});

xyflyerObject = require('./object');

ring.Ring = (function(_super) {

  __extends(Ring, _super);

  Ring.prototype.width = 8;

  Ring.prototype.height = 32;

  function Ring(_arg) {
    var board;
    board = _arg.board, this.x = _arg.x, this.y = _arg.y;
    this.highlightRadius = 0;
    this.setBoard(board);
    this.animation = new Animation(true);
  }

  Ring.prototype.setBoard = function(board) {
    this.board = board;
    this.screenX = this.board.screenX(this.x);
    this.screenY = this.board.screenY(this.y);
    this.scale = this.board.scale;
    this.initCanvas();
    return this.label = this.board.showXY(this.screenX, this.screenY, false, true);
  };

  Ring.prototype.initCanvas = function() {
    var _this = this;
    this.board.addToCanvas({
      draw: function(ctxFunction) {
        if (!_this.removed) {
          return _this.drawHalfRing(ctxFunction, 1);
        }
      }
    }, 3);
    this.board.addToCanvas({
      draw: function(ctxFunction) {
        if (!_this.removed) {
          return _this.drawHalfRing(ctxFunction, -1);
        }
      }
    }, 1);
    return this.board.addRing(this);
  };

  Ring.prototype.drawHalfRing = function(ctx, xDirection) {
    var h, xRadius, yRadius, _i, _ref, _ref1, _results;
    _results = [];
    for (h = _i = 0, _ref = this.highlightRadius, _ref1 = Math.floor(this.highlightRadius / 4) || 1; 0 <= _ref ? _i <= _ref : _i >= _ref; h = _i += _ref1) {
      ctx.strokeStyle = "rgba(255, 255, 255, " + (this.highlightRadius ? 1 - Math.abs(h / this.highlightRadius) : 1) + ")";
      ctx.lineWidth = h || 1;
      ctx.beginPath();
      xRadius = (this.width / 2) * this.scale;
      yRadius = (this.height / 2) * this.scale;
      ctx.moveTo(this.screenX, this.screenY - yRadius);
      ctx.bezierCurveTo(this.screenX + (xRadius * xDirection), this.screenY - yRadius, this.screenX + (xRadius * xDirection), this.screenY + yRadius, this.screenX, this.screenY + yRadius);
      _results.push(ctx.stroke());
    }
    return _results;
  };

  Ring.prototype.glow = function() {
    var radius, time,
      _this = this;
    this.animating = true;
    radius = 16;
    time = 500;
    return this.animation.start(time, function(deltaTime, progress, totalTime) {
      var easedProgress;
      easedProgress = Math.pow(progress, 1 / 5);
      _this.highlightRadius = radius * easedProgress;
      if (progress === 1) {
        return _this.animation.start(time, function(deltaTime, progress, totalTime) {
          _this.highlightRadius = radius * (1 - progress);
          if (progress === 1) {
            _this.highlightRadius = 0;
            return _this.animating = false;
          }
        });
      }
    });
  };

  Ring.prototype.inPath = function(x, formula) {
    if (Math.round(100 * formula(this.x)) / 100 !== Math.round(100 * this.y) / 100) {
      return false;
    }
    if (x >= this.x - (1 / this.board.xUnit)) {
      return true;
    }
  };

  Ring.prototype.highlight = function() {
    if (!this.passedThrough && !this.highlighting) {
      this.highlighting = true;
      this.passedThrough = true;
      return this.glow();
    }
  };

  Ring.prototype.highlightIfPassingThrough = function(_arg) {
    var height, width, x, y;
    x = _arg.x, y = _arg.y, width = _arg.width, height = _arg.height;
    if (this.touches(x, y, width, height)) {
      return this.highlight;
    }
  };

  Ring.prototype.touches = function(x, y, width, height) {
    return this.screenX > x - (width / 2) && this.screenX < x + (width / 2) && this.screenY > y - (height / 2) && this.screenY < y + (height / 2);
  };

  Ring.prototype.reset = function() {
    this.passedThrough = false;
    return this.highlighting = false;
  };

  Ring.prototype.remove = function() {
    this.label.remove();
    return this.removed = true;
  };

  return Ring;

})(xyflyerObject.Object);
