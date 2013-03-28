// Generated by CoffeeScript 1.3.3
var xyflyerEditor;

xyflyerEditor = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/xyflyer_editor', {});

xyflyerEditor.EditorHelper = (function() {

  EditorHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  function EditorHelper(_arg) {
    this.el = _arg.el, this.equationArea = _arg.equationArea, this.boardElement = _arg.boardElement, this.objects = _arg.objects, this.encode = _arg.encode, this.islandCoordinates = _arg.islandCoordinates, this.grid = _arg.grid, this.variables = _arg.variables, this.assets = _arg.assets;
    this.parser = require('./parser');
    this.init();
  }

  EditorHelper.prototype.init = function() {
    var asset, editor, index, _ref,
      _this = this;
    this.variables || (this.variables = {});
    this.rings = [];
    this.assets || (this.assets = {});
    _ref = this.assets;
    for (asset in _ref) {
      index = _ref[asset];
      this.setAsset(asset, index);
    }
    this.initBoard({});
    this.equations = new xyflyer.Equations({
      el: this.equationArea,
      gameArea: this.el,
      plot: function(id, data) {
        return _this.plot(id, data);
      },
      submit: function() {
        return _this.launch();
      }
    });
    this.initButtons();
    this.hideInstructions();
    editor = this.$('.editor');
    return this.$('.editor').bind('mousedown.move_editor', function(e) {
      var startEditorX, startEditorY, startX, startY;
      startX = e.clientX;
      startY = e.clientY;
      startEditorX = parseInt(editor.css('left'));
      startEditorY = parseInt(editor.css('top'));
      $(document.body).bind('mousemove.move_editor', function(e) {
        return editor.css({
          left: startEditorX - (startX - e.clientX),
          top: startEditorY - (startY - e.clientY)
        });
      });
      return $(document.body).one('mouseup.move_editor', function() {
        return $(document.body).unbind('mousemove.move_editor');
      });
    });
  };

  EditorHelper.prototype.initBoard = function(_arg) {
    var equation, grid, islandCoordinates, ring, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results,
      _this = this;
    grid = _arg.grid, islandCoordinates = _arg.islandCoordinates;
    if (grid) {
      this.grid = grid;
    } else if (!this.grid) {
      this.grid = {
        xMin: -10,
        xMax: 10,
        yMin: -10,
        yMax: 10
      };
    }
    if (islandCoordinates) {
      this.islandCoordinates = islandCoordinates;
    } else if (!this.islandCoordinates) {
      this.islandCoordinates = {
        x: 0,
        y: 0
      };
    }
    if (this.board) {
      this.board.clear();
    }
    this.board = new xyflyer.Board({
      el: this.boardElement,
      objects: this.objects,
      grid: this.grid,
      islandCoordinates: this.islandCoordinates,
      resetLevel: function() {
        return _this.resetLevel();
      }
    });
    if (this.plane) {
      this.plane.setBoard(this.board);
      this.plane.reset();
    } else {
      this.plane = new xyflyer.Plane({
        board: this.board,
        objects: this.objects,
        track: function(info) {
          return _this.trackPlane(info);
        }
      });
    }
    _ref = this.rings;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ring = _ref[_i];
      ring.setBoard(this.board);
    }
    if (this.equations) {
      _ref2 = (_ref1 = this.equations) != null ? _ref1.equations : void 0;
      _results = [];
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        equation = _ref2[_j];
        _results.push(this.equations.plotFormula(equation));
      }
      return _results;
    }
  };

  EditorHelper.prototype.initButtons = function() {
    var _ref,
      _this = this;
    if (!((_ref = this.board) != null ? _ref.island : void 0)) {
      $.timeout(100, function() {
        return _this.initButtons();
      });
      return;
    }
    this.$('.editor .edit_board').bind('click', function() {
      return _this.showDialog({
        text: 'What should the bounds of the board be?',
        fields: [['xMin', 'Minimum X'], ['xMax', 'Maximum X'], [], ['yMin', 'Minimum Y'], ['yMax', 'Maximum Y']],
        callback: function(data) {
          return _this.initBoard({
            grid: data
          });
        }
      });
    });
    this.$('.editor .edit_island').bind('click', function() {
      return _this.showDialog({
        text: 'What should the coordinates of the island be?',
        fields: [['x', 'X'], ['y', 'Y']],
        callback: function(data) {
          return _this.initBoard({
            islandCoordinates: data
          });
        }
      });
    });
    this.$('.editor .add_equation').bind('click', function() {
      if (_this.equations.length < 3) {
        _this.addEquation();
        return _this.handleModification();
      } else {
        return alert("You've already added the maximum number of equations.");
      }
    });
    this.$('.editor .remove_equation').bind('click', function() {
      var equation, _i, _len, _ref1, _results;
      if (_this.equations.length <= 1) {
        return alert('You must have at least one equation.');
      } else {
        alert('Please click on the equation you want to remove.');
        _ref1 = _this.equations.equations;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          equation = _ref1[_i];
          _results.push((function(equation) {
            return equation.el.bind('mousedown.remove', function() {
              var dropArea, e, _j, _k, _len1, _len2, _ref2, _ref3, _ref4;
              _ref2 = _this.equations.equations;
              for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
                e = _ref2[_j];
                e.el.unbind('mousedown.remove');
              }
              _ref3 = equation.dropAreas;
              for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
                dropArea = _ref3[_k];
                if ((_ref4 = dropArea.component) != null) {
                  _ref4.reset();
                }
              }
              _this.equations.remove(equation);
              return _this.handleModification();
            });
          })(equation));
        }
        return _results;
      }
    });
    this.$('.editor .add_fragment').bind('click', function() {
      return _this.showDialog({
        text: 'What equation fragment do you want to add?',
        fields: [['fragment', 'Fragment', 'text']],
        callback: function(data) {
          return _this.addEquationComponent(data.fragment);
        }
      });
    });
    this.$('.editor .remove_fragment').bind('click', function() {
      var component, _i, _len, _ref1, _results;
      alert('Please click on the equation fragment you want to remove.');
      _ref1 = _this.equations.equationComponents;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        component = _ref1[_i];
        _results.push((function(component) {
          return component.element.bind('mousedown.remove', function() {
            var c, _j, _len1, _ref2;
            _ref2 = _this.equations.equationComponents;
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              c = _ref2[_j];
              c.element.unbind('mousedown.remove');
            }
            if (component.variable) {
              delete _this.variables[component.variable];
            }
            _this.equations.removeComponent(component);
            return _this.handleModification();
          });
        })(component));
      }
      return _results;
    });
    this.$('.editor .add_ring').bind('click', function() {
      return _this.showDialog({
        text: 'What should the coordinates of this new ring be?',
        fields: [['x', 'X'], ['y', 'Y']],
        callback: function(data) {
          return _this.addRing(data.x, data.y);
        }
      });
    });
    this.$('.editor .remove_ring').bind('click', function() {
      alert('Please click on the ring you want to remove.');
      _this.boardElement.bind('click.remove_ring', function(e) {
        var index, ring, _i, _len, _ref1;
        _this.boardElement.unbind('click.remove_ring');
        _this.board.initClicks(_this.boardElement);
        _ref1 = _this.rings;
        for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
          ring = _ref1[index];
          if (ring.touches(e.offsetX, e.offsetY, 12, 12)) {
            _this.rings.splice(index, 1);
            ring.remove();
            _this.handleModification();
            return;
          }
        }
        return alert('No ring detected. Please click \'Remove\' again if you want to remove a ring.');
      });
      return _this.boardElement.unbind('click.showxy');
    });
    this.$('.editor .change_background').bind('click', function() {
      return _this.showImageDialog("Select The Background Image", 'background', 3, function(index) {
        return _this.setAsset('background', index);
      });
    });
    this.$('.editor .change_island').bind('click', function() {
      return _this.showImageDialog("Select The Island Image", 'island', 2, function(index) {
        return _this.setAsset('island', index);
      });
    });
    this.$('.editor .change_plane').bind('click', function() {
      return _this.showImageDialog("Select The Plane", 'plane', 2, function(index) {
        return _this.setAsset('plane', index);
      });
    });
    this.$('.editor .reset_editor').bind('click', function() {
      if (confirm('Are you sure you want to reset the editor?\n\nAll of your changes will be lost.')) {
        return location.href = location.pathname;
      }
    });
    return this.boardElement.bind('mousedown.dragisland', function(e) {
      var currentX, currentY, element, elements, xStart, yStart, _i, _len, _ref1, _ref2, _results;
      xStart = currentX = e.clientX;
      yStart = currentY = e.clientY;
      elements = _this.board.paper.getElementsByPoint(e.offsetX, e.offsetY);
      _results = [];
      for (_i = 0, _len = elements.length; _i < _len; _i++) {
        element = elements[_i];
        if (!((_ref1 = element[0].href) != null ? (_ref2 = _ref1.toString()) != null ? _ref2.indexOf('island') : void 0 : void 0)) {
          continue;
        }
        _this.boardElement.bind('mousemove.dragisland', function(e) {
          var x, y;
          _this.board.island.transform("...t" + (e.clientX - currentX) + "," + (e.clientY - currentY));
          x = _this.board.screenX(_this.islandCoordinates.x) + (e.clientX - currentX);
          y = _this.board.screenY(_this.islandCoordinates.y) + (e.clientY - currentY);
          _this.plane.move(x, y, 0);
          _this.board.islandCoordinates = _this.islandCoordinates = {
            x: _this.board.paperX(x),
            y: _this.board.paperY(y)
          };
          _this.board.islandLabel.attr({
            text: _this.board.islandText()
          });
          currentX = e.clientX;
          return currentY = e.clientY;
        });
        _results.push(_this.boardElement.one('mouseup.dragisland', function(e) {
          if (e.clientX !== xStart && e.clientY !== yStart) {
            _this.initBoard({});
          }
          _this.boardElement.unbind('mousemove.dragisland');
          return _this.handleModification();
        }));
      }
      return _results;
    });
  };

  EditorHelper.prototype.addEquation = function(equationString, start, solutionComponents) {
    var _this = this;
    if (!start) {
      return this.showDialog({
        text: 'What should this equation start with?',
        fields: [['start', 'Starting Equation', 'text']],
        callback: function(data) {
          return _this.actuallyAddEquation(equationString, (data.start || '').toLowerCase(), solutionComponents);
        }
      });
    } else {
      return this.actuallyAddEquation(equationString, start, solutionComponents);
    }
  };

  EditorHelper.prototype.actuallyAddEquation = function(equationString, start, solutionComponents) {
    var accept, c, component, equation, solutionComponent, _i, _len, _ref,
      _this = this;
    equation = this.equations.add(equationString, start, solutionComponents, this.variables);
    _ref = solutionComponents || [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      solutionComponent = _ref[_i];
      component = ((function() {
        var _j, _len1, _ref1, _results;
        _ref1 = this.equations.equationComponents;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          c = _ref1[_j];
          if (c.equationFragment === solutionComponent.fragment) {
            _results.push(c);
          }
        }
        return _results;
      }).call(this))[0];
      if (component.after === solutionComponent.after) {
        continue;
      }
      accept = this.equations.findComponentDropAreaElement(equation, solutionComponent);
      if (accept != null ? accept.length : void 0) {
        (function(solutionComponent, component, accept) {
          var da, dropArea;
          dropArea = ((function() {
            var _j, _len1, _ref1, _results;
            _ref1 = equation.dropAreas;
            _results = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              da = _ref1[_j];
              if (da.element[0] === accept[0]) {
                _results.push(da);
              }
            }
            return _results;
          })())[0];
          equation.accept(dropArea, component);
          component.initMeasurements();
          component.setDragging();
          component.element.css({
            visibility: 'hidden'
          });
          if (component.variable) {
            return setTimeout((function() {
              return equation.variables[component.variable].set(_this.variables[component.variable].solution);
            }), 100);
          }
        })(solutionComponent, component, accept);
      }
    }
    return this.handleModification();
  };

  EditorHelper.prototype.addEquationComponent = function(fragment) {
    var component, result, variable,
      _this = this;
    component = this.equations.addComponent(fragment);
    if ((result = /(^|[^a-w])([a-d])($|[^a-w])/.exec(fragment))) {
      variable = result[2];
      component.variable = variable;
      if (!this.variables[variable]) {
        this.showDialog({
          text: 'What is the range of this variable?',
          fields: [['min', 'From (min)'], ['max', 'To (max)'], [], ['increment', 'By (increment)'], ['start', 'Starting At']],
          callback: function(data) {
            var equation, _i, _len, _ref;
            _this.variables[variable] = data;
            _ref = _this.equations.equations;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              equation = _ref[_i];
              equation.variables || (equation.variables = {});
              equation.variables[variable] = data;
            }
            return _this.handleModification();
          }
        });
      }
    }
    return this.handleModification();
  };

  EditorHelper.prototype.addRing = function(x, y) {
    if (isNaN(parseInt(x)) || isNaN(parseInt(y))) {
      alert('Those coordinates are not valid.');
      return;
    }
    this.rings.push(new xyflyer.Ring({
      board: this.board,
      x: x,
      y: y
    }));
    return this.handleModification();
  };

  EditorHelper.prototype.plot = function(id, data) {
    var area, formula, _ref;
    _ref = this.parser.parse(data), formula = _ref[0], area = _ref[1];
    this.board.plot(id, formula, area);
    return this.handleModification();
  };

  EditorHelper.prototype.launch = function() {
    var _ref;
    if ((_ref = this.plane) != null) {
      _ref.launch(true);
    }
    return this.handleModification();
  };

  EditorHelper.prototype.resetLevel = function() {
    var ring, _i, _len, _ref, _ref1, _results;
    if ((_ref = this.plane) != null) {
      _ref.reset();
    }
    _ref1 = this.rings;
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      ring = _ref1[_i];
      _results.push(ring.reset());
    }
    return _results;
  };

  EditorHelper.prototype.trackPlane = function(info) {
    var allPassedThrough, ring, _i, _len, _ref;
    allPassedThrough = this.rings.length > 0;
    _ref = this.rings;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ring = _ref[_i];
      ring.highlightIfPassingThrough(info);
      if (!ring.passedThrough) {
        allPassedThrough = false;
      }
    }
    if (allPassedThrough) {
      return this.showInstructions();
    }
  };

  EditorHelper.prototype.createDialog = function(html, callback) {
    var dialog,
      _this = this;
    dialog = $(document.createElement('DIV'));
    dialog.addClass('dialog');
    dialog.html(html);
    this.el.append(dialog);
    dialog.css({
      opacity: 0,
      left: (this.el.width() / 2) - (dialog.width() / 2)
    });
    dialog.animate({
      opacity: 1,
      duration: 250,
      complete: function() {
        return dialog.find('input:first-child').focus();
      }
    });
    dialog.bind('mousedown.dialog', function(e) {
      var body, leftClick, leftStart, topClick, topStart;
      body = $(document.body);
      leftStart = dialog.offset().left - _this.el.offset().left;
      leftClick = e.clientX;
      topStart = dialog.offset().top - _this.el.offset().top;
      topClick = e.clientY;
      body.bind('mousemove.dialog', function(e) {
        if (document.activeElement.type === 'text') {
          return;
        }
        if (e.preventDefault) {
          e.preventDefault();
        }
        return dialog.css({
          left: leftStart + (e.clientX - leftClick),
          top: topStart + (e.clientY - topClick)
        });
      });
      return body.one('mouseup', function() {
        return body.unbind('mousemove.dialog');
      });
    });
    dialog.find('.cancel_button').bind('click', function() {
      return _this.closeDialog(dialog);
    });
    return dialog;
  };

  EditorHelper.prototype.closeDialog = function(dialog) {
    return dialog.animate({
      opacity: 0,
      duration: 250,
      complete: function() {
        return dialog.remove();
      }
    });
  };

  EditorHelper.prototype.showImageDialog = function(text, name, count, callback) {
    var dialog, html, image, index, resize, _i, _j, _len, _ref,
      _this = this;
    html = "<h3>" + text + "</h3><table><tbody><tr>";
    for (index = _i = 1; 1 <= count ? _i <= count : _i >= count; index = 1 <= count ? ++_i : --_i) {
      html += "<td><div class='image'><img src='https://raw.github.com/jaredcosulich/puzzleschool/redesign/assets/images/puzzles/xyflyer/" + name + index + ".png' style='opacity: 0'/></div></td>";
    }
    html += "</tr></tbody></table>\n<a class='blue_button cancel_button'>Cancel</a>";
    dialog = this.createDialog(html);
    _ref = dialog.find('img');
    for (_j = 0, _len = _ref.length; _j < _len; _j++) {
      image = _ref[_j];
      resize = function(image) {
        var height, ratio, width;
        height = image.height();
        width = image.width();
        if (!height || !width) {
          setTimeout((function() {
            return resize(image);
          }), 100);
          return;
        }
        if (height > 120) {
          ratio = 120 / height;
          image.height(120);
          width = width * ratio;
          image.width(width);
        }
        if (width > 160) {
          ratio = 160 / width;
          image.width(160);
          image.height(image.height() * ratio);
        }
        return image.animate({
          opacity: 1,
          duration: 250
        });
      };
      resize($(image));
    }
    return dialog.find('img').bind('click', function(e) {
      var srcComponents;
      e.stop();
      $(document.body).unbind('dialog.move');
      _this.closeDialog(dialog);
      srcComponents = e.currentTarget.src.split('/');
      return callback(srcComponents[srcComponents.length - 1].replace(/[^1-9]/g, ''));
    });
  };

  EditorHelper.prototype.showDialog = function(_arg) {
    var callback, dialog, fieldInfo, fields, lastRow, text, _i, _len,
      _this = this;
    text = _arg.text, fields = _arg.fields, callback = _arg.callback;
    dialog = this.createDialog("<h3>" + text + "</h3>\n<table><tbody><tr></tr></tbody></table>\n<button class='button'>Save</button> &nbsp; <a class='blue_button cancel_button'>Cancel</a>");
    for (_i = 0, _len = fields.length; _i < _len; _i++) {
      fieldInfo = fields[_i];
      if (!fieldInfo.length) {
        dialog.find('tbody').append('<tr></tr>');
        continue;
      }
      lastRow = dialog.find('tr:last-child');
      lastRow.append("<td>" + fieldInfo[1] + ":</td><td><input name='" + fieldInfo[0] + "' class='" + (fieldInfo[2] || 'number') + "'/></td>");
    }
    dialog.find('button').bind('click', function() {
      var data, i, input, _j, _len1, _ref;
      _this.closeDialog(dialog);
      data = {};
      _ref = dialog.find('input');
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        i = _ref[_j];
        input = $(i);
        data[input.attr('name')] = (input.hasClass('number') ? parseFloat(input.val()) : input.val());
      }
      callback(data);
      return _this.handleModification();
    });
    return dialog.find('a').bind('click', function() {
      return _this.closeDialog(dialog);
    });
  };

  EditorHelper.prototype.setAsset = function(type, index) {
    var src;
    this.assets[type] = index;
    src = "https://raw.github.com/jaredcosulich/puzzleschool/redesign/assets/images/puzzles/xyflyer/" + type + index + ".png";
    switch (type) {
      case 'background':
        this.el.css({
          backgroundImage: "url(" + src + ")"
        });
        break;
      default:
        this.objects.find("." + type + " img").remove();
        this.objects.find("." + type).html("<img src='" + src + "'/>");
        this.initBoard({});
    }
    return this.handleModification();
  };

  EditorHelper.prototype.constructSolutionComponents = function(equation) {
    var da, dae, dropArea, solutionComponents, _i, _len, _ref;
    solutionComponents = [];
    _ref = equation.el.find('div');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      dae = _ref[_i];
      dropArea = ((function() {
        var _j, _len1, _ref1, _ref2, _results;
        _ref1 = equation.dropAreas;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          da = _ref1[_j];
          if (((_ref2 = da.element) != null ? _ref2[0] : void 0) === dae) {
            _results.push(da);
          }
        }
        return _results;
      })())[0];
      if (dropArea != null ? dropArea.component : void 0) {
        solutionComponents.push({
          fragment: dropArea.component.equationFragment,
          after: dropArea.component.after
        });
      }
    }
    return solutionComponents;
  };

  EditorHelper.prototype.getInstructions = function() {
    var asset, component, ec, equation, equationInstructions, index, info, instructions, ring, sc, solutionComponents, variable, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _ref4;
    instructions = {
      equations: {},
      rings: []
    };
    this.coffeeInstructions = "{\n    id: " + (new Date().getTime());
    if (this.equations) {
      this.coffeeInstructions += "\n\tequations:";
      _ref = this.equations.equations;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        equation = _ref[_i];
        equationInstructions = instructions.equations[equation.straightFormula()] = {};
        this.coffeeInstructions += "\n\t\t'" + (equation.straightFormula()) + "':";
        if (equation.startingFragment) {
          equationInstructions.start = equation.startingFragment;
          this.coffeeInstructions += "\n\t\t\tstart: '" + equation.startingFragment + "'";
        }
        if ((solutionComponents = this.constructSolutionComponents(equation)).length) {
          equationInstructions.solutionComponents = solutionComponents;
          this.coffeeInstructions += '\n\t\t\tsolutionComponents: [';
          for (_j = 0, _len1 = solutionComponents.length; _j < _len1; _j++) {
            sc = solutionComponents[_j];
            this.coffeeInstructions += "\n\t\t\t\t{fragment: '" + sc.fragment + "', after: '" + sc.after + "'}";
          }
          this.coffeeInstructions += '\n\t\t\t]';
        }
      }
      this.coffeeInstructions += '\n\tfragments: [';
      instructions.fragments = [];
      _ref1 = this.equations.equationComponents;
      for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
        component = _ref1[_k];
        instructions.fragments.push(component.equationFragment);
      }
      this.coffeeInstructions += "" + (((function() {
        var _l, _len3, _ref2, _results;
        _ref2 = this.equations.equationComponents;
        _results = [];
        for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
          ec = _ref2[_l];
          _results.push("'" + ec.equationFragment + "'");
        }
        return _results;
      }).call(this)).join(', ')) + "]";
    }
    this.coffeeInstructions += '\n\trings: [';
    _ref2 = this.rings;
    for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
      ring = _ref2[_l];
      instructions.rings.push({
        x: ring.x,
        y: ring.y
      });
      this.coffeeInstructions += "\n\t\t{x: " + ring.x + ", y: " + ring.y + "}";
    }
    this.coffeeInstructions += '\n\t]';
    instructions.grid = this.grid;
    this.coffeeInstructions += "\n    grid:\n        xMin: " + this.grid.xMin + "\n        xMax: " + this.grid.xMax + "\n        yMin: " + this.grid.yMin + "\n        yMax: " + this.grid.yMax;
    instructions.islandCoordinates = this.islandCoordinates;
    this.coffeeInstructions += "\n\tislandCoordinates: {x: " + this.islandCoordinates.x + ", y: " + this.islandCoordinates.y + "}";
    _ref3 = this.variables;
    for (variable in _ref3) {
      info = _ref3[variable];
      if (!instructions.variables) {
        instructions.variables = {};
        this.coffeeInstructions += '\n\tvariables: ';
      }
      instructions.variables[variable] = {
        start: info.start,
        min: info.min,
        max: info.max,
        increment: info.increment,
        solution: (info.get ? info.get() : null)
      };
      this.coffeeInstructions += "\n        " + variable + ":\n            start: " + info.start + "\n            min: " + info.min + "\n            max: " + info.max + "\n            increment: " + info.increment + "\n            solution: " + instructions.variables[variable].solution;
    }
    _ref4 = this.assets;
    for (asset in _ref4) {
      index = _ref4[asset];
      if (!instructions.assets) {
        instructions.assets = {};
        this.coffeeInstructions += '\n\tassets: ';
      }
      instructions.assets[asset] = index;
      this.coffeeInstructions += "\n\t\t" + asset + ": " + index;
    }
    this.coffeeInstructions += '\n}';
    return this.encode(JSON.stringify(instructions));
  };

  EditorHelper.prototype.handleModification = function() {
    this.hashInstructions();
    return this.hideInstructions();
  };

  EditorHelper.prototype.hashInstructions = function() {
    var levelString;
    levelString = this.getInstructions();
    return window.location.hash = levelString;
  };

  EditorHelper.prototype.showInstructions = function() {
    var href;
    if (this.instructionsDisplayed) {
      return;
    }
    this.instructionsDisplayed = true;
    this.$('.instructions .invalid').hide();
    this.$('.instructions .valid').show();
    href = location.protocol + '//' + location.host + location.pathname;
    this.$('.instructions .link').val("" + (href.replace(/editor/, 'custom')) + "#" + (this.getInstructions()));
    this.hashInstructions();
    return console.log(this.coffeeInstructions.replace(/\t/g, '    '));
  };

  EditorHelper.prototype.hideInstructions = function() {
    this.instructionsDisplayed = false;
    this.$('.instructions .valid').hide();
    return this.$('.instructions .invalid').show();
  };

  return EditorHelper;

})();
