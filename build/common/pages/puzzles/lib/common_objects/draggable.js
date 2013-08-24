// Generated by CoffeeScript 1.3.3
var Client, Transformer, draggable;

draggable = typeof exports !== "undefined" && exports !== null ? exports : provide('../common_objects/draggable', {});

Transformer = require('../common_objects/transformer').Transformer;

Client = require('../common_objects/client').Client;

draggable.Draggable = (function() {

  function Draggable() {}

  Draggable.prototype.initDrag = function(dragElement, trackDrag, center) {
    var offset,
      _this = this;
    this.dragElement = dragElement;
    this.trackDrag = trackDrag;
    this.transformer = new Transformer(this.dragElement);
    if (center) {
      offset = this.dragElement.offset();
      this.startX = offset.left + (offset.width / 2);
      this.startY = offset.top + (offset.height / 2);
    }
    return this.dragElement.bind('mousedown.drag touchstart.drag', function(e) {
      e.stop();
      $(document.body).one('mouseup.drag touchend.drag', function(e) {
        $(document.body).unbind('mousemove.drag touchstart.drag');
        return _this.drag(e, 'stop');
      });
      if (!center) {
        if (!_this.startX) {
          _this.startX = Client.x(e);
        }
        if (!_this.startY) {
          _this.startY = Client.y(e);
        }
      }
      _this.drag(e, 'start');
      return $(document.body).bind('mousemove.drag touchmove.drag', function(e) {
        return _this.drag(e, 'move');
      });
    });
  };

  Draggable.prototype.drag = function(e, state) {
    return this.dragTo({
      x: Client.x(e),
      y: Client.y(e),
      state: state
    });
  };

  Draggable.prototype.dragTo = function(_arg) {
    var state, x, y;
    x = _arg.x, y = _arg.y, state = _arg.state;
    this.currentX = x;
    this.currentY = y;
    this.transformer.translate(this.currentX - this.startX, this.currentY - this.startY);
    return this.trackDrag(this, this.currentX, this.currentY, state);
  };

  Draggable.prototype.resetDrag = function() {
    delete this.startX;
    delete this.startY;
    return this.transformer.translate(0, 0);
  };

  return Draggable;

})();
