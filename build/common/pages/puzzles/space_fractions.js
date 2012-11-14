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
      var row, rows;
      this.setTitle("Light It Up - The Puzzle School");
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
        custom: this.levelName === 'custom',
        editor: this.levelName === 'editor',
        rows: rows
      });
    }
  }
});

soma.views({
  SpaceFractions: {
    selector: '#content .space_fractions',
    create: function() {
      var introMessage, spaceFractions, spaceFractionsEditor, _ref,
        _this = this;
      spaceFractions = require('./lib/space_fractions');
      this.viewHelper = new spaceFractions.ViewHelper({
        el: $(this.selector),
        rows: 10,
        columns: 10
      });
      this.initEncode();
      this.levelName = this.el.data('level_name');
      if (!((_ref = this.levelName) != null ? _ref.length : void 0)) {
        introMessage = this.$('.intro');
        introMessage.css({
          top: this.el.offset().top + (this.el.height() / 2) - (introMessage.height() / 2),
          left: this.el.offset().left + (this.el.width() / 2) - (introMessage.width() / 2)
        });
        introMessage.animate({
          opacity: 1,
          duration: 500
        });
      } else if (this.levelName === 'editor') {
        spaceFractionsEditor = require('./lib/space_fractions_editor');
        this.editor = new spaceFractionsEditor.EditorHelper({
          el: $(this.selector),
          viewHelper: this.viewHelper,
          encodeMethod: function(json) {
            return _this.encode(json);
          }
        });
        this.$('.load_custom_level_data').bind('click', function() {
          _this.$('.level_editor').css({
            height: 'auto'
          });
          return _this.$('.load_custom_level_data').hide();
        });
      } else if (this.levelName === 'custom') {
        window.onhashchange = function() {
          return window.location.reload();
        };
        this.$('.load_custom_level_data').bind('click', function() {
          _this.$('.custom_level').css({
            height: 'auto'
          });
          return _this.$('.load_custom_level_data').hide();
        });
        this.$('.load_to_play').bind('click', function() {
          return _this.viewHelper.loadToPlay(_this.$('.level_description').val());
        });
      }
      if (window.location.hash) {
        this.loadLevelData();
      }
      return this.initInstructions();
    },
    loadLevelData: function() {
      var level;
      level = this.decode(decodeURIComponent(window.location.hash.replace(/^#/, '')));
      if (this.levelName === 'editor') {
        this.editor.levelDescription.val(level);
        return this.editor.load();
      } else {
        this.$('.level_description').val(level);
        return this.viewHelper.loadToPlay(level);
      }
    },
    initInstructions: function() {
      var _this = this;
      return this.$('.instructions_link').bind('click', function() {
        var instructions;
        instructions = _this.$('.instructions');
        instructions.css({
          top: _this.el.offset().top + (_this.el.height() / 2) - (instructions.height() / 2),
          left: _this.el.offset().left + (_this.el.width() / 2) - (instructions.width() / 2)
        });
        instructions.animate({
          opacity: 1,
          duration: 500
        });
        return $.timeout(10, function() {
          return $(document.body).one('click', function() {
            return instructions.animate({
              opacity: 0,
              duration: 500,
              complete: function() {
                return instructions.css({
                  top: -1000,
                  left: -1000
                });
              }
            });
          });
        });
      });
    },
    initEncode: function() {
      var object;
      this.encodeMap = {
        '"objects"': '~o',
        '"type"': '~t',
        '"index"': '~i',
        '"numerator"': '~n',
        '"denominator"': '~d',
        '"fullNumerator"': '~fN',
        '"fullDenominator"': '~fD',
        '"verified"': '~v',
        'true': '~u',
        'false': '~f'
      };
      for (object in this.viewHelper.objects) {
        this.encodeMap['"' + object + '"'] = "!" + (object.split(/_/ig).map(function(section) {
          return section[0];
        }).join(''));
      }
      return this.extraEncodeMap = {
        ':': '-',
        '"': '*',
        ',': "'",
        '=': '+',
        '{': '(',
        '}': ')'
      };
    },
    encode: function(json) {
      var encode, extraEncode, key, regExp, _i, _len, _ref,
        _this = this;
      _ref = ((function() {
        var _results;
        _results = [];
        for (key in this.encodeMap) {
          _results.push(key);
        }
        return _results;
      }).call(this)).sort(function(a, b) {
        return b.length - a.length;
      });
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        encode = _ref[_i];
        regExp = new RegExp(encode, 'g');
        json = json.replace(regExp, this.encodeMap[encode]);
      }
      for (extraEncode in this.extraEncodeMap) {
        regExp = new RegExp('\\' + extraEncode, 'g');
        json = json.replace(regExp, this.extraEncodeMap[extraEncode]);
      }
      return json;
    },
    decode: function(json) {
      var encode, extraEncode, key, regExp, _i, _len, _ref,
        _this = this;
      _ref = ((function() {
        var _results;
        _results = [];
        for (key in this.encodeMap) {
          _results.push(key);
        }
        return _results;
      }).call(this)).sort(function(a, b) {
        return b.length - a.length;
      });
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        encode = _ref[_i];
        regExp = new RegExp(this.encodeMap[encode], 'g');
        json = json.replace(regExp, encode);
      }
      for (extraEncode in this.extraEncodeMap) {
        regExp = new RegExp('\\' + this.extraEncodeMap[extraEncode], 'g');
        json = json.replace(regExp, extraEncode);
      }
      return json;
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
  },
  '/puzzles/light_it_up/:levelName': function(_arg) {
    var levelName;
    levelName = _arg.levelName;
    return new soma.chunks.SpaceFractions({
      levelName: levelName
    });
  },
  '/puzzles/light_it_up': function() {
    return new soma.chunks.SpaceFractions;
  }
});
