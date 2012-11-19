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
      var _this = this;
      this.classId = _arg.classId, this.levelId = _arg.levelId;
      this.template = this.loadTemplate("/build/common/templates/puzzles/space_fractions.html");
      this.loadScript('/build/common/pages/puzzles/lib/space_fractions.js');
      if (this.levelId === 'editor') {
        this.loadScript('/build/common/pages/puzzles/lib/space_fractions_editor.js');
      }
      this.loadStylesheet('/build/client/css/puzzles/space_fractions.css');
      if (this.levelId) {
        return this.loadData({
          url: "/api/puzzles/levels/" + this.levelId,
          success: function(levelInfo) {
            _this.levelInfo = levelInfo;
          },
          error: function() {
            if (typeof window !== "undefined" && window !== null ? window.alert : void 0) {
              return alert('We were unable to load the information for this level. Please check your internet connection.');
            }
          }
        });
      }
    },
    build: function() {
      var row, rows, _ref;
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
        levelId: this.levelId || '',
        classId: this.classId || '',
        custom: this.levelId === 'custom',
        editor: this.levelId === 'editor',
        rows: rows,
        instructions: (_ref = this.levelInfo) != null ? _ref.instructions : void 0
      });
    }
  }
});

soma.views({
  SpaceFractions: {
    selector: '#content .space_fractions',
    create: function() {
      var introMessage, spaceFractions, spaceFractionsEditor,
        _this = this;
      spaceFractions = require('./lib/space_fractions');
      this.viewHelper = new spaceFractions.ViewHelper({
        el: $(this.selector),
        rows: 10,
        columns: 10,
        registerEvent: function(eventInfo) {
          return _this.registerEvent(eventInfo);
        }
      });
      this.user = this.cookies.get('user');
      this.initEncode();
      this.classId = this.el.data('class_id');
      if (this.classId && (isNaN(this.classId) && !this.classId.length)) {
        this.classId = null;
      }
      this.levelId = this.el.data('level_id');
      if (this.levelId && (isNaN(this.levelId) && !this.levelId.length)) {
        this.levelId = null;
      }
      if (!this.levelId) {
        introMessage = this.$('.intro');
        introMessage.css({
          top: ($.viewport().height / 2) - (introMessage.height() / 2) + window.scrollY,
          left: ($.viewport().width / 2) - (introMessage.width() / 2)
        });
        introMessage.animate({
          opacity: 1,
          duration: 500
        });
      } else if (this.levelId === 'editor') {
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
      } else if (this.levelId === 'custom') {
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
      this.loadLevelData(window.location.hash || this.$('.level_instructions').html());
      return this.initInstructions();
    },
    loadLevelData: function(instructions) {
      var level;
      instructions = instructions.replace(/\s/g, '');
      if (!(instructions != null ? instructions.length : void 0)) {
        return;
      }
      level = this.decode(decodeURIComponent(instructions.replace(/^#/, '')));
      if (level[0] !== '{') {
        return;
      }
      if (this.levelId === 'editor') {
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
          top: ($.viewport().height / 2) - (instructions.height() / 2) + window.scrollY,
          left: ($.viewport().width / 2) - (instructions.width() / 2)
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
    },
    registerEvent: function(_arg) {
      var info, type;
      type = _arg.type, info = _arg.info;
      this.pendingEvents || (this.pendingEvents = []);
      this.pendingEvents.push({
        type: type,
        info: JSON.stringify(info),
        puzzle: 'fractions',
        classId: this.classId,
        levelId: this.levelId
      });
      if (!this.lastEvent) {
        this.timeBetweenEvents = 0;
        this.lastEvent = new Date();
      } else {
        this.timeBetweenEvents += new Date().getTime() - this.lastEvent.getTime();
        this.lastEvent = new Date();
      }
      return this.sendEvents();
    },
    sendEvents: function() {
      var event, pendingEvents, timeBetweenEvents, _ref,
        _this = this;
      if (!((_ref = this.pendingEvents) != null ? _ref.length : void 0)) {
        return;
      }
      if (this.sendingEvents) {
        return;
      }
      this.sendingEvents = true;
      pendingEvents = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = this.pendingEvents;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          event = _ref1[_i];
          _results.push(event);
        }
        return _results;
      }).call(this);
      this.pendingEvents = [];
      timeBetweenEvents = this.timeBetweenEvents;
      this.timeBetweenEvents = 0;
      return $.ajaj({
        url: '/api/events/create',
        method: 'POST',
        headers: {
          'X-CSRF-Token': this.cookies.get('_csrf', {
            raw: true
          })
        },
        data: {
          events: pendingEvents
        },
        success: function() {
          var key, statUpdates, updates, _i, _len;
          statUpdates = {
            user: {
              objectType: 'user',
              objectId: _this.user.id,
              actions: []
            },
            "class": {
              objectType: 'class',
              objectId: _this.classId,
              actions: []
            },
            levelClass: {
              objectType: 'level_class',
              objectId: "" + _this.levelId + "/" + _this.classId,
              actions: []
            },
            userLevelClass: {
              objectType: 'user_level_class',
              objectId: "" + _this.user.id + "/" + _this.levelId + "/" + _this.classId,
              actions: []
            }
          };
          statUpdates.user.actions.push({
            attribute: 'levelClasses',
            action: 'add',
            value: ["" + _this.levelId + "/" + _this.classId]
          });
          statUpdates["class"].actions.push({
            attribute: 'users',
            action: 'add',
            value: [_this.user.id]
          });
          statUpdates.levelClass.actions.push({
            attribute: 'users',
            action: 'add',
            value: [_this.user.id]
          });
          statUpdates.userLevelClass.actions.push({
            attribute: 'duration',
            action: 'add',
            value: timeBetweenEvents
          });
          for (_i = 0, _len = pendingEvents.length; _i < _len; _i++) {
            event = pendingEvents[_i];
            if (event.type === 'move') {
              statUpdates.userLevelClass.actions.push({
                attribute: 'moves',
                action: 'add',
                value: 1
              });
            }
            if (event.type === 'hint') {
              statUpdates.userLevelClass.actions.push({
                attribute: 'hints',
                action: 'add',
                value: 1
              });
            }
            if (event.type === 'success') {
              statUpdates.userLevelClass.actions.push({
                attribute: 'success',
                action: 'add',
                value: [JSON.parse(event.info).time]
              });
            }
          }
          updates = (function() {
            var _results;
            _results = [];
            for (key in statUpdates) {
              _results.push(JSON.stringify(statUpdates[key]));
            }
            return _results;
          })();
          return $.ajaj({
            url: '/api/stats/update',
            method: 'POST',
            headers: {
              'X-CSRF-Token': _this.cookies.get('_csrf', {
                raw: true
              })
            },
            data: {
              updates: updates
            },
            success: function() {
              _this.sendingEvents = false;
              return _this.sendEvents();
            }
          });
        }
      });
    }
  }
});

soma.routes({
  '/puzzles/space_fractions/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.SpaceFractions({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/space_fractions/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.SpaceFractions({
      levelId: levelId
    });
  },
  '/puzzles/space_fractions': function() {
    return new soma.chunks.SpaceFractions;
  },
  '/puzzles/light_it_up/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.SpaceFractions({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/light_it_up/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.SpaceFractions({
      levelId: levelId
    });
  },
  '/puzzles/light_it_up': function() {
    return new soma.chunks.SpaceFractions;
  }
});
