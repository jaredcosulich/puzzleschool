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
    this.animation = new Animation(true);
    this.addToBoard();
    this.reset();
  }

  Plane.prototype.setBoard = function(board) {
    this.board = board;
    return this.addToBoard();
  };

  Plane.prototype.addToBoard = function() {
    this.board.addToCanvas(this, 2);
    return this.cloudCanvas = this.board.createCanvas();
  };

  Plane.prototype.drawCloud = function(x, y) {
    this.clouds = true;
    if (this.lastCloudTime && this.latestTime - this.lastCloudTime < 50) {
      return;
    }
    if (this.lastCloudTime) {
      $cloudgen.drawCloud(this.cloudCanvas, x, y, 3 + (Math.random() * 3));
    }
    return this.lastCloudTime = this.latestTime;
  };

  Plane.prototype.fadeClouds = function() {
    var alpha, fade,
      _this = this;
    if (!this.clouds) {
      return;
    }
    alpha = 1;
    fade = function() {
      alpha -= 0.25;
      _this.cloudCanvas.canvas.style.opacity = alpha;
      if (alpha <= 0) {
        _this.clouds = false;
        _this.cloudCanvas.clearRect(0, 0, _this.board.width, _this.board.height);
        _this.cloudCanvas.canvas.style.opacity = 1;
      }
      return $.timeout(100, function() {
        if (alpha > 0) {
          return fade();
        }
      });
    };
    return fade();
  };

  Plane.prototype.draw = function(ctx, t) {
    var keys, lastPosition, moveTo, position,
      _this = this;
    if (!this.image) {
      return;
    }
    this.latestTime = t;
    if (!this.startTime) {
      this.startTime = this.latestTime;
    }
    moveTo = function(position) {
      _this.xPos = position.x;
      _this.yPos = position.y;
      _this.move(_this.xPos + _this.board.xAxis, _this.board.yAxis - _this.yPos);
      if (position.ring) {
        position.ring.highlight();
      }
      return _this.drawCloud(_this.xPos + _this.board.xAxis, _this.board.yAxis - _this.yPos);
    };
    if (this.path) {
      position = this.path[Math.round((this.latestTime - this.startTime) / this.timeFactor * 10)];
      if (!position || this.path.distance === 0) {
        keys = Object.keys(this.path);
        lastPosition = this.path[keys[keys.length - 2]];
        if (this.path.distance === 0 || this.xPos === lastPosition.x && this.yPos === lastPosition.y) {
          if (this.board.paperY(this.currentYPos) > this.board.grid.yMax * 1.5) {
            this.reset();
          } else {
            this.fall();
          }
        } else {
          moveTo(lastPosition);
        }
      } else {
        moveTo(position);
      }
    }
    return ctx.drawImage(this.image[0], this.currentXPos - (this.width / 2), this.currentYPos - (this.height / 2), this.width, this.height);
  };

  Plane.prototype.size = function() {
    this.scale = this.board.scale / 1.5;
    this.width = this.image.width() * this.scale;
    this.height = this.image.height() * this.scale;
    return this.timeFactor = 1.65 / this.scale;
  };

  Plane.prototype.move = function(x, y, next) {
    var _this = this;
    if (!x || !y) {
      return;
    }
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
    if (this.falling) {
      return;
    }
    this.falling = true;
    this.path = null;
    x = this.xPos + this.board.xAxis + 20;
    y = this.board.height * 1.2;
    return this.animate(x, y, 2000, function() {
      return _this.board.resetLevel();
    });
  };

  Plane.prototype.launch = function(force) {
    var f, id, path,
      _this = this;
    if (this.falling || this.cancelFlight && !force) {
      return;
    }
    this.board.resetLevel();
    this.board.fadePlots();
    if (!this.path || !Object.keys(this.path).length) {
      path = this.board.calculatedPath || this.board.calculatePath();
      if (!(path != null ? path.distance : void 0)) {
        return this.moveLaunch({
          toX: this.board.islandCoordinates.x,
          toY: ((function() {
            var _ref, _results;
            _ref = this.board.formulas;
            _results = [];
            for (id in _ref) {
              f = _ref[id];
              _results.push(f.formula(this.board.islandCoordinates.x));
            }
            return _results;
          }).call(this))[0],
          callback: function() {
            return _this.setPath(_this.board.calculatePath());
          }
        });
      } else {
        return this.setPath(path);
      }
    }
  };

  Plane.prototype.setPath = function(path) {
    this.cancelFlight = false;
    this.startTime = null;
    this.latestTime = null;
    return this.path = path;
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
    this.startTime = null;
    this.latestTime = null;
    this.endingX = null;
    this.endingY = null;
    this.path = null;
    this.size();
    this.xPos = Math.round(this.board.islandCoordinates.x * this.board.xUnit);
    this.move(this.board.xAxis + (this.board.islandCoordinates.x * this.board.xUnit), this.board.yAxis - (this.board.islandCoordinates.y * this.board.yUnit));
    if (this.board.showPlots()) {
      return this.fadeClouds();
    }
  };

  return Plane;

})(xyflyerObject.Object);
