// Generated by CoffeeScript 1.3.3
var Animation, board, xyflyerObject,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

board = typeof exports !== "undefined" && exports !== null ? exports : provide('./board', {});

xyflyerObject = require('./object');

Animation = require('./animation').Animation;

board.Board = (function(_super) {

  __extends(Board, _super);

  Board.prototype.maxUnits = 10;

  function Board(_arg) {
    this.el = _arg.el, this.grid = _arg.grid, this.objects = _arg.objects, this.islandCoordinates = _arg.islandCoordinates, this.resetLevel = _arg.resetLevel;
    this.offsetY = __bind(this.offsetY, this);

    this.offsetX = __bind(this.offsetX, this);

    this.init({
      el: this.el,
      grid: this.grid,
      objects: this.objects,
      islandCoordinates: this.islandCoordinates
    });
    this.load();
  }

  Board.prototype.init = function(_arg) {
    this.el = _arg.el, this.grid = _arg.grid, this.objects = _arg.objects, this.islandCoordinates = _arg.islandCoordinates;
    this.islandCoordinates || (this.islandCoordinates = {});
    if (!this.islandCoordinates.x) {
      this.islandCoordinates.x = 0;
    }
    if (!this.islandCoordinates.y) {
      this.islandCoordinates.y = 0;
    }
    this.formulas = {};
    this.rings = [];
    this.ringFronts = [];
    this.clear();
    return this.load();
  };

  Board.prototype.load = function() {
    var dimensions, maxDimension, ratio;
    dimensions = this.el.offset();
    if (!this.paper) {
      this.paper = Raphael(this.el.attr('id'), dimensions.width, dimensions.height);
    }
    this.width = dimensions.width;
    this.height = dimensions.height;
    if ((this.grid.xMax - this.grid.xMin) === (this.grid.yMax - this.grid.yMin)) {
      if (this.width !== this.height) {
        ratio = this.width / this.height;
        if (ratio > 1) {
          this.grid.xMax = Math.floor(this.grid.xMax * ratio);
          this.grid.xMin = Math.ceil(this.grid.xMin * ratio);
        } else {
          this.grid.yMax = Math.floor(this.grid.yMax / ratio);
          this.grid.yMin = Math.ceil(this.grid.yMin / ratio);
        }
      }
    }
    this.xUnit = this.width / (this.grid.xMax - this.grid.xMin);
    this.yUnit = this.height / (this.grid.yMax - this.grid.yMin);
    this.xAxis = this.width - (this.grid.xMax * this.xUnit);
    this.yAxis = this.height + (this.grid.yMin * this.yUnit);
    maxDimension = Math.max(this.grid.xMax - this.grid.xMin, this.grid.yMax - this.grid.yMin);
    this.scale = 1 / (Math.log(Math.sqrt(maxDimension)) - 0.5);
    this.addIsland();
    this.drawGrid();
    this.initClicks();
    return this.initAnimation();
  };

  Board.prototype.initAnimation = function() {
    if (this.animationCtx) {
      return;
    }
    this.animationCtx = [this.createCanvas(1), this.createCanvas(3)];
    this.animationObjects = [];
    if (!this.animation) {
      this.animation = new Animation();
      return this.animate();
    }
  };

  Board.prototype.addRing = function(ring) {
    return this.rings.push(ring);
  };

  Board.prototype.addToCanvas = function(object, zIndex) {
    var _base;
    (_base = this.animationObjects)[zIndex] || (_base[zIndex] = []);
    return this.animationObjects[zIndex].push(object);
  };

  Board.prototype.animate = function() {
    var _this = this;
    return this.animation.frame()(function(t) {
      var animationSet, ctx, i, object, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
      _ref = _this.animationCtx;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ctx = _ref[_i];
        ctx.clearRect(0, 0, _this.width, _this.height);
      }
      _ref1 = _this.animationObjects;
      for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
        animationSet = _ref1[i];
        if (!animationSet) {
          continue;
        }
        for (_k = 0, _len2 = animationSet.length; _k < _len2; _k++) {
          object = animationSet[_k];
          ctx = i <= 2 ? _this.animationCtx[0] : _this.animationCtx[1];
          object.draw(ctx, t);
        }
      }
      return _this.animate();
    });
  };

  Board.prototype.createCanvas = function(zIndex) {
    var canvas;
    canvas = $(document.createElement('CANVAS'));
    canvas.css({
      top: 0,
      left: 0,
      height: this.el.height(),
      width: this.el.width(),
      zIndex: zIndex
    });
    canvas.attr({
      height: this.el.height(),
      width: this.el.width()
    });
    this.el.append(canvas);
    return canvas[0].getContext('2d');
  };

  Board.prototype.addImage = function(image, x, y) {
    var height, width;
    width = image.width() * this.scale;
    height = image.height() * this.scale;
    return this.paper.image(image.attr('src'), x, y, width, height);
  };

  Board.prototype.addIsland = function() {
    var island, islandHeight, islandWidth, islandX, islandY, person, personHeight, personWidth, personX, personY, planeX, planeY, text,
      _this = this;
    person = this.objects.find('.person img');
    personWidth = person.width() * this.scale;
    personHeight = person.height() * this.scale;
    island = this.objects.find('.island img');
    islandWidth = island.width() * this.scale;
    islandHeight = island.height() * this.scale;
    if (!personWidth || !personHeight || !islandWidth || !islandHeight) {
      $.timeout(100, function() {
        return _this.addIsland();
      });
      return;
    }
    if (this.island) {
      this.island.remove();
    }
    this.island = this.paper.set();
    planeX = this.xAxis + (this.islandCoordinates.x * this.xUnit);
    planeY = this.yAxis - (this.islandCoordinates.y * this.yUnit);
    personX = planeX - personWidth + (15 * this.scale);
    personY = planeY - (17 * this.scale);
    islandX = planeX - (islandWidth / 2) - (personWidth / 4);
    islandY = planeY + personHeight + islandHeight - (576 * this.scale);
    this.island.push(this.addImage(island, islandX, islandY));
    this.island.push(this.addImage(person, personX, personY));
    text = this.islandText();
    this.islandLabel = this.paper.text(islandX + (islandWidth / 2) - (12 * this.scale), islandY + islandHeight - (57 * this.scale), text).attr({
      fill: '#ddd',
      stroke: 'none',
      'font-size': 9 + (2 * this.scale)
    }).toFront();
    return this.island.push(this.islandLabel);
  };

  Board.prototype.islandText = function() {
    return "" + (this.scale > 0.6 ? 'Launching From:\n' : '') + this.islandCoordinates.x + ", " + this.islandCoordinates.y;
  };

  Board.prototype.offsetX = function(e) {
    var _ref, _ref1, _ref2, _ref3;
    return (e.pageX ? e.pageX : ((_ref = e.targetTouches) != null ? (_ref1 = _ref[0]) != null ? _ref1.pageX : void 0 : void 0) || ((_ref2 = e.touches) != null ? (_ref3 = _ref2[0]) != null ? _ref3.pageX : void 0 : void 0)) - this.el.offset().left;
  };

  Board.prototype.offsetY = function(e) {
    var _ref, _ref1, _ref2, _ref3;
    return (e.pageY ? e.pageY : ((_ref = e.targetTouches) != null ? (_ref1 = _ref[0]) != null ? _ref1.pageY : void 0 : void 0) || ((_ref2 = e.touches) != null ? (_ref3 = _ref2[0]) != null ? _ref3.pageY : void 0 : void 0)) - this.el.offset().top;
  };

  Board.prototype.initClicks = function() {
    var _this = this;
    this.el.css({
      zIndex: 97
    });
    return this.el.bind('mousedown.showxy touchstart.showxy', function(e) {
      var formula1, onPath, result, y;
      if (_this.clickHandled) {
        return;
      }
      _this.clickHandled = true;
      $.timeout(500, function() {
        return _this.clickHandled = false;
      });
      result = _this.findNearestXOnPath(_this.offsetX(e), _this.offsetY(e));
      onPath = result.x;
      if (result.formulas.length) {
        formula1 = result.formulas[0];
        y = _this.screenY(formula1.formula(_this.paperX(result.x)));
        return _this.showXY(result.x, y, true);
      } else {
        return _this.showXY(_this.offsetX(e), _this.offsetY(e));
      }
    });
  };

  Board.prototype.findNearestXOnPath = function(x, y, formulas, precision) {
    var avgDistance, d, distance, distance2Y, distanceY, distances, dx, factor, formula, formula2, formula2Y, formulaY, goodFormulas, id, index, index2, intersectionDistance, result, side, _i, _j, _k, _l, _len, _len1, _len2, _ref, _ref1;
    if (formulas == null) {
      formulas = this.formulas;
    }
    if (precision == null) {
      precision = 0;
    }
    distances = {};
    factor = Math.pow(10, precision);
    distance = 0.5 / factor;
    result = {
      formulas: [],
      distance: distance * factor,
      x: x
    };
    for (d = _i = 0, _ref = distance / 10; 0 <= distance ? _i <= distance : _i >= distance; d = _i += _ref) {
      _ref1 = [-1, 1];
      for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
        side = _ref1[_j];
        if (side === -1 && !d) {
          continue;
        }
        dx = side * d;
        goodFormulas = [];
        for (id in formulas) {
          formula = formulas[id];
          formulaY = formula.formula(this.paperX(x) + dx);
          distanceY = Math.abs(this.paperY(y) - formulaY);
          if (distanceY <= (distance * factor)) {
            goodFormulas.push(formula);
            if (!result.intersectionDistance && distanceY < result.distance) {
              result.distance = distanceY;
              result.x = this.screenX(this.paperX(x) + dx);
              result.formulas = [formula];
            }
          }
        }
        intersectionDistance = -1;
        for (index = _k = 0, _len1 = goodFormulas.length; _k < _len1; index = ++_k) {
          formula = goodFormulas[index];
          formulaY = formula.formula(this.paperX(x) + dx);
          index2 = 0;
          avgDistance = -1;
          for (_l = 0, _len2 = goodFormulas.length; _l < _len2; _l++) {
            formula2 = goodFormulas[_l];
            if (formula === formula2) {
              continue;
            }
            formula2Y = formula2.formula(this.paperX(x) + dx);
            distance2Y = Math.abs(formulaY - formula2Y);
            avgDistance = ((avgDistance * index2) + distance2Y) / (index2 + 1);
            index2 += 1;
          }
          intersectionDistance = ((intersectionDistance * index) + avgDistance) / (index + 1);
        }
        if (-1 < intersectionDistance && (!result.intersectionDistance || result.intersectionDistance > intersectionDistance)) {
          result.intersectionDistance = intersectionDistance;
          result.x = this.screenX(this.paperX(x) + dx);
          result.formulas = goodFormulas;
        }
      }
    }
    if (precision < 4) {
      result.x = this.findNearestXOnPath(result.x, y, formulas, precision + 1).x;
    }
    return result;
  };

  Board.prototype.paperX = function(x, precision) {
    if (precision == null) {
      precision = 3;
    }
    return Math.round(Math.pow(10, precision) * (x - this.xAxis) / this.xUnit) / Math.pow(10, precision);
  };

  Board.prototype.paperY = function(y, precision) {
    if (precision == null) {
      precision = 3;
    }
    return Math.round(Math.pow(10, precision) * (this.yAxis - y) / this.yUnit) / Math.pow(10, precision);
  };

  Board.prototype.screenX = function(x) {
    return (x * this.xUnit) + this.xAxis;
  };

  Board.prototype.screenY = function(y) {
    return this.yAxis - (y * this.yUnit);
  };

  Board.prototype.showXY = function(x, y, onPath, permanent) {
    var dot, height, opacity, paperX, paperY, radius, string, text, width, xy, xyTip,
      _this = this;
    if (onPath == null) {
      onPath = false;
    }
    if (permanent == null) {
      permanent = false;
    }
    paperX = this.paperX(x);
    paperY = this.paperY(y);
    string = "" + paperX + ", " + paperY;
    width = (string.length * 6) + 2;
    height = 18;
    radius = 3;
    if (!permanent) {
      dot = this.paper.circle(x, y, 0);
      dot.attr({
        opacity: 0
      });
      dot.animate({
        r: radius,
        opacity: 1
      }, 100);
    }
    xyTip = this.paper.rect(x + (width / 2) + (radius * 2), y, 0, 0, 6);
    xyTip.attr({
      fill: '#FFF',
      opacity: 0
    });
    text = this.paper.text(x + (width / 2) + (radius * 2), y, string);
    text.attr({
      fill: '#000',
      stroke: 'none',
      opacity: 0
    });
    xyTip.animate({
      width: width,
      height: height,
      x: x + (radius * 2),
      y: y - (height / 2)
    }, 100);
    opacity = (permanent ? 0.75 : 1);
    xyTip.animate({
      opacity: opacity
    }, 250);
    text.animate({
      opacity: opacity
    }, 250);
    xy = this.paper.set();
    xy.push(xyTip, text, dot);
    if (!permanent) {
      $.timeout(2000, function() {
        var removeTip;
        xyTip.animate({
          opacity: 0
        }, 100);
        text.animate({
          opacity: 0
        }, 100);
        removeTip = function() {
          return xy.remove();
        };
        xyTip.animate({
          width: 0,
          height: 0,
          x: x + (radius * 2),
          y: y
        }, 250);
        return dot.animate({
          r: 0,
          opacity: 0
        }, 250, null, removeTip);
      });
    }
    return xy;
  };

  Board.prototype.drawGrid = function() {
    var color, direction, grid, gridString, increment, label, lastMark, mark, multiple, offset, text, value, xUnits, yUnits, _i, _j, _k, _l, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
    if (this.gridSet) {
      return;
    }
    this.gridSet = true;
    gridString = "M" + this.xAxis + ",0\nL" + this.xAxis + "," + this.height + "\nM0," + this.yAxis + "\nL" + this.width + "," + this.yAxis;
    color = 'rgba(255,255,255,0.5)';
    xUnits = this.width / this.xUnit;
    if (xUnits < this.maxUnits) {
      xUnits = this.maxUnits;
    }
    multiple = Math.floor(xUnits / this.maxUnits);
    increment = this.xUnit * multiple;
    _ref = [-1, 1];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      direction = _ref[_i];
      lastMark = this.xAxis;
      for (mark = _j = _ref1 = this.xAxis, _ref2 = this.xAxis + (this.width * direction), _ref3 = increment * direction; _ref1 <= _ref2 ? _j <= _ref2 : _j >= _ref2; mark = _j += _ref3) {
        gridString += "M" + mark + "," + (this.yAxis + 10);
        gridString += "L" + mark + "," + (this.yAxis - 10);
        if ((0 <= mark && mark <= this.width)) {
          value = Math.round(this.grid.xMin + (mark / this.xUnit));
          offset = value < 0 ? 8 : -8;
          text = this.paper.text(mark + offset, this.yAxis - 6, value);
          text.attr({
            stroke: 'none',
            fill: color
          });
          lastMark = mark;
        }
      }
      label = this.paper.text(lastMark - (24 * direction), this.yAxis + 7, 'X Axis');
      label.attr({
        stroke: 'none',
        fill: color
      });
    }
    yUnits = this.height / this.yUnit;
    if (yUnits < this.maxUnits) {
      yUnits = this.maxUnits;
    }
    multiple = Math.floor(yUnits / this.maxUnits);
    increment = this.yUnit * multiple;
    _ref4 = [-1, 1];
    for (_k = 0, _len1 = _ref4.length; _k < _len1; _k++) {
      direction = _ref4[_k];
      lastMark = this.yAxis;
      for (mark = _l = _ref5 = this.yAxis, _ref6 = this.yAxis + (this.height * direction), _ref7 = increment * direction; _ref5 <= _ref6 ? _l <= _ref6 : _l >= _ref6; mark = _l += _ref7) {
        gridString += "M" + (this.xAxis + 10) + "," + mark;
        gridString += "L" + (this.xAxis - 10) + "," + mark;
        if ((0 <= mark && mark <= this.height)) {
          value = Math.round(this.grid.yMax - (mark / this.yUnit));
          offset = value > 0 ? 6 : -6;
          text = this.paper.text(this.xAxis - 8, mark + offset, value);
          text.attr({
            stroke: 'none',
            fill: color
          });
          lastMark = mark;
        }
      }
      label = this.paper.text(this.xAxis + 7, lastMark - (24 * direction), 'Y Axis');
      label.attr({
        stroke: 'none',
        fill: color,
        transform: 'r270'
      });
    }
    grid = this.paper.path(gridString);
    return grid.attr({
      stroke: color
    });
  };

  Board.prototype.plot = function(id, formula, area) {
    var brokenLine, i, infiniteLine, lastSlope, lastYPos, newYPos, plotArea, slope, testYPos, xPos, yPos, _i, _j, _ref, _ref1, _ref2;
    if ((plotArea = (_ref = this.formulas[id]) != null ? _ref.plotArea : void 0)) {
      plotArea.clearRect(0, 0, this.width, this.height);
    }
    if (!formula) {
      return;
    }
    if (!plotArea) {
      plotArea = this.createCanvas(2);
    }
    plotArea.strokeStyle = 'rgba(0,0,0,0.25)';
    plotArea.lineWidth = 1;
    plotArea.beginPath();
    brokenLine = 0;
    infiniteLine = 0;
    for (xPos = _i = _ref1 = this.grid.xMin * this.xUnit, _ref2 = this.grid.xMax * this.xUnit; _ref1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; xPos = _i += 0.1) {
      lastYPos = yPos;
      lastSlope = slope;
      yPos = formula(xPos / this.xUnit) * this.yUnit;
      if (isNaN(yPos)) {
        continue;
      }
      if (yPos === Number.NEGATIVE_INFINITY) {
        plotArea.lineTo(xPos + this.xAxis, this.height);
        yPos = this.grid.yMin * this.yUnit;
        brokenLine += 1;
      } else if (yPos === Number.POSITIVE_INFINITY) {
        plotArea.lineTo(xPos + this.xAxis, 0);
        yPos = this.grid.yMax * this.yUnit;
        brokenLine += 1;
      }
      if (lastYPos) {
        slope = yPos - lastYPos;
        if (lastSlope && ((lastSlope > 0 && slope < 0) || (lastSlope < 0 && slope > 0))) {
          for (i = _j = -1; _j <= 0; i = _j += 0.001) {
            testYPos = formula((xPos + i) / this.xUnit) * this.yUnit;
            if ((yPos > this.height && testYPos < 0) || (yPos < 0 && testYPos > this.height)) {
              newYPos = (testYPos < 0 ? 0 : this.height);
              plotArea.moveTo(xPos + this.xAxis + i, newYPos);
              slope = yPos - (this.yAxis - newYPos);
              break;
            }
          }
        }
      }
      if (brokenLine > 0) {
        plotArea.moveTo(xPos + this.xAxis, this.yAxis - yPos);
        brokenLine -= 1;
      } else {
        plotArea.lineTo(xPos + this.xAxis, this.yAxis - yPos);
      }
    }
    plotArea.stroke();
    plotArea.closePath();
    this.formulas[id] = {
      id: id,
      area: area,
      formula: formula,
      plotArea: plotArea
    };
    return this.resetLevel();
  };

  Board.prototype.calculatePath = function() {
    var addToPath, id, intersection, intersectionY, lastFormula, lf, otherPrevYPos, otherYPos, path, prevYPos, rings, validPathFound, xPos, y, yPos, _i, _ref, _ref1,
      _this = this;
    intersection = (this.islandCoordinates.x * this.xUnit) + (this.xUnit * 0.001);
    path = {
      distance: 0
    };
    path[0] = {
      x: this.islandCoordinates.x * this.xUnit,
      y: this.islandCoordinates.y * this.yUnit
    };
    rings = this.rings.sort(function(a, b) {
      return a.x - b.x;
    });
    addToPath = function(x, y, formula) {
      var d, distance, formattedDistance, formattedFullDistance, incrementalX, prevPos, ring, significantDigits, _i, _j, _len, _ref;
      if (!((_this.grid.yMin - 50 <= (_ref = y / _this.yUnit) && _ref <= _this.grid.yMax + 50))) {
        return;
      }
      significantDigits = 1;
      formattedFullDistance = Math.ceil(path.distance * Math.pow(10, significantDigits));
      prevPos = path[formattedFullDistance];
      if (prevPos.x === x && prevPos.y === y) {
        return;
      }
      if (((y / _this.yUnit) < _this.grid.yMin) || ((y / _this.yUnit) > _this.grid.yMax)) {
        distance = 1;
      } else {
        distance = Math.sqrt(Math.pow(prevPos.y - y, 2) + Math.pow(prevPos.x - x, 2));
      }
      formattedDistance = Math.ceil(distance * Math.pow(10, significantDigits));
      for (d = _i = 1; 1 <= formattedDistance ? _i <= formattedDistance : _i >= formattedDistance; d = 1 <= formattedDistance ? ++_i : --_i) {
        incrementalX = prevPos.x + (d * ((x - prevPos.x) / formattedDistance));
        path[formattedFullDistance + d] = {
          formula: formula.id,
          x: incrementalX,
          y: formula.formula(incrementalX / _this.xUnit) * _this.yUnit
        };
        for (_j = 0, _len = rings.length; _j < _len; _j++) {
          ring = rings[_j];
          if (ring.inPath(incrementalX / _this.xUnit, formula.formula)) {
            path[formattedFullDistance + d].ring = ring;
          }
        }
      }
      return path.distance += distance;
    };
    for (xPos = _i = _ref = this.islandCoordinates.x * this.xUnit, _ref1 = (this.grid.xMax * 1.1) * this.xUnit; _i <= _ref1; xPos = _i += 1) {
      if (lastFormula) {
        if (lastFormula.area(xPos / this.xUnit)) {
          yPos = lastFormula.formula(xPos / this.xUnit) * this.yUnit;
          for (id in this.formulas) {
            if (!(id !== lastFormula.id)) {
              continue;
            }
            if (!this.formulas[id].area(xPos / this.xUnit)) {
              continue;
            }
            otherYPos = this.formulas[id].formula(xPos / this.xUnit) * this.yUnit;
            prevYPos = lastFormula.formula((xPos - 1) / this.xUnit) * this.yUnit;
            otherPrevYPos = this.formulas[id].formula((xPos - 1) / this.xUnit) * this.yUnit;
            if ((yPos - otherYPos <= 0 && prevYPos - otherPrevYPos > 0) || (yPos - otherYPos >= 0 && prevYPos - otherPrevYPos < 0)) {
              yPos = otherYPos;
              lastFormula = this.formulas[id];
              break;
            }
          }
          addToPath(xPos, yPos, lastFormula);
          continue;
        } else {
          intersection = xPos - 1;
          lf = lastFormula;
          lastFormula = null;
          while (lf.area(intersection / this.xUnit)) {
            intersectionY = lf.formula(intersection / this.xUnit) * this.yUnit;
            addToPath(intersection, intersectionY, lf);
            intersection += this.xUnit * 0.001;
          }
        }
      }
      if (intersection) {
        intersection -= this.xUnit * 0.001;
      }
      validPathFound = false;
      for (id in this.formulas) {
        if (!this.formulas[id].area(xPos / this.xUnit)) {
          continue;
        }
        if (intersection != null) {
          intersectionY = this.formulas[id].formula(intersection / this.xUnit) * this.yUnit;
          if (Math.abs(path[Math.floor(path.distance)].y - intersectionY) / this.yUnit > 0.05) {
            continue;
          }
        }
        y = this.formulas[id].formula(xPos / this.xUnit) * this.yUnit;
        if (isNaN(y)) {
          continue;
        }
        validPathFound = true;
        lastFormula = this.formulas[id];
        addToPath(xPos, y, lastFormula);
        break;
      }
      if (!validPathFound) {
        return path;
      }
    }
    return path;
  };

  Board.prototype.clear = function() {
    if (this.paper) {
      this.paper.remove();
      delete this.paper;
    }
    this.el.find('canvas').remove();
    delete this.animationCtx;
    return delete this.gridSet;
  };

  return Board;

})(xyflyerObject.Object);
