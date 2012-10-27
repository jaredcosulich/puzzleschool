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
      return $(square).data('index', index);
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
    square.html('');
    square.addClass('occupied');
    object = this.objects[objectType];
    objectContainer = $(document.createElement('IMG'));
    objectContainer.attr('src', object.image);
    square.append(objectContainer);
    if (object.distribute) {
      square.data('direction', object.distributeDirection);
      return this.fireLaser(square, object.distributeDirection);
    }
  };

  ViewHelper.prototype.fireLaser = function(square) {
    var denominator, direction, existingLaser, height, laser, numerator, object, offset,
      _this = this;
    square = $(square);
    if ((existingLaser = this.board.find(".laser.index" + (square.data('index')))).length) {
      console.log(square.data('index'), existingLaser[0].className);
      existingLaser.remove();
    }
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
    offset = square.offset();
    height = object.height() * (numerator / denominator);
    if (direction === 'right') {
      laser.css({
        height: height,
        width: 300,
        top: offset.top + ((offset.height - height) / 2),
        left: offset.left + offset.width
      });
    }
    return this.board.append(laser);
  };

  return ViewHelper;

})();
