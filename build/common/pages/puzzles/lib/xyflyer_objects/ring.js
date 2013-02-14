// Generated by CoffeeScript 1.3.3
var ring, xyflyerObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ring = typeof exports !== "undefined" && exports !== null ? exports : provide('./ring', {});

xyflyerObject = require('./object');

ring.Ring = (function(_super) {

  __extends(Ring, _super);

  Ring.prototype.fullDescription = 'm0.5,19.94043c0,-10.68549 0.34383,-19.44043 2.82518,-19.44043c2.48135,0 3.17027,8.65525 3.17027,19.34073c0,10.68549 -0.68892,19.34074 -3.17027,19.34074c-2.48135,0 -2.82518,-8.55555 -2.82518,-19.24104z';

  Ring.prototype.frontDescription = 'm3,19.94043c-2.48135,0 -2.82518,-8.55555 -2.82518,-19.24104c0,-10.68549 0.34383,-19.44043 2.82518,-19.44043';

  Ring.prototype.backDescription = 'm-3,-19c2.48135,0 3.17027,8.65525 3.17027,19.34073c0,10.68549 -0.68892,19.34074 -3.17027,19.34074';

  Ring.prototype.width = 6;

  Ring.prototype.height = 39;

  function Ring(_arg) {
    var _this = this;
    this.board = _arg.board, this.x = _arg.x, this.y = _arg.y;
    this.screenX = this.board.screenX(this.x);
    this.screenY = this.board.screenY(this.y);
    this.scale = 1;
    this.image = this.board.addRing(this);
    this.image.attr({
      stroke: '#FFF'
    });
    this.move(this.x, this.y);
    this.label = this.board.showXY(this.screenX, this.screenY, false, true);
    this.highlighted = this.board.paper.set();
    this.image.forEach(function(half) {
      return _this.highlighted.push(half.glow({
        color: 'white'
      }));
    });
    this.highlighted.attr({
      opacity: 0
    });
  }

  Ring.prototype.move = function(x, y) {
    this.x = x;
    this.y = y;
    return this.image.transform("t" + this.screenX + "," + this.screenY + "s-" + this.scale + "," + this.scale);
  };

  Ring.prototype.highlightIfPassingThrough = function(_arg) {
    var height, width, x, y;
    x = _arg.x, y = _arg.y, width = _arg.width, height = _arg.height;
    if (!this.passedThrough && this.touches(x, y, width, height)) {
      if (!this.highlighting) {
        this.highlighting = true;
        return this.passedThrough = true;
      }
    } else if (this.highlighting && !this.animating) {
      return this.highlighting = false;
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
