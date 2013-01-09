// Generated by CoffeeScript 1.3.3
var neurobehavObject, stimulus,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

stimulus = typeof exports !== "undefined" && exports !== null ? exports : provide('./stimulus', {});

neurobehavObject = require('./object');

stimulus.Stimulus = (function(_super) {

  __extends(Stimulus, _super);

  Stimulus.prototype.objectType = 'stimulus';

  Stimulus.prototype.objectName = 'Stimulus';

  Stimulus.prototype.imageSrc = 'stimulus_button.png';

  Stimulus.prototype.height = 50;

  Stimulus.prototype.width = 50;

  Stimulus.prototype.fullWidth = 100;

  Stimulus.prototype.propertyList = {
    'voltage': {
      name: 'Voltage',
      type: 'select',
      unit: 0.25,
      unitName: 'V',
      set: 'setSlider'
    },
    'duration': {
      name: 'Duration',
      type: 'select',
      unit: 250,
      max: 10000,
      unitName: 'msec'
    }
  };

  function Stimulus(_arg) {
    var duration, voltage;
    voltage = _arg.voltage, duration = _arg.duration;
    this.moveKnob = __bind(this.moveKnob, this);

    this.voltageCalc = __bind(this.voltageCalc, this);

    Stimulus.__super__.constructor.apply(this, arguments);
    this.properties.voltage.value = voltage;
    this.properties.voltage.max = voltage * 2;
    this.properties.duration.value = duration;
  }

  Stimulus.prototype.init = function() {
    var minimumMouseDown, mousedown,
      _this = this;
    this.createImage();
    this.setImage();
    mousedown = false;
    minimumMouseDown = true;
    this.image.mousedown(function() {
      if (!minimumMouseDown) {
        return;
      }
      minimumMouseDown = false;
      setTimeout((function() {
        if (!mousedown) {
          _this.setState(false);
        }
        return minimumMouseDown = true;
      }), _this.properties.duration.value);
      _this.showProperties(_this.slider);
      mousedown = true;
      return _this.setState(true);
    });
    this.image.mouseup(function() {
      if (minimumMouseDown) {
        _this.setState(false);
      }
      return mousedown = false;
    });
    this.image.attr({
      cursor: 'pointer'
    });
    return this.initSlider();
  };

  Stimulus.prototype.initSlider = function() {
    var guide, onDrag, onEnd, onStart, value,
      _this = this;
    this.slider = this.paper.set();
    this.slider.objectType = this.objectType;
    this.slider.objectName = this.objectName;
    value = this.properties.voltage.value;
    this.unit = this.properties.voltage.unit;
    this.range = this.properties.voltage.max / this.unit;
    this.offset = 9;
    this.radius = 6;
    this.left = this.position.left;
    this.right = this.position.left + this.width;
    this.top = this.position.top + this.height + this.offset;
    this.segment = this.width / this.range;
    guide = this.paper.path("M" + this.left + "," + this.top + "L" + this.right + "," + this.top);
    guide.attr({
      'stroke': "#ccc",
      'stroke-width': 5,
      'stroke-linecap': 'round'
    });
    this.knob = this.paper.circle(this.position.left, this.position.top + this.height + this.offset, this.radius);
    this.knob.attr({
      cursor: 'move',
      stroke: '#555',
      fill: 'r(0.5, 0.5)#ddd-#666'
    });
    this.lastDeltaX = (this.segment * value) / this.unit;
    this.deltaX = 0;
    this.knob.transform("t" + this.lastDeltaX + ",0");
    onDrag = function(dX, dY) {
      return _this.moveKnob(dX, dY);
    };
    onStart = function() {
      return _this.slider.noClick = true;
    };
    onEnd = function() {
      if (_this.deltaX) {
        _this.objectEditor.set('voltage', (_this.voltageCalc(_this.deltaX) / _this.segment) * _this.unit);
        _this.lastDeltaX = _this.deltaX;
      } else {
        _this.slider.noClick = false;
      }
      _this.deltaX = 0;
      return $.timeout(10, function() {
        return _this.slider.noClick = false;
      });
    };
    this.knob.drag(onDrag, onStart, onEnd);
    this.slider.push(guide);
    this.slider.push(this.knob);
    return this.initProperties(this.properties, this.slider);
  };

  Stimulus.prototype.voltageCalc = function() {
    return this.segment * Math.round(this.deltaX / this.segment);
  };

  Stimulus.prototype.moveKnob = function(dX, dY) {
    this.deltaX = this.lastDeltaX + dX;
    if (this.deltaX > this.right - this.left) {
      this.deltaX = this.right - this.left;
    }
    if (this.deltaX < 0) {
      this.deltaX = 0;
    }
    this.deltaX = this.voltageCalc(this.deltaX);
    this.knob.transform("t" + this.deltaX + "," + 0);
    this.initPropertiesGlow(this.slider);
    this.propertiesClick(this.slider, true);
    return this.objectEditor.set('voltage', (this.voltageCalc(this.deltaX) / this.segment) * this.unit);
  };

  Stimulus.prototype.setSlider = function(val) {
    this.lastDeltaX = this.segment * (val / this.unit);
    return this.moveKnob(0, 0);
  };

  Stimulus.prototype.setState = function(on) {
    this.on = on;
    this.setImage();
    return this.neuron.addVoltage(this.on ? this.properties.voltage.value : this.properties.voltage.value * -1);
  };

  Stimulus.prototype.setImage = function() {
    return this.image.attr({
      'clip-rect': "" + this.position.left + ", " + this.position.top + ", " + this.width + ", " + this.height,
      transform: "t" + (-1 * this.width * (this.on ? 1 : 0)) + ",0"
    });
  };

  Stimulus.prototype.connectTo = function(neuron) {
    this.neuron = neuron;
    this.connection = this.paper.path("M" + (this.position.left + (this.width / 2)) + "," + (this.position.top + (this.height / 2)) + "\nL" + this.neuron.position.left + "," + (this.neuron.position.top + (this.neuron.height / 2)));
    this.connection.attr({
      'stroke-width': 2,
      'arrow-end': 'block-wide-long'
    });
    this.connection.toBack();
    return this.neuron.addVoltage(this.properties.voltage.value * (this.on ? 1 : 0));
  };

  return Stimulus;

})(neurobehavObject.Object);
