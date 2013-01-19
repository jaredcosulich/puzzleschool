// Generated by CoffeeScript 1.3.3
var bubble;

bubble = typeof exports !== "undefined" && exports !== null ? exports : provide('./bubble', {});

bubble.Bubble = (function() {

  Bubble.prototype.width = 210;

  Bubble.prototype.arrowHeight = 15;

  Bubble.prototype.arrowWidth = 20;

  Bubble.prototype.arrowOffset = 24;

  Bubble.prototype.spacing = 20;

  Bubble.prototype.backgroundColor = '#49494A';

  function Bubble(_arg) {
    this.paper = _arg.paper, this.x = _arg.x, this.y = _arg.y, this.width = _arg.width, this.height = _arg.height, this.position = _arg.position, this.html = _arg.html;
    this.init();
  }

  Bubble.prototype.$ = function(selector) {
    return this.el.find(selector);
  };

  Bubble.prototype.init = function() {};

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
    var x, y;
    x = (function() {
      switch (this.position) {
        case 'right':
          return this.x + this.arrowHeight;
        default:
          return this.x - this.arrowOffset;
      }
    }).call(this);
    y = (function() {
      switch (this.position) {
        case 'right':
          return this.y - this.arrowOffset;
        default:
          return this.y - this.arrowHeight - this.height;
      }
    }).call(this);
    this.base = this.paper.rect(x, y, this.width, this.height, 12);
    return this.container.push(this.base);
  };

  Bubble.prototype.createArrow = function() {
    this.arrow = (function() {
      switch (this.position) {
        case 'right':
          return this.paper.path("M" + (this.x + this.arrowHeight + 2) + "," + (this.y - (this.arrowWidth / 2)) + "\nL" + this.x + "," + this.y + "\nL" + (this.x + this.arrowHeight + 2) + "," + (this.y + (this.arrowWidth / 2)));
        default:
          return this.paper.path("M" + (this.x - (this.arrowWidth / 2)) + "," + (this.y - this.arrowHeight - 2) + "\nL" + this.x + "," + this.y + "\nL" + (this.x + (this.arrowWidth / 2)) + "," + (this.y - this.arrowHeight - 2));
      }
    }).call(this);
    return this.container.push(this.arrow);
  };

  Bubble.prototype.show = function(_arg) {
    var callback, content,
      _this = this;
    content = _arg.content, callback = _arg.callback;
    if (this.container) {
      return;
    }
    this.createContainer();
    if (content) {
      content(this.container);
    } else {
      if (this.htmlContainer) {
        this.htmlContainer.show();
      } else {
        this.createHtml();
      }
    }
    this.container.attr({
      transform: "s0,0," + this.x + "," + this.y
    });
    this.container.animate({
      transform: "s1"
    }, 100, 'linear', function() {
      if (callback) {
        return callback();
      }
    });
    this.visible = true;
    return this.container.toFront();
  };

  Bubble.prototype.hide = function(_arg) {
    var callback,
      _this = this;
    callback = _arg.callback;
    if (!this.container) {
      return;
    }
    this.container.animate({
      transform: "s0,0," + this.x + "," + this.y
    }, 100, 'linear', function() {
      _this.container.remove();
      _this.container = null;
      if (callback) {
        return callback();
      }
    });
    this.htmlContainer.hide();
    return this.visible = false;
  };

  Bubble.prototype.createHtml = function() {
    var bbox, offsetX, offsetY, padding;
    this.htmlContainer = $(document.createElement('DIV'));
    this.htmlContainer.addClass('bubble_description');
    bbox = this.base.getBBox();
    offsetX = this.paper.canvas.offsetLeft;
    offsetY = this.paper.canvas.offsetTop;
    padding = 12;
    this.htmlContainer.css({
      backgroundColor: this.backgroundColor,
      top: offsetY + bbox.y + padding,
      left: offsetX + bbox.x + padding,
      width: bbox.width - (padding * 2),
      height: bbox.height - (padding * 2)
    });
    this.htmlContainer.html(this.html);
    return $(document.body).append(this.htmlContainer);
  };

  return Bubble;

})();
