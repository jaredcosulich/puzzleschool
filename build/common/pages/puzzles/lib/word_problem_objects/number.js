// Generated by CoffeeScript 1.3.3
var Client, Transformer, number;

number = typeof exports !== "undefined" && exports !== null ? exports : provide('./number', {});

Transformer = require('../common_objects/transformer').Transformer;

Client = require('../common_objects/client').Client;

number.Number = (function() {

  function Number(_arg) {
    this.container = _arg.container, this.problemNumber = _arg.problemNumber, this.id = _arg.id, this.value = _arg.value, this.colorIndex = _arg.colorIndex, this.label = _arg.label, this.track = _arg.track;
    this.init();
  }

  Number.prototype.$ = function(selector) {
    return this.el.find(selector);
  };

  Number.prototype.init = function() {
    var _this = this;
    this.el = $(document.createElement('DIV'));
    this.el.data('id', this.id);
    this.el.addClass('number');
    this.el.addClass("color_" + this.colorIndex);
    this.el.addClass('small');
    this.el.html("<div class='settings'>\n    <i class='icon-cog'></i>\n    <i class='icon-move'></i>\n</div>\n<h3><span class='value'>" + this.value + "</span>" + (this.label ? " " + this.label : void 0) + "</h3>\n<div class='ranges'></div>");
    this.transformer = new Transformer(this.el);
    this.el.bind('mousedown.drag touchstart.drag', function(e) {
      var startX, startY;
      startX = Client.x(e, _this.container);
      startY = Client.y(e, _this.container);
      $(document.body).bind('mousemove.drag touchstart.drag', function(e) {
        var currentX, currentY;
        currentX = Client.x(e, _this.container);
        currentY = Client.y(e, _this.container);
        return _this.transformer.translate(currentX - startX, currentY - startY);
      });
      return $(document.body).one('mouseup.drag touchend.drag', function() {
        $(document.body).unbind('mousemove.drag touchstart.drag');
        if (!_this.transformer.dx && !_this.transformer.dy) {
          if (_this.el.hasClass('small')) {
            return _this.el.removeClass('small');
          } else {
            return _this.el.addClass('small');
          }
        } else {
          return _this.transformer.translate(0, 0);
        }
      });
    });
    this.container.append(this.el);
    return this.set(this.value);
  };

  Number.prototype.createRange = function(magnitude) {
    var i, range, _fn, _i,
      _this = this;
    range = $(document.createElement('DIV'));
    range.addClass('range');
    range.addClass("range_" + magnitude);
    range.data('magnitude', magnitude);
    _fn = function(i) {
      var index, label;
      index = $(document.createElement('DIV'));
      index.addClass('index');
      label = $(document.createElement('DIV'));
      label.addClass('label');
      label.html("" + (i * Math.pow(10, magnitude)));
      index.append(label);
      range.append(index);
      return index.bind('click', function() {
        var changingDigit, digits;
        digits = _this.asDigits();
        changingDigit = digits.length - magnitude - 1;
        digits[changingDigit] = parseInt(digits[changingDigit]) === i ? i - 1 : i;
        if (digits[changingDigit] === 0 && parseInt(digits[changingDigit + 1]) === 0) {
          digits[changingDigit + 1] = 9;
        }
        return _this.set(digits.join(''));
      });
    };
    for (i = _i = 1; _i <= 10; i = ++_i) {
      _fn(i);
    }
    this.$('.ranges').prepend(range);
    return range;
  };

  Number.prototype.asDigits = function() {
    return this.value.toString().match(/\d/g);
  };

  Number.prototype.set = function(value) {
    var digit, digits, i, index, m, magnitude, range, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
    this.value = parseInt(value);
    digits = this.asDigits();
    _ref = this.$('.range');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      range = _ref[_i];
      if (parseInt($(range).data('magnitude')) >= digits.length) {
        $(range).remove();
      }
    }
    for (m = _j = 0, _len1 = digits.length; _j < _len1; m = ++_j) {
      digit = digits[m];
      magnitude = digits.length - m - 1;
      if (!(range = this.$(".range_" + magnitude)).length) {
        range = this.createRange(magnitude, digit);
      }
      range.css({
        fontSize: 50 - (10 * m)
      });
      _ref1 = range.find('.index');
      for (i = _k = 0, _len2 = _ref1.length; _k < _len2; i = ++_k) {
        index = _ref1[i];
        index = $(index);
        if ((i + 1) > parseInt(digit)) {
          index.removeClass('icon-circle');
          if (!index.hasClass('icon-circle-blank')) {
            index.addClass('icon-circle-blank');
          }
        } else {
          index.removeClass('icon-circle-blank');
          if (!index.hasClass('icon-circle')) {
            index.addClass('icon-circle');
          }
        }
      }
    }
    this.$('.value').html("" + this.value);
    this.el.data('value', this.value);
    return this.problemNumber.html("" + this.value);
  };

  return Number;

})();
