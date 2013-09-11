// Generated by CoffeeScript 1.3.3
var circuitousObject, tag,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tag = typeof exports !== "undefined" && exports !== null ? exports : provide('./tag', {});

circuitousObject = require('./object');

tag.Tag = (function(_super) {

  __extends(Tag, _super);

  function Tag(_arg) {
    this.el = _arg.el, this.getInfo = _arg.getInfo;
    this.init();
  }

  Tag.prototype.init = function() {
    var _this = this;
    this.permanent = false;
    this.tag = $(document.createElement('DIV'));
    this.tag.addClass('tag');
    this.tag.bind('click', function() {
      _this.permanent = !_this.permanent;
      if (_this.permanent) {
        return _this.enlarge();
      } else {
        return _this.shrink();
      }
    });
    this.tag.bind('mouseover', function() {
      if (!_this.permanent) {
        return _this.enlarge();
      }
    });
    this.tag.bind('mouseout', function() {
      if (!_this.permanent) {
        return _this.shrink();
      }
    });
    this.content = $(document.createElement('DIV'));
    this.content.addClass('content');
    this.tag.append(this.content);
    this.smallContent = $(document.createElement('DIV'));
    this.smallContent.addClass('small_tag_content');
    this.smallContent.html('9A');
    this.content.append(this.smallContent);
    this.largeContent = $(document.createElement('DIV'));
    this.largeContent.addClass('large_tag_content hidden');
    this.largeContent.html('Lightbulb #1:<br/>5 Ohms, 9 Amps');
    this.content.append(this.largeContent);
    return this.el.append(this.tag);
  };

  Tag.prototype.toggleSize = function() {
    if (this.tag.hasClass('large')) {
      return this.shrink;
    } else {
      return this.enlarge();
    }
  };

  Tag.prototype.enlarge = function() {
    this.tag.addClass('large');
    this.smallContent.addClass('hidden');
    return this.largeContent.removeClass('hidden');
  };

  Tag.prototype.shrink = function() {
    this.tag.removeClass('large');
    this.smallContent.removeClass('hidden');
    return this.largeContent.addClass('hidden');
  };

  Tag.prototype.setInfo = function() {};

  return Tag;

})(circuitousObject.Object);
