// Generated by CoffeeScript 1.3.3
var Animation, Client, board, circuitousObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

board = typeof exports !== "undefined" && exports !== null ? exports : provide('./board', {});

circuitousObject = require('./object');

Client = require('../common_objects/client').Client;

Animation = require('../common_objects/animation').Animation;

board.Board = (function(_super) {

  __extends(Board, _super);

  Board.prototype.cellDimension = 32;

  function Board(_arg) {
    this.el = _arg.el;
    this.circuitInfo = {};
    this.components = {};
    this.init();
  }

  Board.prototype.init = function() {
    this.width = this.el.width();
    this.height = this.el.height();
    this.drawGrid();
    this.initWire();
    return this.initElectricity();
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
          _results1.push(this.el.append(cell));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  Board.prototype.componentsAndWires = function() {
    var all, component, id, nodes, wireSegment, xCoords, yCoords, _ref, _ref1;
    all = {};
    _ref = this.components;
    for (id in _ref) {
      component = _ref[id];
      all[id] = component;
    }
    _ref1 = this.wireInfo.positions;
    for (yCoords in _ref1) {
      nodes = _ref1[yCoords];
      for (xCoords in nodes) {
        wireSegment = nodes[xCoords];
        all[wireSegment.id] = wireSegment;
      }
    }
    return all;
  };

  Board.prototype.addComponent = function(component, x, y) {
    var boardPosition, offset, onBoardX, onBoardY, roundedBoardPosition, _ref, _ref1;
    if (!component.id) {
      component.id = this.generateId();
    }
    offset = this.el.offset();
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
    } else {
      return false;
    }
    return true;
  };

  Board.prototype.removeComponent = function(component) {
    var _ref;
    if ((_ref = this.components[component.id]) != null) {
      _ref.setCurrent(0);
    }
    return delete this.components[component.id];
  };

  Board.prototype.initWire = function() {
    var _this = this;
    this.wireInfo = {
      positions: {},
      nodes: {}
    };
    return this.el.bind('mousedown.draw_wire', function(e) {
      $(document.body).one('mouseup.draw_wire', function() {
        $(document.body).unbind('mousemove.draw_wire');
        delete _this.wireInfo.start;
        delete _this.wireInfo.continuation;
        delete _this.wireInfo.erasing;
        return delete _this.wireInfo.lastSegment;
      });
      $(document.body).bind('mousemove.draw_wire', function(e) {
        return _this.drawWire(e);
      });
      return _this.drawWire(e);
    });
  };

  Board.prototype.roundedCoordinates = function(coords, offset) {
    var halfDim, offsetCoords;
    halfDim = this.cellDimension / 2;
    offsetCoords = {
      x: coords.x - ((offset != null ? offset.left : void 0) || (offset != null ? offset.x : void 0) || 0) + halfDim,
      y: coords.y - ((offset != null ? offset.top : void 0) || (offset != null ? offset.y : void 0) || 0) + halfDim
    };
    return {
      x: (Math.round(offsetCoords.x / this.cellDimension) * this.cellDimension) - halfDim,
      y: (Math.round(offsetCoords.y / this.cellDimension) * this.cellDimension) - halfDim
    };
  };

  Board.prototype.addDot = function(_arg) {
    var color, dot, x, y;
    x = _arg.x, y = _arg.y, color = _arg.color;
    dot = $(document.createElement('DIV'));
    dot.html('&nbsp;');
    dot.css({
      position: 'absolute',
      backgroundColor: color || 'red',
      width: 4,
      height: 4,
      marginTop: -2,
      marginLeft: -2,
      left: x,
      top: y,
      zIndex: 9
    });
    this.el.append(dot);
    return console.log('dot', x, y, dot);
  };

  Board.prototype.recordSegmentPosition = function(element, start, end) {
    var node1, node2, segment, xCoords, yCoords, _base, _base1, _base2;
    xCoords = [start.x, end.x].sort().join(':');
    yCoords = [start.y, end.y].sort().join(':');
    node1 = "" + start.x + ":" + start.y;
    node2 = "" + end.x + ":" + end.y;
    if (element) {
      segment = {
        id: "segment" + node1 + node2,
        el: element,
        nodes: [start, end]
      };
      xCoords = [start.x, end.x].sort().join(':');
      yCoords = [start.y, end.y].sort().join(':');
      (_base = this.wireInfo.positions)[xCoords] || (_base[xCoords] = {});
      this.wireInfo.positions[xCoords][yCoords] = segment;
      (_base1 = this.wireInfo.nodes)[node1] || (_base1[node1] = {});
      this.wireInfo.nodes[node1][node2] = segment;
      (_base2 = this.wireInfo.nodes)[node2] || (_base2[node2] = {});
      return this.wireInfo.nodes[node2][node1] = segment;
    } else {
      delete this.wireInfo.positions[xCoords][yCoords];
      delete this.wireInfo.nodes[node1][node2];
      return delete this.wireInfo.nodes[node2][node1];
    }
  };

  Board.prototype.getSegmentPosition = function(start, end) {
    var _ref;
    return (_ref = this.wireInfo.positions[[start.x, end.x].sort().join(':')]) != null ? _ref[[start.y, end.y].sort().join(':')] : void 0;
  };

  Board.prototype.getSegmentsAt = function(node) {
    var endPoint, segment, _ref, _results;
    _ref = this.wireInfo.nodes["" + node.x + ":" + node.y];
    _results = [];
    for (endPoint in _ref) {
      segment = _ref[endPoint];
      _results.push(segment);
    }
    return _results;
  };

  Board.prototype.drawWire = function(e) {
    var coords, i, start, xDelta, xDiff, yDelta, yDiff, _i, _ref, _results;
    coords = this.roundedCoordinates({
      x: Client.x(e),
      y: Client.y(e)
    }, this.el.offset());
    if (start = this.wireInfo.start) {
      xDiff = Math.abs(start.x - coords.x);
      yDiff = Math.abs(start.y - coords.y);
      if (xDiff < this.cellDimension && yDiff < this.cellDimension) {
        return;
      }
      xDelta = yDelta = 0;
      if (xDiff > yDiff) {
        xDelta = this.cellDimension * (start.x > coords.x ? -1 : 1);
      } else {
        yDelta = this.cellDimension * (start.y > coords.y ? -1 : 1);
      }
      _results = [];
      for (i = _i = 0, _ref = Math.floor(Math.max(xDiff, yDiff) / this.cellDimension); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push(this.createOrEraseWireSegment({
          x: start.x + xDelta,
          y: start.y + yDelta
        }));
      }
      return _results;
    } else {
      return this.wireInfo.start = coords;
    }
  };

  Board.prototype.createOrEraseWireSegment = function(coords) {
    var existingSegment, segment;
    existingSegment = this.getSegmentPosition(this.wireInfo.start, coords);
    if (this.wireInfo.erasing || (existingSegment && (!this.wireInfo.continuation || (existingSegment === this.wireInfo.lastSegment)))) {
      if (existingSegment) {
        segment = this.eraseWireSegment(coords);
      }
    } else {
      if (!existingSegment) {
        segment = this.createWireSegment(coords);
      }
    }
    this.wireInfo.lastSegment = segment;
    return this.wireInfo.start = coords;
  };

  Board.prototype.createWireSegment = function(coords) {
    var segment;
    segment = $(document.createElement('DIV'));
    segment.addClass('wire_segment');
    segment.css({
      left: Math.min(this.wireInfo.start.x, coords.x),
      top: Math.min(this.wireInfo.start.y, coords.y)
    });
    if (Math.abs(this.wireInfo.start.x - coords.x) > Math.abs(this.wireInfo.start.y - coords.y)) {
      segment.width(this.cellDimension);
      segment.addClass('horizontal');
    } else {
      segment.height(this.cellDimension);
      segment.addClass('vertical');
    }
    this.el.append(segment);
    this.recordSegmentPosition(segment, this.wireInfo.start, coords);
    this.wireInfo.continuation = true;
    return segment;
  };

  Board.prototype.eraseWireSegment = function(coords) {
    var segment;
    if (!(segment = this.getSegmentPosition(this.wireInfo.start, coords))) {
      return;
    }
    segment.el.remove();
    this.recordSegmentPosition(null, this.wireInfo.start, coords);
    if (!this.wireInfo.continuation) {
      this.wireInfo.erasing = true;
    }
    return segment.el;
  };

  Board.prototype.initElectricity = function() {
    var _this = this;
    this.electricalAnimation = new Animation();
    return this.electricalAnimation.start({
      method: function(_arg) {
        var deltaTime, elapsed;
        deltaTime = _arg.deltaTime, elapsed = _arg.elapsed;
        return _this.moveElectricity(deltaTime, elapsed);
      }
    });
  };

  Board.prototype.moveElectricity = function(deltaTime, elapsed) {
    var amps, c, circuit, component, id, negativeTerminal, piece, _i, _len, _ref, _ref1, _ref2, _ref3, _results;
    this.slowTime = (this.slowTime || 0) + deltaTime;
    if (!(this.slowTime > 5000)) {
      return;
    }
    this.slowTime -= 5000;
    _ref = this.componentsAndWires();
    for (id in _ref) {
      piece = _ref[id];
      piece.receivingCurrent = false;
      piece.excessiveCurrent = false;
    }
    _ref1 = this.components;
    for (id in _ref1) {
      component = _ref1[id];
      if (component.powerSource) {
        _ref2 = component.currentNodes('negative');
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          negativeTerminal = _ref2[_i];
          if ((circuit = this.traceConnections(this.boardPosition(negativeTerminal), component)).complete) {
            if (circuit.totalResistance > 0) {
              amps = component.voltage / circuit.totalResistance;
              for (id in circuit.components) {
                c = this.componentsAndWires()[id];
                c.receivingCurrent = true;
                if (typeof c.setCurrent === "function") {
                  c.setCurrent(amps);
                }
              }
              console.log('complete', circuit.totalResistance, amps);
            } else {
              amps = 'infinite';
              for (id in circuit.components) {
                c = this.componentsAndWires()[id];
                c.excessiveCurrent = true;
                c.el.addClass('excessive_current');
              }
              console.log('complete', circuit.totalResistance, amps);
            }
          } else {
            console.log('incomplete');
          }
        }
      }
    }
    _ref3 = this.componentsAndWires();
    _results = [];
    for (id in _ref3) {
      piece = _ref3[id];
      if (!piece.excessiveCurrent) {
        piece.el.removeClass('excessive_current');
      }
      if (!piece.receivingCurrent) {
        _results.push(typeof piece.setCurrent === "function" ? piece.setCurrent(0) : void 0);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Board.prototype.boardPosition = function(componentPosition) {
    var offset, position;
    offset = this.el.offset();
    position = JSON.parse(JSON.stringify(componentPosition));
    position.x = componentPosition.x - offset.left + 1;
    position.y = componentPosition.y - offset.top + 1;
    return position;
  };

  Board.prototype.componentPosition = function(boardPosition) {
    var offset, position;
    offset = this.el.offset();
    position = JSON.parse(JSON.stringify(boardPosition));
    position.x = boardPosition.x + offset.left - 1;
    position.y = boardPosition.y + offset.top - 1;
    return position;
  };

  Board.prototype.compareNodes = function(node1, node2) {
    return node1.x === node2.x && node1.y === node2.y;
  };

  Board.prototype.generateId = function() {
    return "" + (new Date().getTime()) + (Math.random());
  };

  Board.prototype.newCircuit = function(parent) {
    var circuit;
    circuit = {
      parentId: parent != null ? parent.id : void 0,
      totalResistance: 0,
      components: {},
      id: this.generateId()
    };
    if (parent) {
      parent.parallel || (parent.parallel = {});
      parent.parallel[circuit.id] = circuit;
    }
    this.circuitInfo[circuit.id] = circuit;
    return circuit;
  };

  Board.prototype.addToCircuit = function(circuit, component) {
    circuit.totalResistance += component.resistance || 0;
    return circuit.components[component.id] = true;
  };

  Board.prototype.traceConnections = function(node, component, circuit) {
    var connection, connections, parallelCircuit, totalParallelResistance, _i, _len;
    if (circuit == null) {
      circuit = this.newCircuit();
    }
    if (node.negative) {
      if (circuit.powerSourceId === component.id) {
        circuit.complete = true;
        return circuit;
      } else if (!circuit.powerSourceId) {
        circuit.powerSourceId = component.id;
      }
    }
    this.addToCircuit(circuit, component);
    if ((connections = this.findConnections(node, component, circuit)).length === 1) {
      return this.traceConnections(connections[0].otherNode, connections[0].component, circuit);
    } else if (connections.length > 1) {
      totalParallelResistance = 0;
      for (_i = 0, _len = connections.length; _i < _len; _i++) {
        connection = connections[_i];
        connection.otherNode.negative = true;
        parallelCircuit = this.traceConnections(connection.otherNode, connection.component, this.newCircuit(circuit));
        totalParallelResistance += 1.0 / parallelCircuit.totalResistance;
      }
      circuit.totalResistance += 1.0 / totalParallelResistance;
    } else {
      circuit.complete = false;
    }
    return circuit;
  };

  Board.prototype.findConnections = function(node, component, circuit) {
    var c, connections, id, n, nodes, otherNode, segment, _i, _j, _len, _len1, _ref, _ref1, _ref2;
    connections = [];
    _ref = this.components;
    for (id in _ref) {
      c = _ref[id];
      if (c !== component && (id === circuit.powerSourceId || !circuit.components[id])) {
        _ref1 = (nodes = c.currentNodes());
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          n = _ref1[_i];
          if (!(this.compareNodes(this.boardPosition(n), node))) {
            continue;
          }
          if (nodes.length === 1) {
            otherNode = n;
          } else {
            otherNode = ((function() {
              var _j, _len1, _results;
              _results = [];
              for (_j = 0, _len1 = nodes.length; _j < _len1; _j++) {
                otherNode = nodes[_j];
                if (!this.compareNodes(this.boardPosition(n), otherNode)) {
                  _results.push(otherNode);
                }
              }
              return _results;
            }).call(this))[0];
          }
          connections.push({
            component: c,
            otherNode: this.boardPosition(otherNode)
          });
        }
      }
    }
    _ref2 = this.getSegmentsAt(node);
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      segment = _ref2[_j];
      if (!(!circuit.components[segment.id])) {
        continue;
      }
      otherNode = ((function() {
        var _k, _len2, _ref3, _results;
        _ref3 = segment.nodes;
        _results = [];
        for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
          n = _ref3[_k];
          if (!this.compareNodes(n, node)) {
            _results.push(n);
          }
        }
        return _results;
      }).call(this))[0];
      connections.push({
        component: segment,
        otherNode: otherNode
      });
    }
    return connections;
  };

  return Board;

})(circuitousObject.Object);
