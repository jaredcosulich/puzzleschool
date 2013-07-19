// Generated by CoffeeScript 1.3.3
var battery, circuitousObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

battery = typeof exports !== "undefined" && exports !== null ? exports : provide('./battery', {});

circuitousObject = require('./object');

battery.Battery = (function(_super) {

  __extends(Battery, _super);

  Battery.prototype.powerSource = true;

  Battery.prototype.centerOffset = {
    x: -13,
    y: 0
  };

  Battery.prototype.negativeTerminals = [
    {
      x: 1,
      y: 50
    }
  ];

  Battery.prototype.positiveTerminals = [
    {
      x: 1,
      y: -46
    }
  ];

  function Battery(_arg) {
    _arg;
    this.init();
  }

  Battery.prototype.init = function() {};

  Battery.prototype.currentTerminals = function(type) {
    var terminal, _i, _len, _ref, _results;
    _ref = this["" + type + "Terminals"];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      terminal = _ref[_i];
      _results.push({
        x: this.currentX + terminal.x,
        y: this.currentY + terminal.y
      });
    }
    return _results;
  };

  return Battery;

})(circuitousObject.Object);
