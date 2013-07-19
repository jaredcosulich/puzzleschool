// Generated by CoffeeScript 1.3.3
var animation;

animation = typeof exports !== "undefined" && exports !== null ? exports : provide('../common_objects/animation', {});

animation.Animation = (function() {

  function Animation(calculation) {
    this.calculation = calculation != null ? calculation : false;
    this.animations = [];
    this.animationIndex = 0;
    this.id = new Date().getTime();
  }

  Animation.prototype.frame = function() {
    if (this.calculation) {
      return function(callback) {
        return window.setTimeout((function() {
          return callback(+new Date());
        }), 11);
      };
    } else {
      return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
        return window.setTimeout((function() {
          return callback(+new Date());
        }), 11);
      };
    }
  };

  Animation.prototype.queueAnimation = function(time, method) {
    return this.animations.push({
      method: method,
      time: time,
      index: this.animationIndex += 1
    });
  };

  Animation.prototype.start = function(_arg) {
    var method, time,
      _this = this;
    time = _arg.time, method = _arg.method;
    if (method) {
      this.method = method;
      this.time = time;
    } else {
      if (!this.nextAnimation()) {
        return;
      }
    }
    this.stopped = false;
    this.lastTime = null;
    this.elapsed = 0;
    return this.frame()(function(t) {
      return _this.tick(t);
    });
  };

  Animation.prototype.nextAnimation = function() {
    if (!this.animations.length) {
      return false;
    }
    animation = this.animations.splice(0, 1)[0];
    this.time = animation.time;
    this.method = animation.method;
    this.index = animation.index;
    return true;
  };

  Animation.prototype.tick = function(time) {
    var deltaTime, portion,
      _this = this;
    if (this.stopped) {
      return;
    }
    if (this.lastTime != null) {
      deltaTime = time - this.lastTime;
      this.elapsed += deltaTime;
      if (!this.time || this.elapsed <= this.time) {
        if (this.time) {
          portion = this.elapsed / this.time;
        }
        this.method({
          deltaTime: deltaTime,
          portion: portion,
          elapsed: this.elapsed
        });
      } else if (this.animations.length) {
        this.elapsed -= this.time;
        this.nextAnimation();
      } else {
        this.method(time, 1);
        return;
      }
    }
    this.lastTime = time;
    return setTimeout((function() {
      return _this.frame()(function(t) {
        return _this.tick(t);
      });
    }), 0);
  };

  Animation.prototype.stop = function() {
    return this.stopped = true;
  };

  return Animation;

})();
