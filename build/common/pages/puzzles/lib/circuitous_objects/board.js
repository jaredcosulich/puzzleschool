// Generated by CoffeeScript 1.3.3
var Analyzer, Animation, Client, Wires, board, circuitousObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

board = typeof exports !== "undefined" && exports !== null ? exports : provide('./board', {});

circuitousObject = require('./object');

Wires = require('./wires').Wires;

Analyzer = require('./analyzer').Analyzer;

Client = require('../common_objects/client').Client;

Animation = require('../common_objects/animation').Animation;

board.Board = (function(_super) {

  __extends(Board, _super);

  Board.prototype.cellDimension = 32;

  function Board(_arg) {
    this.el = _arg.el;
    this.init();
  }

  Board.prototype.init = function() {
    this.cells = this.el.find('.cells');
    this.components = {};
    this.changesMade = false;
    this.width = this.cells.width();
    this.height = this.cells.height();
    this.drawGrid();
    this.initElectricity();
    return this.wires = new Wires(this);
  };

  Board.prototype.drawGrid = function() {
    var cell, column, columns, row, rows, _i, _results;
    rows = this.height / this.cellDimension;
    columns = this.width / this.cellDimension;
    _results = [];
    for (row = _i = 1; 1 <= rows ? _i <= rows : _i >= rows; row = 1 <= rows ? ++_i : --_i) {
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (column = _j = 1; 1 <= columns ? _j <= columns : _j >= columns; column = 1 <= columns ? ++_j : --_j) {
          cell = $(document.createElement('DIV'));
          cell.addClass('cell');
          cell.css({
            width: this.cellDimension - 1,
            height: this.cellDimension - 1
          });
          _results1.push(this.cells.append(cell));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Board.prototype.addChangeListener = function(listener) {
    this.changeListeners || (this.changeListeners = []);
    return this.changeListeners.push(listener);
  };

  Board.prototype.recordChange = function() {
    var _this = this;
    this.changesMade = true;
    if (this.changeListeners) {
      return $.timeout(250, function() {
        var listener, _i, _len, _ref, _results;
        _ref = _this.changeListeners;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          listener = _ref[_i];
          _results.push(listener());
        }
        return _results;
      });
    }
  };

  Board.prototype.addComponent = function(component, x, y) {
    var boardPosition, onBoardX, onBoardY, roundedBoardPosition, _ref, _ref1,
      _this = this;
    this.recordChange();
    if (!component.id) {
      component.id = this.generateId('component');
    }
    boardPosition = this.boardPosition({
      x: x,
      y: y
    });
    onBoardX = (0 < (_ref = boardPosition.x) && _ref < this.width);
    onBoardY = (0 < (_ref1 = boardPosition.y) && _ref1 < this.height);
    if (onBoardX && onBoardY) {
      this.components[component.id] = component;
      roundedBoardPosition = this.roundedCoordinates(boardPosition, component.centerOffset);
      component.positionAt(this.componentPosition(roundedBoardPosition));
      component.unbindDrag();
      component.el.bind('mousedown.perpetuate_board', function(e) {
        return _this.perpetuateDrag(e);
      });
    } else {
      return false;
    }
    return true;
  };

  Board.prototype.perpetuateDrag = function(e) {
    var c, cid, _ref;
    e.stop();
    _ref = this.components;
    for (cid in _ref) {
      c = _ref[cid];
      if (c.startDrag(e)) {
        return;
      }
    }
    return this.wires.initDraw(e);
  };

  Board.prototype.removeComponent = function(component) {
    var _ref, _ref1;
    this.recordChange();
    if ((_ref = this.components[component.id]) != null) {
      _ref.el.unbind('mousedown.perpetuate_board');
    }
    if ((_ref1 = this.components[component.id]) != null) {
      _ref1.setCurrent(0, true);
    }
    return delete this.components[component.id];
  };

  Board.prototype.roundedCoordinates = function(coords, offset) {
    var dim, halfDim, offsetCoords;
    dim = this.cellDimension;
    halfDim = 0;
    offsetCoords = {
      x: coords.x - ((offset != null ? offset.left : void 0) || (offset != null ? offset.x : void 0) || 0) + halfDim,
      y: coords.y - ((offset != null ? offset.top : void 0) || (offset != null ? offset.y : void 0) || 0) + halfDim
    };
    return {
      x: (Math.round(offsetCoords.x / dim) * dim) - halfDim,
      y: (Math.round(offsetCoords.y / dim) * dim) - halfDim
    };
  };

  Board.prototype.boardPosition = function(componentPosition) {
    var offset, position;
    offset = this.cells.offset();
    position = JSON.parse(JSON.stringify(componentPosition));
    position.x = componentPosition.x - offset.left;
    position.y = componentPosition.y - offset.top;
    return position;
  };

  Board.prototype.componentPosition = function(boardPosition) {
    var offset, position;
    offset = this.cells.offset();
    position = JSON.parse(JSON.stringify(boardPosition));
    position.x = boardPosition.x + offset.left;
    position.y = boardPosition.y + offset.top;
    return position;
  };

  Board.prototype.componentsAndWires = function() {
    var all, c, id, w, _ref, _ref1;
    all = {};
    _ref = this.components;
    for (id in _ref) {
      c = _ref[id];
      all[id] = c;
    }
    _ref1 = this.wires.all();
    for (id in _ref1) {
      w = _ref1[id];
      all[id] = w;
    }
    return all;
  };

  Board.prototype.initElectricity = function() {
    var _this = this;
    this.analyzer = new Analyzer(this);
    this.electricalAnimation = new Animation();
    return this.electricalAnimation.start({
      method: function(_arg) {
        var deltaTime, elapsed;
        deltaTime = _arg.deltaTime, elapsed = _arg.elapsed;
        return _this.moveElectricity(deltaTime, elapsed);
      }
    });
  };

  Board.prototype.runAnalysis = function() {
    if (!this.changesMade) {
      return;
    }
    this.changesMade = false;
    return this.analyzedComponentsAndWires = this.analyzer.run();
  };

  Board.prototype.moveElectricity = function(deltaTime, elapsed) {
    var c, componentId, componentInfo, id, piece, _ref, _ref1, _ref2,
      _this = this;
    if (this.movingElectricty) {
      return;
    }
    this.movingElectricty = true;
    _ref = this.componentsAndWires();
    for (id in _ref) {
      piece = _ref[id];
      piece.receivingCurrent = false;
      piece.excessiveCurrent = false;
    }
    this.runAnalysis();
    _ref1 = this.analyzedComponentsAndWires;
    for (componentId in _ref1) {
      componentInfo = _ref1[componentId];
      if (!(c = this.componentsAndWires()[componentId])) {
        continue;
      }
      c.receivingCurrent = true;
      if (typeof c.setCurrent === "function") {
        c.setCurrent(componentInfo.amps);
      }
      if (componentInfo.amps === 'infinite') {
        c.excessiveCurrent = true;
        c.el.addClass('excessive_current');
      }
    }
    this.wires.showCurrent(elapsed);
    _ref2 = this.componentsAndWires();
    for (id in _ref2) {
      piece = _ref2[id];
      if (!piece.excessiveCurrent) {
        piece.el.removeClass('excessive_current');
      }
      if (!piece.receivingCurrent) {
        if (typeof piece.setCurrent === "function") {
          piece.setCurrent(0);
        }
      }
    }
    return $.timeout(50, function() {
      return _this.movingElectricty = false;
    });
  };

  Board.prototype.clear = function() {
    var c, id, _ref, _results;
    this.wires.clear();
    _ref = this.components;
    _results = [];
    for (id in _ref) {
      c = _ref[id];
      this.removeComponent(c);
      _results.push(c.resetDrag());
    }
    return _results;
  };

  Board.prototype.clearColors = function() {
    var c, id, _ref, _results;
    _ref = this.componentsAndWires();
    _results = [];
    for (id in _ref) {
      c = _ref[id];
      _results.push(c.el.css({
        backgroundColor: null
      }));
    }
    return _results;
  };

  Board.prototype.color = function(componentIds, index) {
    var color, colors, componentId, _i, _len, _ref, _ref1, _results;
    colors = ['green', 'red', 'yellow', 'purple', 'orange', 'blue', 'brown', 'chartreuse', 'cyan', 'gray', 'khaki', 'pink', 'lavender'];
    _results = [];
    for (_i = 0, _len = componentIds.length; _i < _len; _i++) {
      componentId = componentIds[_i];
      color = colors[index];
      _results.push((_ref = this.componentsAndWires()[componentId]) != null ? (_ref1 = _ref.el) != null ? _ref1.css({
        backgroundColor: color
      }) : void 0 : void 0);
    }
    return _results;
  };

  Board.prototype.addDot = function(_arg) {
    var color, dot, el, height, width, x, y;
    el = _arg.el, x = _arg.x, y = _arg.y, width = _arg.width, height = _arg.height, color = _arg.color;
    if (!el) {
      el = this.cells;
    }
    if (!color) {
      color = 'red';
    }
    dot = $(document.createElement('DIV'));
    dot.html('&nbsp;');
    dot.css({
      position: 'absolute',
      backgroundColor: color,
      width: width || 4,
      height: height || 4,
      marginTop: height ? 0 : -2,
      marginLeft: width ? 0 : -2,
      left: x,
      top: y,
      zIndex: 9
    });
    el.append(dot);
    return console.log('dot', x, y, width, height, dot);
  };

  return Board;

})(circuitousObject.Object);
