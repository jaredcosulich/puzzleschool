// Generated by CoffeeScript 1.3.3
var Equation, EquationComponent, equations;

equations = typeof exports !== "undefined" && exports !== null ? exports : provide('./equations', {});

Equation = require('./equation').Equation;

EquationComponent = require('./equation_component').EquationComponent;

equations.Equations = (function() {

  function Equations(_arg) {
    var launch, submit,
      _this = this;
    this.el = _arg.el, this.gameArea = _arg.gameArea, this.plot = _arg.plot, submit = _arg.submit, this.registerEvent = _arg.registerEvent;
    this.equationsArea = this.$('.equations');
    this.possibleFragments = this.$('.possible_fragments');
    this.equations = [];
    this.equationComponents = [];
    launch = this.$('.launch');
    if (window.AppMobi) {
      launch.bind('touchstart.launch', function() {
        launch.addClass('clicking');
        return launch.one('touchend.launch', function() {
          submit();
          return launch.removeClass('clicking');
        });
      });
    } else {
      launch.bind('mousedown.launch', function() {
        return submit();
      });
    }
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
    equation.appendTo(this.equationsArea);
    return equation;
  };

  Equations.prototype.remove = function(equation) {
    var index;
    index = (equation ? this.equations.indexOf(equation) : this.equations.length - 1);
    equation = this.equations.splice(index, 1)[0];
    this.plot(equation.id);
    equation.container.remove();
    return this.length = this.equations.length;
  };

  Equations.prototype.addComponent = function(equationFragment) {
    var equationComponent, first, fragmentsWidth, index, shift, top, _i, _len, _ref,
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
    this.equationComponents.push(equationComponent);
    top = 0;
    _ref = this.equationComponents;
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      equationComponent = _ref[index];
      if (equationComponent.top() !== top) {
        first = equationComponent;
        top = equationComponent.top();
      }
      if (index === this.equationComponents.length - 1 || this.equationComponents[index + 1].top() !== top) {
        fragmentsWidth = equationComponent.left() + equationComponent.width() - first.left();
        shift = ((this.possibleFragments.width() - fragmentsWidth) / 2) - 6;
        first.elementContainer.css({
          marginLeft: shift
        });
      }
    }
    return equationComponent;
  };

  Equations.prototype.removeComponent = function(equationComponent) {
    var index;
    index = (equationComponent ? this.equationComponents.indexOf(equationComponent) : this.equationComponents.length - 1);
    equationComponent = this.equationComponents.splice(index, 1)[0];
    return equationComponent.element.remove();
  };

  Equations.prototype.trackComponentDragging = function(left, top, component) {
    var equation, _i, _len, _ref,
      _this = this;
    if (!this.el.hasClass('show_places')) {
      this.el.addClass('show_places');
    }
    this.selectedDropArea = null;
    _ref = this.equations;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      equation = _ref[_i];
      equation.expandLastAccept();
      this.selectedDropArea = equation.overlappingDropAreas({
        x: left,
        y: top,
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
    var hints,
      _this = this;
    hints = this.el.find('.hints');
    return hints.bind('mousedown.hint touchstart.hint', function() {
      return hints.one('mouseup.hint touchend.hint', function() {
        return _this.showHint();
      });
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
    var areaOffset, dragElement, dragThis, gameAreaOffset, left, offset, top,
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
    areaOffset = this.equationsArea.offset();
    gameAreaOffset = this.gameArea.offset();
    if (component.inUse) {
      dragElement = component.dropArea.element;
    } else {
      dragElement = component.element;
    }
    offset = dragElement.offset();
    top = offset.top + offset.height - gameAreaOffset.top;
    left = offset.left + (offset.width / 2) - areaOffset.left;
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
        $(document.body).one('mousedown.hint touchstart.hint', function() {
          return dragThis.css({
            opacity: 0,
            top: -1000,
            left: -1000
          });
        });
        return dragElement.one('mousedown.hint touchstart.hint', function() {
          return $.timeout(10, function() {
            var dropAreaOffset, dropHere;
            dropHere = _this.$('.drop_here');
            if ((dropAreaOffset = dropAreaElement.offset()).top === 0) {
              dropAreaOffset = _this.findComponentDropAreaElement(equation, solutionComponent).offset();
            }
            $(document.body).one('mouseup.hint touchend.hint', function() {
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
            return dropHere.css({
              opacity: 1,
              top: dropAreaOffset.top + dropAreaOffset.height - gameAreaOffset.top,
              left: dropAreaOffset.left + Math.min(30, dropAreaOffset.width / 2) - areaOffset.left
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
    var accept, allEquationsSet, c, completedSolution, component, components, dc, dropArea, element, equation, existing, formula, fragment, info, launch, launchOffset, solution, solutionComponent, solutionComponents, straightFormula, test, v, valid, variable, wrongSpot, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref, _ref1, _ref2, _ref3,
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
            _ref1 = equation.dropAreas;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              dropArea = _ref1[_j];
              if (!dropArea.component) {
                continue;
              }
              dc = dropArea.component;
              valid = (function() {
                var _k, _len2, _results;
                _results = [];
                for (_k = 0, _len2 = solutionComponents.length; _k < _len2; _k++) {
                  c = solutionComponents[_k];
                  if (c.fragment === dc.equationFragment) {
                    _results.push(c);
                  }
                }
                return _results;
              })();
              wrongSpot = (function() {
                var _k, _len2, _results;
                _results = [];
                for (_k = 0, _len2 = valid.length; _k < _len2; _k++) {
                  v = valid[_k];
                  if (v.after !== dc.after) {
                    _results.push(v);
                  }
                }
                return _results;
              })();
              if (!valid.length || wrongSpot.length) {
                this.displayHint(dropArea.component, dropArea.component.placeHolder);
                return;
              }
            }
            for (_k = 0, _len2 = solutionComponents.length; _k < _len2; _k++) {
              solutionComponent = solutionComponents[_k];
              component = null;
              valid = (function() {
                var _l, _len3, _ref2, _results;
                _ref2 = this.equationComponents;
                _results = [];
                for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
                  c = _ref2[_l];
                  if (c.equationFragment === solutionComponent.fragment) {
                    _results.push(c);
                  }
                }
                return _results;
              }).call(this);
              if (valid.length > 1) {
                component = ((function() {
                  var _l, _len3, _results;
                  _results = [];
                  for (_l = 0, _len3 = valid.length; _l < _len3; _l++) {
                    v = valid[_l];
                    if (v.after !== solutionComponent.after) {
                      _results.push(v);
                    }
                  }
                  return _results;
                })())[0];
              }
              if (!component) {
                component = valid[0];
              }
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
            _ref2 = equation.dropAreas;
            for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
              dropArea = _ref2[_l];
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
            for (_m = 0, _len4 = components.length; _m < _len4; _m++) {
              component = components[_m];
              fragment = component.equationFragment;
              if (this.testFragment(fragment, solution, straightFormula)) {
                _ref3 = equation.dropAreas;
                for (_n = 0, _len5 = _ref3.length; _n < _len5; _n++) {
                  dropArea = _ref3[_n];
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
        opacity: 1,
        top: launchOffset.top + launchOffset.height - this.gameArea.offset().top,
        left: launchOffset.left + (launchOffset.width / 2) - this.equationsArea.offset().left
      });
      return this.$('.launch').one('mouseup.hint touchend.hint', function() {
        return launch.css({
          opacity: 0,
          top: -1000,
          left: -1000
        });
      });
    }
  };

  return Equations;

})();
