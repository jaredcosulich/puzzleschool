// Generated by CoffeeScript 1.3.3
var CLASSES, LEVELS, soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  Xyflyer: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      var object, _i, _len, _ref,
        _this = this;
      this.classId = _arg.classId, this.levelId = _arg.levelId;
      this.template = this.loadTemplate("/build/common/templates/puzzles/xyflyer.html");
      this.loadScript('/assets/third_party/equation_explorer/tokens.js');
      this.loadScript('/assets/third_party/raphael-min.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/tdop.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/parser.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/object.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/board.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/plane.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/ring.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equation.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equation_component.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/equations.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer_objects/index.js');
      this.loadScript('/build/common/pages/puzzles/lib/xyflyer.js');
      if (this.levelId && !isNaN(this.levelId)) {
        this.loadData({
          url: "/api/puzzles/levels/" + this.levelId,
          success: function(levelInfo) {
            _this.levelInfo = levelInfo;
          },
          error: function() {
            if (typeof window !== "undefined" && window !== null ? window.alert : void 0) {
              return alert('We were unable to load the information for this level. Please check your internet connection.');
            }
          }
        });
      }
      if (this.classId) {
        this.loadData({
          url: "/api/classes/info/" + this.classId,
          success: function(data) {
            var level, _i, _len, _ref;
            _this.classInfo = data;
            _ref = _this.classInfo.levels;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              level = _ref[_i];
              level.classId = _this.classInfo.id;
            }
            return _this.classInfo.levels = sortLevels(_this.classInfo.levels);
          },
          error: function() {
            if (typeof window !== "undefined" && window !== null ? window.alert : void 0) {
              return alert('We were unable to load the information for this class. Please check your internet connection.');
            }
          }
        });
      }
      this.objects = [];
      _ref = ['island'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        object = _ref[_i];
        this.objects.push({
          name: object,
          image: this.loadImage("/assets/images/puzzles/xyflyer/" + object + ".png")
        });
      }
      if (this.levelId === 'editor') {
        this.loadScript('/build/common/pages/puzzles/lib/xyflyer_editor.js');
      }
      return this.loadStylesheet('/build/client/css/puzzles/xyflyer.css');
    },
    build: function() {
      var _ref;
      this.setTitle("XYFlyer - The Puzzle School");
      return this.html = wings.renderTemplate(this.template, {
        objects: this.objects,
        "class": this.classId,
        level: this.levelId,
        instructions: (_ref = this.levelInfo) != null ? _ref.instructions : void 0
      });
    }
  }
});

soma.views({
  Xyflyer: {
    selector: '#content .xyflyer',
    create: function() {
      var equation, fragment, info, ring, xyflyer, _i, _j, _len, _len1, _ref, _ref1, _results,
        _this = this;
      xyflyer = require('./lib/xyflyer');
      this.user = this.cookies.get('user');
      this.classId = this.el.data('class');
      this.levelId = this.el.data('level');
      if (isNaN(parseInt(this.levelId))) {
        this.showMessage('intro');
        return;
      }
      if (this.classId) {
        this.data = eval("a=" + this.$('.level_instructions').html().replace(/\s/g, ''));
      } else {
        this.data = LEVELS[this.levelId];
      }
      if (!this.data) {
        this.showMessage('exit');
        return;
      }
      this.viewHelper = new xyflyer.ViewHelper({
        el: $(this.selector),
        boardElement: this.$('.board'),
        objects: this.$('.objects'),
        equationArea: this.$('.equation_area'),
        grid: this.data.grid,
        islandCoordinates: this.data.islandCoordinates,
        nextLevel: function() {
          return _this.nextLevel();
        },
        registerEvent: function(eventInfo) {
          return _this.registerEvent(eventInfo);
        }
      });
      for (equation in this.data.equations) {
        info = this.data.equations[equation];
        this.viewHelper.addEquation(equation, info.start, info.solutionComponents, this.data.variables);
      }
      _ref = this.data.rings;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ring = _ref[_i];
        this.viewHelper.addRing(ring.x, ring.y);
      }
      if (this.data.fragments) {
        _ref1 = this.data.fragments;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          fragment = _ref1[_j];
          _results.push(this.viewHelper.addEquationComponent(fragment));
        }
        return _results;
      } else {
        return this.$('.possible_fragments').hide();
      }
    },
    centerAndShow: function(element, board) {
      var areaOffset, boardOffset, offset;
      offset = element.offset();
      boardOffset = this.$('.board').offset();
      areaOffset = this.el.offset();
      element.css({
        opacity: 0,
        top: (boardOffset.top - areaOffset.top) + (boardOffset.height / 2) - (offset.height / 2),
        left: (boardOffset.left - areaOffset.left) + (boardOffset.width / 2) - (offset.width / 2)
      });
      return element.animate({
        opacity: 0.9,
        duration: 500
      });
    },
    showMessage: function(type) {
      var equationArea;
      equationArea = this.$('.equation_area');
      equationArea.html(this.$("." + type + "_message").html());
      equationArea.css({
        padding: '0 12px',
        textAlign: 'center'
      });
      return equationArea.find('.button').attr('href', '/puzzles/xyflyer/1');
    },
    nextLevel: function() {
      var complete;
      this.registerEvent({
        type: 'success',
        info: {
          time: new Date()
        }
      });
      complete = this.$('.complete');
      this.centerAndShow(complete);
      this.$('.launch').html('Success! Go To The Next Level >');
      return this.$('.go').attr('href', "/puzzles/xyflyer/" + (this.classId ? this.classId + '/' : '') + (this.levelId + 1));
    },
    registerEvent: function(_arg) {
      var info, type;
      type = _arg.type, info = _arg.info;
      if (!(this.user && this.user.id && this.levelId && this.classId)) {
        return;
      }
      this.pendingEvents || (this.pendingEvents = []);
      this.pendingEvents.push({
        type: type,
        info: JSON.stringify(info),
        puzzle: 'xyflyer',
        classId: this.classId,
        levelId: this.levelId
      });
      if (!this.lastEvent) {
        this.timeBetweenEvents = 0;
        this.lastEvent = new Date();
      } else {
        this.timeBetweenEvents += new Date().getTime() - this.lastEvent.getTime();
        this.lastEvent = new Date();
      }
      return this.sendEvents(type === 'success' || type === 'challenge');
    },
    sendEvents: function(force) {
      var completeEventRecording, event, key, pendingEvents, statUpdates, timeBetweenEvents, updates, _i, _len, _ref,
        _this = this;
      if (!force) {
        if (!((_ref = this.pendingEvents) != null ? _ref.length : void 0)) {
          return;
        }
        if (this.sendingEvents > 0) {
          return;
        }
      }
      this.sendingEvents += 2;
      pendingEvents = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = this.pendingEvents;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          event = _ref1[_i];
          _results.push(event);
        }
        return _results;
      }).call(this);
      this.pendingEvents = [];
      timeBetweenEvents = this.timeBetweenEvents;
      this.timeBetweenEvents = 0;
      statUpdates = {
        user: {
          objectType: 'user',
          objectId: this.user.id,
          actions: []
        },
        "class": {
          objectType: 'class',
          objectId: this.classId,
          actions: []
        },
        levelClass: {
          objectType: 'level_class',
          objectId: "" + this.levelId + "/" + this.classId,
          actions: []
        },
        userLevelClass: {
          objectType: 'user_level_class',
          objectId: "" + this.user.id + "/" + this.levelId + "/" + this.classId,
          actions: []
        }
      };
      statUpdates.user.actions.push({
        attribute: 'levelClasses',
        action: 'add',
        value: ["" + this.levelId + "/" + this.classId]
      });
      statUpdates["class"].actions.push({
        attribute: 'users',
        action: 'add',
        value: [this.user.id]
      });
      statUpdates.levelClass.actions.push({
        attribute: 'users',
        action: 'add',
        value: [this.user.id]
      });
      statUpdates.userLevelClass.actions.push({
        attribute: 'duration',
        action: 'add',
        value: timeBetweenEvents
      });
      for (_i = 0, _len = pendingEvents.length; _i < _len; _i++) {
        event = pendingEvents[_i];
        if (event.type === 'move') {
          statUpdates.userLevelClass.actions.push({
            attribute: 'moves',
            action: 'add',
            value: 1
          });
        }
        if (event.type === 'hint') {
          statUpdates.userLevelClass.actions.push({
            attribute: 'hints',
            action: 'add',
            value: 1
          });
        }
        if (event.type === 'success') {
          statUpdates.userLevelClass.actions.push({
            attribute: 'success',
            action: 'add',
            value: [JSON.parse(event.info).time]
          });
        }
        if (event.type === 'challenge') {
          statUpdates.userLevelClass.actions.push({
            attribute: 'challenge',
            action: 'add',
            value: [JSON.parse(event.info).assessment]
          });
        }
      }
      updates = (function() {
        var _results;
        _results = [];
        for (key in statUpdates) {
          _results.push(JSON.stringify(statUpdates[key]));
        }
        return _results;
      })();
      completeEventRecording = function() {
        _this.sendingEvents -= 1;
        if (_this.sendingEvents < 0) {
          _this.sendingEvents = 0;
        }
        return _this.sendEvents();
      };
      $.ajaj({
        url: '/api/events/create',
        method: 'POST',
        headers: {
          'X-CSRF-Token': this.cookies.get('_csrf', {
            raw: true
          })
        },
        data: {
          events: pendingEvents
        },
        success: function() {
          return completeEventRecording();
        }
      });
      return $.ajaj({
        url: '/api/stats/update',
        method: 'POST',
        headers: {
          'X-CSRF-Token': this.cookies.get('_csrf', {
            raw: true
          })
        },
        data: {
          updates: updates
        },
        success: function() {
          return completeEventRecording();
        }
      });
    }
  }
});

soma.routes({
  '/puzzles/xyflyer/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.Xyflyer({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/xyflyer/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.Xyflyer({
      levelId: levelId
    });
  },
  '/puzzles/xyflyer': function() {
    return new soma.chunks.Xyflyer;
  }
});

LEVELS = [
  {}, {
    equations: {
      '2x': {}
    },
    grid: {
      xMin: -10,
      xMax: 10,
      yMin: -10,
      yMax: 10
    },
    rings: [
      {
        x: 1,
        y: 2
      }, {
        x: 3,
        y: 6
      }
    ],
    fragments: ['2x']
  }, {
    equations: {
      '(1/4)x': {}
    },
    grid: {
      xMin: -10,
      xMax: 10,
      yMin: -10,
      yMax: 10
    },
    rings: [
      {
        x: 2,
        y: 0.5
      }, {
        x: 4,
        y: 1
      }, {
        x: 6,
        y: 1.5
      }
    ],
    fragments: ['4x', '(1/4)x']
  }, {
    equations: {
      'x/2': {
        start: 'x'
      }
    },
    grid: {
      xMin: -10,
      xMax: 40,
      yMin: -10,
      yMax: 40
    },
    rings: [
      {
        x: 12,
        y: 6
      }, {
        x: 20,
        y: 10
      }, {
        x: 31,
        y: 15.5
      }
    ],
    fragments: ['*3', '*.25', '/2', '/5']
  }, {
    equations: {
      '2.5x + 3': {
        start: 'ax + 3'
      }
    },
    grid: {
      xMin: -10,
      xMax: 30,
      yMin: -10,
      yMax: 30
    },
    rings: [
      {
        x: 2,
        y: 8
      }, {
        x: 6,
        y: 18
      }, {
        x: 10,
        y: 28
      }
    ],
    islandCoordinates: {
      x: 0,
      y: 3
    },
    variables: {
      a: {
        start: 0,
        min: -10,
        max: 10,
        increment: 0.5,
        solution: 2.5
      }
    }
  }, {
    equations: {
      '-1*x+18': {
        start: 'x'
      }
    },
    grid: {
      xMin: -10,
      xMax: 20,
      yMin: -10,
      yMax: 20
    },
    rings: [
      {
        x: 10,
        y: 8
      }, {
        x: 15,
        y: 3
      }
    ],
    islandCoordinates: {
      x: 4,
      y: 14
    },
    fragments: ['-1*', '-6', '-12', '-18', '+6', '+12', '+18']
  }, {
    equations: {
      'x*6.5': {
        start: 'x'
      }
    },
    grid: {
      xMin: -10,
      xMax: 20,
      yMin: -10,
      yMax: 60
    },
    rings: [
      {
        x: 3,
        y: 19.5
      }, {
        x: 5,
        y: 32.5
      }, {
        x: 9,
        y: 58.5
      }
    ],
    fragments: ['*2', '*2.5', '*3', '*3.5', '*4', '*4.5', '*5', '*5.5', '*6', '*6.5', '*7', '*7.5', '*8', '*8.5', '*9', '*9.5', '*10']
  }, {
    equations: {
      'x/3.5': {
        start: 'x'
      }
    },
    grid: {
      xMin: -10,
      xMax: 30,
      yMin: -10,
      yMax: 30
    },
    rings: [
      {
        x: 19.25,
        y: 5.5
      }, {
        x: 14,
        y: 4
      }, {
        x: 7,
        y: 2
      }
    ],
    fragments: ['*2', '*2.5', '*3', '*3.5', '*4', '*4.5', '*5', '*5.5', '/2', '/2.5', '/3', '/3.5', '/4', '/4.5', '/5', '/5.5']
  }, {
    equations: {
      'x*5/2': {
        start: 'x'
      }
    },
    grid: {
      xMin: -10,
      xMax: 40,
      yMin: -10,
      yMax: 40
    },
    rings: [
      {
        x: 4,
        y: 10
      }, {
        x: 8,
        y: 20
      }, {
        x: 12,
        y: 30
      }
    ],
    fragments: ['*5', '*3', '/2', '/8']
  }, {
    equations: {
      'sin(ax+3.14)+b': {
        solutionComponents: [
          {
            fragment: 'sin(ax)',
            after: ''
          }, {
            fragment: '+3.14',
            after: 'ax'
          }, {
            fragment: '+b',
            after: 'sin(ax+3.14)'
          }
        ]
      }
    },
    grid: {
      xMin: -10,
      xMax: 30,
      yMin: -10,
      yMax: 30
    },
    rings: [
      {
        x: 7.852,
        y: 4
      }, {
        x: 13.087,
        y: 6
      }, {
        x: 18.324,
        y: 4
      }
    ],
    islandCoordinates: {
      x: 0,
      y: 5
    },
    fragments: ['sin(ax)', '+b', '+3.14'],
    variables: {
      a: {
        start: 1,
        min: -10,
        max: 10,
        increment: 0.2,
        solution: -0.6
      },
      b: {
        start: 2,
        min: -10,
        max: 10,
        increment: 1,
        solution: 5
      }
    }
  }, {
    equations: {
      '2x': {},
      '.5x+2': {}
    },
    grid: {
      xMin: -10,
      xMax: 10,
      yMin: -10,
      yMax: 10
    },
    rings: [
      {
        x: .5,
        y: 1
      }, {
        x: 6,
        y: 5
      }
    ],
    fragments: ['2x', '.5x', '+2']
  }, {
    equations: {
      'ln(x+0.14)+2': {
        solutionComponents: [
          {
            fragment: 'ln(x)',
            after: ''
          }, {
            fragment: '+0.14',
            after: 'x'
          }, {
            fragment: '+2',
            after: 'ln(x+0.14)'
          }
        ]
      },
      '-3(x-4)+6': {
        solutionComponents: [
          {
            fragment: '-3(x)',
            after: ''
          }, {
            fragment: '-4',
            after: 'x'
          }, {
            fragment: '+6',
            after: '-3(x-4)'
          }
        ]
      }
    },
    grid: {
      xMin: -10,
      xMax: 10,
      yMin: -10,
      yMax: 10
    },
    rings: [
      {
        x: 4,
        y: 3.41
      }, {
        x: 6.667,
        y: -2
      }
    ],
    fragments: ['ln(x)', '-3(x)', '+0.14', '+2', '-4', '+6']
  }
];

CLASSES = {
  '1': {
    levels: [
      {}, {
        equations: {
          '2x': {}
        },
        grid: {
          xMin: -10,
          xMax: 10,
          yMin: -10,
          yMax: 10
        },
        rings: [
          {
            x: 1,
            y: 2
          }, {
            x: 3,
            y: 6
          }
        ],
        fragments: ['2x']
      }, {
        equations: {
          '2+3x': {}
        },
        grid: {
          xMin: -10,
          xMax: 20,
          yMin: -10,
          yMax: 20
        },
        rings: [
          {
            x: 1,
            y: 5
          }, {
            x: 3,
            y: 11
          }, {
            x: 5,
            y: 17
          }
        ],
        islandCoordinates: {
          x: 0,
          y: 2
        },
        fragments: ['3x', '1+', '2+', '3+']
      }, {
        equations: {
          '2-3x': {}
        },
        grid: {
          xMin: -20,
          xMax: 20,
          yMin: -20,
          yMax: 20
        },
        rings: [
          {
            x: -2,
            y: 8
          }, {
            x: 3,
            y: -7
          }, {
            x: 5,
            y: -13
          }
        ],
        islandCoordinates: {
          x: -5,
          y: 17
        },
        fragments: ['3x', '1+', '1-', '2+', '2-']
      }, {
        equations: {
          '4+0.2x': {
            start: 'x'
          }
        },
        grid: {
          xMin: -10,
          xMax: 10,
          yMin: -6,
          yMax: 10
        },
        rings: [
          {
            x: -1,
            y: 3.8
          }, {
            x: 3,
            y: 4.6
          }, {
            x: 8,
            y: 5.6
          }
        ],
        islandCoordinates: {
          x: -8,
          y: 2.4
        },
        fragments: ['4+', '2+', '0.2', '0.5', '2']
      }, {
        equations: {
          '(3/2)x-4': {
            solutionComponents: [
              {
                fragment: '(3)x',
                after: ''
              }, {
                fragment: '/2',
                after: '3'
              }, {
                fragment: '-4',
                after: '(3/2)x'
              }
            ]
          }
        },
        grid: {
          xMin: -10,
          xMax: 20,
          yMin: -10,
          yMax: 20
        },
        rings: [
          {
            x: 3,
            y: 0.5
          }, {
            x: 8,
            y: 8
          }, {
            x: 12,
            y: 14
          }
        ],
        islandCoordinates: {
          x: -2,
          y: -7
        },
        fragments: ['(3)x', '/2', '/4', '*2', '*4', '-2', '-4']
      }, {
        equations: {
          '-4-(3/a)x': {}
        },
        grid: {
          xMin: -30,
          xMax: 30,
          yMin: -30,
          yMax: 30
        },
        rings: [
          {
            x: -6,
            y: 5
          }, {
            x: 2,
            y: -7
          }, {
            x: 8,
            y: -16
          }
        ],
        islandCoordinates: {
          x: -12,
          y: 14
        },
        fragments: ['-(3/a)x', '-4', '-2', '2', '4'],
        variables: {
          a: {
            start: -10,
            min: -10,
            max: 10,
            increment: 1,
            solution: 2
          }
        }
      }
    ]
  }
};
