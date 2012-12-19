// Generated by CoffeeScript 1.3.3
var equation,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

equation = typeof exports !== "undefined" && exports !== null ? exports : provide('./equation', {});

equation.Equation = (function() {

  Equation.prototype.defaultText = 'Drop Equation Here';

  function Equation(_arg) {
    this.gameArea = _arg.gameArea, this.id = _arg.id, this.plot = _arg.plot;
    this.clientY = __bind(this.clientY, this);

    this.clientX = __bind(this.clientX, this);

    this.dropAreas = [];
    this.el = $(document.createElement('DIV'));
    this.el.addClass('equation');
    this.el.addClass('equation accept_fragment');
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
    var testDropArea,
      _this = this;
    testDropArea = function(dropArea, over) {
      var da, _i, _len, _ref;
      if (dropArea.dirtyCount) {
        _ref = dropArea.childAreas;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          da = _ref[_i];
          if (testDropArea(da)) {
            return true;
          }
        }
      } else if (dropArea.component) {
        if (over) {
          return true;
        }
        dropArea.element.addClass('accept_component');
      }
      return false;
    };
    this.el.bind('mousemove.fragment', function(e) {
      _this.selectedDropArea = _this.overlappingDropAreas({
        x: _this.clientX(e),
        y: _this.clientY(e),
        test: function(dropArea, over) {
          return testDropArea(dropArea, over);
        }
      });
      if (_this.selectedDropArea) {
        return _this.selectedDropArea.element.addClass('component_over');
      }
    });
    this.el.bind('mouseout.fragment', function() {
      return _this.clear();
    });
    return this.el.bind('mousedown.fragment', function(e) {
      var dropArea, _i, _len, _ref, _ref1;
      if (_this.selectedDropArea.dirtyCount || !((_ref = _this.selectedDropArea) != null ? _ref.component : void 0)) {
        return;
      }
      _this.selectedDropArea.element.removeClass('with_component');
      _this.selectedDropArea.element.html(_this.selectedDropArea.defaultText);
      _this.selectedDropArea.component.mousedown(e);
      _this.selectedDropArea.component.move(e);
      _this.selectedDropArea.component = null;
      _ref1 = _this.selectedDropArea.childAreas;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        dropArea = _ref1[_i];
        _this.dropAreas.splice(dropArea.index, 1);
      }
      _this.selectedDropArea.childAreas = [];
      if (_this.selectedDropArea.parentArea) {
        _this.selectedDropArea.parentArea.dirtyCount -= 1;
      }
      return _this.selectedDropArea.plot();
    });
  };

  Equation.prototype.clear = function() {
    this.selectedDropArea = null;
    this.el.removeClass('component_over');
    this.el.removeClass('accept_component');
    this.$('.component_over').removeClass('component_over');
    return this.$('.accept_component').removeClass('accept_component');
  };

  Equation.prototype.appendTo = function(container) {
    container.append(this.el);
    return this.addDropArea();
  };

  Equation.prototype.overlappingDropAreas = function(_arg) {
    var dropArea, gameAreaOffset, offset, over, overlapping, test, x, y, _i, _len, _ref;
    x = _arg.x, y = _arg.y, test = _arg.test;
    overlapping = [];
    gameAreaOffset = this.gameArea.offset();
    _ref = this.dropAreas;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      dropArea = _ref[_i];
      offset = dropArea.element.offset();
      offset.left -= gameAreaOffset.left;
      offset.top -= gameAreaOffset.top;
      over = x >= offset.left && x <= offset.left + offset.width && y >= offset.top && y <= offset.top + offset.height;
      if (test(dropArea, over)) {
        return dropArea;
      }
    }
  };

  Equation.prototype.addDropArea = function(dropAreaElement, parentArea) {
    var dropArea, gameAreaOffset, hiddenWidth, offset,
      _this = this;
    if (dropAreaElement == null) {
      dropAreaElement = this.el;
    }
    if (parentArea == null) {
      parentArea = null;
    }
    hiddenWidth = 30;
    offset = dropAreaElement.offset();
    gameAreaOffset = this.gameArea.offset();
    dropArea = {
      id: dropAreaElement.attr('id'),
      index: this.dropAreas.length,
      defaultText: (dropAreaElement === this.el ? this.defaultText : ''),
      element: dropAreaElement,
      childAreas: [],
      dirtyCount: 0
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
    if (parentArea) {
      parentArea.childAreas.push(dropArea);
      dropArea.parentArea = parentArea;
    }
    return this.dropAreas.push(dropArea);
  };

  Equation.prototype.highlightDropArea = function(dropArea, readyToDrop) {
    if (dropArea.childAreas.length) {
      return false;
    }
    if (readyToDrop) {
      dropArea.element.addClass('component_over');
      return true;
    } else {
      dropArea.element.removeClass('component_over');
      return false;
    }
  };

  Equation.prototype.formatDropArea = function(dropArea, component) {
    var acceptFragment, fragment, _i, _len, _ref, _results;
    fragment = component.equationFragment;
    dropArea.element.html("<div class='accept_fragment'></div>\n" + (this.formatFragment(fragment)) + "\n<div class='accept_fragment'></div>");
    _ref = dropArea.element.find('.accept_fragment');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      acceptFragment = _ref[_i];
      _results.push(this.addDropArea($(acceptFragment), dropArea));
    }
    return _results;
  };

  Equation.prototype.formatFragment = function(fragment) {
    var accept, constant;
    constant = '<div class=\'fragment\'>';
    accept = '<div class=\'accept_fragment\'></div>';
    fragment = fragment.replace(/(.*)\((.*)\)/, "" + constant + "$1(</div>" + accept + constant + "$2</div>" + accept + constant + ")</div>");
    if (fragment.indexOf(constant) === -1) {
      fragment = "" + constant + fragment + "</div>";
    }
    return fragment;
  };

  return Equation;

})();
