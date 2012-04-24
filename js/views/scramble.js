var localData, x;
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
      this.loadUser();
      return this.setOptions();
    };
    Scramble.prototype.renderView = function() {
      this.el.html(this.template.render());
      this.setTitle();
      this.setProgress();
      this.bindWindow();
      this.bindKeyPress();
      return this.newScramble();
    };
    Scramble.prototype.loadUser = function() {
      var name, names, user, userName, users;
      users = $.cookie('users') || {};
      names = (function() {
        var _results;
        _results = [];
        for (name in users) {
          user = users[name];
          _results.push(name.toLowerCase());
        }
        return _results;
      })();
      name = prompt("What is your name?" + (names.length ? "\n\nExisting: " + (names.join(', ')) : ''), "");
      if (name && name.length) {
        for (userName in users) {
          user = users[userName];
          if (userName.toLowerCase() === name.toLowerCase()) {
            this.user = user;
          }
        }
      }
      if (this.user == null) {
        this.user = {};
      }
      if (name && name.length) {
        this.user.name = name;
      }
      if (this.user.groups == null) {
        this.user.groups = {};
      }
      if (this.user && (this.user.lastGroupPlayed != null)) {
        return this.group = this.user.lastGroupPlayed;
      } else {
        this.group = 'top25words';
        this.user.lastGroupPlayed = this.group;
        return this.user.groups[this.group] = {};
      }
    };
    Scramble.prototype.setOptions = function() {
      this.user.lastGroupPlayed;
      return this.options = localData[this.group].data;
    };
    Scramble.prototype.selectOption = function() {
      var i, incomplete, level, minLevel, option, optionLevel, options, optionsToAdd, possibleLevels, shuffledOptions, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
      this.orderedOptions || (this.orderedOptions = []);
      if (this.orderedOptionsIndex != null) {
        this.orderedOptionsIndex += 1;
      } else {
        this.orderedOptionsIndex = 0;
      }
      if (this.orderedOptions[this.orderedOptionsIndex] != null) {
        this.setStage();
        return this.orderedOptions[this.orderedOptionsIndex];
      }
      optionsToAdd = [[], [], [], [], [], [], []];
      minLevel = 7;
      _ref = this.options;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        option = _ref[_i];
        if (__indexOf.call(this.orderedOptions.slice(-4), option) >= 0) {
          continue;
        }
        optionLevel = this.user.groups[this.group][this.scrambleKey(option)] || 1;
        optionsToAdd[optionLevel] || (optionsToAdd[optionLevel] = []);
        optionsToAdd[optionLevel].push(option);
        if (optionLevel < minLevel) {
          minLevel = optionLevel;
        }
      }
      if (minLevel === 7) {
        incomplete = (function() {
          var _j, _len2, _ref2, _results;
          _ref2 = this.orderedOptions.slice(-4);
          _results = [];
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            option = _ref2[_j];
            if ((this.user.groups[this.group][this.scrambleKey(option)] || 1) < 7) {
              _results.push(option);
            }
          }
          return _results;
        }).call(this);
        if (incomplete.length) {
          for (_j = 0, _len2 = incomplete.length; _j < _len2; _j++) {
            option = incomplete[_j];
            this.orderedOptions.push(option);
          }
        } else {
          this.nextLevel();
        }
        return;
      }
      possibleLevels = [minLevel, minLevel];
      if (optionsToAdd[minLevel].length > 4) {
        if (optionsToAdd[minLevel].length < this.options.length / (3 / 2)) {
          possibleLevels.push(minLevel + 1);
        }
        if (optionsToAdd[minLevel].length < this.options.length / 2) {
          for (i = 0; i <= 1; i++) {
            possibleLevels.push(minLevel + i);
          }
        }
        if (optionsToAdd[minLevel].length < this.options.length / 3) {
          for (i = 0; i <= 2; i++) {
            possibleLevels.push(minLevel + i);
          }
        }
      }
      level = this.random(possibleLevels);
      if (!optionsToAdd[level]) {
        level = ((function() {
          var _results;
          _results = [];
          for (level in optionsToAdd) {
            options = optionsToAdd[level];
            _results.push(level);
          }
          return _results;
        })())[0];
      }
      shuffledOptions = this.shuffle(optionsToAdd[level]);
      _ref2 = shuffledOptions.slice(0, 3);
      for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
        option = _ref2[_k];
        this.orderedOptions.push(option);
      }
      switch (level) {
        case 6:
          this.activeLevel = 'foreignHard';
          break;
        case 5:
          this.activeLevel = 'nativeHard';
          break;
        case 4:
          this.activeLevel = 'foreignMedium';
          break;
        case 3:
          this.activeLevel = 'nativeMedium';
          break;
        case 2:
          this.activeLevel = 'foreign';
          break;
        case 1:
          this.activeLevel = 'native';
      }
      this.activeType = this.activeLevel.replace(/Medium/, '').replace(/Hard/, '');
      this.displayLevel = this.activeType.match(/native/) ? 'foreign' : 'native';
      this.setStage();
      return this.orderedOptions[this.orderedOptionsIndex];
    };
    Scramble.prototype.setTitle = function() {
      this.$('.header .title .text').html(localData[this.group].title);
      return this.$('.header .title .subtitle').html(localData[this.group].subtitle);
    };
    Scramble.prototype.setProgress = function() {
      var index, key, level, scramble, section, _i, _len, _len2, _ref, _ref2, _results;
      if (!this.$('.progress_meter .bar .progress_section').length) {
        _ref = localData[this.group].data;
        for (index = 0, _len = _ref.length; index < _len; index++) {
          scramble = _ref[index];
          section = $(document.createElement("DIV"));
          section.addClass('progress_section');
          section.addClass(this.scrambleKey(scramble));
          if ((index + 1) === localData[this.group].data.length) {
            section.css({
              borderRight: 'none'
            });
          }
          this.$('.progress_meter .bar').append(section);
        }
      }
      _ref2 = localData[this.group].data;
      _results = [];
      for (_i = 0, _len2 = _ref2.length; _i < _len2; _i++) {
        scramble = _ref2[_i];
        key = this.scrambleKey(scramble);
        level = this.user.groups[this.group][key];
        _results.push(level != null ? (level > 7 ? level = 7 : void 0, this.$(".progress_meter .bar ." + key).css({
          opacity: 1 - ((1 / 7) * level)
        })) : this.$(".progress_meter .bar ." + key).css({
          opacity: 1
        }));
      }
      return _results;
    };
    Scramble.prototype.scrambleKey = function(scrambleInfo) {
      return "" + (scrambleInfo["native"].replace(/\W/g, '_')) + "-" + (scrambleInfo.foreign.replace(/\W/g, '_'));
    };
    Scramble.prototype.setStage = function() {
      this.$('.guesses').removeClass('hidden');
      this.$('.scrambled').removeClass('hidden');
      this.$('.scramble_content').removeClass('show_keyboard');
      if ((this.activeLevel.match(/Medium/) != null) || (this.activeLevel.match(/Hard/) != null)) {
        this.$('.guesses').addClass('hidden');
        this.$('.guesses .hidden_message').show();
      }
      if (this.activeLevel.match(/Hard/) != null) {
        this.$('.scrambled').addClass('hidden');
        this.$('.scrambled .hidden_message').show();
        return this.$('.scramble_content').addClass('show_keyboard');
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
    Scramble.prototype.shuffle = function(array) {
      var current, tmp, top;
      top = array.length;
      if (!top) {
        return array;
      }
      while (top--) {
        current = Math.floor(Math.random() * (top + 1));
        tmp = array[current];
        array[current] = array[top];
        array[top] = tmp;
      }
      return array;
    };
    Scramble.prototype.newScramble = function() {
      var boundary, displayWords, highlighted, sentence, _base, _i, _len, _name, _ref;
      this.answerTimes || (this.answerTimes = []);
      this.answerTimes.push(new Date());
      this.lettersAdded = [];
      this.scrambleInfo = this.selectOption();
      (_base = this.user.groups[this.group])[_name = this.scrambleKey(this.scrambleInfo)] || (_base[_name] = 1);
      displayWords = this.$('.display_words');
      if ((this.scrambleInfo["" + this.displayLevel + "Sentence"] != null) && this.scrambleInfo["" + this.displayLevel + "Sentence"].length) {
        sentence = this.scrambleInfo["" + this.displayLevel + "Sentence"];
      } else {
        sentence = this.scrambleInfo[this.displayLevel];
      }
      sentence = " " + sentence + " ";
      highlighted = this.scrambleInfo[this.displayLevel];
      _ref = [' ', '?', ','];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        boundary = _ref[_i];
        sentence = sentence.replace(" " + highlighted + boundary, " <span class='highlighted'>" + highlighted + "</span>" + boundary);
      }
      displayWords.html(sentence);
      this.createGuesses();
      return this.createScramble();
    };
    Scramble.prototype.saveLevel = function() {
      var lastAnswerDuration;
      this.answerTimes.push(new Date());
      lastAnswerDuration = this.answerTimes[this.answerTimes.length - 1] - this.answerTimes[this.answerTimes.length - 2];
      if (lastAnswerDuration < 2500 * this.scrambleInfo["native"].length) {
        this.user.groups[this.group][this.scrambleKey(this.scrambleInfo)] += 1;
      }
      return this.saveUser();
    };
    Scramble.prototype.saveUser = function() {
      var users;
      if (this.user && this.user.name) {
        users = $.cookie('users') || {};
        users[this.user.name.toLowerCase()] = this.user;
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
    Scramble.prototype.shuffleWord = function(word) {
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
        shuffled = this.shuffleWord(shuffled);
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
        _ref2 = this.shuffleWord(this.modifyScramble(group.join('')));
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
        var char, foreignChar, letter, openGuess;
        openGuess = this.$('.guesses .selected')[0] || this.$(".guesses .guess")[0];
        if (openGuess == null) {
          return;
        }
        try {
          char = String.fromCharCode(e.keyCode).toLowerCase();
          if (char === 'e' || char === 'i' || char === 'u' || char === 'o') {
            foreignChar = (function() {
              switch (char) {
                case 'e':
                  return 'è';
                case 'i':
                  return 'ì';
                case 'o':
                  return 'ò';
                case 'u':
                  return 'ù';
              }
            })();
            if ($(openGuess).hasClass("actual_letter_" + foreignChar)) {
              char = foreignChar;
            }
          }
          letter = $(".scrambled ." + (this.containerClassName(openGuess)) + " .letter_" + char)[0];
          if (!letter && (this.activeLevel.match(/Hard/) != null)) {
            if (char.match(/\w|[^\x00-\x80]+/)) {
              letter = this.createLetter(char);
              $(".scrambled ." + (this.containerClassName(openGuess))).append(letter);
            }
          }
          $.timeout(10, __bind(function() {
            $('#clickarea').val('');
            return $('#clickarea').html('');
          }, this));
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
        this.dragPathX = [];
        this.dragPathY = [];
        this.dragAdjustmentX = this.clientX(e) - letter.offset().left + this.el.offset().left;
        return this.dragAdjustmentY = this.clientY(e) - letter.offset().top + this.el.offset().top;
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
      var boundary, correct, correctSentence, displayedSentence, highlighted, scrambled, _i, _len, _ref;
      this.saveLevel();
      correct = $(document.createElement('DIV'));
      if ((this.scrambleInfo["" + this.activeType + "Sentence"] != null) && this.scrambleInfo["" + this.activeType + "Sentence"].length) {
        correctSentence = this.scrambleInfo["" + this.activeType + "Sentence"];
      } else {
        correctSentence = this.scrambleInfo[this.activeType];
      }
      correctSentence = " " + correctSentence + " ";
      highlighted = this.scrambleInfo[this.activeType];
      _ref = [' ', '?', ','];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        boundary = _ref[_i];
        correctSentence = correctSentence.replace(" " + highlighted + boundary, " <span class='highlighted'>" + highlighted + "</span>" + boundary);
      }
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
      displayedSentence = this.$('.display_words').html();
      this.$('.last_answer').animate({
        opacity: 0,
        duration: 300
      });
      return correct.animate({
        opacity: 1,
        duration: 500,
        complete: __bind(function() {
          return $.timeout(200 + (30 * correctSentence.length), __bind(function() {
            this.setProgress();
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
                  duration: 300,
                  complete: __bind(function() {}, this)
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
    Scramble.prototype.nextLevel = function() {
      var message, nextLevel;
      nextLevel = localData[localData[this.group].nextLevel];
      if (nextLevel != null) {
        this.$('#next_level .next_level_link').html(nextLevel.title);
        message = this.$('#next_level');
      }
      return this.$('.scramble_content').animate({
        opacity: 0,
        duration: 500,
        complete: __bind(function() {
          message.css({
            top: 200,
            left: ($('.scramble').width() - this.$('#next_level').width()) / 2
          });
          this.$('#next_level .next_level_link').bind('click', __bind(function() {
            this.group = localData[this.group].nextLevel;
            this.user.lastGroupPlayed = this.group;
            this.user.groups[this.group] = {};
            this.saveUser();
            this.orderedOptions = [];
            this.setOptions();
            this.setTitle();
            this.setProgress();
            return this.$('#next_level').animate({
              opacity: 0,
              duration: 500,
              complete: __bind(function() {
                this.newScramble();
                return this.$('.scramble_content').animate({
                  opacity: 1,
                  duration: 500
                });
              }, this)
            });
          }, this));
          return this.$('#next_level').animate({
            opacity: 1,
            duration: 1000
          });
        }, this)
      });
    };
    return Scramble;
  })();
  return $.route.add({
    '': function() {
      return $('#content').view({
        name: 'Scramble',
        data: {
          level: 'top25words'
        }
      });
    },
    'scramble': function() {
      return $('#content').view({
        name: 'Scramble',
        data: {
          level: 'top25words'
        }
      });
    },
    'scramble/:level': function(level) {
      return $('#content').view({
        name: 'Scramble',
        data: {
          level: level
        }
      });
    }
  });
})(ender);
localData = {
  top25words: {
    title: 'Top 25 Words',
    subtitle: 'The 25 most frequently used Italian words.',
    nextLevel: 'top25phrases',
    data: [
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
        "native": 'the',
        foreign: 'la',
        nativeSentence: 'drop the ball now',
        foreignSentence: 'cadere la palla ora'
      }, {
        "native": 'the',
        foreign: 'il',
        nativeSentence: 'there are drinks for the party',
        foreignSentence: 'ci sono bevande per il partito'
      }, {
        "native": 'a',
        foreign: 'un',
        nativeSentence: 'a little more',
        foreignSentence: 'un po più'
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
        "native": 'i have',
        foreign: 'ho',
        nativeSentence: 'i have twenty dollars',
        foreignSentence: 'ho venti dollari'
      }, {
        "native": 'but',
        foreign: 'ma',
        nativeSentence: 'i was going to but i can not',
        foreignSentence: 'stavo andando ma non posso'
      }, {
        "native": 'he has',
        foreign: 'ha',
        nativeSentence: 'he has a big house',
        foreignSentence: 'ha una grande casa'
      }, {
        "native": 'with',
        foreign: 'con',
        nativeSentence: 'i\'m coming with you',
        foreignSentence: 'vengo con te'
      }, {
        "native": 'what',
        foreign: 'cosa',
        nativeSentence: 'what do you like to do?',
        foreignSentence: 'cosa ti piace fare?'
      }, {
        "native": 'if',
        foreign: 'se',
        nativeSentence: 'what if he wins?',
        foreignSentence: 'cosa succede se vince?'
      }, {
        "native": 'i',
        foreign: 'io',
        nativeSentence: 'i am going to the markets',
        foreignSentence: 'io vado ai mercati'
      }, {
        "native": 'how',
        foreign: 'come',
        nativeSentence: 'how are you?',
        foreignSentence: 'come stai?'
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
        foreign: 'sì',
        nativeSentence: 'yes, you can',
        foreignSentence: 'sì, è possibile'
      }
    ]
  },
  top25phrases: {
    title: 'Phrases For The Top 25 Words',
    subtitle: 'Phrases containing the 25 most frequently used Italian words.',
    nextLevel: 'top50words',
    data: [
      {
        "native": 'that\'s not necessary',
        foreign: 'non è necessario'
      }, {
        "native": 'memories of a cat',
        foreign: 'memorie di un gatto'
      }, {
        "native": 'what luck',
        foreign: 'che fortuna'
      }, {
        "native": 'that bird is fat',
        foreign: 'quell\'uccello è grasso'
      }, {
        "native": 'big and tall',
        foreign: 'grande e grosso'
      }, {
        "native": 'drop the ball now',
        foreign: 'cadere la palla ora'
      }, {
        "native": 'there are drinks for the party',
        foreign: 'ci sono bevande per il partito'
      }, {
        "native": 'a little more',
        foreign: 'un po più'
      }, {
        "native": 'the drinks are for the party',
        foreign: 'le bevande sono per il partito'
      }, {
        "native": 'there are five quotes',
        foreign: 'ci sono cinque citazioni'
      }, {
        "native": 'i have twenty dollars',
        foreign: 'ho venti dollari'
      }, {
        "native": 'i was going to but i can not',
        foreign: 'stavo andando ma non posso'
      }, {
        "native": 'he has a big house',
        foreign: 'ha una grande casa'
      }, {
        "native": 'i\'m coming with you',
        foreign: 'vengo con te'
      }, {
        "native": 'what do you like to do?',
        foreign: 'cosa ti piace fare?'
      }, {
        "native": 'what if he wins?',
        foreign: 'cosa succede se vince?'
      }, {
        "native": 'i am going to the markets',
        foreign: 'io vado ai mercati'
      }, {
        "native": 'how are you?',
        foreign: 'come stai?'
      }, {
        "native": 'there are three friends',
        foreign: 'ci sono tre amici'
      }, {
        "native": 'this is great',
        foreign: 'questo è fantastico'
      }, {
        "native": 'come here',
        foreign: 'vieni qui'
      }, {
        "native": 'you have ten minutes',
        foreign: 'hai dieci minuti'
      }, {
        "native": 'there are six doors',
        foreign: 'ci sono sei porte'
      }, {
        "native": 'are you well?',
        foreign: 'stai bene?'
      }, {
        "native": 'yes, you can',
        foreign: 'sì, è possibile'
      }
    ]
  },
  top50words: {
    title: 'Top 25 - 50 Words',
    subtitle: 'The most frequently used Italian words (25 - 50).',
    nextLevel: 'top50phrases',
    data: [
      {
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
      }
    ]
  },
  top50Phrases: {
    title: 'Phrases For The Top 25 - 50 Words',
    subtitle: 'Phrases containing the 25 - 50 most frequently used Italian words.',
    data: [
      {
        "native": 'a little more',
        foreign: 'un po più'
      }, {
        "native": 'my child is seven years old',
        foreign: 'mio figlio ha sette anni'
      }, {
        "native": 'because i want to',
        foreign: 'perché voglio'
      }, {
        "native": 'why do you want to go?',
        foreign: 'perché vuoi andare?'
      }, {
        "native": 'she leaves tomorrow',
        foreign: 'lei parte domani'
      }, {
        "native": 'it was only fifteen minutes',
        foreign: 'era solo quindici minuti'
      }, {
        "native": 'it was thirty years ago',
        foreign: 'era trent\'anni fa'
      }, {
        "native": 'all of the king\'s horses',
        foreign: 'tutti i cavalli del re'
      }, {
        "native": 'i am feeling so-so',
        foreign: 'mi sento così-così'
      }, {
        "native": 'hello my friend',
        foreign: 'ciao amico mio'
      }, {
        "native": 'this is the best food',
        foreign: 'questo è il miglior cibo'
      }, {
        "native": 'if you want to do this',
        foreign: 'se si vuole fare questo'
      }, {
        "native": 'when is the show?',
        foreign: 'quando è lo spettacolo?'
      }, {
        "native": 'drop the ball now',
        foreign: 'cadere la palla ora'
      }, {
        "native": 'you did your best',
        foreign: 'hai fatto del tuo meglio'
      }, {
        "native": 'i want to be an astronaut',
        foreign: 'voglio essere un astronauta'
      }, {
        "native": 'i have never been to the coast',
        foreign: 'non sono mai stato alla costa'
      }, {
        "native": 'who are you?',
        foreign: 'chi sei?'
      }, {
        "native": 'pizza or pasta',
        foreign: 'pizza o la pasta'
      }, {
        "native": 'he ate all of the cookies',
        foreign: 'ha mangiato tutti i cookie'
      }, {
        "native": 'he is very old',
        foreign: 'lui è molto vecchio'
      }, {
        "native": 'i also need two pencils',
        foreign: 'ho anche bisogno di due matite'
      }, {
        "native": 'he said go left',
        foreign: 'ha detto andate a sinistra'
      }, {
        "native": 'that lady ate my cheese',
        foreign: 'quella signora mangiato il mio formaggio'
      }, {
        "native": 'there was nothing there',
        foreign: 'non c\'era niente'
      }
    ]
  }
};
x = [
  {
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
    "native": 'i want',
    foreign: 'voglio',
    nativeSentence: 'i want a new car',
    foreignSentence: 'voglio una macchina nuova'
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
    foreignSentence: 'puòi fare questo'
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