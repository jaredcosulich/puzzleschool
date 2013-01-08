// Generated by CoffeeScript 1.3.3
var neurobehavObject, oscilloscope,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

oscilloscope = typeof exports !== "undefined" && exports !== null ? exports : provide('./oscilloscope', {});

neurobehavObject = require('./object');

oscilloscope.StaticOscilloscope = (function(_super) {

  __extends(StaticOscilloscope, _super);

  StaticOscilloscope.prototype.objectType = 'oscilloscope';

  StaticOscilloscope.prototype.objectName = 'Oscilloscope';

  StaticOscilloscope.prototype.imageSrc = 'oscilloscope.png';

  StaticOscilloscope.prototype.width = 80;

  StaticOscilloscope.prototype.height = 42;

  StaticOscilloscope.prototype.axisLineCount = 5.0;

  StaticOscilloscope.prototype.xDelta = 1;

  StaticOscilloscope.prototype.scale = 100;

  function StaticOscilloscope(_arg) {
    var _this = this;
    this.container = _arg.container;
    StaticOscilloscope.__super__.constructor.apply(this, arguments);
    this.drawGrid();
    this.createImage();
    this.initImage();
    setInterval((function() {
      return _this.fire();
    }), this.periodicity);
  }

  StaticOscilloscope.prototype.init = function() {
    var backgroundCanvas, voltageCanvas;
    backgroundCanvas = document.createElement('CANVAS');
    this.container.append(backgroundCanvas);
    this.canvasWidth = backgroundCanvas.width = $(backgroundCanvas).width();
    this.canvasHeight = backgroundCanvas.height = $(backgroundCanvas).height();
    this.backgroundContext = backgroundCanvas.getContext('2d');
    voltageCanvas = document.createElement('CANVAS');
    this.container.append(voltageCanvas);
    voltageCanvas.width = $(voltageCanvas).width();
    voltageCanvas.height = $(voltageCanvas).height();
    this.voltageContext = voltageCanvas.getContext('2d');
    this.voltageContext.strokeStyle = 'rgba(255, 92, 92, 1)';
    this.voltageContext.lineWidth = 1;
    return this.xAxis = this.canvasHeight - (this.canvasHeight / this.axisLineCount);
  };

  StaticOscilloscope.prototype.initImage = function() {
    var fullDX, fullDY, glow, lastDX, lastDY, onDrag, onEnd, onStart,
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
    fullDX = 0;
    fullDY = 0;
    onDrag = function(dX, dY) {
      fullDX = lastDX + dX;
      fullDY = lastDY + dY;
      _this.image.transform("t" + fullDX + "," + fullDY);
      return glow.transform("t" + fullDX + "," + fullDY);
    };
    onStart = function() {
      _this.showProperties(_this.image);
      _this.unattach();
      return glow.show();
    };
    onEnd = function() {
      var element, _i, _len, _ref, _results;
      glow.attr({
        opacity: 0
      });
      lastDX = fullDX;
      lastDY = fullDY;
      _ref = _this.paper.getElementsByPoint(_this.position.left + fullDX, (_this.position.top + _this.height) + fullDY);
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

  StaticOscilloscope.prototype.fire = function() {
    var voltage;
    if (!this.neuron) {
      return;
    }
    voltage = this.xAxis - (this.neuron.takeReading() * this.scale);
    this.firePosition || (this.firePosition = 0);
    if (this.firePosition > this.canvasWidth) {
      this.voltageContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
      this.firePosition = 0;
    }
    this.voltageContext.beginPath();
    this.voltageContext.moveTo(this.firePosition, this.lastVoltage || this.xAxis);
    this.firePosition += this.xDelta;
    this.voltageContext.lineTo(this.firePosition, voltage);
    this.voltageContext.stroke();
    this.voltageContext.closePath();
    return this.lastVoltage = voltage;
  };

  StaticOscilloscope.prototype.drawGrid = function() {
    var threshold, translatedThreshold, x, y, _i, _j, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
    this.backgroundContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.backgroundContext.strokeStyle = 'rgba(0, 0, 0, 0.4)';
    this.backgroundContext.lineWidth = 1;
    this.backgroundContext.beginPath();
    for (y = _i = 1, _ref = this.canvasHeight, _ref1 = this.canvasHeight / this.axisLineCount; 1 <= _ref ? _i < _ref : _i > _ref; y = _i += _ref1) {
      this.backgroundContext.moveTo(0, y);
      this.backgroundContext.lineTo(this.canvasWidth, y);
    }
    this.backgroundContext.stroke();
    this.backgroundContext.closePath();
    if ((threshold = (_ref2 = this.neuron) != null ? (_ref3 = _ref2.properties) != null ? (_ref4 = _ref3.threshold) != null ? _ref4.value : void 0 : void 0 : void 0)) {
      translatedThreshold = this.xAxis - (threshold * this.scale);
      this.backgroundContext.strokeStyle = '#0C8D28';
      this.backgroundContext.beginPath();
      for (x = _j = 0, _ref5 = this.canvasWidth; _j <= _ref5; x = _j += 10) {
        this.backgroundContext.moveTo(x, translatedThreshold);
        this.backgroundContext.lineTo(x + 5, translatedThreshold);
      }
      this.backgroundContext.stroke();
      return this.backgroundContext.closePath();
    }
  };

  StaticOscilloscope.prototype.attachTo = function(neuron) {
    var _this = this;
    this.neuron = neuron;
    $(this.neuron).bind('threshold.change.oscilloscope', function() {
      return _this.drawGrid();
    });
    return this.drawGrid();
  };

  StaticOscilloscope.prototype.unattach = function() {
    $(this.neuron).unbind('threshold.change.oscilloscope');
    this.neuron = null;
    this.voltageContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.firePosition = 0;
    return this.drawGrid();
  };

  return StaticOscilloscope;

})(neurobehavObject.Object);
