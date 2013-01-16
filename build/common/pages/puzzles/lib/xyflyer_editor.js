// Generated by CoffeeScript 1.3.3
var xyflyerEditor;

xyflyerEditor = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/xyflyer_editor', {});

xyflyerEditor.EditorHelper = (function() {

  EditorHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  function EditorHelper(_arg) {
    this.el = _arg.el, this.equationArea = _arg.equationArea, this.boardElement = _arg.boardElement, this.objects = _arg.objects, this.encode = _arg.encode;
    this.rings = [];
    this.parser = require('./parser');
    this.init();
  }

  EditorHelper.prototype.init = function() {
    var _this = this;
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
    this.equations.add();
    return this.initButtons();
  };

  EditorHelper.prototype.initBoard = function(_arg) {
    var equation, grid, islandCoordinates, _i, _len, _ref, _ref1, _results,
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
      this.board.paper.clear();
    }
    this.board = new xyflyer.Board({
      boardElement: this.boardElement,
      objects: this.objects,
      grid: this.grid,
      islandCoordinates: this.islandCoordinates,
      resetLevel: function() {
        return _this.resetLevel();
      }
    });
    this.plane = new xyflyer.Plane({
      board: this.board,
      track: function(info) {
        return _this.trackPlane(info);
      }
    });
    if (this.equations) {
      _ref1 = (_ref = this.equations) != null ? _ref.equations : void 0;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        equation = _ref1[_i];
        _results.push(this.equations.plotFormula(equation));
      }
      return _results;
    }
  };

  EditorHelper.prototype.initButtons = function() {
    var _this = this;
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
        _this.hideInstructions();
        return _this.equations.add();
      } else {
        return alert("You've already added the maximum number of equations.");
      }
    });
    this.$('.editor .remove_equation').bind('click', function() {
      var equation;
      if (_this.equations.length <= 1) {
        return alert('You must have at least one equation.');
      } else {
        _this.hideInstructions();
        return equation = _this.equations.remove();
      }
    });
    this.$('.editor .add_fragment').bind('click', function() {
      return _this.showDialog({
        text: 'What equation fragment do you want to add?',
        fields: [['fragment', 'Fragment', 'text']],
        callback: function(data) {
          return _this.equations.addComponent(data.fragment);
        }
      });
    });
    this.$('.editor .remove_fragment').bind('click', function() {
      var component, _i, _len, _ref, _results;
      alert('Please click on the equation fragment you want to remove.');
      _ref = _this.equations.equationComponents;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        component = _ref[_i];
        _results.push(component.element.bind('click.remove', function() {
          var c, _j, _len1, _ref1;
          _this.hideInstructions();
          _ref1 = _this.equations.equationComponents;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            c = _ref1[_j];
            c.element.unbind('click.remove');
          }
          return _this.equations.removeComponent(component);
        }));
      }
      return _results;
    });
    this.$('.editor .add_ring').bind('click', function() {
      return _this.showDialog({
        text: 'What should the coordinates of this new ring be?',
        fields: [['x', 'X'], ['y', 'Y']],
        callback: function(data) {
          return _this.rings.push(new xyflyer.Ring({
            board: _this.board,
            x: data.x,
            y: data.y
          }));
        }
      });
    });
    return this.$('.editor .remove_ring').bind('click', function() {
      alert('Please click on the ring you want to remove.');
      _this.boardElement.bind('click.remove_ring', function(e) {
        var index, ring, _i, _len, _ref;
        _this.hideInstructions();
        _this.boardElement.unbind('click.remove_ring');
        _this.board.initClicks(_this.boardElement);
        _ref = _this.rings;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          ring = _ref[index];
          if (ring.touches(e.offsetX, e.offsetY, 12, 12)) {
            _this.rings.splice(index, 1);
            ring.image.remove();
            ring.label.remove();
            return;
          }
        }
        return alert('No ring detected. Please click \'Remove\' again if you want to remove a ring.');
      });
      return _this.boardElement.unbind('click.showxy');
    });
  };

  EditorHelper.prototype.plot = function(id, data) {
    var area, formula, _ref;
    _ref = this.parser.parse(data), formula = _ref[0], area = _ref[1];
    return this.board.plot(id, formula, area);
  };

  EditorHelper.prototype.launch = function() {
    var _ref;
    return (_ref = this.plane) != null ? _ref.launch(true) : void 0;
  };

  EditorHelper.prototype.resetLevel = function() {
    var ring, _i, _len, _ref, _results;
    this.plane.reset();
    _ref = this.rings;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ring = _ref[_i];
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

  EditorHelper.prototype.showDialog = function(_arg) {
    var callback, closeDialog, dialog, fieldInfo, fields, lastRow, text, _i, _len,
      _this = this;
    text = _arg.text, fields = _arg.fields, callback = _arg.callback;
    dialog = $(document.createElement('DIV'));
    dialog.addClass('dialog');
    dialog.html("<h3>" + text + "</h3>\n<table><tbody><tr></tr></tbody></table>\n<button class='button'>Save</button> &nbsp; <a class='blue_button'>Cancel</a>");
    for (_i = 0, _len = fields.length; _i < _len; _i++) {
      fieldInfo = fields[_i];
      if (!fieldInfo.length) {
        dialog.find('tbody').append('<tr></tr>');
        continue;
      }
      lastRow = dialog.find('tr:last-child');
      lastRow.append("<td>" + fieldInfo[1] + ":</td><td><input name='" + fieldInfo[0] + "' class='" + (fieldInfo[2] || 'number') + "'/></td>");
    }
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
    dialog.bind('mousedown', function(e) {
      var body, leftClick, leftStart, topClick, topStart;
      if (e.preventDefault) {
        e.preventDefault();
      }
      body = $(document.body);
      leftStart = dialog.offset().left - _this.el.offset().left;
      leftClick = e.clientX;
      topStart = dialog.offset().top - _this.el.offset().top;
      topClick = e.clientY;
      body.bind('mousemove.dialog', function(e) {
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
    closeDialog = function() {
      return dialog.animate({
        opacity: 0,
        duration: 250,
        complete: function() {
          return dialog.remove();
        }
      });
    };
    dialog.find('button').bind('click', function() {
      var data, i, input, _j, _len1, _ref;
      _this.hideInstructions();
      closeDialog();
      data = {};
      _ref = dialog.find('input');
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        i = _ref[_j];
        input = $(i);
        data[input.attr('name')] = (input.hasClass('number') ? parseFloat(input.val()) : input.val());
      }
      return callback(data);
    });
    return dialog.find('a').bind('click', function() {
      return closeDialog();
    });
  };

  EditorHelper.prototype.showInstructions = function() {
    var component, equation, instructions, ring, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    this.$('.instructions p').hide();
    this.$('.instructions input').show();
    instructions = {
      equations: {},
      rings: []
    };
    _ref = this.equations.equations;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      equation = _ref[_i];
      instructions.equations[equation.straightFormula()] = {};
    }
    instructions.grid = this.grid;
    instructions.islandCoordinates = this.islandCoordinates;
    _ref1 = this.rings;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      ring = _ref1[_j];
      instructions.rings.push({
        x: ring.x,
        y: ring.y
      });
    }
    _ref2 = this.equations.equationComponents;
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      component = _ref2[_k];
      instructions.fragments || (instructions.fragments = []);
      instructions.fragments.push(component.equationFragment);
    }
    return this.$('.instructions input').val(JSON.stringify(instructions));
  };

  EditorHelper.prototype.hideInstructions = function() {
    this.$('.instructions input').hide();
    return this.$('.instructions p').show();
  };

  return EditorHelper;

})();
