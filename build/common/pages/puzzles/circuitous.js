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
        level_id: this.levelId
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
      '~e': '"wires": [',
      '~f': '"],["',
      '~g': '","',
      '~h': '"]]}'
    },
    create: function() {
      var circuitous, circuitousEditor,
        _this = this;
      circuitous = require('./lib/circuitous');
      this.viewHelper = new circuitous.ViewHelper({
        el: $(this.selector)
      });
      this.levelId = this.el.data('level_id');
      if (this.levelId === 'editor') {
        circuitousEditor = require('./lib/circuitous_editor');
        this.editor = new circuitousEditor.EditorHelper({
          viewHelper: this.viewHelper,
          hashReplacements: this.hashReplacements,
          getInstructions: function() {
            return _this.getInstructions();
          }
        });
      }
      $('.load_instructions .load button').bind('click', function() {
        var instructions;
        instructions = $('.load_instructions .load textarea').val().replace(/\s/g, '');
        if (instructions.length) {
          return _this.loadInstructions(JSON.parse(instructions));
        }
      });
      $('.load_instructions .load button').trigger('click');
      this.viewHelper.board.addChangeListener(function() {
        return $('.load_instructions .get textarea').val(_this.getInstructions());
      });
      return $('.load_instructions .get_values button').bind('click', function() {
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
          _this.viewHelper.options.addComponent(component);
          return setTimeout((function() {
            var componentPosition, _ref4;
            component.el.removeClass('in_options');
            component.setStartDrag({}, true);
            _ref4 = getCoordinates(info.position), x = _ref4[0], y = _ref4[1];
            componentPosition = _this.viewHelper.board.componentPosition({
              x: x - component.nodes[0].x,
              y: y - component.nodes[0].y
            });
            return _this.viewHelper.board.addComponent(component, componentPosition.x, componentPosition.y);
          }), 50);
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
      var component, id, values, _ref;
      values = {};
      _ref = this.viewHelper.board.components;
      for (id in _ref) {
        component = _ref[id];
        values[id] = component.current;
      }
      return JSON.stringify(values);
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
