// Generated by CoffeeScript 1.3.3
var LEVELS, soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  WordProblems: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      this.classId = _arg.classId, this.levelId = _arg.levelId;
      this.template = this.loadTemplate("/build/common/templates/puzzles/word_problems.html");
      this.loadScript('/build/common/pages/puzzles/lib/common_objects/transformer.js');
      this.loadScript('/build/common/pages/puzzles/lib/common_objects/client.js');
      this.loadScript('/build/common/pages/puzzles/lib/word_problem_objects/component.js');
      this.loadScript('/build/common/pages/puzzles/lib/word_problem_objects/operator.js');
      this.loadScript('/build/common/pages/puzzles/lib/word_problem_objects/number.js');
      this.loadScript('/build/common/pages/puzzles/lib/word_problem_objects/interaction.js');
      this.loadScript('/build/common/pages/puzzles/lib/word_problem_objects/index.js');
      this.loadScript('/build/common/pages/puzzles/lib/word_problems.js');
      return this.loadStylesheet('/build/client/css/puzzles/word_problems.css');
    },
    build: function() {
      this.setTitle("Interactive Word Problems - The Puzzle School");
      return this.html = wings.renderTemplate(this.template);
    }
  }
});

soma.views({
  WordProblems: {
    selector: '#content .word_problems',
    create: function() {
      var wordProblems;
      this.level = LEVELS[0];
      wordProblems = require('./lib/word_problems');
      return this.viewHelper = new wordProblems.ViewHelper({
        el: this.el,
        level: this.level
      });
    }
  }
});

soma.routes({
  '/puzzles/word_problems/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.WordProblems({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/word_problems/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.WordProblems({
      levelId: levelId
    });
  },
  '/puzzles/word_problems': function() {
    return new soma.chunks.WordProblems;
  }
});

LEVELS = [
  {
    id: 1367965328479,
    difficulty: 1,
    problem: 'Jane has 9 balloons. 6 are green and the rest are blue. How many balloons are blue?',
    numbers: [
      {
        label: 'Balloons'
      }, {
        label: 'Green Balloons',
        colorIndex: 3
      }
    ]
  }
];