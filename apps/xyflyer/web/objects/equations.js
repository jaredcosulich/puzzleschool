// Generated by CoffeeScript 1.3.3
var Equation, EquationComponent, equations;

equations = typeof exports !== "undefined" && exports !== null ? exports : provide('./equations', {});

Equation = require('./equation').Equation;

EquationComponent = require('./equation_component').EquationComponent;

equations.Equations = (function() {

  function Equations(_arg) {
    var submit,
      _this = this;
    this.el = _arg.el, this.gameArea = _arg.gameArea, this.plot = _arg.plot, submit = _arg.submit, this.registerEvent = _arg.registerEvent;
    this.equationsArea = this.$('.equations');
    this.possibleFragments = this.$('.possible_fragments');
    this.equations = [];
    this.equationComponents = [];
    this.$('.launch').bind('click', function() {
      return submit();
    });
    this.initHints();
    this.initBackspace();
    this.length = 0;
  }

  Equations.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  Equations.prototype.add = function(solution, startingFragment, solutionComponents, variables) {
    var equation, equationCount,
      _this = this;
    equationCount = this.equationsArea.find('.equation').length;
    equation = new Equation({
      id: "equation_" + (equationCount + 1),
      gameArea: this.gameArea,
      solution: solution,
      solutionComponents: solutionComponents,
      startingFragment: startingFragment,
      variables: variables,
      plot: function(eq) {
        return _this.plotFormula(eq);
      }
    });
    this.equations.push(equation);
    this.length = this.equations.length;
    return equation.appendTo(this.equationsArea);
  };

  Equations.prototype.remove = function(equation) {
    var index;
    index = (equation ? this.equations.indexOf(equation) : this.equations.length - 1);
    equation = this.equations.splice(index - 1, 1)[0];
    equation.container.remove();
    return this.length = this.equations.length;
  };

  Equations.prototype.addComponent = function(equationFragment) {
    var equationComponent,
      _this = this;
    equationComponent = new EquationComponent({
      gameArea: this.gameArea,
      equationFragment: equationFragment,
      trackDrag: function(left, top, component) {
        return _this.trackComponentDragging(left, top, component);
      },
      endDrag: function(component) {
        return _this.endComponentDragging(component);
      }
    });
    equationComponent.appendTo(this.possibleFragments);
    return this.equationComponents.push(equationComponent);
  };

  Equations.prototype.removeComponent = function(equationComponent) {
    var index;
    index = (equation ? this.equationComponents.indexOf(equation) : this.equationComponents.length - 1);
    equationComponent = this.equationComponents.splice(index - 1, 1)[0];
    return equationComponent.element.remove();
  };

  Equations.prototype.trackComponentDragging = function(left, top, component) {
    var equation, x, y, _i, _len, _ref,
      _this = this;
    if (!this.el.hasClass('show_places')) {
      this.el.addClass('show_places');
    }
    x = left + (component.width() / 2);
    y = top + (component.height() / 2);
    this.selectedDropArea = null;
    _ref = this.equations;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      equation = _ref[_i];
      equation.expandLastAccept();
      this.selectedDropArea = equation.overlappingDropAreas({
        x: x,
        y: y,
        test: function(dropArea, over) {
          var result;
          result = dropArea != null ? dropArea.highlight(over) : void 0;
          equation.expandLastAccept();
          return result;
        }
      });
      if (this.selectedDropArea) {
        return;
      }
    }
  };

  Equations.prototype.clearDrag = function() {
    var equation, _i, _len, _ref, _results;
    this.el.removeClass('show_places');
    _ref = this.equations;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      equation = _ref[_i];
      _results.push(equation.clear());
    }
    return _results;
  };

  Equations.prototype.endComponentDragging = function(component) {
    this.clearDrag();
    if (!this.selectedDropArea) {
      return false;
    }
    this.lastComponent = component;
    this.selectedDropArea.accept(component);
    if (this.registerEvent) {
      this.registerEvent({
        type: 'move',
        info: {
          equationId: this.selectedDropArea.id,
          fragment: component.equationFragment,
          time: new Date()
        }
      });
    }
    this.selectedDropArea = null;
    return true;
  };

  Equations.prototype.plotFormula = function(equation) {
    var formulaData;
    this.checkMultipleEquations();
    equation.hideBadFormula();
    formulaData = equation.formulaData();
    if (!(this.plot(equation.id, formulaData) || !formulaData.length)) {
      return equation.showBadFormula();
    }
  };

  Equations.prototype.checkMultipleEquations = function() {
    var equation, inUseEquations, _i, _j, _len, _len1, _ref, _ref1, _results;
    inUseEquations = 0;
    _ref = this.equations;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      equation = _ref[_i];
      if (equation.el.html() !== equation.defaultText) {
        inUseEquations += 1;
        if (inUseEquations > 1) {
          break;
        }
      }
    }
    _ref1 = this.equations;
    _results = [];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      equation = _ref1[_j];
      if (inUseEquations > 1) {
        _results.push(equation.showRange());
      } else {
        _results.push(equation.hideRange());
      }
    }
    return _results;
  };

  Equations.prototype.initBackspace = function() {
    var _this = this;
    return window.onkeydown = function(e) {
      var _ref;
      if ($('.opaque_screen').css('opacity') > 0) {
        return;
      }
      if (e.keyCode === 8 && ((_ref = document.activeElement) != null ? _ref.type : void 0) !== 'text' ? e.preventDefault : void 0) {
        return e.preventDefault();
      }
    };
  };

  Equations.prototype.initHints = function() {
    var _this = this;
    return this.el.find('.hint').bind('click', function() {
      return _this.showHint();
    });
  };

  Equations.prototype.testFragment = function(fragment, solution, formula, complete) {
    var solutionIndex;
    solutionIndex = solution.indexOf(fragment);
    if (formula[solutionIndex - 1] !== solution[solutionIndex - 1]) {
      return false;
    }
    return (complete ? solutionIndex === formula.indexOf(fragment) : solutionIndex !== formula.indexOf(fragment));
  };

  Equations.prototype.displayHint = function(component, dropAreaElement, equation, solutionComponent) {
    var dragElement, dragThis, gameAreaOffset, left, offset, top,
      _this = this;
    if (this.registerEvent) {
      this.registerEvent({
        type: 'hint',
        info: {
          equationId: dropAreaElement.id,
          fragment: component.equationFragment,
          time: new Date()
        }
      });
    }
    gameAreaOffset = this.gameArea.offset();
    if (component.top() === 0) {
      dragElement = component.dropArea.element;
    } else {
      dragElement = component.element;
    }
    offset = dragElement.offset();
    top = offset.top + offset.height - gameAreaOffset.top;
    left = offset.left + (offset.width / 2) - gameAreaOffset.left;
    dragThis = this.$('.drag_this');
    dragThis.css({
      opacity: 0,
      top: top,
      left: left
    });
    return dragThis.animate({
      opacity: 1,
      duration: 250,
      complete: function() {
        return dragElement.one('mousedown.hint touchstart.hint', function() {
          $(document.body).one('mouseup.hint touchend.hint', function() {
            $(document.body).unbind('mousemove.hint touchmove.hint');
            return dragThis.animate({
              opacity: 0,
              duration: 250,
              complete: function() {
                return dragThis.css({
                  top: -1000,
                  left: -1000
                });
              }
            });
          });
          return $(document.body).one('mousemove.hint touchmove.hint', function() {
            var dropHere;
            $(document.body).unbind('mouseup.hint touchend.hint');
            dragThis.animate({
              opacity: 0,
              duration: 250,
              complete: function() {
                return dragThis.css({
                  top: -1000,
                  left: -1000
                });
              }
            });
            dropHere = _this.$('.drop_here');
            if ((offset = dropAreaElement.offset()).top === 0) {
              offset = _this.findComponentDropAreaElement(equation, solutionComponent).offset();
            }
            dropHere.css({
              opacity: 0,
              top: offset.top + offset.height - gameAreaOffset.top,
              left: offset.left + (offset.width / 2) - gameAreaOffset.left
            });
            return dropHere.animate({
              opacity: 1,
              duration: 250,
              complete: function() {
                return component.element.one('mouseup.hint touchend.hint', function() {
                  return dropHere.animate({
                    opacity: 0,
                    duration: 250,
                    complete: function() {
                      return dropHere.css({
                        top: -1000,
                        left: -1000
                      });
                    }
                  });
                });
              }
            });
          });
        });
      }
    });
  };

  Equations.prototype.findComponentDropAreaElement = function(equation, solutionComponent) {
    var accept, p, possible, sf, _i, _len;
    possible = equation.el.find('div');
    if (solutionComponent.after.length) {
      for (_i = 0, _len = possible.length; _i < _len; _i++) {
        p = possible[_i];
        sf = equation.straightFormula($(p));
        if (sf === solutionComponent.after || sf.replace(solutionComponent.fragment, '') === solutionComponent.after) {
          accept = $(p).next();
          break;
        }
      }
    } else {
      accept = $(possible[0]);
    }
    return accept;
  };

  Equations.prototype.showHint = function() {
    var accept, allEquationsSet, c, completedSolution, component, components, dropArea, element, equation, existing, formula, fragment, info, launch, launchOffset, solution, solutionComponent, solutionComponents, straightFormula, test, variable, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2,
      _this = this;
    allEquationsSet = true;
    _ref = this.equations;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      equation = _ref[_i];
      formula = equation.formula();
      straightFormula = equation.straightFormula();
      completedSolution = solution = equation.solution;
      for (variable in equation.variables) {
        info = equation.variables[variable];
        if (info.solution) {
          completedSolution = completedSolution.replace(variable, info.solution);
        }
      }
      if (formula !== completedSolution) {
        allEquationsSet = false;
        if (straightFormula !== solution) {
          if ((solutionComponents = equation.solutionComponents)) {
            for (_j = 0, _len1 = solutionComponents.length; _j < _len1; _j++) {
              solutionComponent = solutionComponents[_j];
              component = ((function() {
                var _k, _len2, _ref1, _results;
                _ref1 = this.equationComponents;
                _results = [];
                for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                  c = _ref1[_k];
                  if (c.equationFragment === solutionComponent.fragment) {
                    _results.push(c);
                  }
                }
                return _results;
              }).call(this))[0];
              if (component.after === solutionComponent.after) {
                continue;
              }
              accept = this.findComponentDropAreaElement(equation, solutionComponent);
              if (accept != null ? accept.length : void 0) {
                this.displayHint(component, accept, equation, solutionComponent);
                return;
              }
            }
          } else {
            _ref1 = equation.dropAreas;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              dropArea = _ref1[_k];
              if (dropArea.component) {
                if (solution.indexOf(dropArea.component.equationFragment) === -1) {
                  this.displayHint(dropArea.component, dropArea.component.placeHolder);
                  return;
                }
              }
            }
            components = this.equationComponents.sort(function(a, b) {
              return b.equationFragment.length - a.equationFragment.length;
            });
            for (_l = 0, _len3 = components.length; _l < _len3; _l++) {
              component = components[_l];
              fragment = component.equationFragment;
              if (this.testFragment(fragment, solution, straightFormula)) {
                _ref2 = equation.dropAreas;
                for (_m = 0, _len4 = _ref2.length; _m < _len4; _m++) {
                  dropArea = _ref2[_m];
                  if (dropArea.component || dropArea.fixed) {
                    continue;
                  }
                  element = dropArea.element;
                  element.html(fragment);
                  test = this.testFragment(fragment, solution, equation.straightFormula(), true);
                  element.html('');
                  if (test) {
                    this.displayHint(component, dropArea.element);
                    return;
                  }
                }
              }
            }
          }
        } else {
          for (variable in equation.variables) {
            info = equation.variables[variable];
            if (!info.element || parseFloat(info.get()) === parseFloat(info.solution)) {
              continue;
            }
            if ((existing = this.$(".hints ." + variable + "_hint")).length) {
              existing.animate({
                opacity: 0,
                duration: 500,
                complete: function() {
                  return existing.animate({
                    opacity: 1,
                    duration: 500
                  });
                }
              });
            } else {
              this.$('.hints').append("<p class='" + variable + "_hint'>Set " + variable + " = " + info.solution + "</p>");
            }
            return;
          }
        }
      }
    }
    if (allEquationsSet) {
      launch = this.$('.launch_hint');
      launchOffset = this.$('.launch').offset();
      launch.css({
        opacity: 0,
        top: launchOffset.top + launchOffset.height - this.gameArea.offset().top,
        left: launchOffset.left + (launchOffset.width / 2) - this.gameArea.offset().left
      });
      return launch.animate({
        opacity: 1,
        duration: 250,
        complete: function() {
          return _this.$('.launch').one('mouseup.hint touchend.hint', function() {
            return launch.animate({
              opacity: 0,
              duration: 250,
              complete: function() {
                return launch.css({
                  top: -1000,
                  left: -1000
                });
              }
            });
          });
        }
      });
    }
  };

  return Equations;

})();