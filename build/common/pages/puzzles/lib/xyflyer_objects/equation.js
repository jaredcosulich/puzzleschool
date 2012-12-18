// Generated by CoffeeScript 1.3.3
var equation,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

equation = typeof exports !== "undefined" && exports !== null ? exports : provide('./equation', {});

equation.Equation = (function() {

  Equation.prototype.defaultText = 'Drop Equation Fragment Here';

  function Equation(_arg) {
    this.gameArea = _arg.gameArea, this.id = _arg.id, this.plot = _arg.plot;
    this.clientY = __bind(this.clientY, this);

    this.clientX = __bind(this.clientX, this);

    this.dropAreas = [];
    this.el = $(document.createElement('DIV'));
    this.el.addClass('equation');
    this.el.attr('id', this.id);
    this.el.html(this.defaultText);
    this.initHover();
  }

  Equation.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  Equation.prototype.clientX = function(e) {
    var _ref, _ref1, _ref2, _ref3;
    return (e.clientX || ((_ref = e.targetTouches) != null ? (_ref1 = _ref[0]) != null ? _ref1.pageX : void 0 : void 0) || ((_ref2 = e.touches) != null ? (_ref3 = _ref2[0]) != null ? _ref3.pageX : void 0 : void 0)) - this.gameArea.offset().left;
  };

  Equation.prototype.clientY = function(e) {
    var _ref, _ref1, _ref2, _ref3;
    return (e.clientY || ((_ref = e.targetTouches) != null ? (_ref1 = _ref[0]) != null ? _ref1.pageY : void 0 : void 0) || ((_ref2 = e.touches) != null ? (_ref3 = _ref2[0]) != null ? _ref3.pageY : void 0 : void 0)) - this.gameArea.offset().top;
  };

  Equation.prototype.initHover = function() {
    var _this = this;
    this.el.bind('mouseover.fragment', function(e) {
      var dropArea, overlapping, _i, _len, _results;
      overlapping = _this.overlappingDropAreas({
        left: _this.clientX(e),
        top: _this.clientY(e)
      });
      _results = [];
      for (_i = 0, _len = overlapping.length; _i < _len; _i++) {
        dropArea = overlapping[_i];
        if (!dropArea.dirty && dropArea.component) {
          dropArea.element.addClass('component_over');
          _results.push(_this.selectedDropArea = dropArea);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
    this.el.bind('mouseout.fragment', function() {
      return _this.clear();
    });
    return this.el.bind('mousedown.fragment', function(e) {
      var dropArea, _i, _len, _ref, _ref1;
      if (_this.selectedDropArea.dirty || !((_ref = _this.selectedDropArea) != null ? _ref.component : void 0)) {
        return;
      }
      _this.selectedDropArea.element.removeClass('with_component');
      _this.selectedDropArea.element.html(_this.selectedDropArea.defaultText);
      _this.selectedDropArea.component.mousedown(e);
      _this.selectedDropArea.component = null;
      _ref1 = _this.selectedDropArea.childAreas;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        dropArea = _ref1[_i];
        _this.dropAreas.splice(dropArea.index, 1);
      }
      _this.selectedDropArea.childAreas = [];
      return _this.selectedDropArea.plot();
    });
  };

  Equation.prototype.clear = function() {
    this.selectedDropArea = null;
    this.el.removeClass('component_over');
    this.el.removeClass('accept_component');
    this.$('.component_over').removeClass('component_over');
    return this.$('.accept_component').removeClass('accept_component').css({
      width: 'auto'
    });
  };

  Equation.prototype.appendTo = function(container) {
    container.append(this.el);
    return this.addDropArea();
  };

  Equation.prototype.overlappingDropAreas = function(area) {
    var dropArea, overlapping, _i, _len, _ref;
    if (!area.right) {
      area.right = area.left;
    }
    if (!area.bottom) {
      area.bottom = area.top;
    }
    overlapping = [];
    _ref = this.dropAreas;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      dropArea = _ref[_i];
      if (!((area.left >= dropArea.left && area.left <= dropArea.right && area.top >= dropArea.top && area.top <= dropArea.bottom) || (area.right >= dropArea.left && area.right <= dropArea.right && area.bottom >= dropArea.top && area.bottom <= dropArea.bottom))) {
        continue;
      }
      overlapping.push(dropArea);
    }
    return overlapping;
  };

  Equation.prototype.addDropArea = function(dropAreaElement, parent, hiddenIndex) {
    var dropArea, gameAreaOffset, hiddenWidth, offset,
      _this = this;
    if (dropAreaElement == null) {
      dropAreaElement = this.el;
    }
    if (parent == null) {
      parent = null;
    }
    if (hiddenIndex == null) {
      hiddenIndex = 0;
    }
    hiddenWidth = 30;
    offset = dropAreaElement.offset();
    gameAreaOffset = this.gameArea.offset();
    dropArea = {
      id: dropAreaElement.attr('id'),
      index: this.dropAreas.length,
      defaultText: (dropAreaElement === this.el ? this.defaultText : ''),
      top: offset.top - gameAreaOffset.top,
      left: offset.left - gameAreaOffset.left + (hiddenIndex * hiddenWidth),
      bottom: offset.top + offset.height - gameAreaOffset.top,
      right: offset.left + (offset.width || hiddenWidth) - gameAreaOffset.left + (hiddenIndex * hiddenWidth),
      width: offset.width || hiddenWidth,
      height: offset.height,
      element: dropAreaElement,
      childAreas: []
    };
    dropArea.highlight = function(readyToDrop) {
      return _this.highlightDropArea(dropArea, readyToDrop);
    };
    dropArea.format = function(component) {
      return _this.formatDropArea(dropArea, component);
    };
    dropArea.plot = function() {
      return _this.plot(dropArea);
    };
    this.dropAreas.push(dropArea);
    return this.setParentChildDropAreas(dropArea, parent);
  };

  Equation.prototype.setParentChildDropAreas = function(dropArea, parent) {
    if (!(dropArea && parent)) {
      return;
    }
    parent.childAreas.push(dropArea);
    return dropArea.parentArea = parent;
  };

  Equation.prototype.highlightDropArea = function(dropArea, readyToDrop) {
    var da, _i, _len, _ref, _results;
    if (dropArea.childAreas.length) {
      _ref = dropArea.childAreas;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        da = _ref[_i];
        _results.push(this.highlightDropArea(da));
      }
      return _results;
    } else {
      if (!dropArea.element.width()) {
        dropArea.element.width(dropArea.width);
      }
      if (readyToDrop) {
        dropArea.element.addClass('component_over');
        return true;
      } else {
        return dropArea.element.addClass('accept_component');
      }
    }
  };

  Equation.prototype.formatDropArea = function(dropArea, component) {
    var acceptFragment, fragment, index, _i, _len, _ref, _results;
    fragment = component.equationFragment;
    dropArea.element.html("<div class='accept_fragment'></div>\n<div class='fragment'>" + fragment + "</div>\n<div class='accept_fragment'></div>");
    _ref = dropArea.element.find('.accept_fragment');
    _results = [];
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      acceptFragment = _ref[index];
      _results.push(this.addDropArea($(acceptFragment), dropArea, index));
    }
    return _results;
  };

  return Equation;

})();
