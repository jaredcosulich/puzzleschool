// Generated by CoffeeScript 1.3.3
var circuitous, fn, name, _ref;

circuitous = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/circuitous', {});

_ref = require('./circuitous_objects/index');
for (name in _ref) {
  fn = _ref[name];
  circuitous[name] = fn;
}

circuitous.ChunkHelper = (function() {

  function ChunkHelper() {}

  return ChunkHelper;

})();

circuitous.ViewHelper = (function() {

  function ViewHelper(_arg) {
    this.el = _arg.el, this.worlds = _arg.worlds, this.loadLevel = _arg.loadLevel;
    this.init();
  }

  ViewHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  ViewHelper.prototype.init = function() {
    var _this = this;
    this.board = new circuitous.Board({
      el: this.$('.board')
    });
    this.selector = new circuitous.Selector({
      container: this.$('.game'),
      add: function(component) {
        return _this.addComponent(component, true);
      },
      button: this.$('.add_component'),
      selectorHtml: '<h2>Add Another Component</h2>'
    });
    this.initAllLevels();
    return this.initValues();
  };

  ViewHelper.prototype.addComponent = function(component, onBoard) {
    var img,
      _this = this;
    if (onBoard == null) {
      onBoard = false;
    }
    component.appendTo(this.board.cells);
    component.setName("" + component.constructor.name + " #" + 1);
    img = component.el.find('img');
    component.el.css({
      left: onBoard ? 10 : -10000
    });
    return img.bind('load', function() {
      component.el.width(img.width());
      component.el.height(img.height());
      return $.timeout(10, function() {
        component.initCurrent();
        component.initTag(_this.$('.show_values').hasClass('on'));
        return component.initDrag(component.el, function(component, x, y, stopDrag) {
          return _this.dragComponent(component, x, y, stopDrag);
        }, true, component.dragBuffer);
      });
    });
  };

  ViewHelper.prototype.dragComponent = function(component, x, y, state) {
    var _ref1;
    if (state === 'start') {
      this.board.removeComponent(component);
    } else if (state === 'stop') {
      if (!this.board.addComponent(component, x, y)) {
        this.board.removeComponent(component);
        component.resetDrag();
      }
    }
    return (_ref1 = component.tag) != null ? _ref1.position() : void 0;
  };

  ViewHelper.prototype.initValues = function() {
    var showValues,
      _this = this;
    showValues = this.$('.show_values');
    return showValues.bind('click.toggle_values touchstart.toggle_values', function() {
      var cid, component, hideValues, _ref1, _results;
      hideValues = showValues.hasClass('on');
      showValues.removeClass(hideValues ? 'on' : 'off');
      showValues.addClass(hideValues ? 'off' : 'on');
      _ref1 = _this.board.components;
      _results = [];
      for (cid in _ref1) {
        component = _ref1[cid];
        _results.push(component.tag[hideValues ? 'hide' : 'show']());
      }
      return _results;
    });
  };

  ViewHelper.prototype.initAllLevels = function() {
    var allLevels, index, lastCompleted, level, levels, levelsContainer, stage, stageContainer, world, worldContainer, _i, _len, _ref1, _results,
      _this = this;
    allLevels = this.$('.all_levels');
    allLevels.find('.back_to_challenge').bind('click', function() {
      return _this.showLevel();
    });
    levelsContainer = allLevels.find('.levels_container');
    _ref1 = this.worlds;
    _results = [];
    for (index = _i = 0, _len = _ref1.length; _i < _len; index = ++_i) {
      world = _ref1[index];
      worldContainer = $(document.createElement('DIV'));
      worldContainer.addClass('world');
      levelsContainer.append(worldContainer);
      _results.push((function() {
        var _j, _len1, _ref2, _results1;
        _ref2 = world.stages;
        _results1 = [];
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          stage = _ref2[_j];
          stageContainer = $(document.createElement('DIV'));
          stageContainer.addClass('stage');
          stageContainer.html("<h2>" + stage.name + "</h2>");
          levels = $(document.createElement('DIV'));
          levels.addClass('levels');
          stageContainer.append(levels);
          worldContainer.append(stageContainer);
          lastCompleted = true;
          _results1.push((function() {
            var _k, _len2, _ref3, _results2,
              _this = this;
            _ref3 = stage.levels;
            _results2 = [];
            for (index = _k = 0, _len2 = _ref3.length; _k < _len2; index = ++_k) {
              level = _ref3[index];
              _results2.push((function(level, index) {
                var hint, levelElement, levelInfo, levelLink;
                levelElement = $(document.createElement('DIV'));
                levelElement.addClass('level');
                levelElement.addClass("level_" + level.id);
                if (level.completed) {
                  levelElement.addClass('completed');
                }
                if (!(level.completed || lastCompleted)) {
                  levelElement.addClass('inactive');
                }
                levelInfo = $(document.createElement('DIV'));
                levelInfo.addClass('level_info');
                levelInfo.html("<h3>" + level.challenge + "</h3>\n<div class='completed'>\n    <div  class='hints'>\n        <h3>Hints:</h3>\n        <ul>\n            " + (((function() {
                  var _l, _len3, _ref4, _results3;
                  _ref4 = level.hints;
                  _results3 = [];
                  for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
                    hint = _ref4[_l];
                    _results3.push("<li>" + hint + "</li>");
                  }
                  return _results3;
                })()).join('')) + "\n        </ul>\n    </div>\n    <div class='complete_lesson'>\n        <h3>Lesson:</h3>\n        " + (level.complete.replace('<br/><br/>', '<br/>')) + "\n    </div>\n</div>");
                levelElement.append(levelInfo);
                levelElement.prepend(level.completeVideo.replace(/iframe/, 'iframe class=\'completed\''));
                levelLink = $(document.createElement('A'));
                if (level.completed) {
                  levelLink.html('Completed - Load Again');
                } else {
                  levelLink.html('Load Challenge');
                }
                levelLink.addClass('level_link');
                levelLink.bind('click', function() {
                  _this.loadLevel(level.id);
                  return _this.showLevel();
                });
                levelElement.append(levelLink);
                levels.append(levelElement);
                return lastCompleted = level.completed;
              })(level, index));
            }
            return _results2;
          }).call(this));
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  ViewHelper.prototype.markLevelCompleted = function(levelId) {
    var level, nextLevel;
    level = this.$(".level_" + levelId);
    level.addClass('completed');
    level.find('.level_link').html('Completed - Load Again');
    nextLevel = level.next();
    nextLevel.removeClass('inactive');
    return this.$('.levels_container').scrollTop(nextLevel.offset().top - this.$('.levels_container').offset().top - 200);
  };

  ViewHelper.prototype.showAllLevels = function() {
    return this.el.addClass('show_all_levels');
  };

  ViewHelper.prototype.showLevel = function() {
    return this.el.removeClass('show_all_levels');
  };

  return ViewHelper;

})();
