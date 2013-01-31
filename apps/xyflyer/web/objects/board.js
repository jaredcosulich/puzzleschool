// Generated by CoffeeScript 1.3.3
var board, xyflyerObject,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

board = typeof exports !== "undefined" && exports !== null ? exports : provide('./board', {});

xyflyerObject = require('./object');

board.Board = (function(_super) {

  __extends(Board, _super);

  Board.prototype.maxUnits = 10;

  function Board(_arg) {
    var boardElement;
    boardElement = _arg.boardElement, this.grid = _arg.grid, this.objects = _arg.objects, this.islandCoordinates = _arg.islandCoordinates, this.resetLevel = _arg.resetLevel;
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
    this.init(boardElement);
  }

  Board.prototype.init = function(boardElement) {
    var dimensions, maxDimension;
    dimensions = boardElement.offset();
    this.paper = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height);
    this.width = dimensions.width;
    this.height = dimensions.height;
    this.xUnit = this.width / (this.grid.xMax - this.grid.xMin);
    this.yUnit = this.height / (this.grid.yMax - this.grid.yMin);
    this.xAxis = this.width - (this.grid.xMax * this.xUnit);
    this.yAxis = this.height + (this.grid.yMin * this.yUnit);
    maxDimension = Math.max(this.grid.xMax - this.grid.xMin, this.grid.yMax - this.grid.yMin);
    this.scale = 1 / (Math.log(Math.sqrt(maxDimension)) - 0.5);
    this.addIsland();
    this.drawGrid();
    return this.initClicks(boardElement);
  };

  Board.prototype.addImage = function(image, x, y) {
    var height, width;
    width = image.width() * this.scale;
    height = image.height() * this.scale;
    return this.paper.image(image.attr('src'), x, y, width, height);
  };

  Board.prototype.addIsland = function() {
    var height, island, text, width, x, y,
      _this = this;
    island = this.objects.find('.island img');
    width = island.width() * this.scale;
    height = island.height() * this.scale;
    if (!width || !height) {
      $.timeout(100, function() {
        return _this.addIsland();
      });
      return;
    }
    x = this.xAxis + (this.islandCoordinates.x * this.xUnit) - (width / 2);
    y = this.yAxis - (this.islandCoordinates.y * this.yUnit);
    this.island = this.paper.set();
    this.island.push(this.addImage(island, x, y));
    text = this.islandText();
    this.islandLabel = this.paper.text(x + (width / 2) - (15 * this.scale), y + (height / 2) - (15 * this.scale), text).attr({
      fill: '#ddd',
      stroke: 'none',
      'font-size': 9 + (2 * this.scale)
    }).toFront();
    return this.island.push(this.islandLabel);
  };

  Board.prototype.islandText = function() {
    return "" + (this.scale > 0.6 ? 'Launching From:\n' : '') + this.islandCoordinates.x + ", " + this.islandCoordinates.y;
  };

  Board.prototype.addRing = function(ring) {
    var back, front, ringSet;
    front = this.paper.path(ring.frontDescription);
    front.toFront();
    back = this.paper.path(ring.backDescription);
    back.toBack();
    ringSet = this.paper.set();
    ringSet.push(front, back);
    this.ringFronts.push(front);
    this.rings.push(ringSet);
    return ringSet;
  };

  Board.prototype.setRingFronts = function() {
    var ringFront, _i, _len, _ref, _results;
    _ref = this.ringFronts;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      ringFront = _ref[_i];
      _results.push(ringFront.toFront());
    }
    return _results;
  };

  Board.prototype.addPlane = function(plane) {
    var planeImage;
    this.plane = plane;
    planeImage = this.paper.path(this.plane.description);
    planeImage.transform("s" + this.scale + "," + this.scale);
    return planeImage;
  };

  Board.prototype.initClicks = function(boardElement) {
    var _this = this;
    boardElement.css({
      zIndex: 97
    });
    return boardElement.bind('click.showxy', function(e) {
      var formula1, onPath, result, y;
      result = _this.findNearestXOnPath(e.offsetX, e.offsetY);
      onPath = result.x;
      if (result.formulas.length) {
        formula1 = result.formulas[0];
        y = _this.screenY(formula1.formula(_this.paperX(result.x)));
        return _this.showXY(result.x, y, true);
      } else {
        return _this.showXY(e.offsetX, e.offsetY);
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
    var color, grid, gridString, increment, mark, multiple, start, text, xUnits, yUnits, _i, _j, _ref;
    gridString = "M" + this.xAxis + ",0\nL" + this.xAxis + "," + this.height + "\nM0," + this.yAxis + "\nL" + this.width + "," + this.yAxis;
    color = 'rgba(255,255,255,0.4)';
    xUnits = this.width / this.xUnit;
    if (xUnits < this.maxUnits) {
      xUnits = this.maxUnits;
    }
    multiple = Math.floor(xUnits / this.maxUnits);
    increment = this.xUnit * multiple;
    start = 0 - (multiple > this.grid.xMin ? (this.grid.xMin * this.xUnit) % increment : increment % (this.grid.xMin * this.xUnit));
    for (mark = _i = start, _ref = this.width; start <= _ref ? _i <= _ref : _i >= _ref; mark = _i += increment) {
      gridString += "M" + mark + "," + (this.yAxis + 10);
      gridString += "L" + mark + "," + (this.yAxis - 10);
      if (!(mark > this.width)) {
        text = this.paper.text(mark + 6, this.yAxis - 6, Math.round(this.grid.xMin + (mark / this.xUnit)));
        text.attr({
          stroke: 'none',
          fill: color
        });
      }
    }
    yUnits = this.height / this.yUnit;
    if (yUnits < this.maxUnits) {
      yUnits = this.maxUnits;
    }
    multiple = Math.floor(yUnits / this.maxUnits);
    increment = (this.yUnit * multiple) * -1;
    start = this.height - (multiple > this.grid.yMin ? increment % (this.grid.yMin * this.yUnit) : (this.grid.yMin * this.yUnit) % increment);
    for (mark = _j = start; start <= 0 ? _j <= 0 : _j >= 0; mark = _j += increment) {
      gridString += "M" + (this.xAxis + 10) + "," + mark;
      gridString += "L" + (this.xAxis - 10) + "," + mark;
      if (!(mark > this.height)) {
        text = this.paper.text(this.xAxis + 6, mark - 6, Math.round(this.grid.yMax - (mark / this.yUnit)));
        text.attr({
          stroke: 'none',
          fill: color
        });
      }
    }
    grid = this.paper.path(gridString);
    return grid.attr({
      stroke: color
    });
  };

  Board.prototype.plot = function(id, formula, area) {
    var brokenLine, infiniteLine, lastSlope, lastYPos, line, pathString, slope, xPos, yPos, _i, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
    if (!formula || !formula.length) {
      if ((_ref = this.formulas[id]) != null) {
        if ((_ref1 = _ref.line) != null) {
          _ref1.remove();
        }
      }
      delete this.formulas[id];
      return;
    }
    brokenLine = 0;
    infiniteLine = 0;
    pathString = "M0," + this.height;
    for (xPos = _i = _ref2 = this.grid.xMin * this.xUnit, _ref3 = this.grid.xMax * this.xUnit; _ref2 <= _ref3 ? _i <= _ref3 : _i >= _ref3; xPos = _ref2 <= _ref3 ? ++_i : --_i) {
      lastYPos = yPos;
      yPos = formula(xPos / this.xUnit) * this.yUnit;
      if (isNaN(yPos)) {
        continue;
      }
      if (yPos === Number.NEGATIVE_INFINITY) {
        yPos = this.grid.yMin * this.xUnit;
        brokenLine += 1;
      } else if (yPos === Number.POSITIVE_INFINITY) {
        yPos = this.grid.yMax * this.xUnit;
        brokenLine += 1;
      }
      if (lastYPos) {
        lastSlope = slope;
        slope = yPos - lastYPos;
        if (lastSlope && Math.abs(lastSlope - slope) > Math.abs(lastSlope) && Math.abs(lastYPos - yPos) > Math.abs(lastYPos)) {
          pathString += "L" + (xPos + this.xAxis + 1) + "," + (lastSlope > 0 ? 0 : this.height);
          pathString += "M" + (xPos + this.xAxis + 1) + "," + (lastSlope > 0 ? this.height : 0);
          brokenLine += 1;
        }
      }
      if (brokenLine > 0) {
        pathString += "M" + (xPos + this.xAxis) + "," + (this.yAxis - yPos);
        brokenLine -= 1;
      } else {
        pathString += "L" + (xPos + this.xAxis) + "," + (this.yAxis - yPos);
      }
    }
    if (pathString.indexOf('L') === -1) {
      if ((_ref4 = this.formulas[id]) != null) {
        if ((_ref5 = _ref4.line) != null) {
          _ref5.remove();
        }
      }
      delete this.formulas[id];
    } else {
      if (this.formulas[id]) {
        this.formulas[id].line.attr({
          path: pathString
        });
      } else {
        line = this.paper.path(pathString);
        line.attr({
          stroke: 'rgba(0,0,0,0.1)',
          'stroke-width': 2
        });
        this.formulas[id] = {
          id: id,
          line: line
        };
      }
      this.formulas[id].area = area;
      this.formulas[id].formula = formula;
    }
    this.resetLevel();
    return this.setRingFronts();
  };

  Board.prototype.calculatePath = function(increment) {
    var id, intersection, intersectionY, lastFormula, lf, otherYPos, path, prevYPos, validPathFound, xPos, y, yPos, _i, _ref, _ref1;
    intersection = (this.islandCoordinates.x * this.xUnit) + (this.xUnit * 0.001);
    path = {};
    path[this.islandCoordinates.x * this.xUnit] = {
      y: this.islandCoordinates.y * this.yUnit
    };
    for (xPos = _i = _ref = this.islandCoordinates.x * this.xUnit, _ref1 = (this.grid.xMax * 1.1) * this.xUnit; _i <= _ref1; xPos = _i += 1) {
      xPos = Math.round(xPos);
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
            if ((yPos - otherYPos <= 0 && prevYPos - otherYPos > 0) || (yPos - otherYPos >= 0 && prevYPos - otherYPos < 0)) {
              yPos = otherYPos;
              lastFormula = this.formulas[id];
              break;
            }
          }
          path[xPos] = {
            formula: lastFormula.id,
            y: yPos
          };
          continue;
        } else {
          intersection = xPos - 1;
          lf = lastFormula;
          lastFormula = null;
          while (lf.area(intersection / this.xUnit)) {
            path[intersection] = {
              formula: lf.id,
              y: lf.formula(intersection / this.xUnit) * this.yUnit
            };
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
          if (Math.abs(path[intersection].y - intersectionY) / this.yUnit > 0.05) {
            continue;
          }
        }
        y = this.formulas[id].formula(xPos / this.xUnit) * this.yUnit;
        if (isNaN(y)) {
          continue;
        }
        validPathFound = true;
        path[xPos] = {
          formula: id,
          y: y
        };
        lastFormula = this.formulas[id];
        break;
      }
      if (!validPathFound) {
        return path;
      }
    }
    return path;
  };

  return Board;

})(xyflyerObject.Object);