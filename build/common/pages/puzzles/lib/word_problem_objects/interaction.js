// Generated by CoffeeScript 1.3.3
var interaction;

interaction = typeof exports !== "undefined" && exports !== null ? exports : provide('./interaction', {});

interaction.Interaction = (function() {

  function Interaction(_arg) {
    this.container = _arg.container;
    this.numbers = [];
    this.init();
  }

  Interaction.prototype.init = function() {
    this.el = $(document.createElement('DIV'));
    this.el.addClass('interaction');
    this.label = $(document.createElement('DIV'));
    this.label.addClass('label');
    this.el.append(this.label);
    this.visual = $(document.createElement('DIV'));
    this.visual.addClass('visual');
    this.el.append(this.visual);
    return this.container.append(this.el);
  };

  Interaction.prototype.over = function(x, y, highlight) {
    var offset, over;
    offset = this.el.offset();
    over = x > offset.left && x < offset.left + offset.width && y > offset.top && y < offset.top + offset.height;
    if (highlight && over) {
      this.el.addClass('highlight');
    } else {
      this.el.removeClass('highlight');
    }
    return over;
  };

  Interaction.prototype.accept = function(_arg) {
    var number, operator;
    number = _arg.number, operator = _arg.operator;
    if (number) {
      this.numbers.push(number);
    } else if (operator) {
      this.operators.push(operator);
    }
    return this.display();
  };

  Interaction.prototype.display = function() {
    this.label.html('');
    this.visual.html('');
    if (this.numbers.length === 1) {
      this.showNumber();
    } else {
      this.showAddition();
    }
    return this.centerLabel();
  };

  Interaction.prototype.centerLabel = function() {
    return this.label.css({
      marginLeft: (this.el.width() - this.label.width()) / 2
    });
  };

  Interaction.prototype.showNumber = function() {
    var i, number, _i, _ref, _results;
    number = this.numbers[0];
    this.label.append(this.createReference(number, true));
    _results = [];
    for (i = _i = 1, _ref = number.value; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      _results.push(this.addIcon(number.colorIndex));
    }
    return _results;
  };

  Interaction.prototype.createReference = function(number, showLabel) {
    var container;
    container = $(document.createElement('DIV'));
    container.addClass('container');
    container.addClass("color_" + number.colorIndex);
    container.html("<div class='reference'>\n    " + number.value + "\n    " + (showLabel && number.label ? ' ' + number.label : '') + "\n</div>");
    return container;
  };

  Interaction.prototype.createOperator = function(type) {
    var container;
    container = $(document.createElement('DIV'));
    container.addClass('container');
    container.html("<div class='operator'>" + type + "</div>");
    return container;
  };

  Interaction.prototype.addIcon = function(colorIndex) {
    return this.visual.append("<i class='icon-circle color_" + colorIndex + "'></i>");
  };

  Interaction.prototype.showAddition = function() {
    var i, _i, _j, _ref, _ref1;
    for (i = _i = 1, _ref = this.numbers[0].value; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      this.addIcon(this.numbers[0].colorIndex);
    }
    this.visual.append('<div>+</div>');
    for (i = _j = 1, _ref1 = this.numbers[1].value; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 1 <= _ref1 ? ++_j : --_j) {
      this.addIcon(this.numbers[1].colorIndex);
    }
    this.label.append(this.createReference(this.numbers[0]));
    this.label.append(this.createOperator('+'));
    return this.label.append(this.createReference(this.numbers[1]));
  };

  return Interaction;

})();
