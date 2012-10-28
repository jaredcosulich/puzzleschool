// Generated by CoffeeScript 1.3.3
var OBJECTS, spaceFractions;

spaceFractions = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/space_fractions', {});

OBJECTS = {
  laserLeft: {
    image: 'laser_left',
    distribute: true,
    distributeDirection: 'left',
    accept: false
  },
  laserRight: {
    image: 'laser_right',
    distribute: true,
    distributeDirection: 'right',
    accept: false
  },
  laserUp: {
    image: 'laser_up',
    distribute: true,
    distributeDirection: 'up',
    accept: false
  },
  laserDown: {
    image: 'laser_down',
    distribute: true,
    distributeDirection: 'down',
    accept: false
  },
  rock1: {
    image: 'rock1',
    distribute: false,
    accept: false
  },
  rock2: {
    image: 'rock2',
    distribute: false,
    accept: false
  }
};

spaceFractions.ChunkHelper = (function() {

  function ChunkHelper(languages, levelName, puzzleData) {
    this.languages = languages;
    this.levelName = levelName;
    this.puzzleData = puzzleData;
    this.languageData = languageScramble.data[this.languages];
    this.level = languageScramble.getLevel(this.languageData, this.levelName);
  }

  return ChunkHelper;

})();

spaceFractions.ViewHelper = (function() {

  ViewHelper.prototype.objects = OBJECTS;

  function ViewHelper(_arg) {
    var index, object, objectType, square, _fn, _i, _len, _ref;
    this.el = _arg.el;
    for (objectType in this.objects) {
      object = this.objects[objectType];
      object.image = "/assets/images/puzzles/space_fractions/" + object.image + ".png";
    }
    this.board = this.$('.board');
    _ref = this.board.find('.square');
    _fn = function(square, index) {
      $(square).data('index', index);
      return $(square).addClass("index" + index);
    };
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      square = _ref[index];
      _fn(square, index);
    }
  }

  ViewHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  ViewHelper.prototype.addObjectToBoard = function(objectType, square) {
    var object, objectContainer;
    square = $(square);
    square.html('');
    this.removeExistingLaser(square);
    square.addClass('occupied');
    square.data('object_type', objectType);
    object = this.objects[objectType];
    objectContainer = $(document.createElement('IMG'));
    objectContainer.attr('src', object.image);
    square.append(objectContainer);
    if (object.distribute) {
      square.data('direction', object.distributeDirection);
      return this.fireLaser(square, object.distributeDirection);
    }
  };

  ViewHelper.prototype.removeExistingLaser = function(square) {
    var existingLaser;
    square = $(square);
    if ((existingLaser = this.board.find(".laser.index" + (square.data('index')))).length) {
      return existingLaser.remove();
    }
  };

  ViewHelper.prototype.fireLaser = function(square) {
    var checkSquare, columns, denominator, direction, end, height, increment, index, laser, numerator, object, offset, rows, start, width, _i, _j,
      _this = this;
    square = $(square);
    this.removeExistingLaser(square);
    object = square.find('img');
    if (!object.height()) {
      $.timeout(10, function() {
        return _this.fireLaser(square, direction);
      });
      return;
    }
    direction = square.data('direction');
    numerator = square.data('numerator') || 1;
    denominator = square.data('denominator') || 1;
    laser = $(document.createElement('DIV'));
    laser.addClass("index" + (square.data('index')));
    laser.addClass('laser');
    laser.data('numerator', numerator);
    laser.data('denominator', denominator);
    rows = 10;
    columns = 10;
    increment = (function() {
      switch (direction) {
        case 'up':
          return -1 * columns;
        case 'down':
          return columns;
        case 'left':
          return -1;
        case 'right':
          return 1;
      }
    })();
    start = square.data('index') + increment;
    end = (function() {
      switch (direction) {
        case 'up':
          return 0;
        case 'down':
          return this.board.find('.square').length;
        case 'left':
          return (Math.floor(start / columns) * columns) - 1;
        case 'right':
          return Math.ceil(start / columns) * columns;
      }
    }).call(this);
    offset = square.offset();
    if (direction === 'left' || direction === 'right') {
      height = object.height() * (numerator / denominator);
      width = 0;
      for (index = _i = start; start <= end ? _i < end : _i > end; index = _i += increment) {
        checkSquare = this.board.find(".square.index" + index);
        if (checkSquare.hasClass('occupied')) {
          break;
        }
        width += checkSquare.width();
      }
    } else {
      console.log(start, end, increment);
      width = object.width() * (numerator / denominator);
      height = 0;
      for (index = _j = start; start <= end ? _j < end : _j > end; index = _j += increment) {
        checkSquare = this.board.find(".square.index" + index);
        if (checkSquare.hasClass('occupied')) {
          break;
        }
        height += checkSquare.height();
      }
    }
    laser.css({
      height: height,
      width: width
    });
    if (direction === 'right') {
      laser.css({
        top: offset.top + ((offset.height - height) / 2),
        left: offset.left + offset.width
      });
    } else if (direction === 'left') {
      laser.css({
        top: offset.top + ((offset.height - height) / 2),
        left: offset.left - width
      });
    } else if (direction === 'up') {
      laser.css({
        top: offset.top - height,
        left: offset.left + ((offset.width - width) / 2)
      });
    } else if (direction === 'down') {
      laser.css({
        top: offset.top + offset.height,
        left: offset.left + ((offset.width - width) / 2)
      });
    }
    return this.board.append(laser);
  };

  return ViewHelper;

})();
