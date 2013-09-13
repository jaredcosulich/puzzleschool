// Generated by CoffeeScript 1.3.3
var circuitousObject, tag,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tag = typeof exports !== "undefined" && exports !== null ? exports : provide('./tag', {});

circuitousObject = require('./object');

tag.Tag = (function(_super) {

  __extends(Tag, _super);

  function Tag(_arg) {
    var show;
    this.object = _arg.object, show = _arg.show;
    this.init();
    if (show) {
      this.show();
    } else {
      this.hide();
    }
  }

  Tag.prototype.init = function() {
    var _this = this;
    this.permanent = false;
    this.tag = $(document.createElement('DIV'));
    this.tag.addClass('tag');
    this.tag.bind('mousedown.toggle_permanence', function() {
      _this.tag.one('mouseup.toggle_permanence', function() {
        return _this.togglePermanentlyOpen();
      });
      return $(document.body).bind('mouseup.toggle_permanence', function() {
        return _this.tag.unbind('mouseup.toggle_permanence');
      });
    });
    this.tag.bind('mouseover', function() {
      if (_this.permanent) {
        return;
      }
      return _this.enlarge();
    });
    this.tag.bind('mouseout', function() {
      if (_this.permanent) {
        return;
      }
      return _this.shrink();
    });
    this.content = $(document.createElement('DIV'));
    this.content.addClass('content');
    this.tag.append(this.content);
    this.smallContent = $(document.createElement('DIV'));
    this.smallContent.addClass('small_tag_content');
    this.content.append(this.smallContent);
    this.largeContent = $(document.createElement('DIV'));
    this.largeContent.addClass('large_tag_content hidden');
    this.content.append(this.largeContent);
    this.object.el.append(this.tag);
    return this.position();
  };

  Tag.prototype.position = function() {
    var parentOffset;
    parentOffset = this.object.el.parent().offset();
    if ((this.object.currentX - parentOffset.left) > (parentOffset.width / 2) - (this.object.el.offset().width / 2)) {
      return this.tag.addClass('right');
    } else {
      return this.tag.removeClass('right');
    }
  };

  Tag.prototype.togglePermanentlyOpen = function() {
    this.permanent = !this.permanent;
    if (this.permanent) {
      return this.enlarge();
    } else {
      return this.shrink();
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

  Tag.prototype.setInfo = function(info) {
    return this.changeContent(info);
  };

  Tag.prototype.changeContent = function(info) {
    var key, value,
      _this = this;
    if (!((function() {
      var _ref, _results;
      _results = [];
      for (key in info) {
        value = info[key];
        if (value !== void 0 && ((_ref = this.info) != null ? _ref[key] : void 0) !== value) {
          _results.push(key);
        }
      }
      return _results;
    }).call(this)).length) {
      return;
    }
    this.info = info;
    this.smallContent.html("" + this.info.current + "A");
    this.largeContent.html("<div class='navigation'><a class='icon-pencil'></a><br/><a class='icon-undo'></a></div>\n" + this.info.name + "<br/>\n" + this.info.current + " Amps, \n" + (this.info.voltage ? "" + this.info.voltage + " Volts," : '') + " \n" + this.info.resistance + " Ohms");
    return $.timeout(10, function() {
      _this.largeContent.find('.icon-pencil').bind('mousedown.edit', function(e) {
        e.stop();
        return alert('Edit component values coming soon.');
      });
      return _this.largeContent.find('.icon-undo').bind('mousedown.rotate', function(e) {
        e.stop();
        return alert('Rotate component coming soon.');
      });
    });
  };

  Tag.prototype.hide = function() {
    return this.tag.hide();
  };

  Tag.prototype.show = function() {
    return this.tag.show();
  };

  return Tag;

})(circuitousObject.Object);