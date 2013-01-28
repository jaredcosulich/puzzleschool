// Generated by CoffeeScript 1.3.3
var bubble,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

bubble = typeof exports !== "undefined" && exports !== null ? exports : provide('./bubble', {});

bubble.Bubble = (function() {

  Bubble.prototype.width = 210;

  Bubble.prototype.arrowHeight = 15;

  Bubble.prototype.arrowWidth = 20;

  Bubble.prototype.spacing = 20;

  Bubble.prototype.backgroundColor = '#49494A';

  function Bubble(_arg) {
    this.paper = _arg.paper, this.x = _arg.x, this.y = _arg.y, this.width = _arg.width, this.height = _arg.height, this.position = _arg.position, this.arrowOffset = _arg.arrowOffset, this.html = _arg.html, this.onHide = _arg.onHide, this.onShow = _arg.onShow;
    this.init();
  }

  Bubble.prototype.$ = function(selector) {
    return this.el.find(selector);
  };

  Bubble.prototype.init = function() {
    var _ref;
    this.arrowOffset || (this.arrowOffset = 24);
    if ((_ref = this.position) === 'left' || _ref === 'right') {
      if (this.y - this.arrowOffset < 3) {
        this.arrowOffset = this.y - 3;
      }
      if (this.y - this.arrowOffset + this.height > this.paper.height) {
        return this.arrowOffset = this.height - this.y - 3;
      }
    }
  };

  Bubble.prototype.createContainer = function() {
    var bbox;
    this.container = this.paper.set();
    this.createBase();
    this.createArrow();
    this.container.attr({
      fill: this.backgroundColor,
      stroke: 'none'
    });
    this.container.toFront();
    return bbox = this.container.getBBox();
  };

  Bubble.prototype.createBase = function() {
    this.baseX = (function() {
      switch (this.position) {
        case 'right':
          return this.x + this.arrowHeight;
        case 'left':
          return this.x - this.arrowHeight - this.width;
        default:
          return this.x - this.arrowOffset;
      }
    }).call(this);
    this.baseY = (function() {
      switch (this.position) {
        case 'right':
        case 'left':
          return this.y - this.arrowOffset;
        default:
          return this.y - this.arrowHeight - this.height;
      }
    }).call(this);
    this.base = this.paper.rect(this.baseX, this.baseY, this.width, this.height, 12);
    return this.container.push(this.base);
  };

  Bubble.prototype.createArrow = function() {
    this.arrow = (function() {
      switch (this.position) {
        case 'right':
          return this.paper.path("M" + (this.x + this.arrowHeight + 2) + "," + (this.y - (this.arrowWidth / 2)) + "\nL" + this.x + "," + this.y + "\nL" + (this.x + this.arrowHeight + 2) + "," + (this.y + (this.arrowWidth / 2)));
        case 'left':
          return this.paper.path("M" + (this.x - this.arrowHeight - 2) + "," + (this.y - (this.arrowWidth / 2)) + "\nL" + this.x + "," + this.y + "\nL" + (this.x - this.arrowHeight - 2) + "," + (this.y + (this.arrowWidth / 2)));
        default:
          return this.paper.path("M" + (this.x - (this.arrowWidth / 2)) + "," + (this.y - this.arrowHeight - 2) + "\nL" + this.x + "," + this.y + "\nL" + (this.x + (this.arrowWidth / 2)) + "," + (this.y - this.arrowHeight - 2));
      }
    }).call(this);
    return this.container.push(this.arrow);
  };

  Bubble.prototype.show = function(content) {
    var _this = this;
    if (this.animating || this.container) {
      return;
    }
    this.animating = true;
    this.createContainer();
    if (content) {
      content(this.container);
    } else {
      this.createHtml();
    }
    this.container.attr({
      transform: "s0,0," + this.x + "," + this.y
    });
    this.container.animate({
      transform: "s1"
    }, 250, 'linear', function() {
      if (_this.onShow) {
        _this.onShow();
      }
      return _this.animating = false;
    });
    if (this.htmlContainer) {
      this.htmlContainer.animate({
        left: this.baseX + this.paper.canvas.offsetLeft,
        top: this.baseY + this.paper.canvas.offsetTop,
        height: this.width,
        width: this.height,
        duration: 250
      });
    }
    this.visible = true;
    this.container.toFront();
    return $(document.body).bind('mousedown.hide_bubble', function(e) {
      var x, y, _ref;
      x = e.clientX - _this.paper.canvas.offsetLeft;
      y = e.clientY - _this.paper.canvas.offsetTop;
      if (_ref = _this.base, __indexOf.call(_this.paper.getElementsByPoint(x, y), _ref) < 0) {
        _this.hide();
        return $(document.body).unbind('mousedown.hide_bubble');
      }
    });
  };

  Bubble.prototype.hide = function() {
    var _this = this;
    if (this.animating || !this.container) {
      return;
    }
    this.animating = true;
    this.container.animate({
      transform: "s0,0," + this.x + "," + this.y
    }, 250, 'linear', function() {
      _this.container.remove();
      _this.container = null;
      if (_this.onHide) {
        _this.onHide();
      }
      return _this.animating = false;
    });
    if (this.htmlContainer) {
      this.htmlContainer.animate({
        left: this.x + this.paper.canvas.offsetLeft,
        top: this.y + this.paper.canvas.offsetTop,
        height: 0,
        width: 0,
        duration: 250
      });
    }
    return this.visible = false;
  };

  Bubble.prototype.createHtml = function() {
    var bbox, height, padding, width;
    if (this.htmlContainer) {
      return;
    }
    this.htmlContainer = $(document.createElement('DIV'));
    this.htmlContainer.addClass('bubble_description');
    this.htmlContainer.html("<div class='description'>" + this.html + "</div>");
    this.htmlContainer.css({
      top: this.y + this.paper.canvas.offsetTop,
      left: this.x + this.paper.canvas.offsetLeft,
      width: 0,
      height: 0
    });
    padding = 12;
    bbox = this.base.getBBox();
    width = bbox.width - (padding * 2);
    height = bbox.height - (padding * 2);
    this.htmlContainer.find('.description').css({
      width: width,
      height: height,
      backgroundColor: this.backgroundColor
    });
    return $(document.body).append(this.htmlContainer);
  };

  Bubble.prototype.setHtml = function(html) {
    var _ref, _ref1;
    this.html = html;
    return (_ref = this.htmlContainer) != null ? (_ref1 = _ref.find('.description')) != null ? _ref1.html(this.html) : void 0 : void 0;
  };

  return Bubble;

})();
