// Generated by CoffeeScript 1.3.3
var Transformer, equationComponent,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

equationComponent = typeof exports !== "undefined" && exports !== null ? exports : provide('./equation_component', {});

Transformer = require('./transformer').Transformer;

equationComponent.EquationComponent = (function() {

  function EquationComponent(_arg) {
    this.gameArea = _arg.gameArea, this.equationFragment = _arg.equationFragment, this.trackDrag = _arg.trackDrag, this.endDrag = _arg.endDrag, this.side = _arg.side;
    this.clientY = __bind(this.clientY, this);

    this.clientX = __bind(this.clientX, this);

    this.initElement();
    this.initMove();
    this.inUse = false;
  }

  EquationComponent.prototype.clientX = function(e) {
    var _ref, _ref1, _ref2, _ref3;
    return (e.clientX || ((_ref = e.targetTouches) != null ? (_ref1 = _ref[0]) != null ? _ref1.pageX : void 0 : void 0) || ((_ref2 = e.touches) != null ? (_ref3 = _ref2[0]) != null ? _ref3.pageX : void 0 : void 0)) - this.gameArea.offset().left;
  };

  EquationComponent.prototype.clientY = function(e) {
    var _ref, _ref1, _ref2, _ref3;
    return (e.clientY || ((_ref = e.targetTouches) != null ? (_ref1 = _ref[0]) != null ? _ref1.pageY : void 0 : void 0) || ((_ref2 = e.touches) != null ? (_ref3 = _ref2[0]) != null ? _ref3.pageY : void 0 : void 0)) - this.gameArea.offset().top;
  };

  EquationComponent.prototype.top = function() {
    return this.elementContainer.offset().top;
  };

  EquationComponent.prototype.left = function() {
    return this.elementContainer.offset().left;
  };

  EquationComponent.prototype.width = function() {
    return this.elementContainer.width();
  };

  EquationComponent.prototype.height = function() {
    return this.elementContainer.height();
  };

  EquationComponent.prototype.initElement = function() {
    this.elementContainer = $(document.createElement('DIV'));
    this.elementContainer.addClass('equation_component_container');
    this.element = $(document.createElement('DIV'));
    this.element.addClass('equation_component');
    this.element.html(this.display(this.equationFragment));
    this.elementContainer.append(this.element);
    this.placeHolder = $(document.createElement('DIV'));
    this.placeHolder.addClass('place_holder');
    this.placeHolder.hide();
    if (this.equationFragment.length > 3) {
      this.elementContainer.addClass('long');
      this.placeHolder.addClass('long');
    }
    return this.transformer = new Transformer(this.element);
  };

  EquationComponent.prototype.display = function(html) {
    return html.replace('*', '<b>&middot;</b>');
  };

  EquationComponent.prototype.disableMove = function() {
    return this.elementContainer.unbind('mousedown.drag touchstart.drag');
  };

  EquationComponent.prototype.initMove = function() {
    var _this = this;
    this.disableMove();
    if (window.appScale) {
      return this.elementContainer.bind('touchstart.drag', function(e) {
        return _this.mousedown(e);
      });
    } else {
      return this.elementContainer.bind('mousedown.drag', function(e) {
        return _this.mousedown(e);
      });
    }
  };

  EquationComponent.prototype.appendTo = function(container) {
    this.container = container;
    this.container.append(this.placeHolder);
    return this.container.append(this.elementContainer);
  };

  EquationComponent.prototype.initMeasurements = function() {
    this.offset = this.element.offset();
    return this.gameAreaOffset = this.gameArea.offset();
  };

  EquationComponent.prototype.mousedown = function(e) {
    if (e.preventDefault) {
      e.preventDefault();
    }
    this.initDragging();
    this.move(e);
    return this.showPlaceHolder();
  };

  EquationComponent.prototype.initDragging = function() {
    var body,
      _this = this;
    this.initMeasurements();
    this.gameArea.addClass('dragging');
    this.element.addClass('dragging');
    body = $(document.body);
    if (window.appScale) {
      body.bind('touchmove.drag', function(e) {
        return _this.move(e);
      });
      return body.one('touchend.drag', function(e) {
        return _this.endMove(e);
      });
    } else {
      body.bind('mousemove.drag', function(e) {
        return _this.move(e);
      });
      return body.one('mouseup.drag', function(e) {
        return _this.endMove(e);
      });
    }
  };

  EquationComponent.prototype.showPlaceHolder = function() {
    this.placeHolder.show();
    this.placeHolder.html(this.display(this.element.html()));
    return this.positionPlaceHolder();
  };

  EquationComponent.prototype.positionPlaceHolder = function() {
    if (!this.placeHolder || !this.offset || !this.container) {
      return;
    }
    return this.placeHolder.css({
      position: 'absolute',
      top: this.offset.top - this.container.offset().top,
      left: this.offset.left - this.container.offset().left
    });
  };

  EquationComponent.prototype.move = function(e, inPlace) {
    var base, dx, dy, offset, x, xDiff, y, yDiff;
    if (e.preventDefault) {
      e.preventDefault();
    }
    x = this.clientX(e);
    y = this.clientY(e);
    if (e.type.match(/touch/) && !inPlace) {
      if (this.side) {
        base = 30 * (this.side === 'right' ? -1 : 1) / (window.appScale || 1);
        if (this.side === 'right') {
          xDiff = Math.max(base, x - this.gameAreaOffset.width);
        } else {
          xDiff = Math.min(base, x);
        }
        if (this.side) {
          x += xDiff;
        }
      }
      yDiff = Math.min(30 / (window.appScale || 1), y - 60);
      if (yDiff < 0) {
        yDiff = 0;
      }
      y -= yDiff;
    }
    offset = this.element.offset();
    dx = x - offset.left - (offset.width / 2) + this.gameAreaOffset.left;
    dy = y - offset.top - (offset.height / 2) + this.gameAreaOffset.top;
    this.transformer.translate(dx, dy);
    if (this.trackDrag) {
      return this.trackDrag(x, y, offset.width, offset.height, this);
    }
  };

  EquationComponent.prototype.endMove = function(e) {
    if (!this.gameArea.hasClass('dragging')) {
      return;
    }
    this.gameArea.removeClass('dragging');
    if (this.endDrag(this)) {
      this.placeHolder.show();
      this.elementContainer.unbind('mousedown.drag touchstart.drag');
      this.inUse = true;
      this.transformer.translate(-10000, -10000);
    } else {
      this.reset();
    }
    return $(document.body).unbind('mousemove.drag touchmove.drag');
  };

  EquationComponent.prototype.remove = function() {
    this.elementContainer.remove();
    return this.placeHolder.remove();
  };

  EquationComponent.prototype.reset = function() {
    this.element.removeClass('dragging');
    this.placeHolder.hide();
    this.inUse = false;
    this.transformer.translate(0, 0);
    return this.initMove();
  };

  return EquationComponent;

})();
