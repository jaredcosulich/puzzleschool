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
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/analyzer.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/wires.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/selector.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/battery.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/resistor.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/toggle_switch.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/light_emitting_diode.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/lightbulb.js');
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
        level_id: this.levelId,
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
      '~h': '"]]}'
    },
    create: function() {
      var circuitous, circuitousEditor, instructions, replace, replaceWith, _ref,
        _this = this;
      circuitous = require('./lib/circuitous');
      this.viewHelper = new circuitous.ViewHelper({
        el: $(this.selector)
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
        this.initWorlds();
        this.loadLevel();
        this.initCompleteListener();
      }
      return this.initInstructions();
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
        return [(parseInt(xCell) + 0.5) * cellDimension, (parseInt(yCell) + 0.5) * cellDimension];
      };
      _ref = instructions.wires;
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
          component = new circuitous[info.name];
          _this.viewHelper.addComponent(component);
          return component.el.find('img').bind('load', function() {
            return setTimeout((function() {
              var componentPosition, _ref4;
              component.setStartDrag({}, true);
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
        return [(node.x / cellDimension) - 0.5, (node.y / cellDimension) - 0.5];
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
        _ref1 = _this.level.completeValues;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          _ref2 = _ref1[_j], componentType = _ref2[0], current = _ref2[1];
          componentFound = false;
          _ref3 = _this.viewHelper.board.components;
          for (componentId in _ref3) {
            component = _ref3[componentId];
            if (component.constructor.name === componentType && current === Math.abs(component.current)) {
              componentFound = true;
              delete componentIds[componentId];
              break;
            }
          }
          if (!componentFound) {
            return;
          }
        }
        return _this.showComplete();
      });
    },
    initWorlds: function() {
      return this.worlds = require('./lib/xyflyer_objects/levels').WORLDS;
    },
    loadLevel: function(levelId) {
      if (!levelId) {
        this.level = this.worlds[0].stages[0].levels[0];
      } else {
        this.level = this.findLevel(levelId);
      }
      return this.showChallenge();
    },
    showChallenge: function() {
      var challenge;
      challenge = this.$('.challenge');
      challenge.find('.description').html(this.level.challenge);
      this.showHints();
      this.loadInstructions(this.level.instructions);
      return this.level.loaded = true;
    },
    showHints: function() {
      var hint, hintsElement, hintsLinks, index, _fn, _i, _len, _ref,
        _this = this;
      hintsElement = this.$('.challenge .hints');
      hintsLinks = $(document.createElement('DIV'));
      hintsLinks.addClass('hints_links');
      _ref = this.level.hints;
      _fn = function(hint, index) {
        var hintDiv, hintLink;
        hintLink = $(document.createElement('DIV'));
        hintLink.addClass('hint_link');
        if (index > 0) {
          hintLink.addClass('disabled');
        }
        hintLink.html("Hint " + (index + 1));
        hintDiv = $(document.createElement('DIV'));
        hintDiv.addClass('hint');
        hintDiv.html("<b>Hint " + (index + 1) + "</b>: " + hint);
        hintsElement.append(hintDiv);
        hintLink.bind('click', function() {
          if (hintLink.hasClass('disabled')) {
            return;
          }
          hintLink.animate({
            height: 1,
            duration: 250
          });
          hintDiv.animate({
            height: 54,
            paddingTop: 12,
            duration: 250
          });
          return $(hintsElement.find('.hint_link')[index + 1]).removeClass('disabled');
        });
        return hintsLinks.append(hintLink);
      };
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        hint = _ref[index];
        _fn(hint, index);
      }
      return hintsElement.append(hintsLinks);
    },
    showComplete: function() {
      var completeElement, info,
        _this = this;
      if (this.level.completed) {
        return;
      }
      this.level.completed = true;
      completeElement = $(document.createElement('DIV'));
      completeElement.addClass('complete');
      completeElement.html("<h1>Success</h1>\n<h3 class='description'>" + this.level.complete + "</h3>\n<div class='buttons'><a class='button'>Next Level</a></div>");
      info = this.$('.info');
      return info.css({
        overflow: 'hidden'
      }).animate({
        height: 0,
        duration: 500,
        complete: function() {
          if (_this.level.completeVideo) {
            $.timeout(250, function() {
              completeElement.find('.buttons').css({
                opacity: 1
              });
              return completeElement.find('.description').append(_this.level.completeVideo);
            });
          }
          info.find('.challenge').hide();
          info.append(completeElement);
          return info.animate({
            height: info.parent().height() * 0.85,
            duration: 500
          });
        }
      });
    },
    showModal: function(content) {
      var _this = this;
      if (!this.modalMenu) {
        this.modalMenu = this.$('.modal_menu');
        this.modalMenu.find('.close').bind('click', function() {
          return _this.hideModal();
        });
      }
      this.modalMenu.find('.content').html(content);
      if (parseInt(this.modalMenu.css('left')) < 0) {
        this.modalMenu.css({
          opacity: 0,
          left: (this.el.width() / 2) - (this.modalMenu.width() / 2),
          top: (this.el.height() / 2) - (this.modalMenu.height() / 2)
        });
        return this.modalMenu.animate({
          opacity: 1,
          duration: 500
        });
      }
    },
    hideModal: function() {
      var _this = this;
      if (!this.modalMenu) {
        return;
      }
      return this.modalMenu.animate({
        opacity: 0,
        duration: 500,
        complete: function() {
          return _this.modalMenu.css({
            left: -10000,
            top: -10000
          });
        }
      });
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
