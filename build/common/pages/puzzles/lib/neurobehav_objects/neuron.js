// Generated by CoffeeScript 1.3.3
var neurobehavObject, neuron,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

neuron = typeof exports !== "undefined" && exports !== null ? exports : provide('./neuron', {});

neurobehavObject = require('./object');

neuron.Neuron = (function(_super) {

  __extends(Neuron, _super);

  Neuron.prototype.objectType = 'neuron';

  Neuron.prototype.objectName = 'Neuron';

  Neuron.prototype.height = 60;

  Neuron.prototype.width = 60;

  Neuron.prototype.centerOffset = 30;

  Neuron.prototype.properties = {};

  Neuron.prototype.propertyList = {
    'threshold': {
      name: 'Threshold',
      type: 'slider',
      unit: 0.25,
      max: 3,
      unitName: 'V',
      set: 'setThreshold'
    },
    'spike': {
      name: 'Spike',
      type: 'slider',
      unit: 0.25,
      max: 3,
      unitName: 'V'
    }
  };

  function Neuron(_arg) {
    var spike, threshold;
    this.inhibitoryDescription = _arg.inhibitoryDescription, this.excitatoryDescription = _arg.excitatoryDescription, threshold = _arg.threshold, spike = _arg.spike;
    Neuron.__super__.constructor.apply(this, arguments);
    this.properties.threshold.value = threshold;
    this.properties.spike.value = spike;
    this.initProperties();
  }

  Neuron.prototype.init = function() {
    var _this = this;
    this.image = this.paper.set();
    this.synapses = [];
    this.synapseSpikes = [];
    this.activeSynapseSpikes = [];
    this.draw();
    this.timeSinceStart = 0;
    this.restTime = 0;
    this.timeDelta = 0.5;
    this.resistance = 1;
    this.capacitance = 10;
    this.timeConstant = this.resistance * this.capacitance;
    this.refractory = 1;
    this.voltage = 0;
    this.currentVoltage = this.voltage;
    setInterval((function() {
      return _this.setCurrentVoltage();
    }), this.periodicity);
    this.createSynapse('excitatory');
    return this.createSynapse('inhibitory');
  };

  Neuron.prototype.draw = function() {
    var circle;
    circle = this.paper.circle(this.position.left + (this.width / 2), this.position.top + (this.height / 2), this.width / 2);
    circle.attr({
      stroke: '#2B4590',
      fill: 'r(0.35, 0.35)#8CA0CF-#2B4590'
    });
    this.image.push(circle);
    this.tendril(230, this.height / 2.5);
    this.tendril(260, this.height / 3);
    this.tendril(320, this.height / 2.25);
    this.tendril(50, this.height / 3.5);
    this.tendril(120, this.height / 2.5);
    return Neuron.__super__.draw.call(this);
  };

  Neuron.prototype.tendril = function(angle, length) {
    var centerX, centerY, distance, lengthUnits, perpDistance, perpUnits, perpYDelta, rad, radius, slope, startX, startY, tendril, units, xDelta, yDelta;
    rad = angle * Math.PI / 180;
    radius = this.width / 2;
    centerX = this.position.left + radius;
    centerY = this.position.top + radius;
    slope = Math.tan(rad);
    xDelta = angle > 180 ? -1 : 1;
    yDelta = xDelta / slope;
    distance = Math.sqrt(Math.pow(xDelta, 2) + Math.pow(yDelta, 2));
    units = (radius - 6) / distance;
    lengthUnits = length / distance;
    startX = centerX + (xDelta * units);
    startY = centerY - (yDelta * units);
    perpYDelta = xDelta * slope;
    perpDistance = Math.sqrt(Math.pow(xDelta, 2) + Math.pow(perpYDelta, 2));
    perpUnits = (length / 6) / perpDistance;
    tendril = this.paper.path("M" + (startX + (xDelta * perpUnits)) + "," + (startY + (perpYDelta * perpUnits)) + "\nL" + (startX + (xDelta * lengthUnits) + (xDelta * perpUnits / 2)) + "," + (startY - (lengthUnits * yDelta) + (perpYDelta * (perpUnits / 2))) + "\nL" + (startX + (xDelta * lengthUnits) - (xDelta * perpUnits / 2)) + "," + (startY - (lengthUnits * yDelta) - (perpYDelta * (perpUnits / 2))) + "\nL" + (startX - (xDelta * perpUnits)) + "," + (startY - (perpYDelta * perpUnits)));
    tendril.attr({
      stroke: '#2B4590',
      fill: "" + (360 - angle) + "-#8CA0CF-#2B4590-#8CA0CF"
    });
    return this.image.push(tendril);
  };

  Neuron.prototype.setCurrentVoltage = function() {
    var activeSynapseSpike, stillActiveSynapseSpikes, synapse, synapseSpike, voltage, voltageDiff, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3, _results;
    this.timeSinceStart += this.timeDelta;
    this.lastVoltage = this.currentVoltage;
    if (this.activeSynapseSpikes.length) {
      stillActiveSynapseSpikes = [];
      _ref = this.activeSynapseSpikes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        activeSynapseSpike = _ref[_i];
        activeSynapseSpike.used += 2;
        if (activeSynapseSpike.used >= 50) {
          this.voltage -= activeSynapseSpike.voltage;
        } else {
          voltageDiff = activeSynapseSpike.voltage / activeSynapseSpike.used;
          activeSynapseSpike.voltage -= voltageDiff;
          this.voltage -= voltageDiff;
          stillActiveSynapseSpikes.push(activeSynapseSpike);
        }
      }
      this.activeSynapseSpikes = stillActiveSynapseSpikes;
    }
    _ref1 = this.synapseSpikes;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      synapseSpike = _ref1[_j];
      voltage = this.synapseSpikes.shift() * 3;
      this.activeSynapseSpikes.push({
        used: 2,
        voltage: voltage
      });
      this.voltage += voltage;
    }
    if (this.timeSinceStart > this.restTime) {
      this.currentVoltage = this.lastVoltage + ((-1 * this.lastVoltage) + this.voltage * this.resistance) / this.timeConstant * this.timeDelta;
      if (this.currentVoltage >= this.properties.threshold.value) {
        this.currentVoltage += this.properties.spike.value;
        this.restTime = this.timeSinceStart + this.refractory;
        _ref2 = this.synapses;
        _results = [];
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          synapse = _ref2[_k];
          _results.push((_ref3 = synapse.connection) != null ? _ref3.addSynapseSpike(this.properties.spike.value) : void 0);
        }
        return _results;
      }
    } else {
      return this.currentVoltage = this.voltage / 4;
    }
  };

  Neuron.prototype.setThreshold = function() {
    return $(this).trigger('threshold.change');
  };

  Neuron.prototype.takeReading = function() {
    return this.currentVoltage;
  };

  Neuron.prototype.addSynapseSpike = function(spike) {
    return this.synapseSpikes.push(spike);
  };

  Neuron.prototype.addVoltage = function(amount) {
    return this.voltage += amount;
  };

  Neuron.prototype.createSynapse = function(type) {
    var bbox, descriptionBubble, endX, endY, fullDX, fullDY, glow, lastDX, lastDY, onDrag, onEnd, onStart, subPath, synapse, tip, xShift,
      _this = this;
    xShift = (type === 'inhibitory' ? -12 : 12);
    endX = this.position.left + (this.width / 2) + xShift;
    endY = this.position.top + this.height + 20;
    synapse = this.paper.path("M" + (this.position.left + (this.width / 2)) + "," + (this.position.top + (this.height / 2)) + "\nL" + endX + "," + endY);
    synapse.attr({
      'stroke-width': 2
    });
    synapse.synapseType = type;
    synapse.id = "" + this.id + "/" + this.synapses.length;
    synapse.toBack();
    if (type === 'inhibitory') {
      tip = this.paper.circle(endX, endY, 6);
      tip.attr({
        'cursor': 'move',
        'fill': '#000'
      });
    } else {
      tip = this.paper.path("M" + (endX - 6) + "," + (endY + 6) + "\nL" + (endX + 6) + "," + (endY + 6) + "\nL" + endX + "," + endY + "\nL" + (endX - 6) + "," + (endY + 6) + "                ");
      tip.attr({
        'cursor': 'move',
        'fill': '#000'
      });
    }
    glow = this.initMoveGlow(tip);
    lastDX = 0;
    lastDY = 0;
    fullDX = 0;
    fullDY = 0;
    subPath = null;
    onDrag = function(dX, dY) {
      var path;
      path = synapse.attr('path');
      fullDX = lastDX + dX;
      fullDY = lastDY + dY;
      path[1][1] = endX + fullDX;
      path[1][2] = endY + fullDY;
      synapse.attr('path', path);
      if (subPath) {
        subPath.remove();
      }
      if (synapse.getTotalLength() > _this.width) {
        subPath = _this.paper.path(synapse.getSubpath(_this.width, synapse.getTotalLength()));
        subPath.toFront();
      }
      glow.transform("t" + fullDX + "," + fullDY);
      glow.attr({
        opacity: 0.04
      });
      glow.toFront();
      tip.transform("t" + fullDX + "," + fullDY);
      return tip.toFront();
    };
    onStart = function() {
      _this.disconnectSynapse(synapse);
      return glow.attr({
        opacity: 0.04
      });
    };
    onEnd = function() {
      var element, _i, _len, _ref, _results;
      lastDX = fullDX;
      lastDY = fullDY;
      _ref = _this.paper.getElementsByPoint(endX + fullDX, endY + fullDY);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        if (element.objectType === 'neuron') {
          _results.push(_this.connectSynapse(synapse, element.object));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    tip.drag(onDrag, onStart, onEnd);
    glow.drag(onDrag, onStart, onEnd);
    bbox = tip.getBBox();
    descriptionBubble = new Bubble({
      paper: this.paper,
      x: bbox.x + bbox.width,
      y: bbox.y + (bbox.height / 2),
      width: 240,
      height: 240,
      position: 'right',
      html: this["" + type + "Description"]
    });
    tip.click(function() {
      if (descriptionBubble.visible) {
        return descriptionBubble.hide();
      } else {
        return descriptionBubble.show();
      }
    });
    return this.synapses.push(synapse);
  };

  Neuron.prototype.connectSynapse = function(synapse, neuron) {
    var _this = this;
    if (neuron.objectType !== 'neuron') {
      return;
    }
    return synapse.connection = {
      addSynapseSpike: function(spike) {
        if (synapse.synapseType === 'inhibitory') {
          spike = spike * -1;
        }
        return neuron.addSynapseSpike(spike);
      }
    };
  };

  Neuron.prototype.disconnectSynapse = function(synapse) {
    return synapse.connection = null;
  };

  return Neuron;

})(neurobehavObject.Object);
