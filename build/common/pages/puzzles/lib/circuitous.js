// Generated by CoffeeScript 1.3.3
var circuitous, fn, name, _ref;

circuitous = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/circuitous', {});

_ref = require('./circuitous_objects/index');
for (name in _ref) {
  fn = _ref[name];
  circuitous[name] = fn;
}

circuitous.ChunkHelper = (function() {

  function ChunkHelper() {}

  return ChunkHelper;

})();

circuitous.ViewHelper = (function() {

  function ViewHelper(_arg) {
    this.el = _arg.el;
    this.init();
  }

  ViewHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  ViewHelper.prototype.init = function() {
    var _this = this;
    this.board = new circuitous.Board({
      el: this.$('.board')
    });
    this.selector = new circuitous.Selector({
      add: function(component) {
        return _this.addComponent(component, true);
      },
      button: this.$('.add_component'),
      selectorHtml: '<h2>Add Another Component</h2>'
    });
    return this.initValues();
  };

  ViewHelper.prototype.addComponent = function(component, onBoard) {
    var img,
      _this = this;
    if (onBoard == null) {
      onBoard = false;
    }
    component.appendTo(this.board.cells);
    component.setName("" + component.constructor.name + " #" + 1);
    img = component.el.find('img');
    component.el.css({
      left: onBoard ? 10 : -10000
    });
    return img.bind('load', function() {
      component.el.width(img.width());
      component.el.height(img.height());
      return $.timeout(10, function() {
        component.initCurrent();
        component.initTag(_this.$('.show_values').hasClass('on'));
        return component.initDrag(component.el, function(component, x, y, stopDrag) {
          return _this.dragComponent(component, x, y, stopDrag);
        }, true, component.dragBuffer);
      });
    });
  };

  ViewHelper.prototype.dragComponent = function(component, x, y, state) {
    var _ref1;
    if (state === 'start') {
      this.board.removeComponent(component);
    } else if (state === 'stop') {
      if (!this.board.addComponent(component, x, y)) {
        this.board.removeComponent(component);
        component.resetDrag();
      }
    }
    return (_ref1 = component.tag) != null ? _ref1.position() : void 0;
  };

  ViewHelper.prototype.initValues = function() {
    var showValues,
      _this = this;
    showValues = this.$('.show_values');
    return showValues.bind('click.toggle_values touchstart.toggle_values', function() {
      var cid, component, hideValues, _ref1, _results;
      hideValues = showValues.hasClass('on');
      showValues.removeClass(hideValues ? 'on' : 'off');
      showValues.addClass(hideValues ? 'off' : 'on');
      _ref1 = _this.board.components;
      _results = [];
      for (cid in _ref1) {
        component = _ref1[cid];
        _results.push(component.tag[hideValues ? 'hide' : 'show']());
      }
      return _results;
    });
  };

  return ViewHelper;

})();
