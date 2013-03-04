// Generated by CoffeeScript 1.3.3
var STAGES, soma, wings,
  _this = this;

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
      this.loadScript('/assets/third_party/ace/ace.js');
      this.loadScript('/build/common/pages/puzzles/lib/code.js');
      this.loadStylesheet('/build/client/css/puzzles/code.css');
      if (!this.levelId) {
        return this.levelId = STAGES[0].levels[0].id;
      }
    },
    build: function() {
      this.setTitle("Code Puzzles - The Puzzle School");
      return this.html = wings.renderTemplate(this.template, {
        level: this.levelId,
        stages: STAGES
      });
    }
  }
});

soma.views({
  Code: {
    selector: '#content .code',
    create: function() {
      var code,
        _this = this;
      code = require('./lib/code');
      this.originalHTML = this.el.find('.dynamic_content').html();
      this.level = this.findLevel(this.el.data('level'));
      this.helper = new code.ViewHelper({
        el: this.el,
        completeLevel: function() {
          return _this.completeLevel();
        }
      });
      this.helper.initLevel(this.level);
      return this.initLevelSelector();
    },
    findLevel: function(levelId) {
      var level, stage, _i, _len;
      for (_i = 0, _len = STAGES.length; _i < _len; _i++) {
        stage = STAGES[_i];
        level = ((function() {
          var _j, _len1, _ref, _results;
          _ref = stage.levels;
          _results = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            level = _ref[_j];
            if (level.id === levelId) {
              _results.push(level);
            }
          }
          return _results;
        })())[0];
        if (level) {
          return level;
        }
      }
    },
    initLevelSelector: function() {
      var level, _i, _len, _ref, _results,
        _this = this;
      this.levelSelector = this.$('.level_selector');
      _ref = this.levelSelector.find('.level');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        level = _ref[_i];
        _results.push((function(level) {
          level = $(level);
          return level.bind('click', function() {
            _this.level = _this.findLevel(level.data('id'));
            _this.el.find('.dynamic_content').html(_this.originalHTML);
            _this.helper.initLevel(_this.level);
            history.pushState(null, null, "/puzzles/code/" + _this.level.id);
            return _this.hideLevelSelector();
          });
        })(level));
      }
      return _results;
    },
    completeLevel: function() {
      var challenge, levelIcon,
        _this = this;
      levelIcon = this.$("#level_" + this.level.id).find('img');
      if (levelIcon.attr('src').indexOf('complete') === -1) {
        levelIcon.attr('src', levelIcon.attr('src').replace('level', 'level_complete'));
      }
      challenge = this.$('.challenge');
      return challenge.animate({
        opacity: 0,
        duration: 250,
        complete: function() {
          challenge.html('<h3 class=\'success\'>Success!</h3>\n<a class=\'next_level\'>Select A New Level</a>');
          challenge.find('.next_level').bind('click', function() {
            return _this.showLevelSelector();
          });
          return challenge.animate({
            opacity: 1,
            duration: 250
          });
        }
      });
    },
    showLevelSelector: function() {
      this.levelSelector.css({
        opacity: 0,
        top: 60,
        left: (this.el.width() - this.levelSelector.width()) / 2
      });
      return this.levelSelector.animate({
        opacity: 1,
        duration: 250
      });
    },
    hideLevelSelector: function() {
      var _this = this;
      return this.levelSelector.animate({
        opacity: 0,
        duration: 250,
        complete: function() {
          return _this.levelSelector.css({
            top: -1000,
            left: -1000
          });
        }
      });
    },
    saveProgress: function(puzzleProgress, callback) {
      var languages, levelInfo, levelName, levelUpdates, levels, paddingTop, puzzleUpdates, registrationFlag, _ref,
        _this = this;
      if (this.cookies.get('user')) {
        puzzleUpdates = this.getUpdates(puzzleProgress);
        if (!puzzleUpdates) {
          return;
        }
        levelUpdates = {};
        _ref = puzzleUpdates.levels;
        for (languages in _ref) {
          levels = _ref[languages];
          for (levelName in levels) {
            levelInfo = levels[levelName];
            levelUpdates["" + languages + "/" + levelName] = levelInfo;
          }
        }
        delete puzzleUpdates.levels;
        return $.ajaj({
          url: "/api/puzzles/code/update",
          method: 'POST',
          headers: {
            'X-CSRF-Token': this.cookies.get('_csrf', {
              raw: true
            })
          },
          data: {
            puzzleUpdates: puzzleUpdates,
            levelUpdates: levelUpdates
          },
          success: function() {
            _this.puzzleData = JSON.parse(JSON.stringify(puzzleProgress));
            if (callback) {
              return callback();
            }
          }
        });
      } else if (puzzleProgress.levels) {
        window.postRegistration.push(function(callback) {
          return _this.saveProgress(puzzleProgress, callback);
        });
        if (!this.answerCount) {
          this.answerCount = 0;
        }
        this.answerCount += 1;
        if (this.answerCount > 7) {
          if (this.answerCount % 8 === 0) {
            registrationFlag = $('.register_flag');
            paddingTop = registrationFlag.css('paddingTop');
            $.timeout(1000, function() {
              return registrationFlag.animate({
                paddingTop: 45,
                paddingBottom: 45,
                duration: 1000,
                complete: function() {
                  return $.timeout(1000, function() {
                    return registrationFlag.animate({
                      paddingTop: paddingTop,
                      paddingBottom: paddingTop,
                      duration: 1000
                    });
                  });
                }
              });
            });
          }
          return $(window).bind('beforeunload', function() {
            return 'If you leave this page you\'ll lose your progress on this level. You can save your progress above.';
          });
        }
      }
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

STAGES = [
  {
    name: 'Basic HTML',
    levels: [
      {
        id: 1361991179382,
        challenge: 'Figure out how to change the word "Welcome" to the word "Hello World\'".',
        editors: [
          {
            title: 'Page HTML',
            type: 'html',
            code: '<html>\n    <body>\n        <h1>Welcome</h1>\n    </body>\n</html>'
          }
        ],
        description: '<p>\n    The code displayed in the \'editor\' (where it says \'Page HTML\') \n    is all the code you need to create the simplest website.\n</p>\n<p>\n    The &lt;h1&gt; is used to designate important information and so is displayed in\n    bold large text.\n</p>\n<p>\n    You can learn more about the &lt;h1&gt; tag by googling:\n    <a href=\'https://www.google.com/search?q=h1+tag\' target=\'_blank\'>\'h1 tag\'</a>.\n</p>',
        hints: ['The \'editor\', where you see the words \'Page HTML\' is editable.', 'In the editor, change the word \'Welcome\' to \'Hello World\''],
        tests: [
          {
            description: 'The content contains an &lt;h1&gt; tag with html content \'Hello World\'.',
            test: function(_arg) {
              var body, cleanHtml;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              return cleanHtml(body.find('h1').html()) === 'hello world';
            }
          }
        ]
      }, {
        id: 1361991210187,
        challenge: 'Figure out how to print the words \'html tags are easy\' in an &lt;h1&gt; tag.',
        editors: [
          {
            title: 'Page HTML',
            type: 'html',
            code: '<html>\n    <body>\n        \n    </body>\n</html>'
          }
        ],
        description: '<p>\n    Here we\'ve removed the tag from the body of the html.\n</p>\n<p>\n    You simply need to put it back and don\'t forget to close the tag.\n</p>',
        hints: ['Create a new &lt;h1&gt; tag by typing "&lt;h1&gt;" between &lt;body&gt; and &lt;/body&gt;', 'You need to close the &lt;h1&gt; tag with a closing tag.', 'The closing tag looks like &lt;/h1&gt;'],
        tests: [
          {
            description: 'The content contains an &lt;h1&gt; tag with html content \'html tags are easy\'.',
            test: function(_arg) {
              var body, cleanHtml;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              return cleanHtml(body.find('h1').html()) === 'html tags are easy';
            }
          }, {
            description: 'The &lt;h1&gt; tag is properly closed.',
            test: function(_arg) {
              var body;
              body = _arg.body;
              return body.html().indexOf('</h1>') > -1;
            }
          }
        ]
      }, {
        id: 1361997759104,
        challenge: 'Figure out how to change the smallest text to \'this is the smallest header\'.',
        editors: [
          {
            title: 'Page HTML',
            type: 'html',
            code: '<html>\n    <body>\n        <h2>This is a header</h2>\n        <h4>This is a header</h4>\n        <h6>This is a header</h6>\n        <h1>This is a header</h1>\n        <h5>This is a header</h5>\n        <h3>This is a header</h3>\n    </body>\n</html>'
          }
        ],
        description: '<p>\n    Here is a simply demo of all of the available header tags.\n</p>\n<p>\n    As you can see they range in size, designating the intent to show important information.\n</p>',
        hints: ['The &lt;h4&gt; is smaller than the &lt;h3&gt; tag.', 'Change the text inside the &lt;h6&gt; tag.'],
        tests: [
          {
            description: 'The header with the smallest text size contains the text \'this is the smallest header\'.',
            test: function(_arg) {
              var body, cleanHtml;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              return cleanHtml(body.find('h6').html()) === 'this is the smallest header';
            }
          }
        ]
      }, {
        id: 1362028733004,
        challenge: 'Figure out how to make the text \'such as the &lt;b&gt; tag\' bold using the &lt;b&gt; tag.',
        editors: [
          {
            title: 'Page HTML',
            type: 'html',
            code: '<html>\n  <body>\n    <h1>Playing With Tags</h1>\n    <p>\n      The &lt;p&gt; tag is for paragraph text.\n    </p>\n    <p>\n      If can contain other tags, such as the \n      &lt;b&gt; tag, which makes text bold.\n    </p>\n  </body>\n</html>'
          }
        ],
        description: '<p>\n    There are many html tags, each of which have different attributes.\n</p>\n<p>\n    You can find a list of availablt html tags by googling \n    <a href=\'https://www.google.com/search?q=html+tags\' target=\'_blank\'>html tags</a>\n</p>\n<p>\n    In order to make a tag display in plain text you need to use an html character entity.\n</p>\n<p>\n    You can find a full list of character entitities <a href=\'http://www.w3schools.com/html/html_entities.asp\' target=\'_blank\'>here</a>.\n</p>',
        hints: ['Wrap text in an html tag to apply the attributes of that tag.', 'Simply put a &lt;b&gt; before the \'such as the &lt;b&gt; tag\' text and a &lt;b&gt; after.', 'In the end it should look like &lt;b&gt;such as the &amp;lt;b&amp;gt; tag&lt;/b&gt; with no comma inside the tag.'],
        tests: [
          {
            description: 'There is a &lt;b&gt; tag with the html \'such as the &lt;b&gt; tag\'.',
            test: function(_arg) {
              var body, cleanHtml, html;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              html = cleanHtml(body.find('b').html());
              return html === 'such as the &lt;b&gt; tag';
            }
          }
        ]
      }, {
        id: 1362072970429,
        challenge: 'Figure out how to make the header text red.',
        editors: [
          {
            title: 'Page HTML',
            type: 'html',
            code: '<html>\n  <body>\n    <h1 style=\'color: green\'>Playing With Tags</h1>\n    <p>\n      Html tags can contain attributes that modify the behavior of the tag.\n    </p>\n    <p>\n      This is an example of an attribute modifying the tags style.\n    </p>\n    <p>\n      The \'style\' attribute with a value of \'color: green\' is making the &lt;h1&gt; turn green.\n    </p>\n  </body>\n</html>'
          }
        ],
        description: '<p>\n    You can modify the attributes of a given tag by adding different attributes within the tag.\n</p>',
        hints: ['Look for the word \'green\' in the html.', 'Change the word \'green\' to the word \'red\'.'],
        tests: [
          {
            description: 'The &lt;h1&gt; tag has a color of red.',
            test: function(_arg) {
              var body, cleanHtml;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              return body.find('h1').css('color') === 'red';
            }
          }
        ]
      }, {
        id: 1362074585433,
        challenge: 'Figure out how to change the link to display and direct to a new website.',
        editors: [
          {
            title: 'Page HTML',
            type: 'html',
            code: '<html>\n  <body>\n    <h1>Linking Fun</h1>\n    <p>\n      Anchor tags (&lt;a&gt;) can be used to place a link to another website on your page.\n    </p>\n    <p>\n      This link goes to <a href=\'http://puzzleschool.com\' target=\'_new\'>The Puzzle School</a>.\n    </p>\n  </body>\n</html>'
          }
        ],
        description: '<p>\n    The anchor (&lt;a&gt;) tag allows you to jump to another anchor point.\n</p>\n<p>\n    The anchor point can be on the same page or a new page.\n</p>\n<p>\n    Anchor tags are usually used to link to another website using the \'href\' attribute.\n</p>',
        hints: ['The \'href\' attribute within a link (&lt;a&gt;) tag describes the destination of the link.', 'Change the href attribute to point to a different website besides http://puzzleschool.com', 'To change the title of the link, simply edit the html inside.', 'Change the text \'The Puzzle School\' to a different website\'s name.'],
        tests: [
          {
            description: 'The &lt;a&gt; tag has a link to a new website.',
            test: function(_arg) {
              var body, cleanHtml, link;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              link = body.find('a');
              if (link.attr('href') === 'http://puzzleschool.com') {
                return false;
              }
              return true;
            }
          }, {
            description: 'The &lt;a&gt; tag\'s html if for a different website.',
            test: function(_arg) {
              var body, cleanHtml, link;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              link = body.find('a');
              if (link.html() === 'The Puzzle School') {
                return false;
              }
              return true;
            }
          }
        ]
      }
    ]
  }, {
    name: 'Basic Javascript',
    levels: [
      {
        id: 1362099940993,
        challenge: 'Figure out how to make the number on the page count up to 10.',
        editors: [
          {
            title: 'Page Javascript',
            type: 'javascript',
            code: 'if (window.counterInterval) {\n    window.clearInterval(window.counterInterval);\n}\n\nwindow.counterInterval = setInterval(function() {\n  var counter = document.getElementById(\'counter\');\n  if (!counter) return;\n      \n  var value = parseInt(counter.innerHTML);\n  value += 1;\n  if (value > 5) {\n    value = 1;\n  }\n  counter.innerHTML = value;\n  \n}, 1000);                        '
          }, {
            title: 'Page HTML',
            type: 'html',
            code: '<html>\n  <body>\n    <h1>A Little Javascript</h1>\n    <p>\n      Javascript lets you create dynamic web pages, that can range in complexity.\n    </p>\n    <p>\n      In fact this whole website is created using just javascript, html, and css.\n    </p>\n    <p>\n      Try to make the number below count to 10 instead of 5:\n    </p>\n    <h2 id=\'counter\'>1</h2>\n  </body>\n</html>'
          }
        ],
        description: '<p>\n    Here we see a simple (even though it may look complicated) javascript function.\n</p>\n<p>\n    There is a lot going on in this function. We\'re going to save a full explanation\n    of everything until later, but you may want to google \'setInterval\', which\n    is the part of this function that enables the counting to happen.\n</p>',
        hints: ['The function resets when the html in the &lt;h2&gt hits 5.', 'Change the reset value to 10.', 'The reset value is set in this line: if (value > 5) {', 'Change the 5 in that line to 10'],
        tests: [
          {
            description: 'The html inside the &lt;h2&gt; tag reads 10.',
            test: function(_arg) {
              var body, cleanHtml;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              if (cleanHtml(body.find('h2').html()) === '10') {
                clearInterval(_this.testInterval);
                return true;
              }
              if (_this.testInterval) {
                return false;
              }
              _this.testInterval = setInterval(window.retest, 100);
              return false;
            }
          }
        ]
      }, {
        id: 1362424704636,
        challenge: 'Figure out how to make the button turn the header color green instead or red.',
        editors: [
          {
            title: 'Page Javascript',
            type: 'javascript',
            code: 'var button = document.getElementById(\'color_button\');\nbutton.onclick = function () {\n  var header = document.getElementById(\'header\');\n  header.style.color = \'red\';\n};'
          }, {
            title: 'Page HTML',
            type: 'html',
            code: '<html>\n  <body>\n    <h1 id=\'header\'>Button Binding</h1>\n    <p>\n      Javascript lets attach or bind actions to html elements on the page.\n    </p>\n    <p>\n      In this case clicking the button below will turn change the color of\n      the header from black to red.\n    </p>\n    <p>\n      Try to make the button change the color of the header to green instead:\n    </p>\n    <button id=\'color_button\'>Click Me</button>\n  </body>\n</html>'
          }
        ],
        description: '<p>\n    No description provided.\n</p>',
        hints: ['Javascript can access the color attribute using \'.style.color\'', 'Change the function to set .style.color to \'green\''],
        tests: [
          {
            description: 'The color of the &lt;h2&gt; element is green.',
            test: function(_arg) {
              var body, cleanHtml;
              body = _arg.body, cleanHtml = _arg.cleanHtml;
              if (body.find('#header').css('color') === 'green') {
                clearInterval(_this.testInterval);
                return true;
              }
              if (_this.testInterval) {
                return false;
              }
              _this.testInterval = setInterval(window.retest, 100);
              return false;
            }
          }
        ]
      }
    ]
  }
];
