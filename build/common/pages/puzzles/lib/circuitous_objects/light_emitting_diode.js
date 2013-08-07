// Generated by CoffeeScript 1.3.3
var circuitousObject, lightEmittingDiode,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

lightEmittingDiode = typeof exports !== "undefined" && exports !== null ? exports : provide('./light_emitting_diode', {});

circuitousObject = require('./object');

lightEmittingDiode.LightEmittingDiode = (function(_super) {

  __extends(LightEmittingDiode, _super);

  LightEmittingDiode.prototype.resistance = 5;

  LightEmittingDiode.prototype.centerOffset = {
    x: -16,
    y: 25
  };

  LightEmittingDiode.prototype.nodes = [
    {
      x: -16,
      y: 39,
      positive: true
    }, {
      x: 16,
      y: 39,
      negative: true
    }
  ];

  function LightEmittingDiode(_arg) {
    _arg;
    this.init();
  }

  LightEmittingDiode.prototype.init = function() {};

  LightEmittingDiode.prototype.setCurrent = function(current) {
    this.current = current;
    if (this.current > 0) {
      return this.el.css({
        backgroundColor: 'yellow'
      });
    } else {
      return this.el.css({
        backgroundColor: null
      });
    }
  };

  return LightEmittingDiode;

})(circuitousObject.Object);
