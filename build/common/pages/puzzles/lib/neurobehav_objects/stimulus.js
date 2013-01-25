// Generated by CoffeeScript 1.3.3
var neurobehavObject, slider, stimulus,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

stimulus = typeof exports !== "undefined" && exports !== null ? exports : provide('./stimulus', {});

neurobehavObject = require('./object');

slider = require('./slider');

stimulus.Stimulus = (function(_super) {

  __extends(Stimulus, _super);

  Stimulus.prototype.objectType = 'stimulus';

  Stimulus.prototype.objectName = 'Stimulus';

  Stimulus.prototype.imageSrc = 'stimulus_button.png';

  Stimulus.prototype.width = 180;

  Stimulus.prototype.height = 120;

  Stimulus.prototype.connectionLength = 60;

  Stimulus.prototype.centerOffset = 30;

  Stimulus.prototype.propertyList = {
    'voltage': {
      name: 'Voltage',
      type: 'slider',
      unit: 0.25,
      unitName: 'V',
      set: 'setSlider'
    },
    'duration': {
      name: 'Duration',
      type: 'slider',
      unit: 250,
      max: 10000,
      unitName: 'msec'
    }
  };

  function Stimulus(_arg) {
    var duration, voltage;
    voltage = _arg.voltage, duration = _arg.duration;
    Stimulus.__super__.constructor.apply(this, arguments);
    this.properties.voltage.value = voltage;
    this.properties.voltage.max = voltage * 2;
    this.properties.duration.value = duration;
    this.initProperties();
    this.initSlider();
  }

  Stimulus.prototype.init = function() {
    var minimumMouseDown, mousedown, mouseup,
      _this = this;
    this.draw();
    mousedown = false;
    minimumMouseDown = true;
    mousedown = function() {
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
      mousedown = true;
      return _this.setState(true);
    };
    mouseup = function() {
      if (minimumMouseDown) {
        _this.setState(false);
      }
      return mousedown = false;
    };
    this.image.mousedown(function() {
      return mousedown();
    });
    this.image.touchstart(function() {
      return mousedown();
    });
    this.image.mouseup(function() {
      return mouseup();
    });
    this.image.touchend(function() {
      return mouseup();
    });
    return this.image.attr({
      cursor: 'pointer'
    });
  };

  Stimulus.prototype.draw = function() {
    var connection, connectionSegment, endX, endY, height, i, innerNeedle, lightStartX, lightStartY, middleThingy, slope, startX, startY, startingX, startingY, voltageConnector;
    this.image = this.paper.set();
    this.button = this.paper.circle(this.position.left + this.centerOffset + 2, this.position.top + this.centerOffset - 5, this.centerOffset);
    this.button.attr({
      'stroke-width': 2,
      fill: 'white'
    });
    this.buttonGlow = this.paper.circle(this.position.left + this.centerOffset, this.position.top + this.centerOffset, this.centerOffset);
    this.buttonGlow.attr({
      'stroke-width': 1,
      stroke: '#555',
      fill: '#555'
    });
    this.image.push(this.buttonGlow);
    this.image.push(this.button);
    lightStartX = this.position.left + (this.centerOffset * 0.8) + 2;
    lightStartY = this.position.top + (this.centerOffset / 2) - 5;
    this.lightningBolt = this.paper.path("M" + lightStartX + "," + lightStartY + "\nL" + (lightStartX + (this.centerOffset * 0.4)) + "," + lightStartY + "}\nL" + (lightStartX + (this.centerOffset * 0.3)) + "," + (lightStartY + (this.centerOffset * 0.3)) + "\nL" + (lightStartX + (this.centerOffset * 0.6)) + "," + (lightStartY + (this.centerOffset * 0.3)) + "\nL" + (lightStartX + (this.centerOffset * 0.15)) + "," + (lightStartY + (this.centerOffset * 1.15)) + "\nL" + (lightStartX + (this.centerOffset * 0.15)) + "," + (lightStartY + (this.centerOffset * 0.6)) + "\nL" + (lightStartX - (this.centerOffset * 0.15)) + "," + (lightStartY + (this.centerOffset * 0.6)) + "\nL" + lightStartX + "," + lightStartY);
    this.lightningBolt.attr({
      fill: 'yellow'
    });
    this.image.push(this.lightningBolt);
    startX = this.position.left;
    startY = this.position.top + this.centerOffset;
    voltageConnector = this.paper.path("M" + startX + "," + startY + "\nL" + (startX - (this.centerOffset / 2)) + "," + startY + "\nL" + (startX - (this.centerOffset / 2)) + "," + (startY + (this.centerOffset * 2)) + "\nL" + (startX + (this.centerOffset / 2)) + "," + (startY + (this.centerOffset * 2)) + "\nM" + (startX + (this.centerOffset / 2) + 24) + "," + (startY + (this.centerOffset * 2)) + "\nL" + (startX + (this.centerOffset * 2)) + "," + (startY + (this.centerOffset * 2)) + "\nL" + (startX + (this.centerOffset * 2)) + "," + (startY + (this.centerOffset * 2.5)) + "\nM" + (startX + (this.centerOffset * 2) - 12) + "," + (startY + (this.centerOffset * 2.5)) + "\nL" + (startX + (this.centerOffset * 2) + 12) + "," + (startY + (this.centerOffset * 2.5)) + "\nM" + (startX + (this.centerOffset * 2) - 8) + "," + (startY + (this.centerOffset * 2.5) + 4) + "\nL" + (startX + (this.centerOffset * 2) + 8) + "," + (startY + (this.centerOffset * 2.5) + 4) + "\nM" + (startX + (this.centerOffset * 2) - 4) + "," + (startY + (this.centerOffset * 2.5) + 8) + "\nL" + (startX + (this.centerOffset * 2) + 4) + "," + (startY + (this.centerOffset * 2.5) + 8));
    voltageConnector.attr({
      'stroke-width': 2
    });
    middleThingy = this.paper.path(((function() {
      var _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = this.centerOffset; _i < _ref; i = _i += 6) {
        height = 8 * (((i / 6) % 2) + 1);
        _results.push("M" + (startX + (this.centerOffset / 2) + i) + "," + (startY + (this.centerOffset * 2) + height) + "\nL" + (startX + (this.centerOffset / 2) + i) + "," + (startY + (this.centerOffset * 2) - height));
      }
      return _results;
    }).call(this)).join('\n'));
    middleThingy.attr({
      'stroke-width': 3
    });
    this.image.push(middleThingy);
    startingX = startX + this.centerOffset * 2;
    startingY = startY;
    connectionSegment = this.connectionLength / 10;
    slope = ((this.position.top + (this.height / 1.5)) - startingY) / ((startingX + (connectionSegment * 4)) - (startingX + this.connectionLength));
    endX = startingX + (connectionSegment * 5);
    endY = startingY - (slope * connectionSegment);
    connection = this.paper.path("M" + startingX + "," + startingY + "\nL" + (startingX + (connectionSegment * 4)) + "," + startingY + "\nL" + endX + "," + endY);
    connection.attr({
      'stroke-width': 2
    });
    this.image.push(connection);
    this.needle = this.paper.path("M" + (endX - 5) + "," + (endY - (5 * (1 / slope))) + "\nL" + (startingX + this.connectionLength) + ", " + (this.position.top + (this.height / 1.5)) + "\nL" + (endX + 5) + "," + (endY + (5 * (1 / slope))) + "\nL" + (endX - 5) + "," + (endY - (5 * (1 / slope))));
    this.needle.attr({
      fill: 'white'
    });
    this.image.push(this.needle);
    innerNeedle = this.paper.path("M" + (endX - 3) + "," + (endY - (3 * (1 / slope))) + "\nL" + (startingX + this.connectionLength) + ", " + (this.position.top + (this.height / 1.5)) + "\nL" + (endX + 3) + "," + (endY + (3 * (1 / slope))));
    innerNeedle.attr({
      stroke: '#ccc'
    });
    this.image.push(innerNeedle);
    return Stimulus.__super__.draw.call(this);
  };

  Stimulus.prototype.initSlider = function() {
    var tempShowProperties,
      _this = this;
    this.slider = new Slider({
      paper: this.paper,
      x: this.position.left,
      y: this.position.top + this.height + 9,
      width: this.centerOffset * 2,
      min: 0,
      max: this.properties.voltage.max,
      unit: this.properties.voltage.unit
    });
    this.slider.set(this.properties.voltage.value);
    tempShowProperties = null;
    return this.slider.addListener(function(val) {
      _this.propertiesEditor.show();
      if (tempShowProperties) {
        clearTimeout(tempShowProperties);
      }
      tempShowProperties = setTimeout((function() {
        return _this.propertiesEditor.hide();
      }), 1500);
      return _this.propertiesEditor.set('voltage', val);
    });
  };

  Stimulus.prototype.setState = function(on) {
    this.on = on;
    if (this.on) {
      this.buttonGlow.hide();
      this.button.attr({
        fill: 'orange'
      });
      this.button.transform('t-2,5');
      this.lightningBolt.transform('t-2,5');
    } else {
      this.buttonGlow.show();
      this.button.attr({
        fill: 'white'
      });
      this.button.transform('');
      this.lightningBolt.transform('');
    }
    return this.neuron.addVoltage(this.on ? this.properties.voltage.value : this.properties.voltage.value * -1);
  };

  Stimulus.prototype.setSlider = function(val) {
    return this.slider.set(val);
  };

  Stimulus.prototype.connectTo = function(neuron) {
    this.neuron = neuron;
    this.image.toFront();
    return this.neuron.addVoltage(this.properties.voltage.value * (this.on ? 1 : 0));
  };

  return Stimulus;

})(neurobehavObject.Object);
