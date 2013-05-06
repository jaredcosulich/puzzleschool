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
      var count, filetype, index, object, _i, _ref,
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
      this.puzzleData = {
        levels: {}
      };
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
      } else {
        if (this.cookies.get('user')) {
          this.loadData({
            url: '/api/puzzles/xyflyer',
            success: function(data) {
              return _this.puzzleData = data.puzzle;
            },
            error: function() {
              if (typeof window !== "undefined" && window !== null ? window.alert : void 0) {
                return alert('We were unable to load your account information. Please check your internet connection.');
              }
            }
          });
        }
      }
      this.objects = [];
      _ref = {
        person: 4,
        island: 4,
        plane: 2,
        background: 5
      };
      for (object in _ref) {
        count = _ref[object];
        for (index = _i = 1; 1 <= count ? _i <= count : _i >= count; index = 1 <= count ? ++_i : --_i) {
          filetype = (object === 'background' ? 'jpg' : 'png');
          this.objects.push({
            name: "" + object + index + " " + (index === 1 ? object : ''),
            image: this.loadImage("/assets/images/puzzles/xyflyer/" + object + index + "." + filetype)
          });
        }
      }
      if (this.levelId === 'editor') {
        this.loadScript('/build/common/pages/puzzles/lib/xyflyer_editor.js');
      }
      return this.loadStylesheet('/build/client/css/puzzles/xyflyer.css');
    },
    build: function() {
      var index, world, worlds, _i, _len, _ref;
      this.setTitle("XYFlyer - The Puzzle School");
      worlds = require('./lib/xyflyer_objects/levels').WORLDS;
      for (index = _i = 0, _len = worlds.length; _i < _len; index = ++_i) {
        world = worlds[index];
        world.index = index + 1;
      }
      return this.html = wings.renderTemplate(this.template, {
        puzzleData: JSON.stringify(this.puzzleData),
        objects: this.objects,
        "class": this.classId || 0,
        level: this.levelId,
        classLevel: this.classLevelId || 0,
        instructions: (_ref = this.levelInfo) != null ? _ref.instructions : void 0,
        editor: this.levelId === 'editor',
        worlds: worlds,
        noBackground: this.levelId === 'editor' || !this.levelId
      });
    }
  }
});

soma.views({
  Xyflyer: {
    selector: '#content .xyflyer',
    create: function() {
      var instructions, level, puzzleData, xyflyer, xyflyerEditor, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6,
        _this = this;
      xyflyer = require('./lib/xyflyer');
      this.worlds = require('./lib/xyflyer_objects/levels').WORLDS;
      this.dynamicContent = this.el.find('.dynamic_content');
      this.$('.menu').bind('click', function() {
        return _this.showLevelSelector();
      });
      this.user = this.cookies.get('user');
      this.classId = this.el.data('class');
      this.classLevelId = this.el.data('classlevel');
      this.levelId = this.el.data('level');
      this.level = this.findLevel(this.levelId);
      if ((_ref = (puzzleData = this.el.data('puzzle_data'))) != null ? _ref.length : void 0) {
        this.puzzleData = JSON.parse(puzzleData);
      } else {
        this.puzzleData = {
          levels: {}
        };
      }
      this.puzzleProgress = {};
      this.puzzleProgress[this.levelId] = {};
      this.originalHTML = this.dynamicContent.html();
      this.initEncode();
      this.initLevelSelector();
      this.initWorlds();
      this.selectWorld(0);
      if (isNaN(parseInt(this.levelId))) {
        if ((_ref1 = (instructions = window.location.hash.replace(/\s/g, ''))) != null ? _ref1.length : void 0) {
          level = this.decode(decodeURIComponent(instructions.replace(/^#/, '')));
          this.level = JSON.parse(level);
        }
        if ((instructions = this.loadCoffeeInstructions())) {
          this.level = instructions;
        }
        if (this.levelId === 'editor') {
          xyflyerEditor = require('./lib/xyflyer_editor');
          this.helper = new xyflyerEditor.EditorHelper({
            el: this.dynamicContent,
            boardElement: this.$('.board'),
            equationArea: this.$('.equation_area'),
            objects: this.$('.objects'),
            grid: (_ref2 = this.level) != null ? _ref2.grid : void 0,
            islandCoordinates: (_ref3 = this.level) != null ? _ref3.islandCoordinates : void 0,
            variables: (_ref4 = this.level) != null ? _ref4.variables : void 0,
            assets: (_ref5 = this.level) != null ? _ref5.assets : void 0,
            encode: function(instructions) {
              return _this.encode(instructions);
            }
          });
          this.loadLevel();
        } else if (!this.level) {
          if (Object.keys(this.puzzleData.levels).length) {
            this.showLevelSelector();
          } else {
            this.showMessage('intro');
          }
        }
        if (!(this.levelId === 'custom' && this.level)) {
          return;
        }
      }
      if (this.classId) {
        if (!this.user) {
          if (typeof window !== "undefined" && window !== null) {
            if ((_ref6 = window.location) != null) {
              _ref6.reload();
            }
          }
          return;
        }
        try {
          this.level = eval("a=" + this.$('.level_instructions').html().replace(/\s/g, ''));
        } catch (e) {

        }
      } else if (!this.level) {
        this.showLevelSelector();
        return;
      }
      return this.initLevel();
    },
    initWorlds: function() {
      var _this = this;
      return this.$('.world_link').bind('click', function(e) {
        var worldLink;
        e.stop();
        worldLink = $(e.currentTarget);
        return _this.selectWorld(parseInt(worldLink.data('world')) - 1);
      });
    },
    currentWorld: function() {
      var index, level, stage, world, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3;
      if (!((_ref = this.level) != null ? _ref.id : void 0)) {
        return 0;
      }
      _ref1 = this.worlds;
      for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
        world = _ref1[index];
        _ref2 = world.stages;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          stage = _ref2[_j];
          _ref3 = stage.levels;
          for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
            level = _ref3[_k];
            if (level.id === this.level.id) {
              return index;
            }
          }
        }
      }
    },
    currentStage: function() {
      var level, stage, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      if (!((_ref = this.level) != null ? _ref.id : void 0)) {
        return 0;
      }
      _ref1 = this.worlds[this.currentWorld()].stages;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        stage = _ref1[_i];
        _ref2 = stage.levels;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          level = _ref2[_j];
          if (level.id === this.level.id) {
            return stage;
          }
        }
      }
    },
    load: function() {
      var asset, assets, index, _ref, _ref1, _ref2,
        _this = this;
      this.dynamicContent.html(this.originalHTML);
      assets = {
        person: 1,
        island: 1,
        plane: 1,
        background: 1
      };
      _ref = this.worlds[this.currentWorld()].assets || {};
      for (asset in _ref) {
        index = _ref[asset];
        assets[asset] = index;
      }
      _ref1 = this.currentStage().assets || {};
      for (asset in _ref1) {
        index = _ref1[asset];
        assets[asset] = index;
      }
      _ref2 = this.level.assets || {};
      for (asset in _ref2) {
        index = _ref2[asset];
        assets[asset] = index;
      }
      for (asset in assets) {
        index = assets[asset];
        if (asset === 'background') {
          if ((this.dynamicContent.css('backgroundImage') || '').indexOf("background" + index + ".jpg") === -1) {
            this.dynamicContent.css('backgroundImage', "url('/assets/images/puzzles/xyflyer/background" + index + ".jpg')");
          }
        } else {
          this.$(".objects ." + asset).removeClass(asset);
          this.$(".objects ." + asset + index).addClass(asset);
        }
      }
      if (this.helper) {
        this.helper.reinitialize({
          boardElement: this.$('.board'),
          objects: this.$('.objects'),
          equationArea: this.$('.equation_area'),
          grid: this.level.grid,
          islandCoordinates: this.level.islandCoordinates
        });
      } else {
        this.helper = new xyflyer.ViewHelper({
          el: this.dynamicContent,
          boardElement: this.$('.board'),
          objects: this.$('.objects'),
          equationArea: this.$('.equation_area'),
          grid: this.level.grid,
          islandCoordinates: this.level.islandCoordinates,
          nextLevel: function() {
            return _this.nextLevel();
          },
          registerEvent: function(eventInfo) {
            return _this.registerEvent(eventInfo);
          }
        });
      }
      this.$('.menu').bind('click', function() {
        return _this.showLevelSelector();
      });
      return this.loadLevel();
    },
    loadLevel: function() {
      var equation, fragment, info, ring, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
      if ((_ref = this.level) != null ? _ref.fragments : void 0) {
        _ref1 = this.level.fragments;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          fragment = _ref1[_i];
          this.helper.addEquationComponent(fragment);
        }
      } else if (this.levelId !== 'editor') {
        this.$('.possible_fragments').hide();
      }
      _ref3 = ((_ref2 = this.level) != null ? _ref2.equations : void 0) || {
        '': {}
      };
      for (equation in _ref3) {
        info = _ref3[equation];
        this.helper.addEquation(equation, info.start, info.solutionComponents, (_ref4 = this.level) != null ? _ref4.variables : void 0);
      }
      _ref6 = ((_ref5 = this.level) != null ? _ref5.rings : void 0) || [];
      for (_j = 0, _len1 = _ref6.length; _j < _len1; _j++) {
        ring = _ref6[_j];
        this.helper.addRing(ring.x, ring.y);
      }
      this.selectWorld(this.currentWorld());
      if (window._gaq && this.level) {
        this.level.startTime = new Date();
        return _gaq.push(['_trackEvent', 'level', 'started', "xyflyer-" + this.level.id]);
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
      var equationArea,
        _this = this;
      this.$('.board').hide();
      equationArea = this.$('.equation_area');
      equationArea.html(this.$("." + type + "_message").html());
      equationArea.css({
        padding: '0 12px',
        textAlign: 'center'
      });
      return equationArea.find('.button').bind('click', function() {
        return _this.showLevelSelector();
      });
    },
    isIos: function() {
      return navigator.userAgent.match(/(iPad|iPhone|iPod)/i);
    },
    selectWorld: function(index) {
      this.$('.world_link').removeClass('selected');
      $(this.$('.world_link')[index]).addClass('selected');
      this.$('.world').removeClass('selected');
      return $(this.$('.world')[index]).addClass('selected');
    },
    findLevel: function(levelId) {
      var level, stage, world, _i, _j, _len, _len1, _ref, _ref1;
      _ref = this.worlds;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        world = _ref[_i];
        _ref1 = world.stages;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          stage = _ref1[_j];
          level = ((function() {
            var _k, _len2, _ref2, _results;
            _ref2 = stage.levels;
            _results = [];
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              level = _ref2[_k];
              if (level.id === levelId) {
                _results.push(level);
              }
            }
            return _results;
          })())[0];
          if (level) {
            return JSON.parse(JSON.stringify(level));
          }
        }
      }
    },
    initLevel: function() {
      var _this = this;
      this.dynamicContent.html(this.originalHTML);
      setTimeout((function() {
        var _base, _base1, _name, _ref;
        (_base = _this.puzzleProgress)[_name = _this.level.id] || (_base[_name] = _this.puzzleData.levels[_this.level.id] || {});
        _this.load();
        (_base1 = _this.puzzleProgress[_this.level.id]).started || (_base1.started = new Date().getTime());
        _this.saveProgress();
        return _this.setLevelIcon({
          id: _this.level.id,
          started: true,
          completed: (_ref = _this.puzzleData.levels[_this.level.id]) != null ? _ref.completed : void 0
        });
      }), 100);
      this.currentLevel = this.level.id;
      return setInterval((function() {
        var components;
        if (location.href.indexOf(_this.currentLevel) > -1) {
          return;
        }
        components = location.href.split('/');
        if ((_this.level = _this.findLevel(parseInt(components[components.length - 1])))) {
          _this.initLevel();
          return _this.hideLevelSelector();
        }
      }), 500);
    },
    initLevelSelector: function() {
      var previousCompleted, stageElement, _i, _len, _ref, _results,
        _this = this;
      this.levelSelector = this.$('.level_selector');
      this.levelSelector.bind('click', function(e) {
        return e.stop();
      });
      this.levelSelector.find('.close').bind('click', function() {
        return _this.hideLevelSelector();
      });
      previousCompleted = true;
      _ref = this.levelSelector.find('.stage');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        stageElement = _ref[_i];
        _results.push((function(stageElement) {
          var index, levelElement, stageCompleted, _j, _len1, _ref1, _results1;
          stageCompleted = 0;
          _ref1 = $(stageElement).find('.level');
          _results1 = [];
          for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
            levelElement = _ref1[index];
            _results1.push((function(levelElement, index) {
              var id, levelInfo, locked, _ref2, _ref3, _ref4;
              levelElement = $(levelElement);
              id = levelElement.data('id');
              levelInfo = _this.findLevel(id);
              locked = !previousCompleted;
              if (index === 0) {
                locked = false;
              }
              _this.setLevelIcon({
                id: id,
                started: (_ref2 = _this.puzzleData.levels[id]) != null ? _ref2.started : void 0,
                completed: (_ref3 = _this.puzzleData.levels[id]) != null ? _ref3.completed : void 0,
                locked: locked
              });
              levelElement.unbind('click');
              levelElement.bind('click', function(e) {
                e.stop();
                $(document.body).unbind('click.level_selector');
                if (locked) {
                  return alert('This level is locked.');
                } else {
                  _this.level = levelInfo;
                  _this.initLevel();
                  history.pushState(null, null, "/puzzles/xyflyer/" + id);
                  return _this.hideLevelSelector();
                }
              });
              if ((_ref4 = _this.puzzleData.levels[id]) != null ? _ref4.completed : void 0) {
                stageCompleted += 1;
                return previousCompleted = true;
              } else {
                return previousCompleted = false;
              }
            })(levelElement, index));
          }
          return _results1;
        })(stageElement));
      }
      return _results;
    },
    setLevelIcon: function(_arg) {
      var completed, id, level, locked, started;
      id = _arg.id, started = _arg.started, completed = _arg.completed, locked = _arg.locked;
      if (!id) {
        return;
      }
      level = this.$("#level_" + id);
      level.removeClass('locked').removeClass('completed');
      if (locked) {
        return level.addClass('locked');
      } else if (completed) {
        return level.addClass('completed');
      }
    },
    nextLevel: function() {
      var duration,
        _this = this;
      if (this.levelId === 'custom') {
        $.timeout(500, function() {
          return alert("Nice work. Custom level completed.");
        });
        return;
      }
      this.puzzleProgress[this.level.id].completed = new Date().getTime();
      duration = this.level.startTime != null ? new Date() - this.level.startTime : null;
      return $.timeout(500, function() {
        var index, level, _i, _len, _ref, _results;
        if (window._gaq) {
          _gaq.push(['_trackEvent', 'level', 'completed', "xyflyer-" + _this.level.id, duration]);
        }
        _this.registerEvent({
          type: 'success',
          info: {
            time: _this.puzzleProgress[_this.level.id].completed
          }
        });
        _this.saveProgress();
        _this.initLevelSelector();
        _this.showLevelSelector(true);
        _ref = _this.$('.stage .level:last-child');
        _results = [];
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          level = _ref[index];
          if (index % 2 === 1) {
            if (parseInt(_this.level.id) === parseInt($(level).data('id'))) {
              _results.push(_this.selectWorld(Math.floor(index / 2) + 1));
            } else {
              _results.push(void 0);
            }
          }
        }
        return _results;
      });
    },
    showLevelSelector: function(success) {
      var _this = this;
      $(document.body).unbind('click.level_selector');
      if (parseInt(this.levelSelector.css('opacity')) === 1) {
        this.hideLevelSelector();
        return;
      }
      this.levelSelector.css({
        opacity: 0,
        top: 60,
        left: (this.el.width() - this.levelSelector.width()) / 2
      });
      this.levelSelector.animate({
        opacity: 1,
        duration: 250
      });
      return setTimeout((function() {
        return $(document.body).one('click.level_selector', function() {
          return _this.hideLevelSelector();
        });
      }), 10);
    },
    hideLevelSelector: function() {
      var _this = this;
      $(document.body).unbind('click.level_selector');
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
    saveProgress: function(callback) {
      var _this = this;
      this.mergeProgress(this.puzzleProgress);
      if (this.cookies.get('user')) {
        return $.ajaj({
          url: "/api/puzzles/xyflyer/update",
          method: 'POST',
          headers: {
            'X-CSRF-Token': this.cookies.get('_csrf', {
              raw: true
            })
          },
          data: {
            puzzleUpdates: {},
            levelUpdates: this.puzzleProgress
          },
          success: function() {
            if (callback) {
              return callback();
            }
          }
        });
      } else {
        window.postRegistration.push(function(callback) {
          return _this.saveProgress(callback);
        });
        if (Object.keys(this.puzzleProgress).length % 5 === 4) {
          return this.showRegistrationFlag();
        }
      }
    },
    mergeProgress: function(progress, master) {
      var key, value, _results;
      if (master == null) {
        master = this.puzzleData.levels;
      }
      _results = [];
      for (key in progress) {
        value = progress[key];
        if (typeof value === 'object') {
          master[key] = {};
          _results.push(this.mergeProgress(value, master[key]));
        } else {
          _results.push(master[key] = value);
        }
      }
      return _results;
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
        'min': '~C',
        'max': '~D',
        'increment': '~E',
        'start': '~F',
        'fragment': '~G',
        'solutionComponents': '~H',
        'after': '~I',
        'solution': '~J',
        'assets': '~K',
        'background': '~L',
        'foreground': '~M',
        'island': '~N',
        'person': '~O',
        'plane': '~P',
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
      if (window._gaq && this.level) {
        _gaq.push(['_trackEvent', 'level', 'hint', "xyflyer-" + this.level.id]);
      }
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
    },
    testHints: function(levelIndex) {
      var index, level, stage, world, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2,
        _this = this;
      if (levelIndex == null) {
        levelIndex = 0;
      }
      this.hideLevelSelector();
      this.nextLevel = function() {
        return _this.testHints(levelIndex + 1);
      };
      index = 0;
      _ref = this.worlds;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        world = _ref[_i];
        _ref1 = world.stages;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          stage = _ref1[_j];
          _ref2 = stage.levels;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            level = _ref2[_k];
            if (index === levelIndex) {
              if (level !== this.level) {
                console.log("TESTING LEVEL " + level.id + ", INDEX: " + levelIndex);
                this.level = level;
                this.load();
              }
              $.timeout(100, function() {
                var helper, testHints;
                testHints = function(i) {
                  return _this.testHints(i);
                };
                helper = _this.helper;
                if (!helper.equations.reallyDisplayHint) {
                  helper.equations.reallyDisplayHint = _this.helper.equations.displayHint;
                  helper.equations.reallyDisplayVariable = _this.helper.equations.displayVariable;
                  helper.equations.displayHint = function(component, dropAreaElement, equation, solutionComponent) {
                    var _this = this;
                    helper.equations.reallyDisplayHint(component, dropAreaElement, equation, solutionComponent);
                    return $.timeout(1000, function() {
                      component.mousedown({
                        preventDefault: function() {},
                        type: 'mousedown'
                      });
                      $(document.body).trigger('mousedown.hint');
                      component.element.trigger('mousedown.hint');
                      return $.timeout(1000, function() {
                        $(document.body).trigger('mouseup.hint');
                        component.move({
                          preventDefault: function() {},
                          type: 'mousemove',
                          clientX: dropAreaElement.offset().left,
                          clientY: dropAreaElement.offset().top
                        });
                        component.endMove({
                          preventDefault: function() {},
                          type: 'mouseup',
                          clientX: dropAreaElement.offset().left,
                          clientY: dropAreaElement.offset().top
                        });
                        return testHints(levelIndex);
                      });
                    });
                  };
                  helper.equations.displayVariable = function(variable, value) {
                    var equation, _l, _len3, _ref3;
                    helper.equations.reallyDisplayVariable(variable, value);
                    _ref3 = helper.equations.equations;
                    for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
                      equation = _ref3[_l];
                      if (equation.variables[variable]) {
                        equation.variables[variable].set(value);
                        testHints(levelIndex);
                        return;
                      }
                    }
                  };
                }
                _this.$('.hints').trigger('mousedown.hint');
                _this.$('.hints').trigger('mouseup.hint');
                return $.timeout(1000, function() {
                  var completedSolution, equation, formula, info, launch, ready, variable, _l, _len3, _ref3;
                  ready = true;
                  _ref3 = helper.equations.equations;
                  for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
                    equation = _ref3[_l];
                    formula = equation.formula();
                    completedSolution = equation.solution;
                    for (variable in equation.variables) {
                      info = equation.variables[variable];
                      if (info.solution) {
                        completedSolution = completedSolution.replace(variable, info.solution);
                      }
                    }
                    if (completedSolution !== formula) {
                      ready = false;
                    }
                  }
                  if (ready) {
                    launch = _this.$('.launch');
                    launch.trigger('mouseup.hint');
                    return launch.trigger('click.launch');
                  }
                });
              });
              return;
            }
            index += 1;
          }
        }
      }
    },
    loadCoffeeInstructions: function() {}
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
