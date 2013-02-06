// Generated by CoffeeScript 1.3.3
var Animation, plane, xyflyerObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

plane = typeof exports !== "undefined" && exports !== null ? exports : provide('./plane', {});

xyflyerObject = require('./object');

Animation = require('./animation').Animation;

plane.Plane = (function(_super) {

  __extends(Plane, _super);

  Plane.prototype.increment = 5;

  Plane.prototype.incrementTime = 7;

  function Plane(_arg) {
    this.board = _arg.board, this.track = _arg.track, this.objects = _arg.objects;
    this.scale = this.board.scale / 2;
    this.initCanvas();
    this.animation = new Animation();
    this.reset();
  }

  Plane.prototype.initCanvas = function() {
    var _this = this;
    if (!(this.image = this.objects.find('.plane img')).height()) {
      setTimeout((function() {
        return _this.initCanvas();
      }), 50);
      return;
    }
    this.width = this.image.width() * this.scale;
    this.height = this.image.height() * this.scale;
    return this.canvas = this.board.createCanvas();
  };

  Plane.prototype.move = function(x, y, next) {
    var _this = this;
    if (!this.canvas) {
      setTimeout((function() {
        return _this.move(x, y, next);
      }), 50);
      return;
    }
    this.canvas.clearRect(this.currentXPos - this.width, this.currentYPos - this.height, this.width * 4, this.height * 4);
    this.canvas.drawImage(this.image[0], x - (this.width / 2), y - (this.height / 2), this.width, this.height);
    this.currentXPos = x;
    this.currentYPos = y;
    setTimeout((function() {
      return _this.track({
        x: x,
        y: y,
        width: _this.width,
        height: _this.height
      });
    }), 10);
    if (next) {
      return next();
    }
  };

  Plane.prototype.animate = function(toX, toY, time, next) {
    var startX, startY,
      _this = this;
    if (!time) {
      this.move(toX, toY, next);
      return;
    }
    startX = null;
    startY = null;
    return this.animation.queueAnimation(time, function(portion, remaining) {
      var portionX, portionY;
      if (!(startX != null)) {
        startX = _this.currentXPos;
      }
      if (!(startY != null)) {
        startY = _this.currentYPos;
      }
      if (portion <= 0) {
        return false;
      }
      if (portion > 1) {
        return true;
      }
      if (remaining < 20) {
        _this.move(toX, toY, next);
        return true;
      }
      portionX = (toX - startX) * portion;
      portionY = (toY - startY) * portion;
      _this.move(startX + portionX, startY + portionY);
      return false;
    });
  };

  Plane.prototype.fall = function() {
    var x, y,
      _this = this;
    this.falling = true;
    x = this.xPos + this.board.xAxis + 20;
    y = 1000;
    return this.animate(x, y, 4000, function() {
      return _this.reset();
    });
  };

  Plane.prototype.launch = function(force) {
    var dX, dY, formula, time, _ref, _ref1;
    if (this.falling || this.cancelFlight && !force) {
      return;
    }
    this.cancelFlight = false;
    if (!this.path || !Object.keys(this.path).length) {
      this.path = this.board.calculatePath(this.increment);
    }
    this.xPos += 1;
    this.yPos = (_ref = this.path[this.xPos]) != null ? _ref.y : void 0;
    formula = (_ref1 = this.path[this.xPos]) != null ? _ref1.formula : void 0;
    if (this.yPos === void 0 || this.xPos > ((this.board.grid.xMax + this.width) * this.board.xUnit)) {
      this.fall();
      this.animation.start();
      return;
    }
    if (this.xPos % this.increment === 0) {
      if (this.lastFormula) {
        dX = this.increment;
        dY = this.yPos - this.path[this.xPos - this.increment].y;
        time = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2)) * this.incrementTime;
      }
      this.lastFormula = formula;
      this.animate(this.xPos + this.board.xAxis, this.board.yAxis - this.yPos, time);
    }
    return this.launch();
  };

  Plane.prototype.reset = function() {
    this.falling = false;
    this.cancelFlight = true;
    this.path = null;
    this.xPos = Math.round(this.board.islandCoordinates.x * this.board.xUnit) - 1;
    this.lastFormula = null;
    return this.move(this.board.xAxis + (this.board.islandCoordinates.x * this.board.xUnit), this.board.yAxis - (this.board.islandCoordinates.y * this.board.yUnit));
  };

  return Plane;

})(xyflyerObject.Object);
