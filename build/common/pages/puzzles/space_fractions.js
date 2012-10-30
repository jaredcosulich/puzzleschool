// Generated by CoffeeScript 1.3.3
var soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  SpaceFractions: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      this.levelName = _arg.levelName;
      this.template = this.loadTemplate("/build/common/templates/puzzles/space_fractions.html");
      this.loadScript('/build/common/pages/puzzles/lib/space_fractions.js');
      if (this.levelName === 'editor') {
        this.loadScript('/build/common/pages/puzzles/lib/space_fractions_editor.js');
      }
      return this.loadStylesheet('/build/client/css/puzzles/space_fractions.css');
    },
    build: function() {
      var languageScramble, row, rows;
      this.setTitle("Space Fractions - The Puzzle School");
      languageScramble = require('./lib/language_scramble');
      rows = (function() {
        var _i, _results;
        _results = [];
        for (row = _i = 0; _i < 10; row = ++_i) {
          _results.push({
            columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
          });
        }
        return _results;
      })();
      return this.html = wings.renderTemplate(this.template, {
        levelName: this.levelName || '',
        rows: rows
      });
    }
  }
});

soma.views({
  SpaceFractions: {
    selector: '#content .space_fractions',
    create: function() {
      var spaceFractions, spaceFractionsEditor;
      spaceFractions = require('./lib/space_fractions');
      this.viewHelper = new spaceFractions.ViewHelper({
        el: $(this.selector),
        rows: 10,
        columns: 10
      });
      if (this.el.data('level_name') === 'editor') {
        spaceFractionsEditor = require('./lib/space_fractions_editor');
        return this.editor = new spaceFractionsEditor.EditorHelper({
          el: $(this.selector),
          viewHelper: this.viewHelper
        });
      }
    }
  }
});

soma.routes({
  '/puzzles/space_fractions/:levelName': function(_arg) {
    var levelName;
    levelName = _arg.levelName;
    return new soma.chunks.SpaceFractions({
      levelName: levelName
    });
  },
  '/puzzles/space_fractions': function() {
    return new soma.chunks.SpaceFractions;
  }
});
