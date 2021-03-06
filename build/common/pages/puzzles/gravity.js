// Generated by CoffeeScript 1.3.3
var soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  Gravity: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      _arg;
      this.template = this.loadTemplate('/build/common/templates/puzzles/gravity.html');
      this.loadScript('/build/common/pages/puzzles/lib/gravity.js');
      return this.loadStylesheet('/build/client/css/puzzles/gravity.css');
    },
    build: function() {
      this.setTitle("Gravity - The Puzzle School");
      return this.html = wings.renderTemplate(this.template);
    }
  }
});

soma.views({
  Gravity: {
    selector: '#content .gravity',
    create: function() {
      var gravity;
      $('.register_flag').hide();
      gravity = require('./lib/gravity');
      return this.viewHelper = new gravity.ViewHelper({
        el: $(this.selector)
      });
    }
  }
});

soma.routes({
  '/puzzles/gravity': function() {
    return new soma.chunks.Gravity;
  }
});
