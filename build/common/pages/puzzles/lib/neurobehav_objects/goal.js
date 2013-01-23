// Generated by CoffeeScript 1.3.3
var goal;

goal = typeof exports !== "undefined" && exports !== null ? exports : provide('./goal', {});

goal.Goal = (function() {

  Goal.prototype.periodicity = 20;

  Goal.prototype.offset = 90;

  function Goal(_arg) {
    this.paper = _arg.paper, this.radius = _arg.radius, this.interaction = _arg.interaction, this.test = _arg.test, this.html = _arg.html, this.onSuccess = _arg.onSuccess;
    this.init();
  }

  Goal.prototype.init = function() {
    var _this = this;
    this.draw();
    setInterval((function() {
      _this.interact(_this.interaction());
      if (_this.test()) {
        return _this.success();
      }
    }), this.periodicity);
    this.initWorm();
    return this.initMessage();
  };

  Goal.prototype.draw = function() {
    this.image = this.paper.set();
    this.center = {
      x: (this.paper.width - this.offset) / 2,
      y: this.paper.height / 2
    };
    this.circle = this.paper.circle(this.center.x, this.center.y, this.radius);
    this.circle.attr({
      fill: 'white'
    });
    this.image.push(this.circle);
    this.littleCircle = this.paper.circle(this.center.x + this.radius + this.offset, this.center.y, 3);
    this.littleCircle.attr({
      fill: 'white'
    });
    this.image.push(this.littleCircle);
    this.lineFrom(60);
    this.lineFrom(120);
    return this.image.toBack();
  };

  Goal.prototype.lineFrom = function(angle) {
    var distance, line, startX, startY, units, yUnit;
    yUnit = 1 / (Math.tan(angle * Math.PI / 180));
    distance = Math.sqrt(Math.pow(yUnit, 2) + 1);
    units = this.radius / distance;
    startX = this.center.x + units;
    startY = this.center.y + (units * yUnit);
    line = this.paper.path("M" + startX + "," + startY + "\nL" + (this.center.x + this.radius + this.offset) + "," + this.center.y);
    return this.image.push(line);
  };

  Goal.prototype.initWorm = function() {
    var startX, wormWidth;
    wormWidth = 90;
    startX = this.center.x + this.radius + this.offset - (wormWidth / 2);
    this.wormPath = "M" + startX + "," + this.center.y + "\nc12,-8 18,-12 " + (wormWidth / 3) + ",3\nc6,6 12,12 " + (wormWidth / 6) + ",0\nc6,-16 18,-16 " + (wormWidth / 3) + ",-3\nc4,2 6,3 " + (wormWidth / 6) + ",3";
    this.animatedPath = "M" + startX + "," + this.center.y + "\nc12,6 18,4 " + (wormWidth / 3) + ",-1\nc6,-2 12,-1 " + (wormWidth / 6) + ",1\nc6,4 18,6 " + (wormWidth / 3) + ",1\nc4,-2 6,-3 " + (wormWidth / 6) + ",-2";
    this.worm = this.paper.path(this.wormPath);
    this.worm.attr({
      'stroke-width': 8,
      'stroke-linecap': 'round',
      stroke: '#411B17'
    });
    return this.worm.toBack();
  };

  Goal.prototype.initMessage = function() {
    var background, bbox, glow, height, text, width, x, y,
      _this = this;
    width = 60;
    height = 18;
    x = this.center.x + this.radius + this.offset - (width / 2);
    y = this.center.y - (height * 2);
    this.icon = this.paper.set();
    background = this.paper.rect(x, y, width, height, 6);
    background.attr({
      fill: 'black'
    });
    glow = background.glow({
      width: 10,
      fill: true,
      color: 'red'
    });
    glow.attr({
      opacity: 0
    });
    this.icon.push(glow);
    this.icon.push(background);
    text = this.paper.text(x + (width / 2), y + (height / 2), 'The Goal');
    text.attr({
      fill: 'white',
      stroke: 'none'
    });
    this.icon.push(text);
    this.icon.attr({
      cursor: 'pointer'
    });
    this.icon.hover(function() {
      return glow.attr({
        opacity: 0.04
      });
    }, function() {
      return glow.attr({
        opacity: 0
      });
    });
    bbox = this.icon.getBBox();
    this.goalBubble = new Bubble({
      paper: this.paper,
      x: bbox.x,
      y: bbox.y + (bbox.height / 2),
      width: 400,
      height: 400,
      arrowOffset: 180,
      position: 'left',
      html: this.html
    });
    return this.icon.click(function() {
      if (_this.goalBubble.visible) {
        return _this.goalBubble.hide();
      } else {
        return _this.goalBubble.show();
      }
    });
  };

  Goal.prototype.display = function() {
    return this.goalBubble.show();
  };

  Goal.prototype.interact = function(interaction) {
    var path,
      _this = this;
    if (this.animating || this.interactionState === interaction) {
      return;
    }
    this.animating = true;
    this.interactionState = interaction;
    path = interaction ? this.animatedPath : this.wormPath;
    return this.worm.animate({
      path: path
    }, 300, 'ease-out', function() {
      return _this.animating = false;
    });
  };

  Goal.prototype.success = function() {
    var _this = this;
    if (this.successAchieved) {
      return;
    }
    if (this.animating) {
      setTimeout((function() {
        return _this.success();
      }), 100);
      return;
    }
    this.successAchieved = true;
    if (this.onSuccess) {
      return this.onSuccess(this.goalBubble);
    }
  };

  return Goal;

})();
