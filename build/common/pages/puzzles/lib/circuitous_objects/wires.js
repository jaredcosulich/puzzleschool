// Generated by CoffeeScript 1.3.3
var Transformer, circuitousObject, wires,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

wires = typeof exports !== "undefined" && exports !== null ? exports : provide('./wires', {});

Transformer = require('../common_objects/transformer').Transformer;

circuitousObject = require('./object');

wires.Wires = (function(_super) {

  __extends(Wires, _super);

  Wires.prototype.resistance = 0.00001;

  Wires.prototype.electronsPerSegment = 3;

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
    this.el = this.board.el.find('.wires');
    this.electrons = this.board.el.find('.electrons');
    this.cellDimension = this.board.cellDimension;
    return this.board.el.bind('mousedown.draw_wire', function(e) {
      return _this.initDraw(e);
    });
  };

  Wires.prototype.all = function() {
    return this.info.all;
  };

  Wires.prototype.initDraw = function(e) {
    var _this = this;
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
    return this.draw(e);
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
      for (i = _i = 1, _ref = Math.floor(Math.max(xDiff, yDiff) / this.cellDimension); 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        _results.push(this.createOrErase({
          x: start.x + xDelta * i,
          y: start.y + yDelta * i
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
        segment = this.erase(this.info.start, coords);
      }
    } else {
      if (!existingSegment) {
        segment = this.create(this.info.start, coords);
      }
    }
    this.info.lastSegment = segment;
    return this.info.start = coords;
  };

  Wires.prototype.create = function(start, end) {
    var segment;
    segment = $(document.createElement('DIV'));
    segment.addClass('wire_segment');
    segment.css({
      left: Math.min(start.x, end.x),
      top: Math.min(start.y, end.y)
    });
    if (Math.abs(start.x - end.x) > Math.abs(start.y - end.y)) {
      segment.width(this.cellDimension);
      segment.addClass('horizontal');
    } else {
      segment.height(this.cellDimension);
      segment.addClass('vertical');
    }
    this.el.append(segment);
    this.recordPosition(segment, start, end);
    this.info.continuation = true;
    return segment;
  };

  Wires.prototype.erase = function(start, end) {
    var segment;
    if (!(segment = this.find(start, end))) {
      return;
    }
    this.clearElectrons(segment);
    segment.el.remove();
    this.recordPosition(null, start, end);
    if (!this.info.continuation) {
      this.info.erasing = true;
    }
    return segment.el;
  };

  Wires.prototype.recordPosition = function(element, start, end) {
    var node1, node2, segment, _base, _base1, _ref, _ref1;
    this.board.changesMade = true;
    node1 = "" + start.x + ":" + start.y;
    node2 = "" + end.x + ":" + end.y;
    if (element) {
      segment = {
        id: "wire" + node1 + node2,
        el: element,
        horizontal: element.hasClass('horizontal'),
        resistance: this.resistance,
        nodes: [start, end]
      };
      segment.setCurrent = function(current) {
        return segment.current = current;
      };
      this.info.all[segment.id] = segment;
      (_base = this.info.nodes)[node1] || (_base[node1] = {});
      this.info.nodes[node1][node2] = segment;
      (_base1 = this.info.nodes)[node2] || (_base1[node2] = {});
      return this.info.nodes[node2][node1] = segment;
    } else {
      segment = this.info.nodes[node1][node2];
      if (segment) {
        delete this.info.all[segment.id];
      }
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

  Wires.prototype.initElectrons = function(segment) {
    var electronsSegment;
    if (segment.electrons) {
      return;
    }
    electronsSegment = $(document.createElement('DIV'));
    electronsSegment.addClass('electrons_segment');
    electronsSegment.css({
      top: segment.el.css('top'),
      left: segment.el.css('left')
    });
    this.electrons.append(electronsSegment);
    return segment.electrons = {
      el: electronsSegment,
      transformer: new Transformer(electronsSegment)
    };
  };

  Wires.prototype.moveElectrons = function(segment, elapsedTime) {
    var height, pointedDown, pointedRight, totalMovement, width, x, y;
    totalMovement = (elapsedTime / 100) * Math.abs(segment.current);
    x = y = 0;
    if (segment.horizontal) {
      pointedRight = width = segment.el.width();
      x = totalMovement % ((width % this.cellDimension) * 2);
      if (segment.electrons.el.hasClass('left')) {
        x = x * -1;
      }
    } else {
      pointedDown = segment.nodes[0].y < segment.nodes[1].y;
      height = segment.el.height();
      y = totalMovement % ((height % this.cellDimension) * 2);
      if (segment.electrons.el.hasClass('up')) {
        y = y * -1;
      }
    }
    return segment.electrons.transformer.translate(x, y);
  };

  Wires.prototype.clearElectrons = function(segment) {
    if (!segment.electrons) {
      return;
    }
    segment.electrons.el.remove();
    delete segment.reverse;
    return delete segment.electrons;
  };

  Wires.prototype.setDirection = function(segment) {
    var pointedDown, pointedRight, reverse;
    if (segment.reverse === (reverse = (segment.direction * segment.current) < 1)) {
      return;
    }
    segment.reverse = reverse;
    segment.electrons.el[0].className = 'electrons_segment';
    if (segment.horizontal) {
      pointedRight = segment.nodes[0].x < segment.nodes[1].x;
      if (segment.reverse) {
        pointedRight = !pointedRight;
      }
      segment.electrons.el.addClass(pointedRight ? 'right' : 'left');
      return segment.electrons.el.width(this.cellDimension);
    } else {
      pointedDown = segment.nodes[0].y < segment.nodes[1].y;
      if (segment.reverse) {
        pointedDown = !pointedDown;
      }
      segment.electrons.el.addClass(pointedDown ? 'down' : 'up');
      return segment.electrons.el.height(this.cellDimension);
    }
  };

  Wires.prototype.showCurrent = function(elapsedTime) {
    var segment, segmentId, _ref, _results;
    _ref = this.info.all;
    _results = [];
    for (segmentId in _ref) {
      segment = _ref[segmentId];
      if (segment.current) {
        this.initElectrons(segment);
        this.setDirection(segment);
        _results.push(this.moveElectrons(segment, elapsedTime));
      } else {
        _results.push(this.clearElectrons(segment));
      }
    }
    return _results;
  };

  return Wires;

})(circuitousObject.Object);

;

