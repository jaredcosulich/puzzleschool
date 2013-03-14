// Generated by CoffeeScript 1.3.3

window.app = {
  initialize: function() {
    var xyflyer,
      _this = this;
    if (!(this.width = window.innerWidth || window.landwidth) || !(this.height = window.innerHeight || window.landheight) || this.width < this.height) {
      $.timeout(100, function() {
        return window.app.initialize();
      });
      return;
    }
    document.addEventListener('touchmove', (function(e) {
      return e.preventDefault();
    }), false);
    xyflyer = require('./lib/xyflyer');
    this.el = $('.xyflyer');
    this.el.bind('touchstart', function(e) {
      if (e.preventDefault) {
        return e.preventDefault();
      }
    });
    this.originalHtml = this.el.html();
    this.levelId = 1;
    return this.load();
  },
  $: function(selector) {
    return $(selector, this.el);
  },
  load: function() {
    var _this = this;
    this.el.html(this.originalHtml);
    this.data = LEVELS[this.levelId];
    if (!this.data) {
      this.showMessage('exit');
      return;
    }
    this.helper = new xyflyer.ViewHelper({
      el: $(this.selector),
      boardElement: this.$('.board'),
      objects: this.$('.objects'),
      equationArea: this.$('.equation_area'),
      grid: this.data.grid,
      islandCoordinates: this.data.islandCoordinates,
      nextLevel: function() {
        return _this.nextLevel();
      }
    });
    return this.loadLevel();
  },
  loadLevel: function() {
    var equation, fragment, info, ring, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _results;
    _ref1 = ((_ref = this.data) != null ? _ref.equations : void 0) || {
      '': {}
    };
    for (equation in _ref1) {
      info = _ref1[equation];
      this.helper.addEquation(equation, info.start, info.solutionComponents, (_ref2 = this.data) != null ? _ref2.variables : void 0);
    }
    _ref4 = ((_ref3 = this.data) != null ? _ref3.rings : void 0) || [];
    for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
      ring = _ref4[_i];
      this.helper.addRing(ring.x, ring.y);
    }
    if ((_ref5 = this.data) != null ? _ref5.fragments : void 0) {
      _ref6 = this.data.fragments;
      _results = [];
      for (_j = 0, _len1 = _ref6.length; _j < _len1; _j++) {
        fragment = _ref6[_j];
        _results.push(this.helper.addEquationComponent(fragment));
      }
      return _results;
    } else if (this.levelId !== 'editor') {
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
    var equationArea, path,
      _this = this;
    equationArea = this.$('.equation_area');
    equationArea.html(this.$("." + type + "_message").html());
    equationArea.css({
      padding: '0 12px',
      textAlign: 'center'
    });
    path = '/puzzles/xyflyer/1';
    if (this.isIos()) {
      return equationArea.find('.button').attr('href', path);
    } else {
      return equationArea.find('.button').bind('click', function() {
        return _this.go(path);
      });
    }
  },
  nextLevel: function() {
    var complete,
      _this = this;
    complete = this.$('.complete');
    this.centerAndShow(complete);
    this.$('.launch').unbind('mousedown.launch touchstart.launch');
    this.$('.launch').html('Success! Go To The Next Level >');
    return this.$('.go').one('touchstart.go', function() {
      _this.levelId += 1;
      return _this.load();
    });
  }
};
