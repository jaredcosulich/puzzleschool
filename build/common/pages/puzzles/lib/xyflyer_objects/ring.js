// Generated by CoffeeScript 1.3.3
var Animation, ring, xyflyerObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ring = typeof exports !== "undefined" && exports !== null ? exports : provide('./ring', {});

xyflyerObject = require('./object');

Animation = require('./animation').Animation;

ring.Ring = (function(_super) {

  __extends(Ring, _super);

  Ring.prototype.fullDescription = 'm0.5,19.94043c0,-10.68549 0.34383,-19.44043 2.82518,-19.44043c2.48135,0 3.17027,8.65525 3.17027,19.34073c0,10.68549 -0.68892,19.34074 -3.17027,19.34074c-2.48135,0 -2.82518,-8.55555 -2.82518,-19.24104z';

  Ring.prototype.frontDescription = 'm3,19.94043c-2.48135,0 -2.82518,-8.55555 -2.82518,-19.24104c0,-10.68549 0.34383,-19.44043 2.82518,-19.44043';

  Ring.prototype.backDescription = 'm-3,-19c2.48135,0 3.17027,8.65525 3.17027,19.34073c0,10.68549 -0.68892,19.34074 -3.17027,19.34074';

  Ring.prototype.width = 8;

  Ring.prototype.height = 32;

  function Ring(_arg) {
    this.board = _arg.board, this.x = _arg.x, this.y = _arg.y;
    this.screenX = this.board.screenX(this.x);
    this.screenY = this.board.screenY(this.y);
    this.scale = 1;
    this.initCanvas();
    this.draw();
    this.label = this.board.showXY(this.screenX, this.screenY, false, true);
    this.animation = new Animation();
  }

  Ring.prototype.initCanvas = function() {
    this.frontCanvas = this.board.createCanvas(3);
    return this.backCanvas = this.board.createCanvas(1);
  };

  Ring.prototype.draw = function(highlightRadius) {
    this.drawHalfRing(this.frontCanvas, 1, highlightRadius);
    return this.drawHalfRing(this.backCanvas, -1, highlightRadius);
  };

  Ring.prototype.drawHalfRing = function(canvas, xDirection, highlightRadius) {
    var h, x, xRadius, y, yDirection, yRadius, _i, _j, _k, _len, _ref, _ref1, _results;
    if (highlightRadius == null) {
      highlightRadius = 0;
    }
    canvas.clearRect(0, 0, this.board.width, this.board.height);
    _results = [];
    for (h = _i = 0; _i <= highlightRadius; h = _i += 2) {
      canvas.strokeStyle = "rgba(255, 255, 255, " + (highlightRadius ? 1 - Math.abs(h / highlightRadius) : 1) + ")";
      canvas.lineWidth = h || 1;
      canvas.beginPath();
      xRadius = this.width / 2;
      yRadius = this.height / 2;
      _ref = [-1, 1];
      for (_j = 0, _len = _ref.length; _j < _len; _j++) {
        yDirection = _ref[_j];
        for (x = _k = 0, _ref1 = xRadius + 0.1; 0 <= _ref1 ? _k <= _ref1 : _k >= _ref1; x = _k += 0.1) {
          if (x > xRadius) {
            x = xRadius;
          }
          y = Math.sqrt(yRadius * (yRadius - Math.pow(x, 2)));
          if (x === 0) {
            canvas.moveTo(this.screenX + (x * xDirection), this.screenY + (y * yDirection));
          } else {
            canvas.lineTo(this.screenX + (x * xDirection), this.screenY + (y * yDirection));
          }
        }
      }
      canvas.stroke();
      _results.push(canvas.closePath());
    }
    return _results;
  };

  Ring.prototype.glow = function() {
    var radius, time,
      _this = this;
    this.animating = true;
    radius = 16;
    time = 400;
    return this.animation.start(time, function(deltaTime, progress, totalTime) {
      var easedProgress;
      easedProgress = Math.pow(progress, 1 / 5);
      _this.draw(radius * easedProgress);
      if (progress === 1) {
        return _this.animation.start(time, function(deltaTime, progress, totalTime) {
          _this.draw(radius * (1 - progress));
          if (progress === 1) {
            _this.draw();
            return _this.animating = false;
          }
        });
      }
    });
  };

  Ring.prototype.highlightIfPassingThrough = function(_arg) {
    var height, width, x, y;
    x = _arg.x, y = _arg.y, width = _arg.width, height = _arg.height;
    if (!this.passedThrough && this.touches(x, y, width, height)) {
      if (!this.highlighting) {
        this.highlighting = true;
        this.glow();
        return this.passedThrough = true;
      }
    }
  };

  Ring.prototype.touches = function(x, y, width, height) {
    return this.screenX > x - (width / 2) && this.screenX < x + (width / 2) && this.screenY > y - (height / 2) && this.screenY < y + (height / 2);
  };

  Ring.prototype.reset = function() {
    return this.passedThrough = false;
  };

  return Ring;

})(xyflyerObject.Object);
