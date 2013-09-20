// Generated by CoffeeScript 1.3.3
var Transformer, circuitousObject, wires,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

wires = typeof exports !== "undefined" && exports !== null ? exports : provide('./wires', {});

Transformer = require('../common_objects/transformer').Transformer;

circuitousObject = require('./object');

wires.Wires = (function(_super) {

  __extends(Wires, _super);

  Wires.prototype.edgeBuffer = 6;

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
      nodes: {},
      node: {}
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

  Wires.prototype.clear = function() {
    var segment, segmentId, _ref, _results;
    _ref = this.all();
    _results = [];
    for (segmentId in _ref) {
      segment = _ref[segmentId];
      _results.push(this.eraseSegment(segment));
    }
    return _results;
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

  Wires.prototype.roundedCoords = function(coords) {
    return this.board.roundedCoordinates({
      x: coords.x,
      y: coords.y
    }, this.el.offset());
  };

  Wires.prototype.draw = function(e) {
    var coords, direction, existing, extended, i, roundedCoords, roundedStart, start, xDelta, xDiff, yDelta, yDiff, _i, _ref;
    coords = {
      x: Client.x(e),
      y: Client.y(e)
    };
    if (start = this.info.start) {
      roundedStart = this.roundedCoords(start);
      roundedCoords = this.roundedCoords(coords);
      xDiff = Math.abs(start.x - coords.x);
      yDiff = Math.abs(start.y - coords.y);
      if (xDiff === 0 && yDiff === 0) {
        return;
      }
      if (roundedStart.x === roundedCoords.x && roundedStart.y === roundedCoords.y) {
        if (xDiff > yDiff) {
          direction = start.x > coords.x ? -1 : 1;
          extended = {
            x: this.info.start.x + (this.cellDimension * direction),
            y: this.info.start.y
          };
        } else {
          direction = start.y > coords.y ? -1 : 1;
          extended = {
            x: this.info.start.x,
            y: this.info.start.y + (this.cellDimension * direction)
          };
        }
        if ((existing = this.find(roundedStart, this.roundedCoords(extended)))) {
          this.createOrErase(extended);
          this.info.start = coords;
        }
        return;
      }
      xDelta = yDelta = 0;
      if (xDiff > yDiff) {
        xDelta = this.cellDimension * (start.x > coords.x ? -1 : 1);
      } else {
        yDelta = this.cellDimension * (start.y > coords.y ? -1 : 1);
      }
      for (i = _i = 1, _ref = Math.ceil(Math.max(xDiff, yDiff) / this.cellDimension); 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        this.createOrErase({
          x: start.x + xDelta * i,
          y: start.y + yDelta * i
        });
      }
      return this.info.continuation = true;
    } else {
      return this.info.start = coords;
    }
  };

  Wires.prototype.createOrErase = function(coords) {
    var existingSegment, roundedEnd, roundedStart, segment;
    roundedStart = this.roundedCoords(this.info.start);
    roundedEnd = this.roundedCoords(coords);
    existingSegment = this.find(roundedStart, roundedEnd);
    if (this.info.erasing || (existingSegment && (!this.info.continuation || (existingSegment === this.info.lastSegment)))) {
      if (existingSegment) {
        segment = this.erase(roundedStart, roundedEnd);
      }
    } else {
      if (!existingSegment) {
        segment = this.create(roundedStart, roundedEnd);
      }
    }
    this.info.lastSegment = segment;
    return this.info.start = {
      x: roundedEnd.x + this.el.offset().left,
      y: roundedEnd.y + this.el.offset().top
    };
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
      segment.css({
        left: Math.min(start.x, end.x) + this.edgeBuffer
      });
      segment.width(this.cellDimension - (this.edgeBuffer * 2));
      segment.addClass('horizontal');
    } else {
      segment.css({
        top: Math.min(start.y, end.y) + this.edgeBuffer
      });
      segment.height(this.cellDimension - (this.edgeBuffer * 2));
      segment.addClass('vertical');
    }
    this.el.append(segment);
    this.recordPosition(segment, start, end);
    return segment;
  };

  Wires.prototype.erase = function(start, end) {
    var segment;
    if (!(segment = this.find(start, end))) {
      return;
    }
    if (!this.info.continuation) {
      this.info.erasing = true;
    }
    return this.eraseSegment(segment);
  };

  Wires.prototype.eraseSegment = function(segment) {
    this.clearElectrons(segment);
    segment.el.remove();
    this.recordPosition(null, segment.nodes[0], segment.nodes[1]);
    return segment.el;
  };

  Wires.prototype.labelSegments = function(node) {
    var direction, directions, i, info, info2, oppositeDirection, segment, segmentId, segmentIds, _i, _j, _k, _len, _len1, _len2, _results;
    if (!(segmentIds = this.info.node[this.nodeId(node)])) {
      return;
    }
    directions = [];
    for (segmentId in segmentIds) {
      segment = this.info.all[segmentId];
      direction = this.segmentDirection(segment, node);
      this.removeDirectionLabel(segment, direction);
      if (Object.keys(segmentIds).length === 4) {
        segment.el.addClass("" + direction + "_all");
      } else {
        directions.push({
          direction: direction,
          segment: segment
        });
      }
    }
    if (Object.keys(segmentIds).length === 2) {
      for (_i = 0, _len = directions.length; _i < _len; _i++) {
        info = directions[_i];
        for (_j = 0, _len1 = directions.length; _j < _len1; _j++) {
          info2 = directions[_j];
          if (info2.segment.id !== info.segment.id) {
            info2.segment.el.addClass("" + info2.direction + "_" + info.direction);
          }
        }
      }
    }
    if (Object.keys(segmentIds).length === 3) {
      _results = [];
      for (_k = 0, _len2 = directions.length; _k < _len2; _k++) {
        info = directions[_k];
        if (info.segment.horizontal) {
          oppositeDirection = ((function() {
            var _l, _len3, _results1;
            _results1 = [];
            for (_l = 0, _len3 = directions.length; _l < _len3; _l++) {
              i = directions[_l];
              if (i.direction === (info.direction === 'left' ? 'right' : 'left')) {
                _results1.push(i);
              }
            }
            return _results1;
          })())[0];
        } else {
          oppositeDirection = ((function() {
            var _l, _len3, _results1;
            _results1 = [];
            for (_l = 0, _len3 = directions.length; _l < _len3; _l++) {
              i = directions[_l];
              if (i.direction === (info.direction === 'up' ? 'down' : 'up')) {
                _results1.push(i);
              }
            }
            return _results1;
          })())[0];
        }
        if (oppositeDirection) {
          _results.push(info.segment.el.addClass("" + info.direction + "_blank_t"));
        } else {
          _results.push(info.segment.el.addClass("" + info.direction + "_t"));
        }
      }
      return _results;
    }
  };

  Wires.prototype.otherNode = function(segment, node) {
    if (segment.nodes[0].x === node.x && segment.nodes[0].y === node.y) {
      return segment.nodes[1];
    } else {
      return segment.nodes[0];
    }
  };

  Wires.prototype.segmentDirection = function(segment, node) {
    var otherNode;
    otherNode = this.otherNode(segment, node);
    if (segment.horizontal) {
      if (node.x > otherNode.x) {
        return 'right';
      } else {
        return 'left';
      }
    } else {
      if (node.y > otherNode.y) {
        return 'down';
      } else {
        return 'up';
      }
    }
  };

  Wires.prototype.removeDirectionLabel = function(segment, direction) {
    var className, _i, _len, _ref, _results;
    _ref = segment.el[0].className.split(/\s/);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      className = _ref[_i];
      if (className.match("" + direction + "_")) {
        _results.push(segment.el.removeClass(className));
      }
    }
    return _results;
  };

  Wires.prototype.recordPosition = function(element, start, end) {
    var node1, node2, segment, _base, _base1, _base2, _base3, _ref, _ref1;
    this.board.recordChange();
    node1 = this.nodeId(start);
    node2 = this.nodeId(end);
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
      (_base = this.info.node)[node1] || (_base[node1] = {});
      this.info.node[node1][segment.id] = true;
      (_base1 = this.info.node)[node2] || (_base1[node2] = {});
      this.info.node[node2][segment.id] = true;
      (_base2 = this.info.nodes)[node1] || (_base2[node1] = {});
      this.info.nodes[node1][node2] = segment;
      (_base3 = this.info.nodes)[node2] || (_base3[node2] = {});
      this.info.nodes[node2][node1] = segment;
    } else {
      segment = this.info.nodes[node1][node2];
      if (segment) {
        delete this.info.all[segment.id];
      }
      delete this.info.node[node1][segment.id];
      delete this.info.node[node2][segment.id];
      if ((_ref = this.info.nodes[node1]) != null) {
        delete _ref[node2];
      }
      if ((_ref1 = this.info.nodes[node2]) != null) {
        delete _ref1[node1];
      }
    }
    this.labelSegments(start);
    return this.labelSegments(end);
  };

  Wires.prototype.nodeId = function(node) {
    return "" + node.x + ":" + node.y;
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
    if (segment.horizontal) {
      electronsSegment.css({
        left: parseInt(segment.el.css('left')) - this.edgeBuffer
      });
    } else {
      electronsSegment.css({
        top: parseInt(segment.el.css('top')) - this.edgeBuffer
      });
    }
    this.electrons.append(electronsSegment);
    return segment.electrons = {
      el: electronsSegment,
      transformer: new Transformer(electronsSegment)
    };
  };

  Wires.prototype.moveElectrons = function(segment, elapsedTime) {
    var height, totalMovement, width, x, y;
    totalMovement = (elapsedTime / 100) * Math.abs(segment.current);
    x = y = 0;
    if (segment.horizontal) {
      width = segment.el.width() + (this.edgeBuffer * 2);
      x = totalMovement % ((width % this.cellDimension) * 2);
      if (segment.electrons.el.hasClass('left')) {
        x = x * -1;
      }
    } else {
      height = segment.el.height() + (this.edgeBuffer * 2);
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
    if (segment.reverse === (reverse = (segment.direction * segment.current) < 0)) {
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

