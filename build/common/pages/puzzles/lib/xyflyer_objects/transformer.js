// Generated by CoffeeScript 1.3.3
var transformer;

transformer = typeof exports !== "undefined" && exports !== null ? exports : provide('./transformer', {});

transformer.Transformer = (function() {

  function Transformer(element) {
    this.el = $(element);
    this.dx = 0;
    this.dy = 0;
  }

  Transformer.prototype.run = function() {
    return this.el.css({
      webkitTransform: "matrix(1,0,0,1, " + this.dx + ", " + this.dy + ")",
      MozTransform: "matrix(1,0,0,1, " + this.dx + "px, " + this.dy + "px)",
      msTransform: "matrix(1,0,0,1, " + this.dx + ", " + this.dy + ")",
      OTransform: "matrix(1,0,0,1, " + this.dx + ", " + this.dy + ")",
      transform: "matrix(1,0,0,1, " + this.dx + ", " + this.dy + ")"
    });
  };

  Transformer.prototype.translate = function(dx, dy, adjustment) {
    if (adjustment == null) {
      adjustment = false;
    }
    this["" + (adjustment ? 'adjust' : 'set') + "Translation"](dx, dy);
    return this.run();
  };

  Transformer.prototype.adjustTranslation = function(dx, dy) {
    return this.setTranslation(this.dx + dx, this.dy + dy);
  };

  Transformer.prototype.setTranslation = function(dx, dy) {
    this.dx = dx;
    return this.dy = dy;
  };

  return Transformer;

})();
