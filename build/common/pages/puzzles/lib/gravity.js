// Generated by CoffeeScript 1.3.3
var gravity;

gravity = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/gravity', {});

gravity.ViewHelper = (function() {

  function ViewHelper(_arg) {
    this.el = _arg.el;
    this.wells = [];
    this.asteroids = [];
    this.initGravityWells();
    this.initAsteroids();
    this.lastStep = new Date();
    this.step();
  }

  ViewHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  ViewHelper.prototype.initAsteroids = function() {
    return this.asteroids.push(new gravity.Asteroid(this.el, 100, 100));
  };

  ViewHelper.prototype.initGravityWells = function() {
    var _this = this;
    return this.el.bind('mousedown.well', function(e) {
      var well;
      well = new gravity.Well(_this.el, e.offsetX, e.offsetY);
      well.grow();
      _this.el.bind('mouseup.well', function(e) {
        return well.shrink();
      });
      return _this.wells.push(well);
    });
  };

  ViewHelper.prototype.step = function() {
    var asteroid, well, _i, _j, _len, _len1, _ref, _ref1,
      _this = this;
    _ref = this.wells;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      well = _ref[_i];
      if (!(!well.deleted)) {
        continue;
      }
      well.modify();
      well.affect(this.asteroids);
    }
    _ref1 = this.asteroids;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      asteroid = _ref1[_j];
      asteroid.move(new Date() - this.lastStep);
    }
    this.lastStep = new Date();
    return setTimeout((function() {
      return _this.step();
    }), 10);
  };

  return ViewHelper;

})();

gravity.Well = (function() {

  Well.prototype.MAX_RADIUS = 25;

  Well.prototype.MASS_RATIO = 10;

  Well.prototype.GRAVITATIONAL_CONSTANT = 6.67 * Math.pow(10, -11);

  function Well(container, x, y) {
    this.container = container;
    this.x = x;
    this.y = y;
    this.el = $(document.createElement('DIV'));
    this.el.addClass('well');
    this.el.css({
      left: this.x,
      top: this.y
    });
    this.radius = 0;
    this.container.append(this.el);
  }

  Well.prototype["delete"] = function() {
    this.el.remove();
    return this.deleted = true;
  };

  Well.prototype.grow = function() {
    return this.rate = 1;
  };

  Well.prototype.shrink = function() {
    return this.rate = -1;
  };

  Well.prototype.stop = function() {
    return delete this.rate;
  };

  Well.prototype.modify = function() {
    if (this.rate == null) {
      return;
    }
    this.radius += this.rate;
    if (this.radius > this.MAX_RADIUS) {
      this.stop();
      return;
    }
    if (this.radius < 0) {
      this["delete"]();
    }
    return this.el.css({
      boxShadow: "0px 0 " + (this.radius * 2) + "px " + this.radius + "px rgba(255,255,255,0.8)"
    });
  };

  Well.prototype.affect = function(asteroids) {
    var asteroid, distance, force, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = asteroids.length; _i < _len; _i++) {
      asteroid = asteroids[_i];
      distance = Math.sqrt(Math.pow(this.x - asteroid.x, 2) + Math.pow(this.y - asteroid.y, 2));
      force = (this.GRAVITATIONAL_CONSTANT * asteroid.mass * (this.MASS_RATIO * this.radius)) / Math.pow(distance, 2);
      _results.push(console.log(distance, force));
    }
    return _results;
  };

  return Well;

})();

gravity.Asteroid = (function() {

  function Asteroid(container, x, y) {
    this.container = container;
    this.x = x;
    this.y = y;
    this.mass = 10;
    this.speed = 0.25;
    this.direction = 270;
    this.el = $(document.createElement('DIV'));
    this.el.addClass('asteroid');
    this.container.append(this.el);
    this.move(1);
  }

  Asteroid.prototype.move = function(time) {
    var distance, radians;
    distance = this.speed * time;
    radians = this.direction * (Math.PI / 180);
    this.x = this.x + (Math.cos(radians) * distance);
    this.y = this.y + (Math.sin(radians) * distance);
    if (this.x > this.container.width()) {
      this.x = 0;
    }
    if (this.x < 0) {
      this.x = this.container.width();
    }
    if (this.y > this.container.height()) {
      this.y = 0;
    }
    if (this.y < 0) {
      this.y = this.container.height();
    }
    return this.el.css({
      left: this.x,
      top: this.y
    });
  };

  return Asteroid;

})();
