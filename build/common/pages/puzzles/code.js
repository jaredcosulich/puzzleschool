// Generated by CoffeeScript 1.3.3
var LEVELS, soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  Code: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      this.classId = _arg.classId, this.levelId = _arg.levelId;
      this.template = this.loadTemplate("/build/common/templates/puzzles/code.html");
      this.loadScript('http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/ace.js');
      this.loadScript('/build/common/pages/puzzles/lib/code.js');
      this.loadStylesheet('/build/client/css/puzzles/code.css');
      return this.level = LEVELS[1];
    },
    build: function() {
      this.setTitle("Code Puzzles - The Puzzle School");
      return this.html = wings.renderTemplate(this.template, {
        challenge: this.level.challenge,
        editors: this.level.editors
      });
    }
  }
});

soma.views({
  Code: {
    selector: '#content .code',
    create: function() {
      var code;
      code = require('./lib/code');
      return this.helper = new code.ViewHelper({
        el: this.el
      });
    },
    nextLevel: function() {
      return console.log('NEXT LEVEL');
    }
  }
});

soma.routes({
  '/puzzles/code/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.Code({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/code/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.Code({
      levelId: levelId
    });
  },
  '/puzzles/code': function() {
    return new soma.chunks.Code;
  }
});

LEVELS = [
  {}, {
    challenge: 'Replace the word "Hi" with the words "Let\'s get started!\'".',
    editors: [
      {
        title: 'Page HTML',
        type: 'html',
        code: '<html>\n    <body>\n        <h2>Hi</h2>\n    </body>\n</html>'
      }
    ]
  }
];
