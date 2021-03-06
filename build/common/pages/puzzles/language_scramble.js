// Generated by CoffeeScript 1.3.3
var soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  LanguageScramble: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      var _this = this;
      this.languages = _arg.languages, this.levelName = _arg.levelName;
      this.template = this.loadTemplate('/build/common/templates/puzzles/language_scramble.html');
      this.loadScript('/build/common/pages/puzzles/lib/language_scramble.js');
      this.loadStylesheet('/build/client/css/puzzles/language_scramble.css');
      this.puzzleData = {
        levels: {}
      };
      if (this.cookies.get('user')) {
        return this.loadData({
          url: '/api/puzzles/language_scramble',
          success: function(data) {
            var level, levelInfo, _ref, _results;
            if (data.puzzle != null) {
              _this.puzzleData = data.puzzle;
              _ref = _this.puzzleData.levels;
              _results = [];
              for (levelName in _ref) {
                levelInfo = _ref[levelName];
                languages = levelName.split(/\//)[0];
                level = levelName.split(/\//)[1];
                if (!_this.puzzleData.levels[languages]) {
                  _this.puzzleData.levels[languages] = {};
                }
                _this.puzzleData.levels[languages][level] = levelInfo;
                _results.push(delete _this.puzzleData.levels[levelName]);
              }
              return _results;
            }
          },
          error: function() {
            if (typeof window !== "undefined" && window !== null ? window.alert : void 0) {
              return alert('We were unable to load your account information. Please check your internet connection.');
            }
          }
        });
      }
    },
    build: function() {
      var languageScramble;
      this.setTitle("Language Scramble - The Puzzle School");
      this.loadElement("link", {
        rel: 'img_src',
        href: 'http://www.puzzleschool.com/assets/images/reviews/language_scramble.jpg'
      });
      this.setMeta({
        name: 'og:title',
        property: 'og:title',
        content: 'Language Scramble - The Puzzle School'
      });
      this.setMeta({
        name: 'og:url',
        property: 'og:url',
        content: 'http://www.puzzleschool.com/puzzles/language_scramble'
      });
      this.setMeta({
        name: 'og:image',
        property: 'og:image',
        content: 'http://www.puzzleschool.com/assets/images/reviews/language_scramble.jpg'
      });
      this.setMeta({
        name: 'og:description',
        property: 'og:description',
        content: 'Practice vocabulary and common sentences in your favorite foreign language. Much more fun than flash cards.'
      });
      this.setMeta('description', 'Practice vocabulary and common sentences in your favorite foreign language. Much more fun than flash cards.');
      languageScramble = require('./lib/language_scramble');
      if (!(this.languages && this.languages.length)) {
        this.languages = this.puzzleData.lastLanguages || 'english_italian';
      }
      if (!(this.levelName && this.levelName.length)) {
        this.levelName = this.puzzleData.lastLevelPlayed || 'top10nouns';
      }
      if (!this.puzzleData.levels[this.languages]) {
        this.puzzleData.levels[this.languages] = {};
      }
      this.chunkHelper = new languageScramble.ChunkHelper(this.languages, this.levelName, this.puzzleData);
      return this.html = wings.renderTemplate(this.template, {
        puzzleData: JSON.stringify(this.puzzleData),
        languages: this.languages,
        displayLanguages: this.chunkHelper.displayLanguages(),
        title: this.chunkHelper.level.title,
        subtitle: this.chunkHelper.level.subtitle,
        data: this.chunkHelper.level.data,
        levelName: this.levelName,
        allLevels: this.chunkHelper.allLevels()
      });
    }
  }
});

soma.views({
  LanguageScramble: {
    selector: '#content .language_scramble',
    create: function() {
      var languageScramble,
        _this = this;
      languageScramble = require('./lib/language_scramble');
      this.puzzleData = JSON.parse(this.el.data('puzzle_data'));
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
        saveProgress: function(puzzleProgress) {
          return _this.saveProgress(puzzleProgress);
        }
      });
      this.levelName = this.puzzleData.lastLevelPlayed;
      this.initMenus();
      this.viewHelper.bindWindow();
      this.viewHelper.bindKeyPress();
      if (this.levelName && this.puzzleData.foreignLanguage) {
        this.viewHelper.setLevel(this.levelName);
        return this.viewHelper.newScramble();
      } else {
        return $.timeout(100, function() {
          return _this.showMenu();
        });
      }
    },
    saveProgress: function(puzzleProgress, callback) {
      var languages, levelInfo, levelName, levelUpdates, levels, puzzleUpdates, _ref,
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
          url: "/api/puzzles/language_scramble/update",
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
            return this.showRegistrationFlag();
          }
        }
      }
    },
    initLevelSelectMenu: function(language) {
      var checkPrevious, key, languages, levelSelect, levelsAdded, levelsContainer, levelsGroup, next, previous, showLevel, showNext, showPrevious, startPosition, startingPoint, _fn,
        _this = this;
      language = language.toLowerCase();
      levelSelect = this.$("#" + language + "_select_menu");
      startPosition = {};
      levelSelect.bind('mousedown', function(e) {
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
        levelLink.innerHTML = info.title;
        $(levelLinkDiv).append(levelLink);
        levelsGroup.append(levelLinkDiv);
        percentComplete = document.createElement("DIV");
        percentComplete.className = 'percent_complete';
        $(percentComplete).width("" + (((_ref = _this.puzzleData.levels[languages]) != null ? (_ref1 = _ref[key]) != null ? _ref1.percentComplete : void 0 : void 0) || 0) + "%");
        $(levelLinkDiv).append(percentComplete);
        levelProgress = document.createElement("DIV");
        levelProgress.className = 'mini_progress_meter';
        $(levelLinkDiv).append(levelProgress);
        return $(levelLinkDiv).bind('mousedown.select_level', function() {
          return showLevel(key);
        });
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
      previous = levelSelect.find('.previous');
      next = levelSelect.find('.next');
      startingPoint = parseInt(levelsContainer.css('marginLeft'));
      checkPrevious = function(marginLeft) {
        if (marginLeft == null) {
          marginLeft = parseInt(levelsContainer.css('marginLeft'));
        }
        if (marginLeft >= startingPoint) {
          return previous.animate({
            opacity: 0,
            duration: 250,
            complete: function() {
              return previous.addClass('hidden');
            }
          });
        } else {
          previous.removeClass('hidden');
          return previous.animate({
            opacity: 1,
            duration: 250
          });
        }
      };
      showNext = function() {
        var marginLeft;
        next.unbind('mousedown.next');
        _this.$('document.body').one('mouseup.next', function() {
          return next.removeClass('active');
        });
        next.addClass('active');
        marginLeft = parseInt(levelsContainer.css('marginLeft')) - levelSelect.width();
        checkPrevious(marginLeft);
        return levelsContainer.animate({
          marginLeft: marginLeft,
          duration: 500,
          complete: function() {
            return next.bind('mousedown.next', function() {
              return showNext();
            });
          }
        });
      };
      next.bind('mousedown.next', function() {
        return showNext();
      });
      showPrevious = function() {
        var marginLeft;
        previous.unbind('mousedown.previous');
        _this.$('document.body').one('mouseup.previous', function() {
          return previous.removeClass('active');
        });
        previous.addClass('active');
        marginLeft = parseInt(levelsContainer.css('marginLeft')) + levelSelect.width();
        checkPrevious(marginLeft);
        return levelsContainer.animate({
          marginLeft: marginLeft,
          duration: 500,
          complete: function() {
            checkPrevious();
            return previous.bind('mousedown.previous', function() {
              return showPrevious();
            });
          }
        });
      };
      previous.bind('mousedown.previous', function() {
        return showPrevious();
      });
      return checkPrevious();
    },
    showMenu: function(name) {
      var contentOffset, gameAreaOffset;
      if (name == null) {
        name = this.puzzleData.menu;
      }
      this.$('.scramble_content').animate({
        opacity: 0.25,
        duration: 250
      });
      this.viewHelper.hideDictionary();
      gameAreaOffset = this.el.offset();
      contentOffset = this.$('.scramble_content').offset();
      this.$('.floating_message').css({
        top: -10000,
        left: -10000
      });
      this.puzzleData.menu = name;
      return this.menus[this.puzzleData.menu].css({
        opacity: 1,
        top: (contentOffset.top - gameAreaOffset.top) + ((contentOffset.height - this.menus[this.puzzleData.menu].height()) / 2),
        left: (contentOffset.width - this.menus[this.puzzleData.menu].width()) / 2
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
        upMenu.bind('mousedown.up_menu', function() {
          return _this.showMenu('foreign');
        });
        closeMenu = menu.find('.close_menu_button');
        return closeMenu.bind('mousedown.close_menu', function() {
          if (_this.animatingMenu) {
            return;
          }
          _this.animatingMenu = true;
          _this.$('document.body').one('mouseup.next', function() {
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
      menu.bind('mousedown.menu', function() {
        var menuName, _ref1;
        if (_this.animatingMenu) {
          return;
        }
        _this.animatingMenu = true;
        $.timeout(200, function() {
          return menu.removeClass('active');
        });
        menu.addClass('active');
        menuName = ((_ref1 = _this.puzzleData.foreignLanguage) != null ? _ref1.toLowerCase() : void 0) || _this.puzzleData.menu;
        _this.menus[menuName].css({
          opacity: 0
        });
        _this.showMenu(menuName);
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
        $(levelLink).bind('mousedown.select_level', function() {
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
    compareItem: function(current, original) {
      if (!original) {
        return current;
      }
      if (typeof current === 'object') {
        return this.compareHashes(current, original);
      } else if (Array.isArray(current)) {
        return this.compareArrays(current, original);
      } else {
        if (current !== original) {
          return current;
        }
      }
    },
    compareHashes: function(current, original) {
      var diff, diffValue, key, value;
      diff = {};
      for (key in current) {
        value = current[key];
        diffValue = this.compareItem(value, original[key]);
        if (diffValue != null) {
          diff[key] = diffValue;
        }
      }
      if (Object.keys(diff).length > 0) {
        return diff;
      }
    },
    compareArrays: function(current, original) {
      var diff, diffValue, index, item, _i, _len;
      diff = [];
      for (index = _i = 0, _len = current.length; _i < _len; index = ++_i) {
        item = current[index];
        diffValue = this.compareItem(item, original[index]);
        if (diffValue != null) {
          diff.push(diffValue);
        }
      }
      if (diff.length > 0) {
        return diff;
      }
    },
    getUpdates: function(progress) {
      return this.compareHashes(progress, this.puzzleData);
    }
  }
});

soma.routes({
  '/puzzles/language_scramble/:languages/:levelName': function(data) {
    return new soma.chunks.LanguageScramble({
      languages: data.languages,
      levelName: data.levelName
    });
  },
  '/puzzles/language_scramble/:languages': function(data) {
    return new soma.chunks.LanguageScramble({
      languages: data.languages
    });
  },
  '/puzzles/language_scramble': function() {
    return new soma.chunks.LanguageScramble;
  }
});
