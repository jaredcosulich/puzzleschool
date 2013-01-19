// Generated by CoffeeScript 1.3.3
var neurobehavObject, oscilloscope,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

oscilloscope = typeof exports !== "undefined" && exports !== null ? exports : provide('./oscilloscope', {});

neurobehavObject = require('./object');

oscilloscope.Oscilloscope = (function(_super) {

  __extends(Oscilloscope, _super);

  Oscilloscope.prototype.objectType = 'oscilloscope';

  Oscilloscope.prototype.objectName = 'Oscilloscope';

  Oscilloscope.prototype.width = 180;

  Oscilloscope.prototype.height = 96;

  Oscilloscope.prototype.connectionLength = 60;

  Oscilloscope.prototype.screenWidth = 150;

  Oscilloscope.prototype.screenHeight = 90;

  Oscilloscope.prototype.centerOffset = 75;

  Oscilloscope.prototype.screenColor = '#64A539';

  Oscilloscope.prototype.xDelta = 1;

  function Oscilloscope(_arg) {
    var _this = this;
    this.board = _arg.board;
    Oscilloscope.__super__.constructor.apply(this, arguments);
    this.draw();
    this.drawThreshold();
    this.initImage();
    setInterval((function() {
      return _this.fire();
    }), this.periodicity);
  }

  Oscilloscope.prototype.init = function() {
    this.image = this.paper.set();
    this.scale = this.screenHeight / 2;
    return this.xAxis = this.screenHeight - 12;
  };

  Oscilloscope.prototype.draw = function() {
    var connection, connectionSegment, endX, endY, graph, innerNeedle, slope, startingX, startingY;
    graph = this.paper.rect(this.position.left, this.position.top, this.screenWidth + 12, this.screenHeight + 12, 6);
    graph.attr({
      fill: '#ACACAD'
    });
    this.image.push(graph);
    startingX = graph.attr('x');
    startingY = graph.attr('y') + (graph.attr('height') / 2);
    this.screen = this.paper.rect(graph.attr('x') + 6, graph.attr('y') + 6, this.screenWidth, this.screenHeight, 6);
    this.screen.attr({
      fill: 'black'
    });
    this.image.push(this.screen);
    connectionSegment = this.connectionLength / 10;
    slope = ((this.position.top + this.height) - startingY) / ((startingX - (connectionSegment * 4)) - (startingX - this.connectionLength));
    endX = startingX - (connectionSegment * 5);
    endY = startingY + (slope * connectionSegment);
    connection = this.paper.path("M" + startingX + "," + startingY + "\nL" + (startingX - (connectionSegment * 4)) + "," + startingY + "\nL" + endX + "," + endY);
    connection.attr({
      'stroke-width': 2
    });
    this.image.push(connection);
    this.needle = this.paper.path("M" + (endX - 5) + "," + (endY - (5 * (1 / slope))) + "\nL" + (startingX - this.connectionLength) + ", " + (this.position.top + this.height) + "\nL" + (endX + 5) + "," + (endY + (5 * (1 / slope))) + "\nL" + (endX - 5) + "," + (endY - (5 * (1 / slope))));
    this.needle.attr({
      fill: 'white'
    });
    this.image.push(this.needle);
    innerNeedle = this.paper.path("M" + (endX - 3) + "," + (endY - (3 * (1 / slope))) + "\nL" + (startingX - this.connectionLength) + ", " + (this.position.top + this.height) + "\nL" + (endX + 3) + "," + (endY + (3 * (1 / slope))));
    innerNeedle.attr({
      stroke: '#ccc'
    });
    this.image.push(innerNeedle);
    return Oscilloscope.__super__.draw.call(this);
  };

  Oscilloscope.prototype.initImage = function() {
    var glow, lastDX, lastDY, onDrag, onEnd, onStart,
      _this = this;
    this.image.properties = {
      description: this.description
    };
    this.image.attr({
      cursor: 'move'
    });
    glow = this.initMoveGlow(this.image);
    lastDX = 0;
    lastDY = 0;
    onDrag = function(dX, dY) {
      if (_this.neuron) {
        _this.unattach();
      }
      _this.image.toFront();
      _this.image.transform("...T" + (dX - lastDX) + "," + (dY - lastDY));
      glow.transform("...T" + (dX - lastDX) + "," + (dY - lastDY));
      lastDX = dX;
      return lastDY = dY;
    };
    onStart = function() {
      return glow.show();
    };
    onEnd = function() {
      var bbox, element, _i, _len, _ref, _results;
      glow.attr({
        opacity: 0
      });
      lastDX = 0;
      lastDY = 0;
      bbox = _this.needle.getBBox();
      _ref = _this.paper.getElementsByPoint(bbox.x, bbox.y + bbox.height);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        if (element.objectType === 'neuron') {
          _results.push(_this.attachTo(element.object));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    this.image.drag(onDrag, onStart, onEnd);
    return glow.drag(onDrag, onStart, onEnd);
  };

  Oscilloscope.prototype.screenPath = function(path) {
    var border, line, set;
    set = this.paper.set();
    border = this.paper.path(path);
    line = this.paper.path(path);
    border.attr({
      stroke: this.screenColor,
      'stroke-opacity': 0.5,
      'stroke-width': 3
    });
    line.attr({
      stroke: this.screenColor
    });
    set.push(border, line);
    this.image.push(set);
    return set;
  };

  Oscilloscope.prototype.fire = function() {
    var bbox, part, start, voltage, _i, _j, _len, _len1, _ref, _ref1;
    if (!this.neuron) {
      return;
    }
    voltage = this.xAxis - (this.neuron.takeReading() * this.scale);
    this.firePosition || (this.firePosition = this.screenWidth);
    bbox = this.screen.getBBox();
    if (this.firePosition >= this.screenWidth) {
      this.firePosition = 0;
      start = "M" + bbox.x + ", " + (bbox.y + (this.lastVoltage || this.xAxis));
      if (this.voltageDisplay) {
        _ref = this.voltageDisplay.items;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          part = _ref[_i];
          part.attr({
            path: start
          });
        }
      } else {
        this.voltageDisplay = this.screenPath(start);
      }
      this.voltageDisplay.attr({
        'clip-rect': "" + bbox.x + ", " + bbox.y + ", " + bbox.width + ", " + bbox.height
      });
    }
    _ref1 = this.voltageDisplay.items;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      part = _ref1[_j];
      part.attr({
        path: "" + (part.attr('path')) + "\nL" + (bbox.x + this.firePosition) + ", " + (bbox.y + voltage)
      });
    }
    this.firePosition += this.xDelta;
    return this.lastVoltage = voltage;
  };

  Oscilloscope.prototype.drawThreshold = function() {
    var bbox, path, threshold, translatedThreshold, x, _i, _ref, _ref1, _ref2, _ref3;
    if (this.thresholdLine) {
      this.thresholdLine.remove();
    }
    if ((threshold = (_ref = this.neuron) != null ? (_ref1 = _ref.properties) != null ? (_ref2 = _ref1.threshold) != null ? _ref2.value : void 0 : void 0 : void 0)) {
      bbox = this.screen.getBBox();
      translatedThreshold = bbox.y + this.xAxis - (threshold * this.scale);
      path = [];
      for (x = _i = 0, _ref3 = this.screenWidth; _i < _ref3; x = _i += 10) {
        path.push("M" + (bbox.x + x) + "," + translatedThreshold);
        path.push("L" + (bbox.x + x + 5) + "," + translatedThreshold);
      }
      this.thresholdLine = this.screenPath(path.join(''));
      this.thresholdLine.attr({
        opacity: 0.75
      });
      return this.thresholdLine.toFront();
    }
  };

  Oscilloscope.prototype.attachTo = function(neuron) {
    var _this = this;
    this.neuron = neuron;
    $(this.neuron).bind('threshold.change.oscilloscope', function() {
      return _this.drawThreshold();
    });
    return this.drawThreshold();
  };

  Oscilloscope.prototype.unattach = function() {
    if (this.neuron) {
      $(this.neuron).unbind('threshold.change.oscilloscope');
    }
    this.neuron = null;
    this.voltageDisplay.remove();
    this.voltageDisplay = null;
    this.firePosition = 0;
    return this.drawThreshold();
  };

  return Oscilloscope;

})(neurobehavObject.Object);
