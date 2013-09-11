// Generated by CoffeeScript 1.3.3
var Draggable, object,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

object = typeof exports !== "undefined" && exports !== null ? exports : provide('./object', {});

Draggable = require('../common_objects/draggable').Draggable;

object.Object = (function(_super) {

  __extends(Object, _super);

  Object.prototype.baseFolder = '/assets/images/puzzles/circuitous/';

  Object.prototype.circuitPaths = {};

  function Object() {}

  Object.prototype.image = function() {
    var filename;
    filename = this.constructor.name.replace(/(.)([A-Z])/g, '$1_$2').toLowerCase();
    return "" + this.baseFolder + filename + ".png";
  };

  Object.prototype.imageElement = function() {
    return "<div class='component'><img src='" + (this.image()) + "' /></div>";
  };

  Object.prototype.appendTo = function(container) {
    var _this = this;
    container.append(this.imageElement());
    this.el = container.find('.component').last();
    return this.el.bind('dragstart', function(e) {
      return e.preventDefault();
    });
  };

  Object.prototype.generateId = function(namespace) {
    var n;
    return "" + ((n = namespace) ? n : '') + (new Date().getTime()) + (Math.random());
  };

  Object.prototype.positionAt = function(_arg) {
    var x, y, _ref, _ref1;
    x = _arg.x, y = _arg.y;
    return this.dragTo({
      x: x + (((_ref = this.centerOffset) != null ? _ref.x : void 0) || 0) + (this.offset || 0),
      y: y + (((_ref1 = this.centerOffset) != null ? _ref1.y : void 0) || 0) + (this.offset || 0)
    });
  };

  Object.prototype.currentNodes = function(type) {
    var info, node, _i, _len, _ref, _results;
    _ref = this.nodes || [];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      if (type && !node[type]) {
        continue;
      }
      info = JSON.parse(JSON.stringify(node));
      info.x = this.currentX + node.x - (this.offset || 0);
      info.y = this.currentY + node.y - (this.offset || 0);
      _results.push(info);
    }
    return _results;
  };

  Object.prototype.initCurrent = function() {};

  Object.prototype.setCurrent = function(current) {
    this.current = current;
  };

  Object.prototype.initTag = function() {
    var _this = this;
    return this.tag = new Tag({
      el: this.el,
      getInfo: function() {
        return _this.getInfo();
      }
    });
  };

  return Object;

})(Draggable);
