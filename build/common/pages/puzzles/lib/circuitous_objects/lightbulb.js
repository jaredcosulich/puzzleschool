// Generated by CoffeeScript 1.3.3
var circuitousObject, lightbulb,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

lightbulb = typeof exports !== "undefined" && exports !== null ? exports : provide('./lightbulb', {});

circuitousObject = require('./object');

lightbulb.Lightbulb = (function(_super) {

  __extends(Lightbulb, _super);

  Lightbulb.prototype.resistance = 5;

  Lightbulb.prototype.centerOffset = {
    x: 0,
    y: 25
  };

  Lightbulb.prototype.nodes = [
    {
      x: 0,
      y: 39
    }
  ];

  function Lightbulb(_arg) {
    _arg;
    this.init();
  }

  Lightbulb.prototype.init = function() {};

  Lightbulb.prototype.setCurrent = function(current) {
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

  return Lightbulb;

})(circuitousObject.Object);
