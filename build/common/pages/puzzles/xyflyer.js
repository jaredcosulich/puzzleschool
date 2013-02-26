// Generated by CoffeeScript 1.3.3
var soma, sortLevels, wings;

soma = require('soma');

wings = require('wings');

sortLevels = function(levels) {
  return levels.sort(function(level1, level2) {
    var a, b;
    a = level1.difficulty + level1.id;
    b = level2.difficulty + level2.id;
    if (a === b) {
      return 0;
    } else {
      if (a < b) {
        return -1;
      } else {
        return 1;
      }
    }
  });
};

soma.chunks({
  Xyflyer: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      var object, _i, _len, _ref,
        _this = this;
      this.classId = _arg.classId, this.levelId = _arg.levelId;
      this.template = this.loadTemplate("/build/common/templates/puzzles/xyflyer.html");
      this.loadScript('/assets/third_party/equation_explorer/tokens.js');
      this.loadScript('/assets/third_party/raphael-min.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/levels.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/animation.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/transformer.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/tdop.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/parser.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/object.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/board.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/plane.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/ring.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equation.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equation_component.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equations.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/index.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer.js');
      if (this.classId) {
        this.loadData({
          url: "/api/classes/info/" + this.classId,
          success: function(data) {
            var levels;
            levels = sortLevels(data.levels);
            _this.classLevelId = levels[_this.levelId - 1].id;
            return _this.loadData({
              url: "/api/puzzles/levels/" + _this.classLevelId,
              success: function(levelInfo) {
                _this.levelInfo = levelInfo;
              },
              error: function() {
                if (typeof window !== "undefined" && window !== null ? window.alert : void 0) {
                  return alert('We were unable to load the information for this level. Please check your internet connection.');
                }
              }
            });
          },
          error: function() {
            if ((_this.user = _this.cookies.get('user')) && (typeof window !== "undefined" && window !== null ? window.alert : void 0)) {
              return alert('We were unable to load the information for this class. Please check your internet connection.');
            }
          }
        });
      }
      this.objects = [];
      _ref = ['island', 'plane'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        this.objects.push({
          name: object,
          image: this.loadImage("/assets/images/puzzles/xyflyer/" + object + ".png")
        });
      }
      if (this.levelId === 'editor') {
        this.loadScript('/build/common/pages/puzzles/lib/xyflyer_editor.js');
      }
      return this.loadStylesheet('/build/client/css/puzzles/xyflyer.css');
    },
    build: function() {
      var _ref;
      this.setTitle("XYFlyer - The Puzzle School");
      return this.html = wings.renderTemplate(this.template, {
        objects: this.objects,
        "class": this.classId || 0,
        level: this.levelId,
        classLevel: this.classLevelId || 0,
        instructions: (_ref = this.levelInfo) != null ? _ref.instructions : void 0,
        editor: this.levelId === 'editor'
      });
    }
  }
});

soma.views({
  Xyflyer: {
    selector: '#content .xyflyer',
    create: function() {
      var instructions, level, xyflyer, xyflyerEditor, _ref, _ref1, _ref2, _ref3,
        _this = this;
      xyflyer = require('./lib/xyflyer');
      this.user = this.cookies.get('user');
      this.classId = this.el.data('class');
      this.levelId = this.el.data('level');
      this.classLevelId = this.el.data('classlevel');
      this.initEncode();
      if (isNaN(parseInt(this.levelId))) {
        if ((_ref = (instructions = window.location.hash.replace(/\s/g, ''))) != null ? _ref.length : void 0) {
          level = this.decode(decodeURIComponent(instructions.replace(/^#/, '')));
          this.data = JSON.parse(level);
        }
        if (this.levelId === 'editor') {
          xyflyerEditor = require('./lib/xyflyer_editor');
          this.helper = new xyflyerEditor.EditorHelper({
            el: $(this.selector),
            boardElement: this.$('.board'),
            equationArea: this.$('.equation_area'),
            objects: this.$('.objects'),
            grid: (_ref1 = this.data) != null ? _ref1.grid : void 0,
            islandCoordinates: (_ref2 = this.data) != null ? _ref2.islandCoordinates : void 0,
            encode: function(instructions) {
              return _this.encode(instructions);
            }
          });
          this.loadLevel();
        } else if (!this.data) {
          this.showMessage('intro');
        }
        if (!(this.levelId === 'custom' && this.data)) {
          return;
        }
      }
      if (this.classId) {
        if (!this.user) {
          if (typeof window !== "undefined" && window !== null) {
            if ((_ref3 = window.location) != null) {
              _ref3.reload();
            }
          }
          return;
        }
        try {
          this.data = eval("a=" + this.$('.level_instructions').html().replace(/\s/g, ''));
        } catch (e) {

        }
      } else if (!this.data) {
        this.data = LEVELS[this.levelId];
      }
      if (!this.data) {
        this.showMessage('exit');
        return;
      }
      this.helper = new xyflyer.ViewHelper({
        el: $(this.selector),
        boardElement: this.$('.board'),
        objects: this.$('.objects'),
        equationArea: this.$('.equation_area'),
        grid: this.data.grid,
        islandCoordinates: this.data.islandCoordinates,
        nextLevel: function() {
          return _this.nextLevel();
        },
        registerEvent: function(eventInfo) {
          return _this.registerEvent(eventInfo);
        }
      });
      return this.loadLevel();
    },
    loadLevel: function() {
      var equation, fragment, info, ring, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _results;
      _ref1 = ((_ref = this.data) != null ? _ref.equations : void 0) || {
        '': {}
      };
      for (equation in _ref1) {
        info = _ref1[equation];
        this.helper.addEquation(equation, info.start, info.solutionComponents, (_ref2 = this.data) != null ? _ref2.variables : void 0);
      }
      _ref4 = ((_ref3 = this.data) != null ? _ref3.rings : void 0) || [];
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        ring = _ref4[_i];
        this.helper.addRing(ring.x, ring.y);
      }
      if ((_ref5 = this.data) != null ? _ref5.fragments : void 0) {
        _ref6 = this.data.fragments;
        _results = [];
        for (_j = 0, _len1 = _ref6.length; _j < _len1; _j++) {
          fragment = _ref6[_j];
          _results.push(this.helper.addEquationComponent(fragment));
        }
        return _results;
      } else if (this.levelId !== 'editor') {
        return this.$('.possible_fragments').hide();
      }
    },
    centerAndShow: function(element, board) {
      var areaOffset, boardOffset, offset;
      offset = element.offset();
      boardOffset = this.$('.board').offset();
      areaOffset = this.el.offset();
      element.css({
        opacity: 0,
        top: (boardOffset.top - areaOffset.top) + (boardOffset.height / 2) - (offset.height / 2),
        left: (boardOffset.left - areaOffset.left) + (boardOffset.width / 2) - (offset.width / 2)
      });
      return element.animate({
        opacity: 0.9,
        duration: 500
      });
    },
    showMessage: function(type) {
      var equationArea, path,
        _this = this;
      equationArea = this.$('.equation_area');
      equationArea.html(this.$("." + type + "_message").html());
      equationArea.css({
        padding: '0 12px',
        textAlign: 'center'
      });
      path = '/puzzles/xyflyer/1';
      if (this.isIos()) {
        return equationArea.find('.button').attr('href', path);
      } else {
        return equationArea.find('.button').bind('mousedown.go', function() {
          return _this.go(path);
        });
      }
    },
    isIos: function() {
      return navigator.userAgent.match(/(iPad|iPhone|iPod)/i);
    },
    nextLevel: function() {
      var complete, path,
        _this = this;
      this.registerEvent({
        type: 'success',
        info: {
          time: new Date()
        }
      });
      complete = this.$('.complete');
      this.centerAndShow(complete);
      this.$('.launch').html('Success! Go To The Next Level >');
      path = "/puzzles/xyflyer/" + (this.classId ? "" + this.classId + "/" : '') + (this.levelId + 1);
      if (this.isIos()) {
        return this.$('.go').attr('href', path);
      } else {
        this.$('.launch').unbind('mousedown.launch touchstart.launch');
        return this.$('.go').bind('mousedown.go', function() {
          return _this.go(path);
        });
      }
    },
    initEncode: function() {
      this.encodeMap = {
        '"equations":': '~a',
        '"rings":': '~b',
        '"grid":': '~c',
        '"islandCoordinates":': '~d',
        '"fragments":': '~e',
        '"variables":': '~f',
        '"x":': '~g',
        '"y":': '~h',
        '"xMin":': '~i',
        '"yMin":': '~j',
        '"xMax":': '~k',
        '"yMax":': '~l',
        '-': '~m',
        '\\+': '~n',
        '\\*': '~o',
        '\\/': '~p',
        '\\(': '~q',
        '\\)': '~r',
        '0': '~s',
        '1': '~t',
        '2': '~u',
        '3': '~v',
        '4': '~w',
        '5': '~x',
        '6': '~y',
        '7': '~z',
        '8': '~A',
        '9': '~B',
        '"verified"': '~V'
      };
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
      for (extraEncode in this.extraEncodeMap) {
        regExp = new RegExp('\\' + this.extraEncodeMap[extraEncode], 'g');
        json = json.replace(regExp, extraEncode);
      }
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
        json = json.replace(regExp, encode.replace(/\\/g, ''));
      }
      return json;
    },
    registerEvent: function(_arg) {
      var info, type;
      type = _arg.type, info = _arg.info;
      if (!(this.user && this.user.id && (this.classLevelId || this.levelId) && this.classId)) {
        return;
      }
      this.pendingEvents || (this.pendingEvents = []);
      this.pendingEvents.push({
        type: type,
        info: JSON.stringify(info),
        puzzle: 'xyflyer',
        classId: this.classId,
        levelId: this.classLevelId || this.levelId
      });
      if (!this.lastEvent) {
        this.timeBetweenEvents = 0;
        this.lastEvent = new Date();
      } else {
        this.timeBetweenEvents += new Date().getTime() - this.lastEvent.getTime();
        this.lastEvent = new Date();
      }
      return this.sendEvents(type === 'success' || type === 'challenge');
    },
    sendEvents: function(force) {
      var completeEventRecording, event, key, pendingEvents, statUpdates, timeBetweenEvents, updates, _i, _len, _ref,
        _this = this;
      if (!force) {
        if (!((_ref = this.pendingEvents) != null ? _ref.length : void 0)) {
          return;
        }
        if (this.sendingEvents > 0) {
          return;
        }
      }
      this.sendingEvents += 2;
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
      statUpdates = {
        user: {
          objectType: 'user',
          objectId: this.user.id,
          actions: []
        },
        "class": {
          objectType: 'class',
          objectId: this.classId,
          actions: []
        },
        levelClass: {
          objectType: 'level_class',
          objectId: "" + (this.classLevelId || this.levelId) + "/" + this.classId,
          actions: []
        },
        userLevelClass: {
          objectType: 'user_level_class',
          objectId: "" + this.user.id + "/" + (this.classLevelId || this.levelId) + "/" + this.classId,
          actions: []
        }
      };
      statUpdates.user.actions.push({
        attribute: 'levelClasses',
        action: 'add',
        value: ["" + (this.classLevelId || this.levelId) + "/" + this.classId]
      });
      statUpdates["class"].actions.push({
        attribute: 'users',
        action: 'add',
        value: [this.user.id]
      });
      statUpdates.levelClass.actions.push({
        attribute: 'users',
        action: 'add',
        value: [this.user.id]
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
        if (event.type === 'challenge') {
          statUpdates.userLevelClass.actions.push({
            attribute: 'challenge',
            action: 'add',
            value: [JSON.parse(event.info).assessment]
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
      completeEventRecording = function() {
        _this.sendingEvents -= 1;
        if (_this.sendingEvents < 0) {
          _this.sendingEvents = 0;
        }
        return _this.sendEvents();
      };
      $.ajaj({
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
          return completeEventRecording();
        }
      });
      return $.ajaj({
        url: '/api/stats/update',
        method: 'POST',
        headers: {
          'X-CSRF-Token': this.cookies.get('_csrf', {
            raw: true
          })
        },
        data: {
          updates: updates
        },
        success: function() {
          return completeEventRecording();
        }
      });
    }
  }
});

soma.routes({
  '/puzzles/xyflyer/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.Xyflyer({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/xyflyer/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.Xyflyer({
      levelId: levelId
    });
  },
  '/puzzles/xyflyer': function() {
    return new soma.chunks.Xyflyer;
  }
});
