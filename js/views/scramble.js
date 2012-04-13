var localData;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
}, __indexOf = Array.prototype.indexOf || function(item) {
  for (var i = 0, l = this.length; i < l; i++) {
    if (this[i] === item) return i;
  }
  return -1;
};
(function($) {
  var views;
  views = require('views');
  views.Scramble = (function() {
    __extends(Scramble, views.Page);
    function Scramble() {
      this.clientY = __bind(this.clientY, this);
      this.clientX = __bind(this.clientX, this);
      Scramble.__super__.constructor.apply(this, arguments);
    }
    Scramble.prototype.prepare = function(_arg) {
      this.level = _arg.level;
      this.template = this._requireTemplate('templates/scramble.html');
      return this.setLevels();
    };
    Scramble.prototype.renderView = function() {
      this.el.html(this.template.render());
      this.bindWindow();
      this.bindKeyPress();
      this.setOptions();
      return this.newScramble();
    };
    Scramble.prototype.setLevels = function() {
      var copiedData, dataType, effort, effortLevels, level, levels, names, scrambleInfo, sortedData, user, users, _i, _j, _len, _len2, _ref, _ref2, _results;
      this.level = 0;
      users = $.cookie('users') || {};
      names = (function() {
        var _results;
        _results = [];
        for (user in users) {
          level = users[user];
          _results.push(user.toLowerCase());
        }
        return _results;
      })();
      this.user = prompt("What is your name?" + (names.length ? "\n\nExisting: " + (names.join(', ')) : ''), "").toLowerCase();
      if (_ref = this.user, __indexOf.call(names, _ref) >= 0) {
        this.level = users[this.user].level;
        this.nativeLevel = users[this.user].nativeLevel;
        this.foreignLevel = users[this.user].foreignLevel;
        this.nativeMediumLevel = users[this.user].nativeMediumLevel;
        this.foreignMediumLevel = users[this.user].foreignMediumLevel;
        this.nativeHardLevel = users[this.user].nativeHardLevel;
        this.foreignHardLevel = users[this.user].foreignHardLevel;
      } else if (this.user && this.user.length > 0) {
        users[this.user] = {
          level: this.level
        };
        $.cookie('users', users);
      }
      _ref2 = ['native', 'foreign'];
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        dataType = _ref2[_i];
        if (!this["" + dataType + "Level"]) {
          this["" + dataType + "Level"] = 1;
        }
        levels = this["" + dataType + "Levels"] = {};
        levels.maxLevel = 0;
        copiedData = localData.slice(0);
        for (_j = 0, _len2 = copiedData.length; _j < _len2; _j++) {
          scrambleInfo = copiedData[_j];
          if (scrambleInfo.nativeSentence && scrambleInfo["native"] !== scrambleInfo.nativeSentence) {
            copiedData.push({
              "native": scrambleInfo.nativeSentence,
              foreign: scrambleInfo.foreignSentence,
              nativeSentence: scrambleInfo.nativeSentence,
              foreignSentence: scrambleInfo.foreignSentence
            });
          }
        }
        sortedData = copiedData.sort(function(a, b) {
          return b[dataType].length - a[dataType].length;
        });
        _results.push((function() {
          var _results2;
          _results2 = [];
          while (sortedData.length) {
            if (!levels["level" + levels.maxLevel] || levels["level" + levels.maxLevel].length >= 6) {
              levels.maxLevel += 1;
              levels["level" + levels.maxLevel] = [];
            }
            level = levels["level" + levels.maxLevel];
            scrambleInfo = sortedData.pop();
            if (sortedData.length) {
              level.push(scrambleInfo);
            }
            _results2.push((function() {
              var _k, _len3, _ref3, _results3;
              _ref3 = ['Medium', 'Hard'];
              _results3 = [];
              for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
                effort = _ref3[_k];
                if (!(effortLevels = this["" + dataType + effort + "Levels"])) {
                  this["" + dataType + effort + "Level"] = 1;
                  effortLevels = this["" + dataType + effort + "Levels"] = {};
                  effortLevels.maxLevel = 0;
                }
                if (!effortLevels["level" + effortLevels.maxLevel] || effortLevels["level" + effortLevels.maxLevel].length >= 6) {
                  effortLevels.maxLevel += 1;
                  effortLevels["level" + effortLevels.maxLevel] = [];
                }
                _results3.push(effortLevels["level" + effortLevels.maxLevel].push(scrambleInfo));
              }
              return _results3;
            }).call(this));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };
    Scramble.prototype.takeABreak = function() {
      this["break"] = (this["break"] || 0) + 3;
      this.breakAdjustment = (this.breakAdjustment || 0) + 9;
      return this.setOptions;
    };
    Scramble.prototype.setOptions = function() {
      var activeLevel, grouping, level, mod;
      level = this.level;
      grouping = Math.floor(level / 18);
      mod = level % 18;
      if (grouping > 15 || mod >= (15 - grouping)) {
        if (grouping > 12 && mod - 12 >= (15 - grouping)) {
          this.activeLevel = 'foreignHard';
        } else if (grouping > 9 && mod - 9 >= (15 - grouping)) {
          this.activeLevel = 'nativeHard';
        } else if (grouping > 6 && mod - 6 >= (15 - grouping)) {
          this.activeLevel = 'foreignMedium';
        } else if (grouping > 3 && mod - 3 >= (15 - grouping)) {
          this.activeLevel = 'nativeMedium';
        } else {
          this.activeLevel = 'foreign';
        }
      } else {
        this.activeLevel = 'native';
      }
      this.activeType = this.activeLevel.replace(/Medium/, '').replace(/Hard/, '');
      this.displayLevel = this.activeType.match(/native/) ? 'foreign' : 'native';
      activeLevel = this["" + this.activeLevel + "Level"];
      if ((this["break"] != null) && this["break"] > 0) {
        activeLevel -= this.breakAdjustment;
      }
      if (activeLevel <= 0) {
        activeLevel = 1;
      }
      console.log(this.level, this.activeLevel, activeLevel);
      this.options = this["" + this.activeLevel + "Levels"]["level" + activeLevel];
      $('.guesses').removeClass('hidden');
      $('.scrambled').removeClass('hidden');
      if ((this.activeLevel.match(/Medium/) != null) || (this.activeLevel.match(/Hard/) != null)) {
        $('.guesses').addClass('hidden');
        $('.guesses .hidden_message').show();
      }
      if (this.activeLevel.match(/Hard/) != null) {
        $('.scrambled').addClass('hidden');
        return $('.scrambled .hidden_message').show();
      }
    };
    Scramble.prototype.randomIndex = function(array) {
      return Math.floor(Math.random() * array.length);
    };
    Scramble.prototype.random = function(array) {
      if (!array) {
        return null;
      }
      if (!array.length) {
        return null;
      }
      if (array.length === 1) {
        return array[0];
      }
      return array[this.randomIndex(array)];
    };
    Scramble.prototype.newScramble = function() {
      var displayWords, highlighted, i, sentence, _ref;
      this.lastScrambles || (this.lastScrambles = []);
      this.lettersAdded = [];
      this.checkLevel();
      for (i = 0; i < 4; i++) {
        if (this.scrambleInfo && (_ref = this.scrambleInfo["native"], __indexOf.call(this.lastScrambles.slice(-4).map(function(s) {
          return s["native"];
        }), _ref) < 0)) {
          break;
        }
        this.scrambleInfo = this.random(this.options);
      }
      this.lastScrambles.push(this.scrambleInfo);
      displayWords = this.$('.display_words');
      if ((this.scrambleInfo["" + this.displayLevel + "Sentence"] != null) && this.scrambleInfo["" + this.displayLevel + "Sentence"].length) {
        sentence = this.scrambleInfo["" + this.displayLevel + "Sentence"];
      } else {
        sentence = this.scrambleInfo[this.displayLevel];
      }
      sentence = " " + sentence + " ";
      highlighted = this.scrambleInfo[this.displayLevel];
      sentence = sentence.replace(" " + highlighted + " ", " <span class='highlighted'>" + highlighted + "</span> ");
      sentence = sentence.replace(" " + highlighted + "?", " <span class='highlighted'>" + highlighted + "</span>?");
      displayWords.html(sentence);
      this.createGuesses();
      this.createScramble();
      return this.startHelpTimer();
    };
    Scramble.prototype.startHelpTimer = function() {
      return;
      clearTimeout(this.helpTimeout);
      return this.helpTimeout = setTimeout((__bind(function() {
        var firstMissingGuess, letter, letterPosition;
        if ((firstMissingGuess = $('.guesses .guess')[0]) == null) {
          return;
        }
        letterPosition = firstMissingGuess.className.indexOf('letter_') + 'letter_'.length;
        letter = firstMissingGuess.className.slice(letterPosition, (letterPosition + 1 + 1) || 9e9);
        $(firstMissingGuess).trigger('click');
        $(this.$(".scrambled ." + (this.containerClassName(firstMissingGuess)) + " .letter_" + letter)[0]).trigger('click');
        if (this.checkCorrectAnswer()) {
          return this.next();
        } else {
          return this.startHelpTimer();
        }
      }, this)), 15000);
    };
    Scramble.prototype.checkLevel = function() {
      var lastAnswerDuration, users;
      this.answerTimes || (this.answerTimes = []);
      if ((this["break"] != null) && this["break"] > 0) {
        this["break"]--;
        this.breakAdjustment--;
        if (this["break"] === 0) {
          this.breakAdjustment = 0;
          this.answerTimes.push(new Date());
        }
        this.setOptions();
        return;
      }
      this.level += 1;
      this.answerTimes.push(new Date());
      if (this.answerTimes.length === 1) {
        return;
      }
      lastAnswerDuration = this.answerTimes[this.answerTimes.length - 1] - this.answerTimes[this.answerTimes.length - 2];
      if (lastAnswerDuration < 3000) {
        this["" + this.activeLevel + "Level"] += 4;
      } else if (lastAnswerDuration < 6000) {
        this["" + this.activeLevel + "Level"] += 3;
      } else if (lastAnswerDuration < 9000) {
        this["" + this.activeLevel + "Level"] += 2;
      } else if (lastAnswerDuration < 20000) {
        this["" + this.activeLevel + "Level"] += 1;
      } else if (lastAnswerDuration > 30000) {
        this.takeABreak();
      }
      this.setOptions();
      if (this.user && this.user.length) {
        users = $.cookie('users');
        users[this.user].level = this.level;
        users[this.user]["" + this.activeLevel + "Level"] = this["" + this.activeLevel + "Level"];
        return $.cookie('users', users);
      }
    };
    Scramble.prototype.createGuesses = function() {
      var container, group, guesses, index, letter, _i, _len, _len2, _ref, _results;
      guesses = this.$('.guesses');
      this.clearContainer(guesses);
      _ref = this.separateIntoWordGroups(this.scrambleInfo[this.activeType]);
      _results = [];
      for (index = 0, _len = _ref.length; index < _len; index++) {
        group = _ref[index];
        container = $(document.createElement("DIV"));
        container.addClass('container');
        container.addClass("color" + (index + 1));
        guesses.append(container);
        for (_i = 0, _len2 = group.length; _i < _len2; _i++) {
          letter = group[_i];
          container.append(letter.match(/\w|[^\x00-\x80]+/) != null ? this.createGuess(letter) : this.createSpace(letter));
        }
        container.width(container.width());
        _results.push(container.css({
          float: 'none',
          height: container.height()
        }));
      }
      return _results;
    };
    Scramble.prototype.createGuess = function(letter) {
      var guess;
      guess = $(document.createElement("DIV"));
      guess.addClass('guess');
      guess.addClass("actual_letter_" + letter);
      return guess.bind('click', __bind(function() {
        if (guess.hasClass('selected')) {
          return guess.removeClass('selected');
        } else {
          this.$('.guesses .guess').removeClass('selected');
          return guess.addClass('selected');
        }
      }, this));
    };
    Scramble.prototype.createSpace = function(letter) {
      var space;
      space = $(document.createElement("DIV"));
      space.addClass('space');
      return space.html(letter);
    };
    Scramble.prototype.separateIntoWordGroups = function(letters) {
      var group, groups, letter, nextGroup, _i, _len;
      groups = [[]];
      for (_i = 0, _len = letters.length; _i < _len; _i++) {
        letter = letters[_i];
        group = groups[groups.length - 1];
        if (group.length === 18) {
          groups.push(nextGroup = []);
          while (!(group[group.length - 1].match(/\s/) != null)) {
            nextGroup.push(group.pop());
          }
          group = nextGroup.reverse();
        }
        group.push(letter);
      }
      return groups;
    };
    Scramble.prototype.shuffle = function(word) {
      var current, letter, shuffled, tmp, top, wordArray;
      top = word.length;
      if (!top) {
        return '';
      }
      if (top === 1) {
        return word;
      }
      if (top === 2) {
        return ((function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = word.length; _i < _len; _i++) {
            letter = word[_i];
            _results.push(letter);
          }
          return _results;
        })()).reverse().join('');
      }
      wordArray = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = word.length; _i < _len; _i++) {
          letter = word[_i];
          _results.push(letter);
        }
        return _results;
      })();
      while (top--) {
        current = Math.floor(Math.random() * (top + 1));
        tmp = wordArray[current];
        wordArray[current] = wordArray[top];
        wordArray[top] = tmp;
      }
      shuffled = wordArray.join('');
      if (shuffled === word) {
        shuffled = this.shuffle(shuffled);
      }
      return shuffled;
    };
    Scramble.prototype.createLetter = function(letter) {
      var letterContainer;
      letterContainer = $(document.createElement("DIV"));
      letterContainer.addClass('letter');
      letterContainer.addClass("letter_" + letter);
      letterContainer.html(letter);
      this.bindLetter(letterContainer);
      return letterContainer;
    };
    Scramble.prototype.createScramble = function() {
      var container, group, index, letter, scrambled, _i, _len, _len2, _ref, _ref2, _results;
      scrambled = this.$('.scrambled');
      this.clearContainer(scrambled);
      _ref = this.separateIntoWordGroups(this.scrambleInfo[this.activeType]);
      _results = [];
      for (index = 0, _len = _ref.length; index < _len; index++) {
        group = _ref[index];
        container = $(document.createElement("DIV"));
        container.addClass('container');
        container.addClass("color" + (index + 1));
        scrambled.append(container);
        _ref2 = this.shuffle(this.modifyScramble(group.join('')));
        for (_i = 0, _len2 = _ref2.length; _i < _len2; _i++) {
          letter = _ref2[_i];
          if (letter.match(/\w|[^\x00-\x80]+/)) {
            container.append(this.createLetter(letter));
          }
        }
        container.width(container.width());
        _results.push(container.css({
          float: 'none',
          height: container.height()
        }));
      }
      return _results;
    };
    Scramble.prototype.modifyScramble = function(word) {
      var add, commonLetters, i, letter;
      if (!(word.length < 6)) {
        return word;
      }
      commonLetters = (function() {
        var _i, _len, _ref, _results;
        _ref = 'etaoinshrdlumkpcd';
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          letter = _ref[_i];
          _results.push(letter);
        }
        return _results;
      })();
      add = 6 - word.length;
      if (add > 2) {
        add = 2;
      }
      for (i = 0; 0 <= add ? i < add : i > add; 0 <= add ? i++ : i--) {
        word += commonLetters[Math.floor(Math.random() * commonLetters.length)];
      }
      return word;
    };
    Scramble.prototype.bindKeyPress = function() {
      setInterval((__bind(function() {
        return $('#clickarea')[0].focus();
      }, this)), 100);
      $('#clickarea').bind('keydown', __bind(function(e) {
        var guessedLetters, lastLetterAdded;
        if (e.keyCode === 8) {
          lastLetterAdded = this.lettersAdded.pop();
          guessedLetters = $(".guesses .letter_" + lastLetterAdded);
          if (guessedLetters.length) {
            $(guessedLetters[guessedLetters.length - 1]).trigger('click');
          }
        }
      }, this));
      return $('#clickarea').bind('keypress', __bind(function(e) {
        var char, letter, openGuess;
        openGuess = this.$('.guesses .selected')[0] || this.$(".guesses .guess")[0];
        if (openGuess == null) {
          return;
        }
        char = String.fromCharCode(e.keyCode);
        try {
          letter = $(".scrambled ." + (this.containerClassName(openGuess)) + " .letter_" + char)[0];
          if (!letter && (this.activeLevel.match(/Hard/) != null)) {
            if (char.match(/\w|[^\x00-\x80]+/)) {
              letter = this.createLetter(char);
              $(".scrambled ." + (this.containerClassName(openGuess))).append(letter);
            }
          }
        } catch (e) {
          return;
        }
        if (letter == null) {
          return;
        }
        return $(letter).trigger('click');
      }, this));
    };
    Scramble.prototype.containerClassName = function(square) {
      return $(square).closest('.container')[0].className.match(/color\d+/)[0];
    };
    Scramble.prototype.replaceLetterWithBlank = function(letter) {
      var blankLetter;
      blankLetter = $(document.createElement("DIV"));
      blankLetter.addClass('blank_letter').addClass(letter.html());
      return blankLetter.insertBefore(letter, this.$(".scrambled ." + (this.containerClassName(letter))));
    };
    Scramble.prototype.replaceBlankWithLetter = function(letter) {
      var blankLetter, containerClass;
      containerClass = this.containerClassName(letter);
      blankLetter = this.$(".scrambled ." + containerClass + " ." + (letter.html()))[0];
      if (blankLetter == null) {
        return;
      }
      blankLetter = $(blankLetter);
      letter.remove().insertBefore(blankLetter, this.$(".scrambled ." + containerClass));
      if (letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/) != null) {
        letter.removeClass(letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[0]);
        letter.removeClass('wrong_letter');
        letter.removeClass('correct_letter');
      }
      blankLetter.remove();
      return this.bindLetter(letter);
    };
    Scramble.prototype.replaceGuessWithLetter = function(guess, letter) {
      var guessLetter, letterPosition;
      $('.guesses .hidden_message').hide();
      $('.guesses .space').css({
        visibility: 'visible'
      });
      guess = $(guess);
      letter.remove().insertBefore(guess, this.$('.guesses'));
      letter.addClass(guess[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[0]);
      guess.remove();
      this.bindLetter(letter);
      this.lettersAdded.push(letter.html());
      letterPosition = guess[0].className.indexOf('actual_letter_') + 'actual_letter_'.length;
      guessLetter = guess[0].className.slice(letterPosition, (letterPosition + 1) || 9e9);
      letter.addClass(letter.html() === guessLetter ? 'correct_letter' : 'wrong_letter');
      if (this.checkCorrectAnswer()) {
        return this.next();
      }
    };
    Scramble.prototype.replaceLetterWithGuess = function(letter) {
      var actualLetter, letterAddedIndex;
      letterAddedIndex = this.lettersAdded.indexOf(letter.html());
      this.lettersAdded.slice(letterAddedIndex, letterAddedIndex + 1);
      actualLetter = letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[1];
      this.createGuess(actualLetter).insertBefore(letter, this.$(".guesses ." + (this.containerClassName(letter))));
      if (letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/) != null) {
        letter.removeClass(letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/)[0]);
        letter.removeClass('wrong_letter');
        return letter.removeClass('correct_letter');
      }
    };
    Scramble.prototype.guessInPath = function(letter, lastX, lastY, currentX, currentY) {
      var guess, guessDims, guessPosition, guesses, i, x, xSlope, y, ySlope, _i, _len;
      letter = $(letter);
      xSlope = currentX - lastX;
      ySlope = lastY - currentY;
      if (Math.abs(xSlope) < Math.abs(ySlope)) {
        xSlope = xSlope / Math.abs(ySlope);
        ySlope = ySlope / Math.abs(ySlope);
      } else {
        ySlope = ySlope / Math.abs(xSlope);
        xSlope = xSlope / Math.abs(xSlope);
      }
      guesses = this.$(".guesses ." + (this.containerClassName(letter)) + " .guess");
      for (_i = 0, _len = guesses.length; _i < _len; _i++) {
        guess = guesses[_i];
        guess = $(guess);
        guessPosition = guess.offset();
        guessDims = guess.dim();
        for (i = 2; i <= 14; i++) {
          x = currentX + (xSlope * (((i % 12) - 2) * 10));
          y = currentY - (ySlope * (((i % 12) - 2) * 10));
          if (x < guessPosition.left) {
            continue;
          }
          if (x > guessPosition.left + guessDims.width) {
            continue;
          }
          if (y > guessPosition.top + guessDims.height) {
            continue;
          }
          if (y < guessPosition.top) {
            continue;
          }
          return guess;
        }
      }
      return null;
    };
    Scramble.prototype.clientX = function(e) {
      return e.clientX || (e.targetTouches[0] ? e.targetTouches[0].pageX : null);
    };
    Scramble.prototype.clientY = function(e) {
      return e.clientY || (e.targetTouches[0] ? e.targetTouches[0].pageY : null);
    };
    Scramble.prototype.bindLetter = function(letter) {
      var click, startDrag;
      this.dragging = null;
      this.dragAdjustmentX = 0;
      this.dragAdjustmentY = 0;
      this.dragPathX = [];
      this.dragPathY = [];
      click = __bind(function(e) {
        var alreadyDragged, containerClass, guess;
        if (this.dragPathX.length > 1 || this.dragPathY > 1) {
          return;
        }
        if (this.dragging && this.dragging.css('position') === 'absolute') {
          alreadyDragged = true;
          this.dragging.css({
            position: 'static'
          });
          this.dragging = null;
        }
        this.startHelpTimer();
        containerClass = this.containerClassName(letter);
        if (letter[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/) != null) {
          this.replaceLetterWithGuess(letter);
          return this.replaceBlankWithLetter(letter);
        } else {
          guess = this.$('.guesses .selected')[0] || this.$(".guesses ." + containerClass + " .guess")[0];
          if (guess == null) {
            return;
          }
          if (!alreadyDragged) {
            this.replaceLetterWithBlank(letter);
          }
          return this.replaceGuessWithLetter(guess, letter);
        }
      }, this);
      startDrag = __bind(function(e) {
        if (e.preventDefault != null) {
          e.preventDefault();
        }
        this.dragging = letter;
        this.startHelpTimer();
        this.dragPathX = [];
        this.dragPathY = [];
        this.dragAdjustmentX = this.clientX(e) - letter.offset().left;
        return this.dragAdjustmentY = this.clientY(e) - letter.offset().top;
      }, this);
      letter = $(letter);
      letter.attr({
        onclick: 'void(0)',
        ontouchstart: 'void(0)',
        ontouchend: 'void(0)',
        ontouchmove: 'void(0)'
      });
      letter.bind('click', click);
      letter.bind('touchend', click);
      letter.bind('mousedown', startDrag);
      return letter.bind('touchstart', startDrag);
    };
    Scramble.prototype.bindWindow = function() {
      var endDrag, moveDrag;
      moveDrag = __bind(function(e) {
        if (!this.dragging) {
          return;
        }
        if (e.preventDefault != null) {
          e.preventDefault();
        }
        if (this.dragging.css('position') !== 'absolute') {
          if (this.dragging[0].className.match(/actual_letter_(\w|[^\x00-\x80]+)/) != null) {
            this.replaceLetterWithGuess(this.dragging);
          } else {
            this.replaceLetterWithBlank(this.dragging);
          }
        }
        if (this.dragPathX[this.dragPathX.length - 1] !== this.clientX(e)) {
          this.dragPathX.push(this.clientX(e));
        }
        if (this.dragPathX[this.dragPathY.length - 1] !== this.clientY(e)) {
          this.dragPathY.push(this.clientY(e));
        }
        return this.dragging.css({
          position: 'absolute',
          top: this.clientY(e) - this.dragAdjustmentY,
          left: this.clientX(e) - this.dragAdjustmentX
        });
      }, this);
      endDrag = __bind(function(e, force) {
        var currentX, currentY, guess, lastX, lastY, x, y;
        if (!force && (this.dragPathX.length <= 1 || this.dragPathY.length <= 1)) {
          $.timeout(40, __bind(function() {
            if (this.dragging != null) {
              return endDrag(e, true);
            }
          }, this));
          return;
        }
        if (e.preventDefault != null) {
          e.preventDefault();
        }
        currentX = this.dragPathX.pop();
        currentY = this.dragPathY.pop();
        lastX = ((function() {
          var _i, _len, _ref, _results;
          _ref = this.dragPathX.reverse();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            x = _ref[_i];
            if (Math.abs(x - currentX) > 10) {
              _results.push(x);
            }
          }
          return _results;
        }).call(this))[0] || currentX + 0.01;
        lastY = ((function() {
          var _i, _len, _ref, _results;
          _ref = this.dragPathY.reverse();
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            y = _ref[_i];
            if (Math.abs(y - currentY) > 10) {
              _results.push(y);
            }
          }
          return _results;
        }).call(this))[0] || currentY - 0.01;
        guess = this.guessInPath(this.dragging, lastX, lastY, currentX, currentY);
        this.dragging.css({
          position: 'static'
        });
        if (guess != null) {
          this.replaceGuessWithLetter(guess, this.dragging);
        } else {
          this.replaceBlankWithLetter(this.dragging);
        }
        return this.dragging = null;
      }, this);
      $(window).bind('mousemove', moveDrag);
      $(window).bind('mouseup', endDrag);
      $(window).bind('touchmove', moveDrag);
      return $(window).bind('touchend', endDrag);
    };
    Scramble.prototype.checkCorrectAnswer = function() {
      return this.$('.guesses .letter, .guesses .space').map(function(html) {
        return $(html).html();
      }).join('') === this.scrambleInfo[this.activeType];
    };
    Scramble.prototype.next = function() {
      var correct, correctSentence, highlighted, scrambled;
      correct = $(document.createElement('DIV'));
      if ((this.scrambleInfo["" + this.activeType + "Sentence"] != null) && this.scrambleInfo["" + this.activeType + "Sentence"].length) {
        correctSentence = this.scrambleInfo["" + this.activeType + "Sentence"];
      } else {
        correctSentence = this.scrambleInfo[this.activeType];
      }
      correctSentence = " " + correctSentence + " ";
      highlighted = this.scrambleInfo[this.activeType];
      correctSentence = correctSentence.replace(" " + highlighted + " ", " <span class='highlighted'>" + highlighted + "</span> ");
      correctSentence = correctSentence.replace(" " + highlighted + "?", " <span class='highlighted'>" + highlighted + "</span>?");
      correct.html(correctSentence);
      correct.addClass('correct');
      correct.css({
        opacity: 0
      });
      scrambled = this.$('.scrambled');
      this.clearContainer(scrambled);
      this.$('.scrambled .hidden_message').hide();
      this.$('.scrambled').css({
        width: null
      });
      scrambled.append(correct);
      return correct.animate({
        opacity: 1,
        duration: 500,
        complete: __bind(function() {
          return $.timeout(200 + (30 * correctSentence.length), __bind(function() {
            return this.$('.foreign_words, .scrambled, .guesses').animate({
              opacity: 0,
              duration: 500,
              complete: __bind(function() {
                this.$('.scrambled, .guesses').css({
                  width: null,
                  height: null
                });
                this.newScramble();
                return this.$('.foreign_words, .scrambled, .guesses').animate({
                  opacity: 1,
                  duration: 300
                });
              }, this)
            });
          }, this));
        }, this)
      });
    };
    Scramble.prototype.clearContainer = function(container) {
      return container.find('.container, .correct, .guess, .letter, .space').remove();
    };
    return Scramble;
  })();
  return $.route.add({
    'scramble': function() {
      return $('#content').view({
        name: 'Scramble',
        data: {
          level: 1
        }
      });
    },
    'scramble/:level': function(level) {
      return $('#content').view({
        name: 'Scramble',
        data: {
          level: parseInt(level)
        }
      });
    }
  });
})(ender);
localData = [
  {
    "native": 'not',
    foreign: 'non',
    nativeSentence: 'that\'s not necessary',
    foreignSentence: 'non è necessario'
  }, {
    "native": 'of',
    foreign: 'di',
    nativeSentence: 'memories of a cat',
    foreignSentence: 'memorie di un gatto'
  }, {
    "native": 'what',
    foreign: 'che',
    nativeSentence: 'what luck',
    foreignSentence: 'che fortuna'
  }, {
    "native": 'is',
    foreign: 'è',
    nativeSentence: 'that bird is fat',
    foreignSentence: 'quell\'uccello è grasso'
  }, {
    "native": 'and',
    foreign: 'e',
    nativeSentence: 'big and tall',
    foreignSentence: 'grande e grosso'
  }, {
    "native": 'for',
    foreign: 'per',
    nativeSentence: 'the drinks are for the party',
    foreignSentence: 'le bevande sono per il partito'
  }, {
    "native": 'are',
    foreign: 'sono',
    nativeSentence: 'there are five quotes',
    foreignSentence: 'ci sono cinque citazioni'
  }, {
    "native": 'i have three blue shirts',
    foreign: 'ho tre maglie azzurre'
  }, {
    "native": 'i have twenty dollars',
    foreign: 'ho venti dollari'
  }, {
    "native": 'but',
    foreign: 'ma',
    nativeSentence: 'i was going to but i can not',
    foreignSentence: 'stavo andando ma non posso'
  }, {
    "native": 'he has a big house',
    foreign: 'ha una grande casa'
  }, {
    "native": 'with',
    foreign: 'con',
    nativeSentence: 'i\'m coming with you',
    foreignSentence: 'vengo con te'
  }, {
    "native": 'if',
    foreign: 'se',
    nativeSentence: 'what if he wins?',
    foreignSentence: 'cosa succede se vince?'
  }, {
    "native": 'there',
    foreign: 'ci',
    nativeSentence: 'there are three friends',
    foreignSentence: 'ci sono tre amici'
  }, {
    "native": 'this',
    foreign: 'questo',
    nativeSentence: 'this is great',
    foreignSentence: 'questo è fantastico'
  }, {
    "native": 'here',
    foreign: 'qui',
    nativeSentence: 'come here',
    foreignSentence: 'vieni qui'
  }, {
    "native": 'you have',
    foreign: 'hai',
    nativeSentence: 'you have ten minutes',
    foreignSentence: 'hai dieci minuti'
  }, {
    "native": 'six',
    foreign: 'sei',
    nativeSentence: 'there are six doors',
    foreignSentence: 'ci sono sei porte'
  }, {
    "native": 'well',
    foreign: 'bene',
    nativeSentence: 'are you well?',
    foreignSentence: 'stai bene?'
  }, {
    "native": 'yes',
    foreign: 'sì'
  }, {
    "native": 'more',
    foreign: 'più',
    nativeSentence: 'a little more',
    foreignSentence: 'un po più'
  }, {
    "native": 'my',
    foreign: 'mio',
    nativeSentence: 'my child is seven years old',
    foreignSentence: 'mio figlio ha sette anni'
  }, {
    "native": 'because',
    foreign: 'perché',
    nativeSentence: 'because i want to',
    foreignSentence: 'perché voglio'
  }, {
    "native": 'why',
    foreign: 'perché',
    nativeSentence: 'why do you want to go?',
    foreignSentence: 'perché vuoi andare?'
  }, {
    "native": 'she',
    foreign: 'lei',
    nativeSentence: 'she leaves tomorrow',
    foreignSentence: 'lei parte domani'
  }, {
    "native": 'only',
    foreign: 'solo',
    nativeSentence: 'it was only fifteen minutes',
    foreignSentence: 'era solo quindici minuti'
  }, {
    "native": 'was',
    foreign: 'era',
    nativeSentence: 'it was thirty years ago',
    foreignSentence: 'era trent\'anni fa'
  }, {
    "native": 'all',
    foreign: 'tutti',
    nativeSentence: 'all of the king\'s horses',
    foreignSentence: 'tutti i cavalli del re'
  }, {
    "native": 'so-so',
    foreign: 'così-così',
    nativeSentence: 'i am feeling so-so',
    foreignSentence: 'mi sento così-così'
  }, {
    "native": 'hello',
    foreign: 'ciao',
    nativeSentence: 'hello my friend',
    foreignSentence: 'ciao amico mio'
  }, {
    "native": 'this',
    foreign: 'questo',
    nativeSentence: 'this is the best food',
    foreignSentence: 'questo è il miglior cibo'
  }, {
    "native": 'to do',
    foreign: 'fare',
    nativeSentence: 'if you want to do this',
    foreignSentence: 'se si vuole fare questo'
  }, {
    "native": 'when',
    foreign: 'quando',
    nativeSentence: 'when is the show?',
    foreignSentence: 'quando è lo spettacolo?'
  }, {
    "native": 'now',
    foreign: 'ora',
    nativeSentence: 'drop the ball now',
    foreignSentence: 'cadere la palla ora'
  }, {
    "native": 'you did',
    foreign: 'hai fatto',
    nativeSentence: 'you did your best',
    foreignSentence: 'hai fatto del tuo meglio'
  }, {
    "native": 'to be',
    foreign: 'essere',
    nativeSentence: 'i want to be an astronaut',
    foreignSentence: 'voglio essere un astronauta'
  }, {
    "native": 'never',
    foreign: 'mai',
    nativeSentence: 'i have never been to the coast',
    foreignSentence: 'non sono mai stato alla costa'
  }, {
    "native": 'who',
    foreign: 'chi',
    nativeSentence: 'who are you?',
    foreignSentence: 'chi sei?'
  }, {
    "native": 'or',
    foreign: 'o',
    nativeSentence: 'pizza or pasta',
    foreignSentence: 'pizza o la pasta'
  }, {
    "native": 'all',
    foreign: 'tutti',
    nativeSentence: 'he ate all of the cookies',
    foreignSentence: 'ha mangiato tutti i cookie'
  }, {
    "native": 'very',
    foreign: 'molto',
    nativeSentence: 'he is very old',
    foreignSentence: 'lui è molto vecchio'
  }, {
    "native": 'also',
    foreign: 'anche',
    nativeSentence: 'i also need two pencils',
    foreignSentence: 'ho anche bisogno di due matite'
  }, {
    "native": 'he said',
    foreign: 'ha detto',
    nativeSentence: 'he said go left',
    foreignSentence: 'ha detto andate a sinistra'
  }, {
    "native": 'that',
    foreign: 'quella',
    nativeSentence: 'that lady ate my cheese',
    foreignSentence: 'quella signora mangiato il mio formaggio'
  }, {
    "native": 'nothing',
    foreign: 'niente',
    nativeSentence: 'there was nothing there',
    foreignSentence: 'non c\'era niente'
  }, {
    "native": 'thanks',
    foreign: 'grazie',
    nativeSentence: 'thanks for the help',
    foreignSentence: 'grazie per l\'aiuto'
  }, {
    "native": 'he',
    foreign: 'lui',
    nativeSentence: 'he is eighteen years old',
    foreignSentence: 'lui ha diciotto anni'
  }, {
    "native": 'i want a new car',
    foreign: 'voglio una macchina nuova'
  }, {
    "native": 'we have a house',
    foreign: 'abbiamo una casa'
  }, {
    "native": 'we have a car',
    foreign: 'abbiamo un auto'
  }, {
    "native": 'we have an oven',
    foreign: 'abbiamo un forno'
  }, {
    "native": 'state',
    foreign: 'stato',
    nativeSentence: 'the dog was in a state of frenzy',
    foreignSentence: 'il cane era in uno stato di frenesia'
  }, {
    "native": 'in',
    foreign: 'nel',
    nativeSentence: 'throw it in the bucket',
    foreignSentence: 'gettarlo nel secchio'
  }, {
    "native": 'his',
    foreign: 'il suo',
    nativeSentence: 'his favorite flavor',
    foreignSentence: 'il suo gusto preferito'
  }, {
    "native": 'where',
    foreign: 'dove',
    nativeSentence: 'where are my keys',
    foreignSentence: 'dove sono le mie chiavi'
  }, {
    "native": 'i can find',
    foreign: 'posso trovare'
  }, {
    "native": 'i can walk',
    foreign: 'posso camminare'
  }, {
    "native": 'i can live',
    foreign: 'posso abitare'
  }, {
    "native": 'first',
    foreign: 'prima',
    nativeSentence: 'she was the first to finish',
    foreignSentence: 'fu la prima a finire'
  }, {
    "native": 'we are',
    foreign: 'siamo',
    nativeSentence: 'we are all twins',
    foreignSentence: 'siamo tutti gemelli'
  }, {
    "native": 'your',
    foreign: 'tuo',
    nativeSentence: 'your brother is here',
    foreignSentence: 'tuo fratello è qui'
  }, {
    "native": 'they have',
    foreign: 'hanno',
    nativeSentence: 'they have seventeen stereos',
    foreignSentence: 'hanno diciassette impianti stereo'
  }, {
    "native": 'ago',
    foreign: 'fa',
    nativeSentence: 'they started dating eight years ago',
    foreignSentence: 'hanno cominciato a frequentarsi otto anni fa'
  }, {
    "native": 'two',
    foreign: 'due',
    nativeSentence: 'we saw two planes',
    foreignSentence: 'abbiamo visto due aerei'
  }, {
    "native": 'you want',
    foreign: 'vuoi',
    nativeSentence: 'you want three slices?',
    foreignSentence: 'vuoi tre fette?'
  }, {
    "native": 'something',
    foreign: 'qualcosa',
    nativeSentence: 'there is something wrong',
    foreignSentence: 'c\'è qualcosa di sbagliato'
  }, {
    "native": 'true',
    foreign: 'vero',
    nativeSentence: 'is it true?',
    foreignSentence: 'è vero?'
  }, {
    "native": 'home',
    foreign: 'casa',
    nativeSentence: 'i am going home',
    foreignSentence: 'sto andando a casa'
  }, {
    "native": 'on',
    foreign: 'su',
    nativeSentence: 'the man is standing on a mountain',
    foreignSentence: 'uomo è in piedi su una montagna'
  }, {
    "native": 'your',
    foreign: 'tuo',
    nativeSentence: 'what is your favorite movie?',
    foreignSentence: 'qual è il tuo film preferito?'
  }, {
    "native": 'always',
    foreign: 'sempre',
    nativeSentence: 'it is always cold',
    foreignSentence: 'è sempre freddo'
  }, {
    "native": 'perhaps',
    foreign: 'forse',
    nativeSentence: 'perhaps i can help',
    foreignSentence: 'forse mi può aiutare'
  }, {
    "native": 'to say',
    foreign: 'dire',
    nativeSentence: 'i want to say something',
    foreignSentence: 'voglio dire qualcosa'
  }, {
    "native": 'their',
    foreign: 'loro',
    nativeSentence: 'their house is beautiful',
    foreignSentence: 'la loro casa è bella'
  }, {
    "native": 'another',
    foreign: 'un altro',
    nativeSentence: 'can i have another chocolate?',
    foreignSentence: 'posso avere un altro cioccolato?'
  }, {
    "native": 'you know',
    foreign: 'sai',
    nativeSentence: 'do you know his name?',
    foreignSentence: 'sai il suo nome?'
  }, {
    "native": 'i have to walk',
    foreign: 'devo camminare'
  }, {
    "native": 'i have to go',
    foreign: 'devo andare'
  }, {
    "native": 'that',
    foreign: 'quella',
    nativeSentence: 'that lady is happy',
    foreignSentence: 'quella signora è felice'
  }, {
    "native": 'life',
    foreign: 'vita',
    nativeSentence: 'he lived a fun life',
    foreignSentence: 'ha vissuto una vita divertente'
  }, {
    "native": 'that',
    foreign: 'quel',
    nativeSentence: 'that cat is fast',
    foreignSentence: 'quel gatto è veloce'
  }, {
    "native": 'time',
    foreign: 'tempo',
    nativeSentence: 'do we have enough time?',
    foreignSentence: 'abbiamo abbastanza tempo?'
  }, {
    "native": 'to go',
    foreign: 'andare',
    nativeSentence: 'he wants to go to the movies',
    foreignSentence: 'vuole andare al cinema'
  }, {
    "native": 'sure',
    foreign: 'certo'
  }, {
    "native": 'then',
    foreign: 'poi',
    nativeSentence: 'we went to dinner and then went to a concert',
    foreignSentence: 'siamo andati a cena e poi è andato a un concerto'
  }, {
    "native": 'man',
    foreign: 'uomo',
    nativeSentence: 'a man stole my purse',
    foreignSentence: 'un uomo ha rubato la mia borsa'
  }, {
    "native": 'sir',
    foreign: 'signore',
    nativeSentence: 'excuse me sir',
    foreignSentence: 'mi scusi signore'
  }, {
    "native": 'a little',
    foreign: 'un po',
    nativeSentence: 'can we have some candy?',
    foreignSentence: 'possiamo avere un po \'di caramelle?'
  }, {
    "native": 'i can',
    foreign: 'può',
    nativeSentence: 'i can talk for hours',
    foreignSentence: 'può parlare per ore'
  }, {
    "native": 'i think',
    foreign: 'credo',
    nativeSentence: 'i believe she is correct',
    foreignSentence: 'credo che sia corretto'
  }, {
    "native": 'already',
    foreign: 'già',
    nativeSentence: 'he already has three dogs',
    foreignSentence: 'che ha già tre cani'
  }, {
    "native": 'now',
    foreign: 'adesso',
    nativeSentence: 'i need to leave now',
    foreignSentence: 'ho bisogno di partire adesso'
  }, {
    "native": 'let\'s go',
    foreign: 'andiamo',
    nativeSentence: 'let\'s go to the park',
    foreignSentence: 'andiamo al parco'
  }, {
    "native": 'years',
    foreign: 'anni',
    nativeSentence: 'he is twelve years old',
    foreignSentence: 'lui ha dodici anni'
  }, {
    "native": 'seen',
    foreign: 'visto',
    nativeSentence: 'have you seen my keys',
    foreignSentence: 'avete visto le mie chiavi'
  }, {
    "native": 'outside',
    foreign: 'fuori',
    nativeSentence: 'let\'s go for a hike outside',
    foreignSentence: 'andiamo a fare una passeggiata fuori'
  }, {
    "native": 'just',
    foreign: 'proprio',
    nativeSentence: 'i have just one cat',
    foreignSentence: 'solo uno per me'
  }, {
    "native": 'only one',
    foreign: 'solo uno',
    nativeSentence: 'only one for me',
    foreignSentence: 'solo uno per me'
  }, {
    "native": 'how long',
    foreign: 'quanto tempo',
    nativeSentence: 'how long until you graduate?',
    foreignSentence: 'quanto tempo fino a laurearsi?'
  }, {
    "native": 'one time',
    foreign: 'una volta',
    nativeSentence: 'i\'ve only seen that movie one time',
    foreignSentence: 'ho solo visto quel film una sola volta'
  }, {
    "native": 'will be',
    foreign: 'sarà',
    nativeSentence: 'climbing a mountain will always be a goal',
    foreignSentence: 'scalare una montagna sarà sempre un obiettivo'
  }, {
    "native": 'after',
    foreign: 'dopo',
    nativeSentence: 'let\s go to the park after the movie',
    foreignSentence: 'andiamo al parco dopo il film'
  }, {
    "native": 'without',
    foreign: 'senza',
    nativeSentence: 'i\'m not leaving without you',
    foreignSentence: 'non me ne vado senza di te'
  }, {
    "native": 'things',
    foreign: 'cose',
    nativeSentence: 'too many things can go wrong',
    foreignSentence: 'troppe cose possono andare storte'
  }, {
    "native": 'nobody',
    foreign: 'nessuno',
    nativeSentence: 'so nobody heard anything?',
    foreignSentence: 'quindi nessuno ha sentito niente?'
  }, {
    "native": 'day',
    foreign: 'giorno',
    nativeSentence: 'every day i learn something new',
    foreignSentence: 'ogni giorno imparo qualcosa di nuovo'
  }, {
    "native": 'best',
    foreign: 'meglio',
    nativeSentence: 'do your best',
    foreignSentence: 'fate del vostro meglio'
  }, {
    "native": 'father',
    foreign: 'padre',
    nativeSentence: 'my father is sixty years old',
    foreignSentence: 'mio padre ha sessanta anni'
  }, {
    "native": 'you can',
    foreign: 'puoi',
    nativeSentence: 'you can do this',
    foreignSentence: 'si può fare questo'
  }, {
    "native": 'hello',
    foreign: 'ciao',
    nativeSentence: 'hello my friend',
    foreignSentence: 'ciao amico mio'
  }, {
    "native": 'you need to',
    foreign: 'devi',
    nativeSentence: 'you need to do this for me',
    foreignSentence: 'è necessario fare questo per me'
  }, {
    "native": 'here',
    foreign: 'ecco',
    nativeSentence: 'here is the cat',
    foreignSentence: 'ecco qui il gatto'
  }, {
    "native": 'someone',
    foreign: 'qualcuno',
    nativeSentence: 'i know someone who can help',
    foreignSentence: 'conosco qualcuno che può aiutare'
  }, {
    "native": 'work',
    foreign: 'lavoro',
    nativeSentence: 'i have a lot of work to do',
    foreignSentence: 'ho un sacco di lavoro da fare'
  }, {
    "native": 'he knows',
    foreign: 'sa',
    nativeSentence: 'he knows who you are',
    foreignSentence: 'sa chi sei'
  }, {
    "native": 'to',
    foreign: 'ai',
    nativeSentence: 'i\'m going to the markets',
    foreignSentence: 'io vado ai mercati'
  }, {
    "native": 'to see',
    foreign: 'vedere',
    nativeSentence: 'i\'d like to see that one day',
    foreignSentence: 'mi piacerebbe vedere che un giorno'
  }, {
    "native": 'every',
    foreign: 'ogni',
    nativeSentence: 'i think about her every day',
    foreignSentence: 'ogni giorno penso a lei'
  }, {
    "native": 'too much',
    foreign: 'troppo',
    nativeSentence: 'how much is too much?',
    foreignSentence: 'quanto è troppo?'
  }, {
    "native": 'i missed you so much',
    foreign: 'mi sei mancato molto'
  }, {
    "native": 'good morning',
    foreign: 'buongiorno'
  }, {
    "native": 'good evening',
    foreign: 'buona sera'
  }, {
    "native": 'how are you?',
    foreign: 'come stai?'
  }, {
    "native": 'goodbye',
    foreign: 'arrivederci'
  }, {
    "native": 'what a shame',
    foreign: 'che peccato'
  }, {
    "native": 'i can\'t believe it',
    foreign: 'non ci posso credere'
  }, {
    "native": 'what time is it?',
    foreign: 'che ore sono?'
  }, {
    "native": 'can you help me?',
    foreign: 'mi puoi aiutare?'
  }, {
    "native": 'i\'m running late',
    foreign: 'sono in ritardo'
  }, {
    "native": 'how\'s your family?',
    foreign: 'come sta la tua famiglia?'
  }, {
    "native": 'where do you work?',
    foreign: 'dove lavori?'
  }, {
    "native": 'where are you from?',
    foreign: 'di dove sei?'
  }, {
    "native": 'are you from around here?',
    foreign: 'sei di qui?'
  }, {
    "native": 'where do you live?',
    foreign: 'dove vivi?'
  }, {
    "native": 'how old are you?',
    foreign: 'quanti anni hai?'
  }, {
    "native": 'what\'s your phone number?',
    foreign: 'qual\'è il tuo numero di telefono?'
  }, {
    "native": 'what do you like to do?',
    foreign: 'cosa ti piace fare?'
  }, {
    "native": 'i need to use the restroom',
    foreign: 'devo andare in bagno'
  }, {
    "native": 'i\'ll be right back',
    foreign: 'torno subito'
  }, {
    "native": 'please repeat',
    foreign: 'ripeti, per favore'
  }, {
    "native": 'are you kidding?',
    foreign: 'stai scherzando?'
  }, {
    "native": 'just kidding',
    foreign: 'scherzo'
  }, {
    "native": 'talk to you later',
    foreign: 'ci sentiamo dopo'
  }, {
    "native": 'see you soon',
    foreign: 'a presto'
  }, {
    "native": 'the cat loves to sing and dance',
    foreign: 'il gatto ama cantare e ballare'
  }, {
    "native": 'the man walked down the street',
    foreign: 'l\'uomo camminava per la strada'
  }, {
    "native": 'how many apples are there?',
    foreign: 'quante mele ci sono?'
  }, {
    "native": 'i know how to play guitar',
    foreign: 'so come suonare la chitarra'
  }, {
    "native": 'she can run a mile very quickly',
    foreign: 'lei può eseguire un miglio molto rapidamente'
  }, {
    "native": 'that pizza is fantastic',
    foreign: 'quella pizza è fantastico'
  }, {
    "native": 'it\'s a beautiful day outside',
    foreign: 'è una bella giornata fuori'
  }, {
    "native": 'where were you?',
    foreign: 'dove eravate?'
  }, {
    "native": 'bright light',
    foreign: 'luce brillante'
  }, {
    "native": 'red carpet',
    foreign: 'tappeto rosso'
  }, {
    "native": 'heavy door',
    foreign: 'pesante porta'
  }, {
    "native": 'messy bedroom',
    foreign: 'camera da letto disordinato'
  }, {
    "native": 'the bird flew fast',
    foreign: 'l\'uccello volò veloce'
  }, {
    "native": 'be careful with the sharp knife',
    foreign: 'stare attenti con il coltello affilato'
  }, {
    "native": 'eat your vegetables',
    foreign: 'mangiare le verdure'
  }, {
    "native": 'the steak was juicy',
    foreign: 'la bistecca era succosa'
  }, {
    "native": 'i am hungry',
    foreign: 'ho fame'
  }, {
    "native": 'i am tired',
    foreign: 'sono stanco'
  }, {
    "native": 'he was very sleepy',
    foreign: 'era molto sonno'
  }, {
    "native": 'he failed his test',
    foreign: 'ha fallito la sua prova'
  }, {
    "native": 'they are late',
    foreign: 'sono in ritardo'
  }, {
    "native": 'a lot of money',
    foreign: 'un sacco di soldi'
  }, {
    "native": 'exercise is healthy',
    foreign: 'esercizio è sano'
  }, {
    "native": 'where is it?',
    foreign: 'dov\'è?'
  }, {
    "native": 'where are you going?',
    foreign: 'dove va?'
  }, {
    "native": 'when does the museum open?',
    foreign: 'quando apre il museo?'
  }, {
    "native": 'when does the train arrive?',
    foreign: 'quando arriva il treno?'
  }, {
    "native": 'how much is that?',
    foreign: 'quanto costa?'
  }, {
    "native": 'how many are there?',
    foreign: 'quanti ce ne sono?'
  }, {
    "native": 'why is that?',
    foreign: 'perchè?'
  }, {
    "native": 'why not?',
    foreign: 'perchè no?'
  }, {
    "native": 'who\'s there?',
    foreign: 'chi è?'
  }, {
    "native": 'who is it for?',
    foreign: 'chi è per?'
  }, {
    "native": 'which one do you want?',
    foreign: 'quale vuole?'
  }, {
    "native": 'when are the stores open?',
    foreign: 'quando hanno luogo i negozi aperti?'
  }, {
    "native": 'whose is that?',
    foreign: 'di chi è quello?'
  }, {
    "native": 'how would you like to pay?',
    foreign: 'come desidera pagare?'
  }, {
    "native": 'how are you getting here?',
    foreign: 'come arriva qui?'
  }, {
    "native": 'is it free?',
    foreign: 'è libero?'
  }, {
    "native": 'are there any buses going into town?',
    foreign: 'ci sono autobus per il centro?'
  }, {
    "native": 'can i have this?',
    foreign: 'posso avere questo?'
  }, {
    "native": 'can we have that?',
    foreign: 'possiamo avere quello?'
  }, {
    "native": 'can you show me that?',
    foreign: 'potete mostrarmi quello?'
  }, {
    "native": 'can i help you?',
    foreign: 'posso aiutare?'
  }, {
    "native": 'can you help me?',
    foreign: 'può aiutarmi?'
  }, {
    "native": 'how are you?',
    foreign: 'come sta?'
  }, {
    "native": 'whose handbag is that?',
    foreign: 'di chi borsa è quella?'
  }, {
    "native": 'do you speak english?',
    foreign: 'parla inglese?'
  }, {
    "native": 'can you speak more slowly?',
    foreign: 'può parlare più lentamente?'
  }, {
    "native": 'can you repeat that?',
    foreign: 'può repetere'
  }, {
    "native": 'what was that?',
    foreign: 'cosa ha detto?'
  }, {
    "native": 'i understand.',
    foreign: 'capisco.'
  }, {
    "native": 'i don\'t understand.',
    foreign: 'non capisco.'
  }, {
    "native": 'do you understand?',
    foreign: 'capisce?'
  }, {
    "native": 'could you spell it?',
    foreign: 'come si scrive?'
  }, {
    "native": 'can you translate this for me?',
    foreign: 'può tradurre questo?'
  }, {
    "native": 'what does this mean?',
    foreign: 'cosa significa questo?'
  }, {
    "native": 'please write it down.',
    foreign: 'la scriva per piacere.'
  }, {
    "native": 'when is the first flight?',
    foreign: 'quando parte il primo volo?'
  }, {
    "native": 'when is the next flight?',
    foreign: 'quando parte il prossimo volo?'
  }, {
    "native": 'when is the last flight?',
    foreign: 'quando parte l\'ultimo volo?'
  }, {
    "native": 'i\'d like one round-trip ticket',
    foreign: 'vorrei un di andata e ritorno biglietto'
  }, {
    "native": 'i\'d like three one-way tickets',
    foreign: 'vorrei tre di andata biglietti'
  }, {
    "native": 'i\'d like four economy class tickets.',
    foreign: 'vorrei quattro classe turistica biglietti.'
  }, {
    "native": 'i\'d like two business class tickets.',
    foreign: 'vorrei due business class biglietti.'
  }, {
    "native": 'i\'d like one first class ticket.',
    foreign: 'vorrei un prima classe biglietti.'
  }, {
    "native": 'how much is a flight to paris?',
    foreign: 'quanto costa il volo per parigi?'
  }, {
    "native": 'i\'d like to confirm my reservation',
    foreign: 'vorrei confirmare la mia prenotazione.'
  }, {
    "native": 'i\'d like to change my reservation.',
    foreign: 'vorrei cambiare la mia prenotazione.'
  }, {
    "native": 'i\'d like to cancel my reservation.',
    foreign: 'vorrei anullare la mia prenotazione.'
  }, {
    "native": 'what time do i have to check in?',
    foreign: 'a che ora devo registrare i bagagli?'
  }, {
    "native": 'how long is the flight?',
    foreign: 'quanto dura il volo?'
  }, {
    "native": 'what time does the plane leave?',
    foreign: 'a che ora decolla l\'aereo?'
  }, {
    "native": 'what time do we arrive?',
    foreign: 'a che ora arriveremo?'
  }, {
    "native": 'which gate does the flight depart from?',
    foreign: 'da quale uscita parte il volo?'
  }, {
    "native": 'has the flight landed?',
    foreign: 'è atteratto il volo?'
  }, {
    "native": 'how late will the flight be?',
    foreign: 'di quanto ritarderà il volo?'
  }
];
/*
\d+.\s+(\w+).+\n
: '$1'\n


    
'The apple is red'
'It is John\'s apple'
'I give John the apple'
'We want to give him the apple'
'He gives it to John'
'She gives it to him'

*/