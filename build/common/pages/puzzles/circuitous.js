// Generated by CoffeeScript 1.3.3
/*
RESOURCES

https://www.circuitlab.com

https://www.youtube.com/watch?v=a6YyEeqFFDA&feature=youtube_gdata_player&noredirect=1

http://phet.colorado.edu/en/simulation/circuit-construction-kit-dc

https://www.khanacademy.org/science/physics/electricity-and-magnetism/v/circuits--part-1

http://en.wikipedia.org/wiki/Electrical_circuit

http://www.allaboutcircuits.com

https://6002x.mitx.mit.edu
*/

var soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  Circuitous: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      this.classId = _arg.classId, this.levelId = _arg.levelId;
      this.template = this.loadTemplate("/build/common/templates/puzzles/circuitous.html");
      this.loadScript('/build/common/pages/puzzles/lib/common_objects/animation.js');
      this.loadScript('/build/common/pages/puzzles/lib/common_objects/client.js');
      this.loadScript('/build/common/pages/puzzles/lib/common_objects/transformer.js');
      this.loadScript('/build/common/pages/puzzles/lib/common_objects/draggable.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/object.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/tag.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/analyzer.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/wires.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/selector.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/battery.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/resistor.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/toggle_switch.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/light_emitting_diode.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/lightbulb.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/ohms_law_worksheet.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/board.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/options.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/menu.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/index.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/levels.js');
      if (this.levelId === 'editor') {
        this.loadScript('/build/common/pages/puzzles/lib/circuitous_editor.js');
      }
      this.loadScript('/build/common/pages/puzzles/lib/circuitous.js');
      return this.loadStylesheet('/build/client/css/puzzles/circuitous.css');
    },
    build: function() {
      this.setTitle("Circuitous - The Puzzle School");
      this.loadElement("link", {
        rel: 'img_src',
        href: 'http://www.puzzleschool.com/assets/images/reviews/xyflyer.jpg'
      });
      this.setMeta('og:title', 'Circuitous - The Puzzle School');
      this.setMeta('og:url', 'http://www.puzzleschool.com/puzzles/circuitous');
      this.setMeta('og:image', 'http://www.puzzleschool.com/assets/images/reviews/circuitous.jpg');
      this.setMeta('og:site_name', 'The Puzzle School');
      this.setMeta('og:description', 'Explore circuits through simple challenges you can solve in creative ways.');
      this.setMeta('description', 'Explore circuits through simple challenges you can solve in creative ways.');
      return this.html = wings.renderTemplate(this.template, {
        level_id: this.levelId || false,
        editor: this.levelId === 'editor'
      });
    }
  }
});

soma.views({
  Circuitous: {
    selector: '#content .circuitous',
    hashReplacements: {
      '~a': '{"components": [',
      '~b': '{"name": "Battery", ',
      '~c': '{"name": "Lightbulb", ',
      '~d': '"position": ',
      '~e': '"wires": [["',
      '~f': '"],["',
      '~g': '","',
      '~h': '"]]}',
      '~i': '{"name": "Resistor", ',
      '~j': '"volts": ',
      '~k': '"resistance": '
    },
    create: function() {
      var circuitous, circuitousEditor, instructions, replace, replaceWith, _ref,
        _this = this;
      circuitous = require('./lib/circuitous');
      this.worlds = require('./lib/xyflyer_objects/levels').WORLDS;
      this.viewHelper = new circuitous.ViewHelper({
        el: $(this.selector),
        worlds: this.worlds,
        loadLevel: function(levelId) {
          return _this.loadLevel(levelId);
        }
      });
      this.levelId = this.el.data('level_id');
      if (this.levelId === 'editor') {
        circuitousEditor = require('./lib/circuitous_editor');
        this.editor = new circuitousEditor.EditorHelper({
          el: $(this.selector),
          viewHelper: this.viewHelper,
          hashReplacements: this.hashReplacements,
          getInstructions: function() {
            return _this.getInstructions();
          }
        });
        if ((instructions = location.hash).length) {
          instructions = instructions.replace(/#/, '');
          _ref = this.hashReplacements;
          for (replace in _ref) {
            replaceWith = _ref[replace];
            instructions = instructions.replace(new RegExp(replace, 'g'), replaceWith);
          }
          this.loadInstructions(JSON.parse(instructions));
        }
      } else {
        this.initInfo();
        this.initCompleteListener();
        if (this.levelId) {
          this.loadLevel(this.levelId);
        } else {
          this.showLevelSelector();
        }
      }
      this.initInstructions();
      return setInterval((function() {
        var components;
        if (!_this.level) {
          return;
        }
        if (location.href.indexOf(_this.level.id) > -1) {
          return;
        }
        components = location.href.split('/');
        return _this.loadLevel(parseInt(components[components.length - 1]));
      }), 500);
    },
    initInfo: function() {
      var _this = this;
      this.$('.info .challenge').hide();
      this.$('.select_level').bind('click', function() {
        return _this.showLevelSelector();
      });
      this.$('.all_levels_link').bind('click', function() {
        return _this.viewHelper.showAllLevels();
      });
      return this.$('.schematic_mode').bind('click', function() {
        return alert('This will show the current circuit in standard schematic notation. We\'ll make the button look enabled when it is ready.');
      });
    },
    initInstructions: function() {
      var _this = this;
      $('.load_instructions .load button').bind('click', function() {
        var instructions;
        instructions = $('.load_instructions .load textarea').val().replace(/\s/g, '');
        if (instructions.length) {
          return _this.loadInstructions(JSON.parse(instructions));
        }
      });
      $('.load_instructions .load button').trigger('click');
      return this.viewHelper.board.addChangeListener(function() {
        $('.load_instructions .get textarea').val(_this.getInstructions());
        return $('.load_instructions .get_values textarea').val(_this.getValues());
      });
    },
    loadInstructions: function(instructions) {
      var getCoordinates, info, nodes, position, positions, x, y, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3, _results,
        _this = this;
      getCoordinates = function(position) {
        var cellDimension, xCell, yCell, _ref;
        _ref = position.split(','), xCell = _ref[0], yCell = _ref[1];
        cellDimension = _this.viewHelper.board.cellDimension;
        return [parseInt(xCell) * cellDimension, parseInt(yCell) * cellDimension];
      };
      _ref = instructions.wires || [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        positions = _ref[_i];
        nodes = [];
        for (_j = 0, _len1 = positions.length; _j < _len1; _j++) {
          position = positions[_j];
          _ref1 = getCoordinates(position), x = _ref1[0], y = _ref1[1];
          nodes.push({
            x: x,
            y: y
          });
        }
        (_ref2 = this.viewHelper.board.wires).create.apply(_ref2, nodes);
      }
      _ref3 = instructions.components;
      _results = [];
      for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
        info = _ref3[_k];
        _results.push((function(info) {
          var component;
          component = new circuitous[info.name]({
            recordChange: function() {
              return _this.viewHelper.recordChange();
            }
          });
          _this.viewHelper.addComponent(component);
          if (info.resistance !== void 0) {
            component.setResistance(info.resistance);
          }
          if (info.voltage !== void 0) {
            component.setVoltage(info.voltage);
          }
          return component.el.find('img').bind('load', function() {
            return setTimeout((function() {
              var componentPosition, _ref4;
              component.setStartDrag({});
              _ref4 = getCoordinates(info.position), x = _ref4[0], y = _ref4[1];
              componentPosition = _this.viewHelper.board.componentPosition({
                x: x - component.nodes[0].x,
                y: y - component.nodes[0].y
              });
              return _this.viewHelper.board.addComponent(component, componentPosition.x, componentPosition.y);
            }), 10);
          });
        })(info));
      }
      return _results;
    },
    getInstructions: function() {
      var cells, component, components, id, instructions, node, wire, wires, xCell, xCell0, xCell1, yCell, yCell0, yCell1, _ref, _ref1, _ref2, _ref3, _ref4,
        _this = this;
      instructions = [];
      components = [];
      cells = function(node) {
        var cellDimension;
        cellDimension = _this.viewHelper.board.cellDimension;
        return [node.x / cellDimension, node.y / cellDimension];
      };
      _ref = this.viewHelper.board.components;
      for (id in _ref) {
        component = _ref[id];
        node = this.viewHelper.board.boardPosition(component.currentNodes()[0]);
        _ref1 = cells(node), xCell = _ref1[0], yCell = _ref1[1];
        components.push("{\"name\": \"" + component.constructor.name + "\", \"position\": \"" + xCell + "," + yCell + "\"}");
      }
      instructions.push("\"components\": [" + (components.join(',')) + "]");
      wires = [];
      _ref2 = this.viewHelper.board.wires.all();
      for (id in _ref2) {
        wire = _ref2[id];
        _ref3 = cells(wire.nodes[0]), xCell0 = _ref3[0], yCell0 = _ref3[1];
        _ref4 = cells(wire.nodes[1]), xCell1 = _ref4[0], yCell1 = _ref4[1];
        wires.push("[\"" + xCell0 + "," + yCell0 + "\",\"" + xCell1 + "," + yCell1 + "\"]");
      }
      instructions.push("\"wires\": [" + (wires.join(',')) + "]");
      return "{" + (instructions.join(',')) + "}";
    },
    getValues: function() {
      var component, componentId, values, _ref;
      values = [];
      _ref = this.viewHelper.board.components;
      for (componentId in _ref) {
        component = _ref[componentId];
        values.push(JSON.stringify([component.constructor.name, component.current]));
      }
      return "[" + (values.join(',')) + "]";
    },
    initCompleteListener: function() {
      var _this = this;
      return this.viewHelper.board.addChangeListener(function() {
        var component, componentFound, componentId, componentIds, componentType, current, id, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
        if (!_this.level.loaded) {
          return;
        }
        componentIds = {};
        _ref = Object.keys(_this.viewHelper.board.components);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          id = _ref[_i];
          componentIds[id] = true;
        }
        _ref1 = _this.level.completeValues || [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          _ref2 = _ref1[_j], componentType = _ref2[0], current = _ref2[1];
          componentFound = false;
          _ref3 = _this.viewHelper.board.components;
          for (componentId in _ref3) {
            component = _ref3[componentId];
            if (componentIds[componentId]) {
              if (component.constructor.name === componentType) {
                if (!((current === 'infinite' && component.current === 'infinite') || (current === void 0 && component.current === void 0) || (current === Math.abs(component.current)) || (current === 'used' && Math.abs(component.current) > 0))) {
                  continue;
                }
                componentFound = true;
                delete componentIds[componentId];
                break;
              }
            }
          }
          if (!componentFound) {
            return;
          }
        }
        return _this.showComplete();
      });
    },
    findLevel: function(levelId) {
      var level, stage, world, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      _ref = this.worlds;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        world = _ref[_i];
        _ref1 = world.stages;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          stage = _ref1[_j];
          _ref2 = stage.levels;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            level = _ref2[_k];
            if (level.id === levelId) {
              return level;
            }
          }
        }
      }
    },
    loadLevel: function(levelId) {
      var title;
      if (!levelId) {
        this.level = this.worlds[0].stages[0].levels[0];
      } else {
        this.level = this.findLevel(levelId);
      }
      if (!this.level) {
        this.showLevelSelector();
        return;
      }
      this.hideModal();
      this.viewHelper.board.clear();
      this.showChallenge();
      title = "Circuitous Level " + this.level.id;
      if (history.pushState) {
        history.pushState(null, title, "/puzzles/circuitous/" + this.level.id);
      }
      return document.title = title;
    },
    showChallenge: function() {
      var info,
        _this = this;
      info = this.$('.info');
      return this.hideInfo(function() {
        var challenge;
        info.find('.intro, .complete').remove();
        challenge = _this.$('.challenge');
        challenge.find('.description').html(_this.level.challenge);
        challenge.show();
        return _this.showInfo({
          height: 150,
          callback: function() {
            info.css({
              height: null
            });
            _this.showHints();
            _this.$('.show_values').addClass(_this.level.values ? 'on' : 'off');
            _this.$('.show_values').removeClass(_this.level.values ? 'off' : 'on');
            _this.loadInstructions(_this.level.instructions);
            return _this.level.loaded = new Date().getTime();
          }
        });
      });
    },
    showHints: function() {
      var hint, hintsElement, hintsLinks, index, _fn, _i, _len, _ref,
        _this = this;
      hintsElement = this.$('.challenge .hints');
      hintsElement.html('');
      hintsLinks = $(document.createElement('DIV'));
      hintsLinks.addClass('hints_links');
      _ref = this.level.hints;
      _fn = function(hint, index) {
        var hintDiv, hintLink;
        hintLink = $(document.createElement('DIV'));
        hintLink.addClass('hint_link');
        hintLink.addClass('hidden');
        if (index > 1) {
          hintLink.addClass('disabled');
        }
        hintLink.html("Hint " + (index + 1));
        hintDiv = $(document.createElement('DIV'));
        hintDiv.addClass('hint');
        hintDiv.html("<b>Hint " + (index + 1) + "</b>: " + hint);
        hintsElement.append(hintDiv);
        hintLink.bind('click', function() {
          var height, solution;
          if (hintLink.hasClass('disabled')) {
            return;
          }
          hintLink.addClass('hidden');
          height = hintDiv.height();
          hintDiv.addClass('displayed');
          hintDiv.animate({
            height: height + 12,
            marginTop: -24,
            marginBottom: 24,
            paddingTop: 12,
            duration: 250
          });
          $(hintsElement.find('.hint_link')[index + 1]).removeClass('disabled');
          if (index === _this.level.hints.length - 1) {
            hintsLinks.remove();
            solution = $(document.createElement('A'));
            solution.addClass('solution');
            solution.html('View An Example Solution');
            solution.bind('click', function() {
              return _this.showModal("<img src='/assets/images/puzzles/circuitous/levels/" + _this.level.id + "_solution.png'/>");
            });
            return hintsElement.append(solution);
          }
        });
        hintsLinks.append(hintLink);
        return $.timeout(10, function() {
          if (index > 0) {
            return hintLink.removeClass('hidden');
          } else {
            return hintLink.trigger('click');
          }
        });
      };
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        hint = _ref[index];
        _fn(hint, index);
      }
      return hintsElement.append(hintsLinks);
    },
    hideInfo: function(callback) {
      var info,
        _this = this;
      info = this.$('.info');
      info.find('iframe').remove();
      return info.addClass('hidden').animate({
        height: 0,
        duration: 500,
        complete: function() {
          if (callback) {
            return callback();
          }
        }
      });
    },
    showInfo: function(_arg) {
      var callback, height, info,
        _this = this;
      height = _arg.height, callback = _arg.callback;
      info = this.$('.info');
      return info.animate({
        height: height,
        duration: 500,
        complete: function() {
          info.removeClass('hidden');
          if (callback) {
            return callback();
          }
        }
      });
    },
    showComplete: function() {
      var completeElement, info, youtube,
        _this = this;
      if (this.level.completed > this.level.loaded) {
        return;
      }
      this.level.completed = new Date().getTime();
      this.viewHelper.markLevelCompleted(this.level.id);
      completeElement = $(document.createElement('DIV'));
      completeElement.addClass('complete');
      youtube = "<img src='http://img.youtube.com/vi/" + this.level.completeVideoId + "/mqdefault.jpg'/><div class='play_button'><i class='icon-youtube-play'></i></div>";
      completeElement.html("<h1>Success</h1>\n<div class='description'>\n    " + this.level.complete + "\n    <div class='video_thumbnail'>\n        " + (this.level.completeVideoId ? youtube : 'Video Coming Soon') + "\n    </div>\n</div>\n<div class='buttons'><a class='button next_level'>Next Level</a></div>");
      info = this.$('.info');
      return this.hideInfo(function() {
        if (_this.level.completeVideoId) {
          $.timeout(20, function() {
            return completeElement.find('.video_thumbnail').bind('click', function() {
              return _this.showModal("<iframe width=\"640\" height=\"480\" src=\"//www.youtube.com/embed/" + _this.level.completeVideoId + "?rel=0&autoplay=1\" frameborder=\"0\" allowfullscreen></iframe>");
            });
          });
        }
        completeElement.find('.next_level').bind('click', function() {
          var level, selectNext, stage, world, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
          selectNext = false;
          _ref = _this.worlds;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            world = _ref[_i];
            _ref1 = world.stages;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              stage = _ref1[_j];
              _ref2 = stage.levels;
              for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
                level = _ref2[_k];
                if (selectNext) {
                  _this.loadLevel(level.id);
                  return true;
                }
                if (level.id === _this.level.id) {
                  selectNext = true;
                }
              }
            }
          }
        });
        info.find('.challenge').hide();
        info.append(completeElement);
        return _this.showInfo({
          height: info.parent().height() * 0.78
        });
      });
    },
    showLevelSelector: function() {
      var allLevels, currentWorldIndex, level, levelIndex, levelSelector, levels, nextLevels, prevLevels, stage, stageContainer, world, worldContainer, worldIndex, worldsContainer, _fn, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2,
        _this = this;
      levelSelector = $(document.createElement('DIV'));
      levelSelector.addClass('level_selector');
      worldsContainer = $(document.createElement('DIV'));
      worldsContainer.addClass('worlds_container');
      levelSelector.append(worldsContainer);
      currentWorldIndex = 0;
      _ref = this.worlds;
      for (worldIndex = _i = 0, _len = _ref.length; _i < _len; worldIndex = ++_i) {
        world = _ref[worldIndex];
        if (typeof level !== "undefined" && level !== null ? level.completed : void 0) {
          currentWorldIndex = worldIndex;
        }
        worldContainer = $(document.createElement('DIV'));
        worldContainer.addClass('world');
        worldsContainer.append(worldContainer);
        _ref1 = world.stages;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          stage = _ref1[_j];
          stageContainer = $(document.createElement('DIV'));
          stageContainer.addClass('stage');
          stageContainer.html("<h3>" + stage.name + "</h3>");
          levels = $(document.createElement('DIV'));
          levels.addClass('levels');
          stageContainer.append(levels);
          worldContainer.append(stageContainer);
          _ref2 = stage.levels;
          _fn = function(level, levelIndex) {
            var levelLink;
            levelLink = $(document.createElement('A'));
            levelLink.html("Level " + (levelIndex + 1));
            levelLink.addClass('level');
            if (level.completed) {
              levelLink.addClass('completed');
            }
            levelLink.bind('click', function() {
              return _this.hideModal(function() {
                return _this.loadLevel(level.id);
              });
            });
            return levels.append(levelLink);
          };
          for (levelIndex = _k = 0, _len2 = _ref2.length; _k < _len2; levelIndex = ++_k) {
            level = _ref2[levelIndex];
            _fn(level, levelIndex);
          }
        }
      }
      allLevels = $(document.createElement('A'));
      allLevels.addClass('all_levels_link');
      allLevels.html('All Levels');
      allLevels.bind('click', function() {
        return _this.viewHelper.showAllLevels();
      });
      levelSelector.append(allLevels);
      nextLevels = $(document.createElement('A'));
      nextLevels.addClass('next_levels_link');
      if (currentWorldIndex >= this.worlds.length - 1) {
        nextLevels.addClass('hidden');
      }
      nextLevels.html('Next &nbsp; <i class=\'icon-chevron-sign-right\'></i>');
      nextLevels.bind('click', function() {
        return _this.switchWorld({
          next: true
        });
      });
      levelSelector.append(nextLevels);
      prevLevels = $(document.createElement('A'));
      prevLevels.addClass('prev_levels_link');
      if (currentWorldIndex === 0) {
        prevLevels.addClass('hidden');
      }
      prevLevels.html('<i class=\'icon-chevron-sign-left\'></i> &nbsp; Previous');
      prevLevels.bind('click', function() {
        return _this.switchWorld({
          next: false
        });
      });
      levelSelector.append(prevLevels);
      this.showModal(levelSelector);
      return setTimeout((function() {
        return worldsContainer.css({
          marginLeft: worldsContainer.find('.world').width() * (currentWorldIndex * -1)
        });
      }), 100);
    },
    switchWorld: function(_arg) {
      var currentMarginLeft, direction, levelSelector, newMarginLeft, next, worldWidth, worldsContainer,
        _this = this;
      next = _arg.next, worldsContainer = _arg.worldsContainer;
      if (this.switchingWorld) {
        return;
      }
      this.switchingWorld = true;
      worldsContainer || (worldsContainer = this.$('.worlds_container'));
      worldWidth = worldsContainer.find('.world').width();
      direction = (next ? -1 : 1);
      currentMarginLeft = parseInt(worldsContainer.css('marginLeft') || 0);
      newMarginLeft = currentMarginLeft + (worldWidth * direction);
      worldsContainer.animate({
        marginLeft: newMarginLeft,
        duration: 500,
        complete: function() {
          return delete _this.switchingWorld;
        }
      });
      levelSelector = worldsContainer.closest('.level_selector');
      levelSelector.find('.next_levels_link').removeClass('hidden');
      levelSelector.find('.prev_levels_link').removeClass('hidden');
      if ((newMarginLeft / worldWidth) * -1 >= this.worlds.length - 1) {
        levelSelector.find('.next_levels_link').addClass('hidden');
      }
      if (newMarginLeft >= 0) {
        return levelSelector.find('.prev_levels_link').addClass('hidden');
      }
    },
    showModal: function(content) {
      var _this = this;
      if (content == null) {
        content = null;
      }
      if (!this.modalMenu) {
        this.modalMenu = this.$('.modal_menu');
        this.modalMenu.find('.close').bind('click', function() {
          return _this.hideModal();
        });
      }
      if (content) {
        this.modalMenu.find('.modal_content').html(content);
      }
      return setTimeout((function() {
        if (parseInt(_this.modalMenu.css('left')) < 0) {
          _this.modalMenu.css({
            opacity: 0,
            left: (_this.el.width() / 2) - (_this.modalMenu.width() / 2),
            top: (_this.el.height() / 2) - (_this.modalMenu.height() / 2)
          });
          return _this.modalMenu.animate({
            opacity: 1,
            duration: 500
          });
        }
      }), 100);
    },
    hideModal: function(callback) {
      var _this = this;
      if (!this.modalMenu) {
        return;
      }
      this.modalMenu.find('iframe').attr('src', '');
      this.modalMenu.animate({
        opacity: 0,
        duration: 500,
        complete: function() {
          return _this.modalMenu.css({
            left: -10000,
            top: -10000
          });
        }
      });
      if (callback) {
        return setTimeout(callback, 250);
      }
    }
  }
});

soma.routes({
  '/puzzles/circuitous/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.Circuitous({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/circuitous/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.Circuitous({
      levelId: levelId
    });
  },
  '/puzzles/circuitous': function() {
    return new soma.chunks.Circuitous;
  }
});
