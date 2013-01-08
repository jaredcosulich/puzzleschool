// Generated by CoffeeScript 1.3.3
var object;

object = typeof exports !== "undefined" && exports !== null ? exports : provide('./object', {});

object.Object = (function() {

  Object.prototype.periodicity = 20;

  Object.prototype.baseFolder = '/assets/images/puzzles/neurobehav/';

  function Object(_arg) {
    this.id = _arg.id, this.paper = _arg.paper, this.position = _arg.position, this.description = _arg.description, this.objectEditor = _arg.objectEditor;
    this.properties = this.setProperties(this.propertyList);
    this.init();
  }

  Object.prototype.setProperties = function(propertyList) {
    var properties, propertyId, _fn,
      _this = this;
    properties = propertyList ? JSON.parse(JSON.stringify(propertyList)) : {};
    properties.description = this.description;
    _fn = function(propertyId) {
      var setFunction;
      if ((setFunction = properties[propertyId].set)) {
        return properties[propertyId].set = function(val) {
          return _this[setFunction](val);
        };
      }
    };
    for (propertyId in properties) {
      _fn(propertyId);
    }
    return properties;
  };

  Object.prototype.createImage = function() {
    this.image = this.paper.image("" + this.baseFolder + this.imageSrc, this.position.left, this.position.top, this.fullWidth || this.width, this.fullHeight || this.height);
    this.image.objectType = this.objectType;
    this.image.objectName = this.objectName;
    this.image.object = this;
    return this.image;
  };

  Object.prototype.init = function() {
    return raise("no init method for " + this.objectType);
  };

  Object.prototype.initMoveGlow = function(element) {
    var glow, set,
      _this = this;
    glow = element.glow({
      width: 30,
      fill: true,
      color: 'yellow'
    });
    glow.attr({
      opacity: 0,
      cursor: 'move'
    });
    set = this.paper.set();
    set.push(element);
    set.push(glow);
    set.hover(function() {
      return glow.attr({
        opacity: 0.04
      });
    }, function() {
      return glow.attr({
        opacity: 0
      });
    });
    glow.toFront();
    element.toFront();
    return glow;
  };

  Object.prototype.initPropertiesGlow = function(element) {
    var glow, s,
      _this = this;
    if (element == null) {
      element = this.image;
    }
    if (element.propertiesGlow) {
      element.propertiesGlow.remove();
    }
    if (element.forEach) {
      glow = this.paper.set();
      element.forEach(function(e) {
        return glow.push(e.glow({
          width: 20,
          fill: true,
          color: 'red'
        }));
      });
    } else {
      glow = element.glow({
        width: 20,
        fill: true,
        color: 'red'
      });
    }
    glow.attr({
      opacity: 0
    });
    s = this.paper.set();
    s.push(glow);
    s.push(element);
    s.attr({
      cursor: 'pointer'
    });
    s.hover(function() {
      return glow.attr({
        opacity: 0.04
      });
    }, function() {
      if (!element.propertiesDisplayed) {
        return glow.attr({
          opacity: 0
        });
      }
    });
    element.propertiesGlow = glow;
    return s;
  };

  Object.prototype.initProperties = function(properties, element) {
    var elementAndGlow,
      _this = this;
    if (properties == null) {
      properties = this.properties;
    }
    if (element == null) {
      element = this.image;
    }
    element.properties = properties;
    elementAndGlow = this.initPropertiesGlow(element);
    elementAndGlow.click(function() {
      return _this.propertiesClick(element);
    });
    return element.propertiesGlow;
  };

  Object.prototype.propertiesClick = function(element, display) {
    if (element == null) {
      element = this.image;
    }
    if (element.noClick && !display) {
      return;
    }
    if (display || !element.propertiesDisplayed) {
      return this.showProperties(element);
    } else {
      return this.hideProperties(element);
    }
  };

  Object.prototype.showProperties = function(element) {
    var previouslySelectedElement;
    if (element == null) {
      element = this.image;
    }
    if (element.propertiesGlow) {
      element.propertiesGlow.attr({
        opacity: 0.04
      });
    }
    previouslySelectedElement = this.objectEditor.show(element, element.objectName, element.properties);
    if (previouslySelectedElement && previouslySelectedElement !== element) {
      this.hideProperties(previouslySelectedElement);
    }
    return element.propertiesDisplayed = true;
  };

  Object.prototype.hideProperties = function(element) {
    if (element == null) {
      element = this.image;
    }
    if (element.propertiesGlow) {
      element.propertiesGlow.attr({
        opacity: 0
      });
    }
    this.objectEditor.hide(element);
    return element.propertiesDisplayed = false;
  };

  return Object;

})();
