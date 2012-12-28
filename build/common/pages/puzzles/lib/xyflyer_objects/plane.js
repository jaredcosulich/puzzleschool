// Generated by CoffeeScript 1.3.3
var plane, xyflyerObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

plane = typeof exports !== "undefined" && exports !== null ? exports : provide('./plane', {});

xyflyerObject = require('./object');

plane.Plane = (function(_super) {

  __extends(Plane, _super);

  Plane.prototype.description = 'm45.80125,3.33402c0.61292,0.46928 1.05152,2.94397 1.0285,5.25969c-0.02302,2.31571 0.88025,4.64063 1.80347,4.95859c1.07606,0.47389 -1.08528,0.4524 -4.94019,-0.04909c-4.62682,-0.50918 -7.87342,-0.07825 -9.7398,1.29276c-2.7988,1.97934 -2.64902,2.44402 2.56464,6.04694c10.58017,7.36176 4.70142,8.53851 -7.58,1.46862c-4.45249,-2.51458 -11.06171,-5.51379 -14.75765,-6.4769c-7.85194,-2.23958 -13.64944,-0.88678 -13.51925,-2.07142c1.88137,-3.08462 5.38157,-1.90437 6.92488,-4.45687c1.87412,-1.08561 1.3257,-1.69121 -1.17471,-4.04786c-2.5984,-2.65056 0.64206,-2.46396 6.1737,0.21575c6.14608,2.99462 26.3761,2.57809 28.87842,-0.63936c2.0361,-2.9133 2.80954,-3.06 4.338,-1.50085z';

  Plane.prototype.increment = 5;

  Plane.prototype.width = 50;

  Plane.prototype.height = 30;

  function Plane(_arg) {
    this.board = _arg.board, this.track = _arg.track;
    this.scale = this.board.scale / 2;
    this.image = this.board.addPlane(this);
    this.image.attr({
      fill: '#000'
    });
    this.reset();
  }

  Plane.prototype.move = function(x, y, time, next) {
    var method, transformation;
    if (this.falling) {
      return;
    }
    method = 'linear';
    if (x === 'falling') {
      this.falling = true;
      x = this.xPos + this.board.xAxis + this.width + (this.board.islandCoordinates.x * this.board.xUnit);
      y = 1000;
      time = 2000;
      method = 'easeIn';
    }
    transformation = "t" + (x - (this.width / 2)) + "," + (y - (this.height / 2)) + "s-" + this.scale + "," + this.scale;
    this.image.animate({
      transform: transformation
    }, time, method, next);
    return this.track({
      x: x,
      y: y,
      width: this.width,
      height: this.height
    });
  };

  Plane.prototype.launch = function(force) {
    var dX, dY, formula, time, _ref, _ref1,
      _this = this;
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
      this.move('falling');
      $.timeout(2000, function() {
        return _this.reset();
      });
      return;
    }
    if (this.xPos % this.increment === 0) {
      if (this.lastFormula) {
        dX = this.increment;
        dY = this.yPos - this.path[this.xPos - this.increment].y;
        time = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2)) * this.increment;
      }
      this.move(this.xPos + this.board.xAxis, this.board.yAxis - this.yPos, time, function() {
        return _this.launch();
      });
      return this.lastFormula = formula;
    } else {
      return this.launch();
    }
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
