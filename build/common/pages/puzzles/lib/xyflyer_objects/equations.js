// Generated by CoffeeScript 1.3.3
var Equation, EquationComponent, equations;

equations = typeof exports !== "undefined" && exports !== null ? exports : provide('./equations', {});

Equation = require('./equation').Equation;

EquationComponent = require('./equation_component').EquationComponent;

equations.Equations = (function() {

  function Equations(_arg) {
    var submit,
      _this = this;
    this.gameArea = _arg.gameArea, this.el = _arg.el, this.plot = _arg.plot, submit = _arg.submit;
    this.equationsArea = this.$('.equations');
    this.possibleFragments = this.$('.possible_fragments');
    this.equations = [];
    this.$('.launch').bind('click', function() {
      return submit();
    });
  }

  Equations.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  Equations.prototype.add = function() {
    var equation, equationCount,
      _this = this;
    equationCount = this.equationsArea.find('.equation').length;
    equation = new Equation({
      gameArea: this.gameArea,
      id: "equation_" + (equationCount + 1),
      plot: function(dropArea) {
        return _this.plotFormula(dropArea);
      }
    });
    this.equations.push(equation);
    return equation.appendTo(this.equationsArea);
  };

  Equations.prototype.addComponent = function(equationFragment, equationAreas) {
    var equationComponent,
      _this = this;
    equationComponent = new EquationComponent({
      gameArea: this.gameArea,
      equationFragment: equationFragment,
      equationAreas: equationAreas,
      trackDrag: function(left, top, component) {
        return _this.trackComponentDragging(left, top, component);
      },
      endDrag: function(component) {
        return _this.endComponentDragging(component);
      }
    });
    return this.possibleFragments.append(equationComponent.element);
  };

  Equations.prototype.trackComponentDragging = function(left, top, component) {
    var bottom, equation, right, x, y, _i, _len, _ref,
      _this = this;
    x = left + (component.width() / 2);
    y = top + (component.height() / 2);
    left = x - (component.width() / 3);
    right = x + (component.width() / 3);
    top = y - (component.height() / 3);
    bottom = y + (component.height() / 3);
    this.selectedDropArea = null;
    this.clearDrag();
    _ref = this.equations;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      equation = _ref[_i];
      this.selectedDropArea = equation.overlappingDropAreas({
        left: left,
        right: right,
        top: top,
        bottom: bottom,
        test: function(dropArea) {
          return dropArea != null ? dropArea.highlight(true) : void 0;
        }
      });
    }
    if (this.selectedDropArea) {

    }
  };

  Equations.prototype.clearDrag = function() {
    var equation, _i, _len, _ref, _results;
    _ref = this.equations;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      equation = _ref[_i];
      _results.push(equation.clear());
    }
    return _results;
  };

  Equations.prototype.endComponentDragging = function(component) {
    var element;
    this.clearDrag();
    if (!this.selectedDropArea) {
      return;
    }
    element = this.selectedDropArea.element;
    element.addClass('with_component');
    this.selectedDropArea.component = component;
    if (this.selectedDropArea.parentArea) {
      this.selectedDropArea.parentArea.dirtyCount += 1;
    }
    this.selectedDropArea.format(component);
    this.selectedDropArea.plot();
    this.selectedDropArea.width = this.selectedDropArea.element.width();
    component.element.hide();
    return this.selectedDropArea = null;
  };

  Equations.prototype.getFormula = function(dropArea) {
    var element;
    element = $(dropArea.element)[0];
    if (element.textContent) {
      return element.textContent;
    } else {
      return element.innerText;
    }
  };

  Equations.prototype.plotFormula = function(dropArea) {
    var data;
    while (dropArea.parentArea) {
      dropArea = dropArea.parentArea;
    }
    dropArea.element.removeClass('bad_formula');
    data = this.getFormula(dropArea);
    if (!data.length || data === dropArea.defaultText) {
      return;
    }
    if (!this.plot(dropArea.id, data)) {
      return dropArea.element.addClass('bad_formula');
    }
  };

  return Equations;

})();
