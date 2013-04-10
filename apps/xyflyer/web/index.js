// Generated by CoffeeScript 1.3.3
var xyflyer;

xyflyer = require('./lib/xyflyer');

window.app = {
  initialize: function() {
    var _this = this;
    if (!(this.width = window.innerWidth || window.landwidth) || !(this.height = window.innerHeight || window.landheight) || this.width < this.height) {
      $.timeout(100, function() {
        return window.app.initialize();
      });
      return;
    }
    document.addEventListener('touchmove', (function(e) {
      return e.preventDefault();
    }), false);
    this.el = $('.xyflyer');
    this.dynamicContent = this.el.find('.dynamic_content');
    this.$('.menu').bind('click', function() {
      return _this.showLevelSelector();
    });
    this.el.bind('touchstart', function(e) {
      if (e.preventDefault) {
        return e.preventDefault();
      }
    });
    this.originalHtml = this.dynamicContent.html();
    this.worlds = require('./lib/xyflyer_objects/levels').WORLDS;
    this.levelId = 1364229884455;
    this.level = this.worlds[0].stages[0].levels[0];
    this.puzzleData = {
      levels: {}
    };
    return this.load();
  },
  $: function(selector) {
    return $(selector, this.el);
  },
  load: function() {
    var asset, index, _ref,
      _this = this;
    this.dynamicContent.html(this.originalHTML);
    $('svg').remove();
    _ref = this.level.assets || this.worlds[this.currentWorld()].assets || {};
    for (asset in _ref) {
      index = _ref[asset];
      if (asset === 'background') {
        this.dynamicContent.css('backgroundImage', this.dynamicContent.css('backgroundImage').replace(/\d+\./, "" + index + "."));
      } else {
        this.$(".objects ." + asset).removeClass(asset);
        this.$(".objects ." + asset + index).addClass(asset);
      }
    }
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
      registerEvent: function(eventInfo) {}
    });
    this.$('.menu').bind('click', function() {
      return _this.showLevelSelector();
    });
    return this.loadLevel();
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
    return this.selectWorld(this.currentWorld());
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
    var previousCompleted, previousStageProficient, stageElement, _i, _len, _ref, _results,
      _this = this;
    this.levelSelector = this.$('.level_selector');
    this.levelSelector.bind('click', function(e) {
      return e.stop();
    });
    previousCompleted = true;
    previousStageProficient = true;
    _ref = this.levelSelector.find('.stage');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      stageElement = _ref[_i];
      _results.push((function(stageElement) {
        var index, levelElement, stageCompleted, _fn, _j, _len1, _ref1;
        stageCompleted = 0;
        _ref1 = $(stageElement).find('.level');
        _fn = function(levelElement, index) {
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
        };
        for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
          levelElement = _ref1[index];
          _fn(levelElement, index);
        }
        return previousStageProficient = stageCompleted >= 3;
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
    var index, level, _i, _len, _ref, _results;
    this.initLevelSelector();
    this.showLevelSelector(true);
    _ref = this.$('.stage .level:last-child');
    _results = [];
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      level = _ref[index];
      if (index % 2 === 1) {
        if (parseInt(this.level.id) === parseInt($(level).data('id'))) {
          _results.push(this.selectWorld(Math.floor(index / 2) + 1));
        } else {
          _results.push(void 0);
        }
      }
    }
    return _results;
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
    console.log('show level selector');
    this.levelSelector.animate({
      opacity: 1,
      duration: 250,
      complete: function() {
        return console.log('done');
      }
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
  }
};
