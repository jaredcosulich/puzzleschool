// Generated by CoffeeScript 1.3.3
var xyflyer,
  __slice = [].slice;

xyflyer = require('./lib/xyflyer');

window.app = {
  initialize: function() {
    var data, i, _i,
      _this = this;
    if (!window.appSized || !(this.width = window.innerWidth || window.landwidth) || !(this.height = window.innerHeight || window.landheight) || this.width < this.height) {
      $.timeout(100, function() {
        return window.app.initialize();
      });
      return;
    }
    document.addEventListener('touchmove', (function(e) {
      return e.preventDefault();
    }), false);
    if (data = window.localStorage.getItem('player_data')) {
      this.players = JSON.parse(data);
    }
    if (!this.players) {
      this.players = {};
      for (i = _i = 0; _i <= 3; i = ++_i) {
        this.players[i + 1] = {
          id: i + 1,
          name: "Player" + (i + 1),
          attempted: 0,
          completed: 0,
          hand: 'Right'
        };
      }
    }
    this.el = $('.xyflyer');
    this.dynamicContent = this.el.find('.dynamic_content');
    this.el.bind('touchstart', function(e) {
      if (e.preventDefault) {
        return e.preventDefault();
      }
    });
    this.originalHTML = this.dynamicContent.html();
    this.worlds = require('./lib/xyflyer_objects/levels').WORLDS;
    this.puzzleProgress = {};
    this.initLevelSelector();
    this.initSettings();
    this.initWorlds();
    return this.showMenu(this.settings);
  },
  $: function(selector) {
    return $(selector, this.el);
  },
  clear: function() {
    $('svg').remove();
    return this.dynamicContent.html(this.originalHTML);
  },
  load: function() {
    var asset, assets, index, _ref, _ref1, _ref2,
      _this = this;
    this.$('.level_selector_menu').bind('touchstart.menu', function() {
      _this.$('.level_selector_menu').addClass('active');
      return $(document.body).one('touchend.menu', function() {
        return _this.$('.level_selector_menu').removeClass('active');
      }, _this.showMenu(_this.levelSelector));
    });
    this.$('.settings_menu').bind('touchstart.settings_menu', function() {
      _this.$('.settings_menu').addClass('active');
      return $(document.body).one('touchend.settings_menu', function() {
        return _this.$('.settings_menu').removeClass('active');
      }, _this.showMenu(_this.settings));
    });
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
    this.level.assets = assets;
    for (asset in assets) {
      index = assets[asset];
      if (asset === 'background') {
        if ((this.dynamicContent.css('backgroundImage') || '').indexOf("background" + index + ".jpg") === -1) {
          this.dynamicContent.css('backgroundImage', this.dynamicContent.css('backgroundImage').replace(/\d+\.jpg/, "" + index + ".jpg"));
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
        islandCoordinates: this.level.islandCoordinates,
        flip: this.selectedPlayer.hand.toLowerCase()
      });
    } else {
      this.helper = new xyflyer.ViewHelper({
        el: this.dynamicContent,
        boardElement: this.$('.board'),
        objects: this.$('.objects'),
        equationArea: this.$('.equation_area'),
        grid: this.level.grid,
        islandCoordinates: this.level.islandCoordinates,
        flip: this.selectedPlayer.hand.toLowerCase(),
        nextLevel: function() {
          return _this.nextLevel();
        },
        registerEvent: function(eventInfo) {}
      });
    }
    return this.loadLevel();
  },
  initWorlds: function() {
    var worldLinks,
      _this = this;
    worldLinks = this.$('.world_link');
    return worldLinks.bind('touchstart.select_world', function(e) {
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
  loadLevel: function() {
    var equation, fontSize, fragment, info, ring, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
    if ((_ref = this.level) != null ? _ref.fragments : void 0) {
      _ref1 = this.level.fragments;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        fragment = _ref1[_i];
        this.helper.addEquationComponent(fragment, this.selectedPlayer.hand.toLowerCase());
      }
    } else if (this.level.id !== 'editor') {
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
    if ((fontSize = (_ref7 = this.level) != null ? (_ref8 = _ref7.assets) != null ? _ref8.font : void 0 : void 0)) {
      this.$('.equation_container .intro, .equation').css({
        fontSize: fontSize
      });
    }
    if (this.level) {
      this.$('.world_index').html("" + (this.currentWorld() + 1));
      this.$('.level_index').html("" + (this.worldLevelIndex()));
    }
    if (this.currentWorld() >= 2) {
      this.$('.explanation').hide();
      this.$('.possible_fragments p').hide();
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
    return equationArea.find('.button').bind('touchstart', function() {
      return _this.showMenu(_this.levelSelector);
    });
  },
  isIos: function() {
    return navigator.userAgent.match(/(iPad|iPhone|iPod)/i);
  },
  selectWorld: function(index) {
    var completed, id, info;
    if (index >= 5) {
      this.$('.world .game_completed .game_completed').hide();
      completed = (function() {
        var _ref, _results;
        _ref = this.selectedPlayer.progress;
        _results = [];
        for (id in _ref) {
          info = _ref[id];
          if (info.completed) {
            _results.push(id);
          }
        }
        return _results;
      }).call(this);
      if (completed.length >= 200) {
        this.$('.world .game_completed .game_completed_message').show();
      } else {
        this.$('.world .game_completed .stage_completed_message').show();
      }
    }
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
  worldLevelIndex: function() {
    var index, level, stage, world, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    _ref = this.worlds;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      world = _ref[_i];
      index = 1;
      _ref1 = world.stages;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        stage = _ref1[_j];
        _ref2 = stage.levels;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          level = _ref2[_k];
          if (level.id === this.level.id) {
            return index;
          }
          index += 1;
        }
      }
    }
  },
  initLevel: function() {
    var _this = this;
    return setTimeout((function() {
      var _base, _base1, _name, _ref;
      (_base = _this.puzzleProgress)[_name = _this.level.id] || (_base[_name] = {});
      _this.load();
      (_base1 = _this.puzzleProgress[_this.level.id]).started || (_base1.started = new Date().getTime());
      _this.savePlayer();
      _this.populatePlayer();
      return _this.setLevelIcon({
        id: _this.level.id,
        started: true,
        completed: (_ref = _this.puzzleProgress[_this.level.id]) != null ? _ref.completed : void 0
      });
    }), 100);
  },
  initLevelSelector: function(changedLevelIds) {
    var previousCompleted, stageElement, _i, _len, _ref, _results,
      _this = this;
    this.levelSelector || (this.levelSelector = this.$('.level_selector'));
    this.levelSelector.bind('touchstart', function(e) {
      return e.stop();
    });
    this.levelSelector.find('.close').bind('touchstart.close', function() {
      _this.levelSelector.find('.close').addClass('active');
      _this.hideMenu(_this.levelSelector);
      return $(document.body).one('touchend.close', function() {
        return _this.levelSelector.find('.close').removeClass('active');
      });
    });
    previousCompleted = true;
    _ref = this.levelSelector.find('.stage');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      stageElement = _ref[_i];
      _results.push((function(stageElement) {
        var id, index, lastLevelId, levelElement, stageCompleted, _j, _len1, _ref1, _results1;
        stageCompleted = 0;
        _ref1 = $(stageElement).find('.level');
        _results1 = [];
        for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
          levelElement = _ref1[index];
          levelElement = $(levelElement);
          lastLevelId = id;
          id = levelElement.data('id');
          if (!changedLevelIds || !changedLevelIds.length || changedLevelIds.indexOf(id) > -1 || changedLevelIds.indexOf(lastLevelId) > -1) {
            _results1.push((function(levelElement, index) {
              var levelInfo, locked, _ref2, _ref3, _ref4;
              levelInfo = _this.findLevel(id);
              locked = !previousCompleted;
              if (index === 0) {
                locked = false;
              }
              _this.setLevelIcon({
                id: id,
                started: (_ref2 = _this.puzzleProgress[id]) != null ? _ref2.started : void 0,
                completed: (_ref3 = _this.puzzleProgress[id]) != null ? _ref3.completed : void 0,
                locked: locked
              });
              levelElement.unbind('touchstart.select_level');
              levelElement.bind('touchstart.select_level', function(e) {
                e.stop();
                if (!locked) {
                  levelElement.addClass('active');
                  _this.clear();
                  _this.level = levelInfo;
                  _this.initLevel();
                }
                return $(document.body).one('touchend.select_level', function(e) {
                  levelElement.removeClass('active');
                  $(document.body).unbind('touchstart.level_selector');
                  if (locked) {
                    return _this.alert('This level is locked.');
                  } else {
                    return _this.hideMenu(_this.levelSelector);
                  }
                });
              });
              if ((_ref4 = _this.puzzleProgress[id]) != null ? _ref4.completed : void 0) {
                stageCompleted += 1;
                return previousCompleted = true;
              } else {
                return previousCompleted = false;
              }
            })(levelElement, index));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      })(stageElement));
    }
    return _results;
  },
  alert: function(messageText) {
    var hidden, hide, message;
    message = this.$('.message');
    hidden = false;
    hide = function() {
      var _this = this;
      if (hidden) {
        return;
      }
      hidden = true;
      return message.animate({
        opacity: 0,
        duration: 250,
        complete: function() {
          return message.css({
            top: -1000,
            left: -1000
          });
        }
      });
    };
    message.one('touchstart.hide', function(e) {
      hide();
      return e.stop();
    });
    message.html(messageText);
    message.css({
      opacity: 0,
      top: (this.el.height() / 2) - (message.height() / 2),
      left: (this.el.width() / 2) - (message.width() / 2)
    });
    return message.animate({
      opacity: 1,
      duration: 250,
      complete: function() {
        return $.timeout(1500, hide);
      }
    });
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
    var _this = this;
    this.puzzleProgress[this.level.id].completed = new Date().getTime();
    this.savePlayer();
    this.populatePlayer();
    return $.timeout(1000, function() {
      var index, level, _i, _len, _ref;
      _this.initLevelSelector([_this.level.id]);
      _ref = _this.$('.stage .level:last-child');
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        level = _ref[index];
        if (index % 2 === 1) {
          if (parseInt(_this.level.id) === parseInt($(level).data('id'))) {
            _this.selectWorld(Math.floor(index / 2) + 1);
          }
        }
      }
      return _this.showMenu(_this.levelSelector, true);
    });
  },
  showMenu: function(menu, success) {
    var _this = this;
    this.hideMenu(this.$('.menu'), true);
    $(document.body).unbind('touchstart.hide_menu');
    if (parseInt(menu.css('opacity')) === 1) {
      this.hideMenu(menu);
      return;
    }
    menu.css({
      opacity: 0,
      top: (this.el.height() - menu.height()) / 2,
      left: (this.el.width() - menu.width()) / 2
    });
    menu.animate({
      opacity: 1,
      duration: 500
    });
    return $.timeout(600, function() {
      return $(document.body).one('touchstart.hide_menu', function() {
        return $(document.body).one('touchend.hide_menu', function() {
          return _this.hideMenu(menu);
        });
      });
    });
  },
  hideMenu: function(menu, immediate) {
    var _this = this;
    $(document.body).unbind('touchstart.hide_menu touchend.hide_menu');
    if (immediate) {
      return menu.css({
        opacity: 0,
        top: -1000,
        left: -1000
      });
    } else {
      return menu.animate({
        opacity: 0,
        duration: 500,
        complete: function() {
          return menu.css({
            top: -1000,
            left: -1000
          });
        }
      });
    }
  },
  initSettings: function() {
    var id, info, playerName, _i, _len, _ref,
      _this = this;
    this.settings || (this.settings = this.$('.settings'));
    this.settings.bind('touchstart', function(e) {
      return e.stop();
    });
    this.settings.find('.close').bind('touchstart.close', function() {
      _this.settings.find('.close').addClass('active');
      _this.hideMenu(_this.settings);
      return $(document.body).one('touchend.close', function() {
        return _this.settings.find('.close').removeClass('active');
      });
    });
    _ref = ((function() {
      var _ref, _results;
      _ref = this.players;
      _results = [];
      for (id in _ref) {
        info = _ref[id];
        if (info.lastPlayed) {
          _results.push(info);
        }
      }
      return _results;
    }).call(this)).sort(function(a, b) {
      return b.lastPlayed - a.lastPlayed;
    });
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      info = _ref[_i];
      playerName = this.settings.find(".player_selection .player" + info.id);
      playerName.html(info.name);
      if (!this.selectedPlayer) {
        this.selectPlayer(playerName.closest('.select_player'));
      }
    }
    if (!this.selectedPlayer) {
      this.selectPlayer($(this.settings.find('.select_player')[0]));
    }
    this.settings.find('.select_player').bind('touchstart.select_player', function(e) {
      return _this.selectPlayer($(e.currentTarget));
    });
    this.settings.find('.edit_player').bind('touchstart.edit_player', function(e) {
      var button;
      button = $(e.currentTarget);
      button.addClass('active');
      $(document.body).one('touchend.edit_player', function() {
        return button.removeClass('active');
      });
      return _this.editPlayer();
    });
    this.settings.find('.play_button').bind('touchstart.play', function(e) {
      var button;
      button = $(e.currentTarget);
      button.addClass('active');
      $(document.body).one('touchend.play', function() {
        return button.removeClass('active');
      });
      return _this.hideMenu(_this.settings);
    });
    this.initKeyboard();
    this.initRadios();
    this.initActions();
    return this.showPlayer();
  },
  initActions: function() {
    var _this = this;
    this.settings.find('.form .actions .save').bind('touchstart.save', function(e) {
      var button;
      button = $(e.currentTarget);
      button.addClass('active');
      $(document.body).one('touchend.save', function() {
        return button.removeClass('active');
      });
      _this.selectedPlayer.name = _this.settings.find('.form .name').html();
      _this.selectedPlayer.hand = _this.settings.find('.form .hand input:checked').val();
      _this.helper.setFlip(_this.selectedPlayer.hand.toLowerCase());
      _this.savePlayer();
      _this.populatePlayer();
      return _this.showPlayer();
    });
    return this.settings.find('.form .actions .cancel').bind('touchstart.cancel', function(e) {
      var button;
      button = $(e.currentTarget);
      button.addClass('active');
      $(document.body).one('touchend.cancel', function() {
        return button.removeClass('active');
      });
      return _this.showPlayer();
    });
  },
  initRadios: function() {
    var direction, _i, _len, _ref, _results,
      _this = this;
    _ref = ['left', 'right'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      direction = _ref[_i];
      _results.push((function(direction) {
        var hand;
        hand = _this.settings.find(".hand ." + direction);
        return hand.bind('touchstart.hand', function() {
          _this.settings.find('.hand input').attr({
            checked: ''
          });
          return hand.attr({
            checked: 'checked'
          });
        });
      })(direction));
    }
    return _results;
  },
  initKeyboard: function() {
    var addBreak, addLetter, keyboard, l, letter, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _results,
      _this = this;
    keyboard = this.settings.find('.keyboard');
    addLetter = function(letter) {
      var color;
      color = letter.match(/&.*;/) ? 'red' : 'blue';
      return keyboard.append("<a class='letter'><span class='" + color + "_button'>" + letter + "</span></a>");
    };
    addBreak = function() {
      return keyboard.append('<br/>');
    };
    _ref = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '&lsaquo;'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      letter = _ref[_i];
      addLetter(letter);
    }
    addBreak();
    _ref1 = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      letter = _ref1[_j];
      addLetter(letter);
    }
    addBreak();
    _ref2 = ['&and;', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '&#95;'];
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      letter = _ref2[_k];
      addLetter(letter);
    }
    keyboard.find('.letter').bind('touchstart.letter', function(e) {
      letter = $(e.currentTarget);
      letter.addClass('active');
      $(document.body).one('touchend.letter', function() {
        return letter.removeClass('active');
      });
      return _this.clickLetter(letter);
    });
    _ref3 = keyboard.find('.letter span');
    _results = [];
    for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
      l = _ref3[_l];
      if ($(l).html() === '∧') {
        _results.push(this.clickLetter($(l).closest('.letter')));
      }
    }
    return _results;
  },
  clickLetter: function(letter) {
    var htmlLetter, l, letters, name, _i, _j, _k, _l, _len, _len1, _len2, _len3, _results;
    letters = this.settings.find('.keyboard .letter span');
    htmlLetter = letter.find('span').html();
    name = this.settings.find('.player_details .form .name');
    if (!(htmlLetter === '∨' && htmlLetter === '∧')) {
      if (name.html().match(/Player\d/) || name.html() === '&nbsp;') {
        name.html('');
      }
    }
    switch (htmlLetter) {
      case '_':
        name.append(' ');
        break;
      case '∧':
        for (_i = 0, _len = letters.length; _i < _len; _i++) {
          l = letters[_i];
          $(l).html($(l).html().toUpperCase());
        }
        letter.find('span').html('&or;');
        break;
      case '∨':
        for (_j = 0, _len1 = letters.length; _j < _len1; _j++) {
          l = letters[_j];
          $(l).html($(l).html().toLowerCase());
        }
        letter.find('span').html('&and;');
        break;
      case '‹':
        name.html(name.html().slice(0, name.html().length - 1));
        break;
      default:
        name.append(htmlLetter);
    }
    if (name.html().length <= 0) {
      name.html('&nbsp;');
    } else if (htmlLetter !== '∨' && htmlLetter !== '∧') {
      for (_k = 0, _len2 = letters.length; _k < _len2; _k++) {
        l = letters[_k];
        if ($(l).html() === '∨') {
          this.clickLetter($(l).closest('.letter'));
        }
      }
    }
    if ((name.html() === '&nbsp;' || name.html().match(/\s$/)) && htmlLetter !== '∨' && htmlLetter !== '∧') {
      _results = [];
      for (_l = 0, _len3 = letters.length; _l < _len3; _l++) {
        l = letters[_l];
        if ($(l).html() === '∧') {
          _results.push(this.clickLetter($(l).closest('.letter')));
        }
      }
      return _results;
    }
  },
  selectPlayer: function(player) {
    var existingProgressIds, id, info, lastLevel, lastLevelId, level, startedLevels, _base, _name,
      _this = this;
    this.settings.find('.select_player').removeClass('selected');
    player.addClass('selected');
    this.selectedPlayer = this.players[player.data('id')];
    existingProgressIds = (function() {
      var _i, _len, _ref, _results;
      _ref = Object.keys(this.puzzleProgress || {});
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        id = _ref[_i];
        _results.push(parseInt(id));
      }
      return _results;
    }).call(this);
    this.puzzleProgress = this.selectedPlayer.progress || {};
    this.initLevelSelector(__slice.call(existingProgressIds).concat(__slice.call((function() {
        var _i, _len, _ref, _results;
        _ref = Object.keys(this.puzzleProgress);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          id = _ref[_i];
          _results.push(parseInt(id));
        }
        return _results;
      }).call(this))));
    startedLevels = (function() {
      var _ref, _results;
      _ref = this.puzzleProgress;
      _results = [];
      for (level in _ref) {
        info = _ref[level];
        if (info.started) {
          _results.push({
            id: level,
            started: info.started
          });
        }
      }
      return _results;
    }).call(this);
    if (startedLevels.length) {
      lastLevelId = startedLevels.sort(function(a, b) {
        return b.started - a.started;
      })[0].id;
      lastLevel = this.findLevel(parseInt(lastLevelId));
      if (lastLevel) {
        this.level = lastLevel;
      }
    } else {
      this.level = this.worlds[0].stages[0].levels[0];
    }
    this.clear();
    this.initLevel();
    (_base = this.puzzleProgress)[_name = this.level.id] || (_base[_name] = {});
    return this.populatePlayer();
  },
  populatePlayer: function() {
    var completed, id, info, key, value, _ref;
    if (!this.selectedPlayer) {
      return;
    }
    _ref = this.selectedPlayer;
    for (key in _ref) {
      value = _ref[key];
      this.settings.find(".player_details .info ." + key).html("" + value);
    }
    completed = (function() {
      var _ref1, _results;
      _ref1 = this.selectedPlayer.progress;
      _results = [];
      for (id in _ref1) {
        info = _ref1[id];
        if (info.completed) {
          _results.push(id);
        }
      }
      return _results;
    }).call(this);
    this.settings.find('.player_details .info .completed').html("" + completed.length);
    this.settings.find('.form .name').html(this.selectedPlayer.name);
    this.settings.find('.form .hand input').attr({
      checked: ''
    });
    this.settings.find(".form .hand input." + (this.selectedPlayer.hand.toLowerCase())).attr({
      checked: 'checked'
    });
    return this.settings.find(".player_selection .player" + this.selectedPlayer.id).html(this.selectedPlayer.name);
  },
  savePlayer: function() {
    this.selectedPlayer.lastPlayed = new Date().getTime();
    this.selectedPlayer.progress = this.puzzleProgress;
    return window.localStorage.setItem('player_data', JSON.stringify(this.players));
  },
  editPlayer: function() {
    var details;
    details = this.settings.find('.player_details');
    details.find('.info').hide();
    return details.find('.form').show();
  },
  showPlayer: function() {
    this.settings.find('.player_details .form').hide();
    return this.settings.find('.player_details .info').show();
  },
  testHints: function(levelIndex) {
    var index, level, stage, world, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2,
      _this = this;
    if (levelIndex == null) {
      levelIndex = 0;
    }
    this.hideMenu(this.levelSelector);
    this.hideMenu(this.settings);
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
              this.clear();
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
                      type: 'touchstart'
                    });
                    $(document.body).trigger('touchstart.hint');
                    component.element.trigger('touchstart.hint');
                    return $.timeout(1000, function() {
                      $(document.body).trigger('touchend.hint');
                      component.move({
                        preventDefault: function() {},
                        type: 'touchmove',
                        clientX: dropAreaElement.offset().left,
                        clientY: dropAreaElement.offset().top + (30 / (window.appScale || 1))
                      });
                      component.endMove({
                        preventDefault: function() {},
                        type: 'touchend',
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
              _this.$('.hints').trigger('touchstart.hint');
              _this.$('.hints').trigger('touchend.hint');
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
                  launch.trigger('touchend.hint');
                  launch.trigger('touchstart.launch');
                  return launch.trigger('touchend.launch');
                }
              });
            });
            return;
          }
          index += 1;
        }
      }
    }
  }
};
