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

  Plane.prototype.incrementTime = 6;

  function Plane(_arg) {
    this.board = _arg.board, this.track = _arg.track, this.objects = _arg.objects;
    this.initCanvas();
    this.animation = new Animation();
    this.reset();
  }

  Plane.prototype.setBoard = function(board) {
    this.board = board;
  };

  Plane.prototype.initCanvas = function() {
    return this.canvas = this.board.createCanvas(2);
  };

  Plane.prototype.clear = function() {
    return this.canvas.clearRect(this.currentXPos - this.width, this.currentYPos - this.height, this.width * 4, this.height * 4);
  };

  Plane.prototype.size = function() {
    this.scale = this.board.scale / 2;
    this.width = this.image.width() * this.scale;
    return this.height = this.image.height() * this.scale;
  };

  Plane.prototype.move = function(x, y, next) {
    var _this = this;
    if (!this.canvas) {
      setTimeout((function() {
        return _this.move(x, y, next);
      }), 50);
      return;
    }
    this.clear();
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
    }), 0);
    if (next) {
      return next();
    }
  };

  Plane.prototype.animate = function(toX, toY, time, next) {
    var startX, startY,
      _this = this;
    if (toX === this.currentXPos && toY === this.currentYPos) {
      return;
    }
    if (!time) {
      this.move(toX, toY, next);
      return;
    }
    startX = this.endingX || this.currentXPos;
    startY = this.endingY || this.currentYPos;
    this.endingX = toX;
    this.endingY = toY;
    return this.animation.start(time, function(deltaTime, portion) {
      var portionX, portionY;
      portionX = (toX - startX) * portion;
      portionY = (toY - startY) * portion;
      return _this.move(startX + portionX, startY + portionY, (portion === 1 ? next : null));
    });
  };

  Plane.prototype.fall = function() {
    var x, y,
      _this = this;
    this.falling = true;
    x = this.xPos + this.board.xAxis + 20;
    y = 1000;
    return this.animate(x, y, 3000, function() {
      return _this.reset();
    });
  };

  Plane.prototype.launch = function(force) {
    var duration, timeFactor,
      _this = this;
    alert('launch3');
    if (this.falling || this.cancelFlight && !force) {
      return;
    }
    this.cancelFlight = false;
    timeFactor = 1.9 / this.scale;
    if (!this.path || !Object.keys(this.path).length) {
      this.path = this.board.calculatePath();
      if (!this.path.distance) {
        this.fall();
      }
    }
    duration = this.path.distance * timeFactor;
    return this.animation.start(duration, function(deltaTime, progress, totalTime) {
      var position;
      position = _this.path[Math.round(totalTime / timeFactor * 10)];
      if (!position) {
        _this.animation.stop();
        if (!(_this.board.paperY(_this.currentYPos) > _this.board.grid.yMax)) {
          return _this.fall();
        }
      } else {
        _this.xPos = position.x;
        _this.yPos = position.y;
        return _this.move(_this.xPos + _this.board.xAxis, _this.board.yAxis - _this.yPos);
      }
    });
  };

  Plane.prototype.reset = function() {
    var _this = this;
    if (!(this.image = this.objects.find('.plane img')).height()) {
      setTimeout((function() {
        return _this.reset();
      }), 50);
      return;
    }
    this.falling = false;
    this.cancelFlight = true;
    this.path = null;
    this.size();
    this.xPos = Math.round(this.board.islandCoordinates.x * this.board.xUnit);
    return this.move(this.board.xAxis + (this.board.islandCoordinates.x * this.board.xUnit), this.board.yAxis - (this.board.islandCoordinates.y * this.board.yUnit));
  };

  return Plane;

})(xyflyerObject.Object);
