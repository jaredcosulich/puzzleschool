// Generated by CoffeeScript 1.3.3

window.app = {
  initialize: function() {
    var data, languageScramble,
      _this = this;
    if (!(this.width = window.innerWidth || window.landwidth) || !(this.height = window.innerHeight || window.landheight) || this.width < this.height) {
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
    this.languages = "english_italian";
    if (!this.puzzleData.levels[this.languages]) {
      this.puzzleData.levels[this.languages] = {};
    }
    this.levelName = this.puzzleData.lastLevelPlayed || "top10words";
    this.viewHelper = new languageScramble.ViewHelper({
      el: $(this.selector),
      puzzleData: this.puzzleData,
      languages: this.languages,
      saveProgress: function(puzzleProgress) {
        return _this.saveProgress(puzzleProgress);
      }
    });
    this.initProgressMeter();
    this.initMenuButton();
    this.initKeyboard();
    this.checkSize(50);
    this.sizeElements();
    this.viewHelper.setLevel(this.levelName);
    this.viewHelper.bindWindow();
    this.viewHelper.bindKeyPress();
    return this.viewHelper.newScramble();
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
  sizeElements: function() {
    var levelSelect;
    this.progressMeter.css({
      top: this.height - this.percentComplete.height()
    });
    levelSelect = this.$('#level_select_menu');
    levelSelect.width(this.width);
    return levelSelect.height(this.height);
  },
  initProgressMeter: function() {
    this.progressMeter = this.viewHelper.$('.level_progress_meter');
    return this.percentComplete = this.progressMeter.find('.percent_complete');
  },
  saveProgress: function(puzzleProgress) {
    var percentComplete, _ref;
    percentComplete = 0;
    if ((_ref = puzzleProgress.levels[this.languages][puzzleProgress.lastLevelPlayed]) != null ? _ref.percentComplete : void 0) {
      percentComplete = puzzleProgress.levels[this.languages][puzzleProgress.lastLevelPlayed].percentComplete;
    }
    this.percentComplete.width("" + percentComplete + "%");
    return AppMobi.cache.setCookie("data", JSON.stringify(puzzleProgress), -1);
  },
  initMenuButton: function() {
    var key, levelSelect, showLevel, startPosition, _fn,
      _this = this;
    levelSelect = this.$('#level_select_menu');
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
    _fn = function(key) {
      var info, levelLink, levelLinkDiv, levelProgress, percentComplete, _ref;
      info = languageScramble.data[_this.languages].levels[key];
      levelLinkDiv = document.createElement("DIV");
      levelLinkDiv.className = 'level';
      levelLinkDiv.id = "level_link_" + key;
      levelLink = document.createElement("A");
      levelLink.className = 'level_link';
      levelLink.innerHTML = "" + info.title + "<br/><small>" + info.subtitle + "</small>";
      $(levelLink).bind('click', function() {
        return showLevel(key);
      });
      $(levelLinkDiv).append(levelLink);
      levelSelect.append(levelLinkDiv);
      levelProgress = document.createElement("A");
      levelProgress.className = 'percent_complete';
      levelProgress.innerHTML = '&nbsp;';
      percentComplete = ((_ref = _this.puzzleData.levels[_this.languages][key]) != null ? _ref.percentComplete : void 0) || 0;
      $(levelProgress).width("" + percentComplete + "%");
      $(levelProgress).bind('click', function() {
        return showLevel(key);
      });
      return $(levelLinkDiv).append(levelProgress);
    };
    for (key in languageScramble.data[this.languages].levels) {
      _fn(key);
    }
    this.$('.menu_button').bind('click', function() {
      levelSelect.css({
        opacity: 0,
        top: (_this.height - levelSelect.height()) / 2,
        left: (_this.width - levelSelect.width()) / 2
      });
      return levelSelect.animate({
        opacity: 1,
        duration: 500
      });
    });
    return this.$('#close_menu_button').bind('click', function() {
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
    });
  },
  initKeyboard: function() {
    var addBreak, addLetter, keyboard, letter, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2,
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
    _ref2 = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      letter = _ref2[_k];
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
