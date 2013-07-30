// Generated by CoffeeScript 1.3.3
var circuitousObject, wires,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

wires = typeof exports !== "undefined" && exports !== null ? exports : provide('./wires', {});

circuitousObject = require('./object');

wires.Wires = (function(_super) {

  __extends(Wires, _super);

  function Wires(board) {
    this.board = board;
    this.init();
  }

  Wires.prototype.init = function() {
    var _this = this;
    this.info = {
      all: {},
      positions: {},
      nodes: {}
    };
    this.el = this.board.el;
    this.cellDimension = this.board.cellDimension;
    return this.el.bind('mousedown.draw_wire', function(e) {
      $(document.body).one('mouseup.draw_wire', function() {
        $(document.body).unbind('mousemove.draw_wire');
        delete _this.info.start;
        delete _this.info.continuation;
        delete _this.info.erasing;
        return delete _this.info.lastSegment;
      });
      $(document.body).bind('mousemove.draw_wire', function(e) {
        return _this.draw(e);
      });
      return _this.draw(e);
    });
  };

  Wires.prototype.all = function() {
    return this.info.all;
  };

  Wires.prototype.draw = function(e) {
    var coords, i, start, xDelta, xDiff, yDelta, yDiff, _i, _ref, _results;
    coords = this.board.roundedCoordinates({
      x: Client.x(e),
      y: Client.y(e)
    }, this.el.offset());
    if (start = this.info.start) {
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
        _results.push(this.createOrErase({
          x: start.x + xDelta,
          y: start.y + yDelta
        }));
      }
      return _results;
    } else {
      return this.info.start = coords;
    }
  };

  Wires.prototype.createOrErase = function(coords) {
    var existingSegment, segment;
    existingSegment = this.find(this.info.start, coords);
    if (this.info.erasing || (existingSegment && (!this.info.continuation || (existingSegment === this.info.lastSegment)))) {
      if (existingSegment) {
        segment = this.erase(coords);
      }
    } else {
      if (!existingSegment) {
        segment = this.create(coords);
      }
    }
    this.info.lastSegment = segment;
    return this.info.start = coords;
  };

  Wires.prototype.create = function(coords) {
    var segment;
    segment = $(document.createElement('DIV'));
    segment.addClass('wire_segment');
    segment.css({
      left: Math.min(this.info.start.x, coords.x),
      top: Math.min(this.info.start.y, coords.y)
    });
    if (Math.abs(this.info.start.x - coords.x) > Math.abs(this.info.start.y - coords.y)) {
      segment.width(this.cellDimension);
      segment.addClass('horizontal');
    } else {
      segment.height(this.cellDimension);
      segment.addClass('vertical');
    }
    this.el.append(segment);
    this.recordPosition(segment, this.info.start, coords);
    this.info.continuation = true;
    return segment;
  };

  Wires.prototype.erase = function(coords) {
    var segment;
    if (!(segment = this.find(this.info.start, coords))) {
      return;
    }
    segment.el.remove();
    this.recordPosition(null, this.info.start, coords);
    if (!this.info.continuation) {
      this.info.erasing = true;
    }
    return segment.el;
  };

  Wires.prototype.recordPosition = function(element, start, end) {
    var node1, node2, segment, _base, _base1, _ref, _ref1;
    node1 = "" + start.x + ":" + start.y;
    node2 = "" + end.x + ":" + end.y;
    if (element) {
      segment = {
        id: "segment" + node1 + node2,
        el: element,
        nodes: [start, end]
      };
      this.info.all[segment.id] = segment;
      (_base = this.info.nodes)[node1] || (_base[node1] = {});
      this.info.nodes[node1][node2] = segment;
      (_base1 = this.info.nodes)[node2] || (_base1[node2] = {});
      return this.info.nodes[node2][node1] = segment;
    } else {
      if ((_ref = this.info.nodes[node1]) != null) {
        delete _ref[node2];
      }
      return (_ref1 = this.info.nodes[node2]) != null ? delete _ref1[node1] : void 0;
    }
  };

  Wires.prototype.find = function(start, end) {
    var endPoint, node1, node2, segment, _ref, _ref1, _ref2, _results;
    if (end == null) {
      end = null;
    }
    node1 = "" + start.x + ":" + start.y;
    if (end) {
      node2 = "" + end.x + ":" + end.y;
      return ((_ref = this.info.nodes[node1]) != null ? _ref[node2] : void 0) || ((_ref1 = this.info.nodes[node2]) != null ? _ref1[node1] : void 0);
    } else {
      _ref2 = this.info.nodes[node1];
      _results = [];
      for (endPoint in _ref2) {
        segment = _ref2[endPoint];
        _results.push(segment);
      }
      return _results;
    }
  };

  return Wires;

})(circuitousObject.Object);

;

