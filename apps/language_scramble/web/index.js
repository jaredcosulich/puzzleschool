// Generated by CoffeeScript 1.3.3

window.app = {
  initialize: function() {
    var data, languageScramble,
      _this = this;
    if (!(this.width = window.innerWidth || window.landwidth) || !(this.height = window.innerHeight || window.landheight)) {
      $.timeout(100, function() {
        return window.app.initialize();
      });
      return;
    }
    document.addEventListener('touchmove', (function(e) {
      return e.preventDefault();
    }), false);
    languageScramble = require('./lib/language_scramble');
    this.selector = $('.language_scramble');
    $('.scramble_content').height(window.innerHeight);
    if (AppMobi) {
      if (data = AppMobi.cache.getCookie('data')) {
        this.puzzleData = JSON.parse(data);
      }
    } else {
      if (data = window.localStorage.getItem('data')) {
        this.puzzleData = JSON.parse(data);
      }
    }
    if (!this.puzzleData) {
      this.puzzleData = {
        levels: {}
      };
    }
    if (!this.puzzleData.nativeLanguage) {
      this.puzzleData.nativeLanguage = 'English';
    }
    if (!this.puzzleData.foreignLanguage) {
      this.puzzleData.menu = 'foreign';
    } else if (!this.puzzleData.levels["" + this.puzzleData.nativeLanguage + "_" + this.puzzleData.foreignLanguage]) {
      this.puzzleData.levels["" + this.puzzleData.nativeLanguage + "_" + this.puzzleData.foreignLanguage] = {};
    }
    this.viewHelper = new languageScramble.ViewHelper({
      el: $(this.selector),
      puzzleData: this.puzzleData,
      dragOffset: 60,
      saveProgress: function(puzzleProgress) {
        return _this.saveProgress(puzzleProgress);
      }
    });
    this.initMenus();
    this.initKeyboard();
    this.checkSize(50);
    this.viewHelper.bindWindow();
    this.viewHelper.bindKeyPress();
    this.levelName = this.puzzleData.lastLevelPlayed;
    if (this.levelName && this.puzzleData.foreignLanguage) {
      this.viewHelper.setLevel(this.levelName);
      return this.viewHelper.newScramble();
    } else {
      return this.showMenu();
    }
  },
  $: function(selector) {
    return this.selector.find(selector);
  },
  checkSize: function(interval) {
    var _this = this;
    if (this.width !== (window.innerWidth || window.landwidth)) {
      this.width = window.innerWidth || window.landwidth;
      this.height = window.innerHeight || window.landheight;
      this.sizeElements();
      this.viewHelper.displayScramble();
    }
    return $.timeout(interval, function() {
      return _this.checkSize(interval * 2);
    });
  },
  saveProgress: function(puzzleProgress) {
    puzzleProgress.menu = this.puzzleData.menu;
    return AppMobi.cache.setCookie("data", JSON.stringify(puzzleProgress), -1);
  },
  initLevelSelectMenu: function(language) {
    var key, languages, levelSelect, levelsAdded, levelsContainer, levelsGroup, next, previous, showLevel, showNext, showPrevious, startPosition, _fn,
      _this = this;
    language = language.toLowerCase();
    levelSelect = this.$("#" + language + "_select_menu");
    startPosition = {};
    levelSelect.bind('touchstart', function(e) {
      return startPosition = {
        scrollTop: parseInt(levelSelect.scrollTop()),
        touch: _this.viewHelper.clientY(e)
      };
    });
    levelSelect.bind('touchmove', function(e) {
      return levelSelect.scrollTop(startPosition.scrollTop - (_this.viewHelper.clientY(e) - startPosition.touch));
    });
    showLevel = function(level) {
      _this.viewHelper.$('#next_level').css({
        opacity: 0
      });
      _this.viewHelper.$('.scramble_content').css({
        opacity: 1
      });
      _this.viewHelper.setLevel(level);
      _this.viewHelper.newScramble();
      return levelSelect.animate({
        opacity: 0,
        duration: 500,
        complete: function() {
          return levelSelect.css({
            top: -1000,
            left: -1000
          });
        }
      });
    };
    languages = "" + (this.puzzleData.nativeLanguage.toLowerCase()) + "_" + (language.toLowerCase());
    levelsContainer = levelSelect.find('.levels_container');
    levelsGroup = null;
    levelsAdded = 0;
    _fn = function(key, levelsGroup, levelsAdded) {
      var info, levelLink, levelLinkDiv, levelProgress, percentComplete, _ref, _ref1;
      info = languageScramble.data[languages].levels[key];
      levelLinkDiv = document.createElement("DIV");
      levelLinkDiv.className = 'level';
      levelLinkDiv.id = "level_link_" + key;
      levelLink = document.createElement("A");
      levelLink.className = 'level_link';
      levelLink.innerHTML = "" + info.title + "<br/><small>" + info.subtitle + "</small>";
      $(levelLink).bind('touchstart.select_level', function() {
        return showLevel(key);
      });
      $(levelLinkDiv).append(levelLink);
      levelsGroup.append(levelLinkDiv);
      percentComplete = document.createElement("DIV");
      percentComplete.className = 'percent_complete';
      $(percentComplete).width("" + (((_ref = _this.puzzleData.levels[languages]) != null ? (_ref1 = _ref[key]) != null ? _ref1.percentComplete : void 0 : void 0) || 0) + "%");
      $(levelLinkDiv).append(percentComplete);
      levelProgress = document.createElement("DIV");
      levelProgress.className = 'mini_progress_meter';
      return $(levelLinkDiv).append(levelProgress);
    };
    for (key in languageScramble.data[languages].levels) {
      if (levelsAdded % 4 === 0) {
        levelsGroup = $(document.createElement("DIV"));
        levelsGroup.addClass('levels_group');
        levelsContainer.append(levelsGroup);
        levelsContainer.width(levelsGroup.width() * (1 + (levelsAdded / 4)));
      }
      _fn(key, levelsGroup, levelsAdded);
      levelsAdded += 1;
    }
    next = levelSelect.find('.next');
    showNext = function() {
      next.unbind('touchstart.next');
      _this.$('document.body').one('touchend.next', function() {
        return next.removeClass('active');
      });
      next.addClass('active');
      return levelsContainer.animate({
        marginLeft: parseInt(levelsContainer.css('marginLeft')) - levelSelect.width(),
        duration: 500,
        complete: function() {
          return next.bind('touchstart.next', function() {
            return showNext();
          });
        }
      });
    };
    next.bind('touchstart.next', function() {
      return showNext();
    });
    previous = levelSelect.find('.previous');
    showPrevious = function() {
      previous.unbind('touchstart.previous');
      _this.$('document.body').one('touchend.previous', function() {
        return previous.removeClass('active');
      });
      previous.addClass('active');
      return levelsContainer.animate({
        marginLeft: parseInt(levelsContainer.css('marginLeft')) + levelSelect.width(),
        duration: 500,
        complete: function() {
          return previous.bind('touchstart.previous', function() {
            return showPrevious();
          });
        }
      });
    };
    return previous.bind('touchstart.previous', function() {
      return showPrevious();
    });
  },
  showMenu: function(name) {
    if (name == null) {
      name = this.puzzleData.menu;
    }
    this.$('.floating_message').css({
      top: -10000,
      left: -10000
    });
    this.puzzleData.menu = name;
    return this.menus[this.puzzleData.menu].css({
      opacity: 1,
      top: (this.height - this.menus[this.puzzleData.menu].height()) / 2,
      left: (this.width - this.menus[this.puzzleData.menu].width()) / 2
    });
  },
  initMenus: function() {
    var menu, name, _fn, _ref,
      _this = this;
    this.menus = {
      "native": this.$('#native_select_menu'),
      foreign: this.$('#foreign_select_menu'),
      italian: this.$('#italian_select_menu'),
      spanish: this.$('#spanish_select_menu')
    };
    _ref = this.menus;
    _fn = function(menu) {
      var closeMenu, upMenu;
      upMenu = menu.find('.up_menu_button');
      upMenu.bind('touchstart.up_menu', function() {
        return _this.showMenu('foreign');
      });
      closeMenu = menu.find('.close_menu_button');
      return closeMenu.bind('touchstart.close_menu', function() {
        if (_this.animatingMenu) {
          return;
        }
        _this.animatingMenu = true;
        _this.$('document.body').one('touchend.next', function() {
          return closeMenu.removeClass('active');
        });
        closeMenu.addClass('active');
        _this.$('.scramble_content').animate({
          opacity: 1,
          duration: 250
        });
        return menu.animate({
          opacity: 0,
          duration: 500,
          complete: function() {
            _this.animatingMenu = false;
            return menu.css({
              top: -10000,
              left: -10000
            });
          }
        });
      });
    };
    for (name in _ref) {
      menu = _ref[name];
      _fn(menu);
    }
    menu = this.$('.menu_button');
    menu.bind('touchstart.menu', function() {
      var menuName, _ref1;
      if (_this.animatingMenu) {
        return;
      }
      _this.animatingMenu = true;
      $.timeout(200, function() {
        return menu.removeClass('active');
      });
      menu.addClass('active');
      _this.$('.scramble_content').animate({
        opacity: 0.25,
        duration: 250
      });
      _this.viewHelper.hideDictionary();
      menuName = ((_ref1 = _this.puzzleData.foreignLanguage) != null ? _ref1.toLowerCase() : void 0) || _this.puzzleData.menu;
      _this.menus[menuName].css({
        opacity: 0,
        top: (_this.height - _this.menus[menuName].height()) / 2,
        left: (_this.width - _this.menus[menuName].width()) / 2
      });
      return _this.menus[menuName].animate({
        opacity: 1,
        duration: 500,
        complete: function() {
          return _this.animatingMenu = false;
        }
      });
    });
    return this.initForeignMenu();
  },
  initForeignMenu: function() {
    var foreignGroup, language, _fn, _i, _len, _ref, _results,
      _this = this;
    foreignGroup = this.$('#foreign_select_menu .levels_container .levels_group');
    _ref = ['Italian', 'Spanish'];
    _fn = function(language) {
      var levelLink, levelLinkDiv;
      levelLinkDiv = document.createElement("DIV");
      levelLinkDiv.className = 'level';
      levelLink = document.createElement("A");
      levelLink.className = 'level_link';
      levelLink.innerHTML = language;
      $(levelLink).bind('touchstart.select_level', function() {
        _this.viewHelper.setForeignLanguage(language);
        return _this.showMenu(language.toLowerCase());
      });
      $(levelLinkDiv).append(levelLink);
      return foreignGroup.append(levelLinkDiv);
    };
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      language = _ref[_i];
      _fn(language);
      _results.push(this.initLevelSelectMenu(language));
    }
    return _results;
  },
  initKeyboard: function() {
    var addBreak, addLetter, keyboard, letter, _i, _len, _ref,
      _this = this;
    keyboard = this.$('.keyboard');
    addLetter = function(letter) {
      var color;
      color = letter.match(/&.*;/) ? 'red' : 'blue';
      return keyboard.append("<a class='letter'><span class='" + color + "_button'>" + letter + "</span></a>");
    };
    addBreak = function() {
      return keyboard.append('<br/>');
    };
    _ref = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '&lsaquo;'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      letter = _ref[_i];
      addLetter(letter);
    }
    return keyboard.find('.letter').bind('touchstart.letter', function(e) {
      letter = $(e.currentTarget);
      letter.addClass('active');
      $(document.body).one('touchend.letter', function() {
        return letter.removeClass('active');
      });
      return _this.clickLetter(letter);
    });
  },
  clickLetter: function(letter) {
    var guessedLetter, guessedLetters, htmlLetter, lastLetterAdded;
    htmlLetter = letter.find('span').html();
    switch (htmlLetter) {
      case '‹':
        lastLetterAdded = this.viewHelper.lettersAdded.pop();
        guessedLetters = $(".guesses .letter_" + lastLetterAdded);
        if (guessedLetters.length) {
          guessedLetter = $(guessedLetters[guessedLetters.length - 1]);
          guessedLetter.trigger('keypress.start');
          return guessedLetter.trigger('keypress.end');
        }
        break;
      default:
        return this.viewHelper.typeLetter(htmlLetter, true);
    }
  }
};
