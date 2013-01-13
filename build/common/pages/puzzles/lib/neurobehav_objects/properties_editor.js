// Generated by CoffeeScript 1.3.3
var Slider, propertiesEditor;

propertiesEditor = typeof exports !== "undefined" && exports !== null ? exports : provide('./properties_editor', {});

Slider = require('./slider').Slider;

propertiesEditor.PropertiesEditor = (function() {

  PropertiesEditor.prototype.width = 180;

  PropertiesEditor.prototype.arrowHeight = 15;

  PropertiesEditor.prototype.arrowWidth = 20;

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
    var bbox, startX, startY;
    this.container = this.paper.set();
    bbox = this.element.getBBox();
    this.x = bbox.x - 24;
    this.y = bbox.y - (this.height + this.arrowHeight);
    this.base = this.paper.rect(this.x, this.y, this.width, this.height, 12);
    this.container.push(this.base);
    startX = bbox.x + (bbox.width / 2);
    startY = bbox.y - (this.arrowHeight + 2);
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
            unit: property.unit,
            val: property.value
          });
          return _this.container.push(slider.el);
        }
      })(property));
    }
    return _results;
  };

  PropertiesEditor.prototype.createSlider = function(property) {};

  PropertiesEditor.prototype.show = function() {
    this.createContainer();
    return this.createProperties();
  };

  PropertiesEditor.prototype.hide = function() {
    return this.container.remove();
  };

  PropertiesEditor.prototype.set = function(id, value) {
    value = parseFloat(value);
    this.objectProperties.find("." + id).find('input, select').val(value + '');
    if (this.properties) {
      return this.properties[id].value = value;
    }
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
