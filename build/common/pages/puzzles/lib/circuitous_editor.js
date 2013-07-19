// Generated by CoffeeScript 1.3.3
var circuitousEditor;

circuitousEditor = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/circuitous_editor', {});

circuitousEditor.EditorHelper = (function() {

  function EditorHelper(_arg) {
    this.el = _arg.el;
    this.initOptions();
  }

  EditorHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  EditorHelper.prototype.initOptions = function() {
    this.board = new circuitous.Board({
      el: this.$('.board')
    });
    return this.options = new circuitous.Options({
      el: this.$('.options'),
      rows: 5,
      columns: 4,
      board: this.board
    });
  };

  return EditorHelper;

})();
