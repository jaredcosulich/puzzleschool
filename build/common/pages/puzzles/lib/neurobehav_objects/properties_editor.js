// Generated by CoffeeScript 1.3.3
var Slider, propertiesEditor;

propertiesEditor = typeof exports !== "undefined" && exports !== null ? exports : provide('./properties_editor', {});

Slider = require('./slider').Slider;

propertiesEditor.PropertiesEditor = (function() {

  PropertiesEditor.prototype.width = 210;

  PropertiesEditor.prototype.arrowHeight = 15;

  PropertiesEditor.prototype.arrowWidth = 20;

  PropertiesEditor.prototype.arrowOffset = 24;

  PropertiesEditor.prototype.spacing = 20;

  PropertiesEditor.prototype.backgroundColor = '#49494A';

  function PropertiesEditor(_arg) {
    this.element = _arg.element, this.paper = _arg.paper, this.properties = _arg.properties, this.name = _arg.name;
    this.init();
  }

  PropertiesEditor.prototype.$ = function(selector) {
    return this.el.find(selector);
  };

  PropertiesEditor.prototype.init = function() {
    return this.height = (Object.keys(this.properties).length * this.spacing) + (this.spacing * 2);
  };

  PropertiesEditor.prototype.createContainer = function() {
    var bbox, start, startX, startY;
    this.container = this.paper.set();
    bbox = this.element.getBBox();
    this.x = bbox.x - this.arrowOffset;
    this.y = bbox.y - (this.height + this.arrowHeight);
    this.base = this.paper.rect(this.x, this.y, this.width, this.height, 12);
    this.container.push(this.base);
    start = this.start();
    startX = start.x;
    startY = start.y - (this.arrowHeight + 2);
    this.arrow = this.paper.path("M" + (startX - (this.arrowWidth / 2)) + "," + startY + "\nL" + startX + "," + (startY + this.arrowHeight) + "\nL" + (startX + (this.arrowWidth / 2)) + "," + startY);
    this.container.push(this.arrow);
    this.container.attr({
      fill: this.backgroundColor,
      stroke: 'none'
    });
    return this.container.toFront();
  };

  PropertiesEditor.prototype.createProperties = function() {
    var propertiesDisplayed, property, propertyId, title, _ref, _results,
      _this = this;
    title = this.paper.text(this.x + (this.width / 2), this.y + 18, this.name);
    title.attr({
      fill: 'white',
      stroke: 'none',
      'font-size': 14
    });
    this.container.push(title);
    propertiesDisplayed = 0;
    _ref = this.properties;
    _results = [];
    for (propertyId in _ref) {
      property = _ref[propertyId];
      _results.push((function(property) {
        var name, slider, y;
        y = _this.y + (_this.spacing * 2) + (propertiesDisplayed * _this.spacing);
        name = _this.paper.text(_this.x + 12, y, property.name.toLowerCase());
        name.attr({
          fill: '#ccc',
          stroke: 'none',
          'font-size': 12,
          'font-weight': 1,
          'text-anchor': 'start'
        });
        _this.container.push(name);
        propertiesDisplayed += 1;
        if (property.type === 'slider') {
          slider = new Slider({
            paper: _this.paper,
            x: _this.x + 72,
            y: y,
            width: 60,
            min: 0,
            max: property.max,
            unit: property.unit
          });
          slider.addListener(function(value) {
            property.value = value;
            return _this.display(property);
          });
          property.object = slider;
          _this.container.push(slider.el);
        }
        return _this.display(property, _this.x + 144, y);
      })(property));
    }
    return _results;
  };

  PropertiesEditor.prototype.start = function() {
    var bbox;
    bbox = this.element.getBBox();
    return {
      x: bbox.x + (bbox.width / 2),
      y: bbox.y - 3
    };
  };

  PropertiesEditor.prototype.display = function(property, x, y) {
    var text;
    text = "" + property.value + " " + property.unitName;
    if (property.display) {
      property.display.attr({
        text: text
      });
    } else {
      property.display = this.paper.text(x, y, text);
      property.display.attr({
        fill: '#F6E631',
        stroke: 'none',
        'font-size': 11,
        'text-anchor': 'start'
      });
      this.container.push(property.display);
    }
    if (property.set) {
      return property.set(property.value);
    }
  };

  PropertiesEditor.prototype.show = function() {
    var start,
      _this = this;
    if (this.container) {
      return;
    }
    this.createContainer();
    this.createProperties();
    start = this.start();
    this.container.attr({
      transform: "s0,0," + start.x + "," + start.y
    });
    return this.container.animate({
      transform: "s1"
    }, 100, 'linear', function() {
      var property, propertyId, _ref, _ref1, _results;
      _ref = _this.properties;
      _results = [];
      for (propertyId in _ref) {
        property = _ref[propertyId];
        _results.push((_ref1 = property.object) != null ? _ref1.set(property.value) : void 0);
      }
      return _results;
    });
  };

  PropertiesEditor.prototype.hide = function() {
    var start,
      _this = this;
    if (!this.container) {
      return;
    }
    start = this.start();
    return this.container.animate({
      transform: "s0,0," + start.x + "," + start.y
    }, 100, 'linear', function() {
      var property, propertyId, _ref, _results;
      _this.container.remove();
      _this.container = null;
      _ref = _this.properties;
      _results = [];
      for (propertyId in _ref) {
        property = _ref[propertyId];
        _results.push(property.display = null);
      }
      return _results;
    });
  };

  PropertiesEditor.prototype.toggle = function() {
    if (this.container != null) {
      return this.hide();
    } else {
      return this.show();
    }
  };

  PropertiesEditor.prototype.set = function(id, value) {
    var property, _ref;
    value = parseFloat(value);
    property = this.properties[id];
    if (property.value === value) {
      return;
    }
    property.value = value;
    if ((_ref = property.object) != null) {
      _ref.set(value);
    }
    return this.display(property);
  };

  PropertiesEditor.prototype.selectElement = function(property) {
    var options, selected, value, _i, _ref, _ref1, _ref2;
    options = [];
    for (value = _i = _ref = property.min || 0, _ref1 = property.max, _ref2 = property.unit; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; value = _i += _ref2) {
      selected = ("" + value) === ("" + property.value);
      options.push("<option value=" + value + " " + (selected ? 'selected=selected' : '') + ">" + value + "</option>");
    }
    return "<select>" + (options.join('')) + "</select>";
  };

  return PropertiesEditor;

})();
