// Generated by CoffeeScript 1.3.3
var Transformer, equation,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

equation = typeof exports !== "undefined" && exports !== null ? exports : provide('./equation', {});

Transformer = require('./transformer').Transformer;

equation.Equation = (function() {

  Equation.prototype.defaultText = 'Drag equations below and drop here';

  function Equation(_arg) {
    var _ref;
    this.id = _arg.id, this.gameArea = _arg.gameArea, this.solution = _arg.solution, this.solutionComponents = _arg.solutionComponents, this.startingFragment = _arg.startingFragment, this.variables = _arg.variables, this.plot = _arg.plot;
    this.clientY = __bind(this.clientY, this);

    this.clientX = __bind(this.clientX, this);

    this.dropAreas = [];
    this.container = $(document.createElement('DIV'));
    this.container.addClass('equation_container');
    this.container.html('<div class=\'intro\'>Y=</div>');
    this.el = $(document.createElement('DIV'));
    this.el.addClass('equation');
    this.el.attr('id', this.id);
    this.el.bind("touchstart touchmove touchend", function(e) {
      if (e.preventDefault) {
        return e.preventDefault();
      }
    });
    if ((_ref = this.startingFragment) != null ? _ref.length : void 0) {
      this.startingElement = this.formatFragment(this.startingFragment);
      this.el.addClass('starting_fragment');
    } else {
      this.startingElement = this.defaultText;
    }
    this.container.append(this.el);
    this.initHover();
    this.initRange();
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
      if (dropArea.fixed) {
        return false;
      }
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
      var component, _ref, _ref1;
      if (!_this.selectedDropArea) {
        _this.selectedDropArea = _this.overlappingDropAreas({
          x: _this.clientX(e),
          y: _this.clientY(e),
          test: function(dropArea, over) {
            return testDropArea(dropArea, over);
          }
        });
      }
      if (((_ref = _this.selectedDropArea) != null ? _ref.dirtyCount : void 0) || !((_ref1 = _this.selectedDropArea) != null ? _ref1.component : void 0)) {
        return;
      }
      component = _this.selectedDropArea.component;
      component.initDragging();
      component.move(e);
      return _this.removeFragment(_this.selectedDropArea, e);
    });
  };

  Equation.prototype.removeFragment = function(dropArea, e) {
    var childArea, da, removeDropAreas, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3,
      _this = this;
    this.el.find('.accept_component').removeClass('accept_component');
    this.el.find('.accept_fragment:not(.with_component)').removeClass('accept_fragment');
    dropArea.element.removeClass('with_component');
    if ((_ref = dropArea.component) != null) {
      _ref.after = null;
    }
    dropArea.component = null;
    _ref1 = dropArea.childAreas;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      childArea = _ref1[_i];
      this.removeDropArea(childArea);
    }
    dropArea.childAreas = [];
    removeDropAreas = [];
    _ref2 = this.dropAreas;
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      da = _ref2[_j];
      if (!(!da.component && !da.fixed)) {
        continue;
      }
      da.element.addClass('removing');
      removeDropAreas.push(da);
    }
    $(document.body).one('mouseup.removing_drop_area touchend.removing_drop_area', function() {
      return _this.$('.removing').remove();
    });
    for (_k = 0, _len2 = removeDropAreas.length; _k < _len2; _k++) {
      da = removeDropAreas[_k];
      this.removeDropArea(da);
    }
    _ref3 = this.dropAreas;
    for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
      da = _ref3[_l];
      this.wrap(da);
    }
    if (!this.dropAreas.length) {
      this.addFirstDropArea();
    }
    this.recordComponentPositions();
    if (dropArea.parentArea) {
      dropArea.parentArea.dirtyCount -= 1;
    }
    this.initVariables();
    return this.plot(this);
  };

  Equation.prototype.removeDropArea = function(dropAreaToRemove) {
    var dropArea, index, removeIndex, _i, _len, _ref;
    removeIndex = -1;
    _ref = this.dropAreas;
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      dropArea = _ref[index];
      if (dropArea === dropAreaToRemove) {
        removeIndex = index;
        break;
      }
    }
    if (removeIndex > -1) {
      return this.dropAreas.splice(removeIndex, 1);
    }
  };

  Equation.prototype.clear = function() {
    this.selectedDropArea = null;
    this.el.find('.accept_fragment').css({
      width: ''
    });
    this.el.removeClass('component_over');
    this.el.removeClass('accept_component');
    this.$('.component_over').removeClass('component_over');
    return this.$('.accept_component').removeClass('accept_component');
  };

  Equation.prototype.appendTo = function(area) {
    area.append(this.container);
    return this.addFirstDropArea();
  };

  Equation.prototype.addFirstDropArea = function() {
    var dropArea, dropAreaElement;
    dropAreaElement = this.newDropArea();
    this.el.append(dropAreaElement);
    this.addDropArea(dropAreaElement);
    dropAreaElement.html(this.startingElement);
    if (this.startingElement === this.defaultText) {
      dropAreaElement.addClass('only_area');
    } else {
      dropAreaElement.addClass('fragment');
      dropAreaElement.removeClass('accept_fragment');
      dropArea = this.dropAreas[this.dropAreas.length - 1];
      dropArea.fixed = true;
      this.wrap(dropArea);
      dropArea.width = dropAreaElement.width();
    }
    this.initVariables();
    return this.plot(this);
  };

  Equation.prototype.newDropArea = function() {
    var dropArea;
    dropArea = $(document.createElement('DIV'));
    dropArea.addClass('accept_fragment');
    return dropArea;
  };

  Equation.prototype.overlappingDropAreas = function(_arg) {
    var dropArea, gameAreaOffset, offset, over, overlapping, test, x, y, _i, _len, _ref;
    x = _arg.x, y = _arg.y, test = _arg.test;
    overlapping = [];
    gameAreaOffset = this.gameArea.offset();
    _ref = this.dropAreas;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      dropArea = _ref[_i];
      if (!dropArea.element.hasClass('accept_fragment')) {
        continue;
      }
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
    var dropArea,
      _this = this;
    if (parentArea == null) {
      parentArea = null;
    }
    dropArea = {
      id: this.id,
      index: this.dropAreas.length,
      startingFragment: (dropAreaElement === this.el ? this.startingElement : ''),
      element: dropAreaElement,
      childAreas: [],
      dirtyCount: 0,
      formulaData: function() {
        return _this.formulaData();
      }
    };
    dropArea.highlight = function(readyToDrop) {
      return _this.highlightDropArea(dropArea, readyToDrop);
    };
    dropArea.accept = function(component) {
      return _this.accept(dropArea, component);
    };
    if (parentArea) {
      parentArea.childAreas.push(dropArea);
      dropArea.parentArea = parentArea;
    }
    this.dropAreas.push(dropArea);
    if (this.el.find('.accept_fragment').length > 1) {
      return this.el.find('.only_area').removeClass('only_area');
    }
  };

  Equation.prototype.accept = function(dropArea, component) {
    var element,
      _this = this;
    element = dropArea.element;
    element.addClass('with_component');
    dropArea.component = component;
    component.dropArea = dropArea;
    if (dropArea.parentArea) {
      dropArea.parentArea.dirtyCount += 1;
    }
    this.formatDropArea(dropArea, component);
    this.wrap(dropArea);
    this.initVariables();
    dropArea.width = dropArea.element.width();
    element.bind('touchstart.remove', function(e) {
      if (dropArea.dirtyCount || !dropArea.component) {
        return;
      }
      component.move(e);
      element.hide();
      component.initDragging();
      return $.timeout(100, function() {
        return _this.removeFragment(dropArea, e);
      });
    });
    component.placeHolder.unbind('mousedown.placeholder touchstart.placeholder');
    component.placeHolder.bind('mousedown.placeholder touchstart.placeholder', function(e) {
      return component.placeHolder.one('mouseup.placeholder touchend.placeholder', function(e) {
        _this.removeFragment(dropArea, e);
        return component.endMove(e);
      });
    });
    this.recordComponentPositions();
    return this.plot(this);
  };

  Equation.prototype.recordComponentPositions = function() {
    var dropArea, previousWithComponent, _i, _len, _ref, _results;
    _ref = this.dropAreas;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      dropArea = _ref[_i];
      if (!dropArea.component) {
        continue;
      }
      previousWithComponent = dropArea.element.previous();
      if (previousWithComponent) {
        if (!previousWithComponent.hasClass('with_component')) {
          previousWithComponent = previousWithComponent.previous();
        }
        _results.push(dropArea.component.after = this.straightFormula(previousWithComponent));
      } else {
        _results.push(delete dropArea.component.after);
      }
    }
    return _results;
  };

  Equation.prototype.wrap = function(dropArea) {
    var afterDropArea, beforeDropArea, next, previous, _ref, _ref1;
    if (!((_ref = dropArea.element) != null ? (_ref1 = _ref.parent()) != null ? _ref1.length : void 0 : void 0)) {
      return;
    }
    previous = dropArea.element.previous();
    while (previous.hasClass('removing')) {
      previous = previous.previous();
    }
    if (!previous.length || previous.hasClass('with_component') || previous.hasClass('fragment')) {
      beforeDropArea = this.newDropArea();
      dropArea.element.before(beforeDropArea);
      this.addDropArea(beforeDropArea);
    }
    next = dropArea.element.next();
    while (next.hasClass('removing')) {
      next = next.next();
    }
    if (!next.length || next.hasClass('with_component') || next.hasClass('fragment')) {
      afterDropArea = this.newDropArea();
      dropArea.element.after(afterDropArea);
      this.addDropArea(afterDropArea);
    }
    return this.wrapChildren(dropArea);
  };

  Equation.prototype.wrapChildren = function(dropArea) {
    var afterDropArea, beforeDropArea, fragment, next, previous, _i, _len, _ref, _results;
    _ref = dropArea.element.find('.fragment:not(.removing)');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      fragment = _ref[_i];
      fragment = $(fragment);
      previous = fragment.previous();
      while (previous.hasClass('removing')) {
        previous = previous.previous();
      }
      if (previous.hasClass('fragment')) {
        beforeDropArea = this.newDropArea();
        fragment.before(beforeDropArea);
        this.addDropArea(beforeDropArea, dropArea);
      }
      next = fragment.next();
      while (next.hasClass('removing')) {
        next = next.next();
      }
      if (next.hasClass('fragment')) {
        afterDropArea = this.newDropArea();
        fragment.after(afterDropArea);
        _results.push(this.addDropArea(afterDropArea, dropArea));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Equation.prototype.highlightDropArea = function(dropArea, readyToDrop) {
    if (dropArea.childAreas.length || dropArea.component || dropArea.fixed) {
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
    var element, fragment;
    fragment = component.equationFragment;
    element = dropArea.element;
    return element.html(this.formatFragment(fragment));
  };

  Equation.prototype.formatFragment = function(fragment) {
    var constant;
    constant = '<div class=\'fragment\'>';
    fragment = fragment.replace(/(.*\()(.*)\)(\^*\d*\**\/*)*/g, "" + constant + "$1</div>" + constant + "$2</div>" + constant + ")$3</div>");
    if (fragment.indexOf(constant) === -1) {
      fragment = "" + constant + fragment + "</div>";
    }
    return fragment;
  };

  Equation.prototype.formulaData = function() {
    return this.formula();
    return "" + (this.formula()) + (this.rangeText());
  };

  Equation.prototype.rangeText = function() {
    var _ref;
    if (!((_ref = this.range) != null ? _ref.from : void 0)) {
      return '';
    }
    return "{" + this.range.from + "<=x<=" + this.range.to + "}";
  };

  Equation.prototype.straightFormula = function(el) {
    var element, tempEl, text;
    if (el == null) {
      el = this.el;
    }
    if (!el.length) {
      return '';
    }
    element = el[0];
    if (el.find('.removing').length > 0) {
      tempEl = element.cloneNode(true);
      $(tempEl).find('.removing').remove();
      element = tempEl;
    }
    text = element.textContent ? element.textContent : element.innerText;
    if (text === this.defaultText) {
      text = '';
    }
    return text || '';
  };

  Equation.prototype.formula = function() {
    var info, text, variable;
    text = this.straightFormula();
    for (variable in this.variables) {
      info = this.variables[variable];
      if (!info.get) {
        continue;
      }
      text = text.replace(RegExp("(^|[^a-w])" + variable + "($|[^a-w])"), "$1" + (info.get()) + "$2");
    }
    return text;
  };

  Equation.prototype.initRange = function() {
    var element,
      _this = this;
    return;
    element = $(document.createElement('DIV'));
    element.addClass('range');
    element.html('From X = <input type=\'text\' class=\'from\'></input> to X = <input type=\'text\' class=\'to\'></input>');
    this.container.append(element);
    return setTimeout((function() {
      element.find('input').bind('keyup', function() {
        return _this.setRange(element.find('.from').val(), element.find('.to').val());
      });
      _this.range = {
        element: element,
        hidden: false,
        height: element.css('height'),
        padding: element.css('paddingTop')
      };
      return _this.hideRange();
    }), 10);
  };

  Equation.prototype.showRange = function() {
    var _ref;
    return;
    if (!((_ref = this.range) != null ? _ref.hidden : void 0)) {
      return;
    }
    this.range.element.animate({
      height: this.range.height,
      paddingTop: this.range.padding,
      paddingBottom: this.range.padding,
      duration: 250
    });
    return this.range.hidden = false;
  };

  Equation.prototype.hideRange = function() {
    return;
    if (!this.range || this.range.hidden) {
      return;
    }
    this.range.element.animate({
      height: 0,
      paddingTop: 0,
      paddingBottom: 0,
      duration: 250
    });
    return this.range.hidden = true;
  };

  Equation.prototype.setRange = function(from, to) {
    if (from == null) {
      from = null;
    }
    if (to == null) {
      to = null;
    }
    return;
    this.range.element.find('.from').val(from != null ? from : '');
    this.range.element.find('.to').val(to != null ? to : '');
    this.range.from = from;
    this.range.to = to;
    return this.plot(this);
  };

  Equation.prototype.initVariables = function() {
    var formula, variable, _ref, _results;
    formula = this.straightFormula();
    _results = [];
    for (variable in this.variables) {
      if (RegExp("(^|[^a-w])" + variable + "($|[^a-w])").test(formula)) {
        _results.push(this.initVariable(variable));
      } else if (((_ref = this.variables[variable].element) != null ? _ref.closest('.equation_container')[0] : void 0) === this.container[0]) {
        _results.push(this.removeVariable(variable));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Equation.prototype.initVariable = function(variable) {
    var element, info,
      _this = this;
    info = this.variables[variable];
    if (info.element) {
      return;
    }
    element = $(document.createElement('DIV'));
    element.addClass('variable');
    element.html("" + variable + " = <input type='text' value='" + info.start + "'/>\n<div class='slider'><div class='track'></div><div class='knob'></div>");
    this.container.append(element);
    setTimeout((function() {
      var input, knob, track, trackWidth;
      input = element.find('input');
      track = element.find('.track');
      knob = element.find('.knob');
      info.knobTransformer = new Transformer(knob);
      info.set(info.start);
      trackWidth = element.find('.track').width();
      input.bind('keyup.variable', function(e) {
        var _ref, _ref1;
        if (!((47 < (_ref = e.keyCode) && _ref < 58) || (188 < (_ref1 = e.keyCode) && _ref1 < 191))) {
          return;
        }
        if (!isNaN(input.val())) {
          return _this.variables[variable].set(input.val());
        }
      });
      return element.bind('mousedown.drag_knob touchstart.drag_knob', function(e) {
        var body, offsetLeft, startingX, x;
        if (e.preventDefault) {
          e.preventDefault();
        }
        body = $(document.body);
        x = _this.clientX(e);
        offsetLeft = knob.offset().left - _this.gameArea.offset().left + (knob.width() / 2);
        if (x < offsetLeft) {
          x = offsetLeft;
        }
        startingX = x - offsetLeft;
        body.bind('mousemove.drag_knob touchmove.drag_knob', function(e) {
          var dx, percentage;
          if (e.preventDefault) {
            e.preventDefault();
          }
          dx = _this.clientX(e) - offsetLeft;
          if (dx < 0) {
            dx = 0;
          }
          if (dx > trackWidth) {
            dx = trackWidth;
          }
          info.knobTransformer.translate(dx, 0);
          percentage = dx / trackWidth;
          return info.set(info.min + (percentage * Math.abs(info.max - info.min)));
        });
        return body.one('mouseup.drag_knob touchend.drag_knob', function() {
          return body.unbind('mousemove.drag_knob touchmove.drag_knob');
        });
      });
    }), 10);
    info.get = function() {
      return element.find('input').val();
    };
    info.set = function(val) {
      var decimalPosition, incrementedVal, left, trackWidth, _ref;
      incrementedVal = Math.round(val / info.increment) * info.increment;
      if ((-1 < (_ref = info.increment) && _ref < 1)) {
        decimalPosition = ("" + info.increment).length - 2;
      }
      if (decimalPosition > -1) {
        incrementedVal = incrementedVal.toFixed(decimalPosition);
      }
      element.find('input').val("" + incrementedVal);
      trackWidth = element.find('.track').width();
      left = trackWidth * (Math.abs(info.min - val) / Math.abs(info.max - info.min));
      info.knobTransformer.translate(left, 0);
      return _this.plot(_this);
    };
    return info.element = element;
  };

  Equation.prototype.removeVariable = function(variable) {
    var element;
    element = this.variables[variable].element;
    element.animate({
      height: 0,
      duration: 250,
      complete: function() {
        return element.remove();
      }
    });
    delete this.variables[variable].element;
    delete this.variables[variable].get;
    return delete this.variables[variable].set;
  };

  Equation.prototype.expandLastAccept = function() {
    var lastAccept, prevOffset, remainder, _ref;
    lastAccept = this.el.find('.accept_fragment:last-child:not(.removing)');
    prevOffset = (_ref = lastAccept.previous()) != null ? _ref.offset() : void 0;
    if (prevOffset) {
      remainder = prevOffset.left + prevOffset.width - this.el.offset().left;
    } else {
      remainder = 0;
    }
    return lastAccept.width(this.el.width() - remainder - 12);
  };

  Equation.prototype.hideBadFormula = function() {
    var _this = this;
    this.el.removeClass('bad_formula');
    if (this.badFormula) {
      if (this.badFormula.animation) {
        this.badFormula.animation.stop();
      }
      return this.badFormula.animation = this.badFormula.animate({
        height: 0,
        paddingTop: 0,
        paddingBottom: 0,
        duration: 500,
        complete: function() {
          if (!_this.badFormula) {
            return;
          }
          _this.badFormula.remove();
          return delete (_this.badFormula = null);
        }
      });
    }
  };

  Equation.prototype.showBadFormula = function() {
    this.el.addClass('bad_formula');
    if (!this.badFormula) {
      this.badFormula = $(document.createElement('DIV'));
      this.badFormula.addClass('bad_formula_message');
      this.badFormula.html('This equation is not valid.');
      this.container.append(this.badFormula);
      this.badFormula.data('height', this.badFormula.height());
      this.badFormula.height(0);
    }
    if (this.badFormula.animation) {
      this.badFormula.animation.stop();
    }
    return this.badFormula.animation = this.badFormula.animate({
      height: this.badFormula.data('height'),
      duration: 500
    });
  };

  return Equation;

})();
