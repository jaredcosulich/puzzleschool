// Generated by CoffeeScript 1.3.3
/*
RESOURCES

https://www.circuitlab.com

https://www.youtube.com/watch?v=a6YyEeqFFDA&feature=youtube_gdata_player&noredirect=1

http://phet.colorado.edu/en/simulation/circuit-construction-kit-dc

https://www.khanacademy.org/science/physics/electricity-and-magnetism/v/circuits--part-1

http://en.wikipedia.org/wiki/Electrical_circuit
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
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/selector.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/battery.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/resistor.js');
      this.loadScript('/build/common/pages/puzzles/lib/circuitous_objects/toggle_switch.js');
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
    create: function() {
      var circuitous, circuitousEditor;
      circuitous = require('./lib/circuitous');
      this.viewHelper = new circuitous.ViewHelper({
        el: $(this.selector)
      });
      this.levelId = this.el.data('level_id');
      if (this.levelId === 'editor') {
        circuitousEditor = require('./lib/circuitous_editor');
        return this.editor = new circuitousEditor.EditorHelper({
          el: $(this.selector)
        });
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
