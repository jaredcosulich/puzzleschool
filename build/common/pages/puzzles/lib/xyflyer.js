// Generated by CoffeeScript 1.3.3
var xyflyer;

xyflyer = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/xyflyer', {});

xyflyer.ChunkHelper = (function() {

  function ChunkHelper() {}

  return ChunkHelper;

})();

xyflyer.ViewHelper = (function() {

  ViewHelper.prototype.baseFolder = '/assets/images/puzzles/xyflyer/';

  ViewHelper.prototype.maxUnits = 10;

  ViewHelper.prototype.increment = 5;

  ViewHelper.prototype.planeWidth = 50;

  ViewHelper.prototype.planeHeight = 30;

  ViewHelper.prototype.formulas = {};

  function ViewHelper(_arg) {
    var boardElement;
    this.el = _arg.el, boardElement = _arg.boardElement, this.objects = _arg.objects, this.grid = _arg.grid;
    this.initBoard(boardElement);
  }

  ViewHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  ViewHelper.prototype.addImage = function(image, x, y) {
    var height, width;
    width = image.width() * this.scale;
    height = image.height() * this.scale;
    return this.board.image(image.attr('src'), x, y, width, height);
  };

  ViewHelper.prototype.addIsland = function() {
    var height, island, width,
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
    this.addImage(island, this.xAxis - (width / 2), this.yAxis);
    return this.movePlane(this.xAxis, this.yAxis);
  };

  ViewHelper.prototype.initBoard = function(boardElement) {
    var dimensions, maxDimension;
    dimensions = boardElement.offset();
    this.board = Raphael(dimensions.left, dimensions.top, dimensions.width, dimensions.height);
    this.width = dimensions.width;
    this.height = dimensions.height;
    this.xUnit = this.width / (this.grid.xMax - this.grid.xMin);
    this.yUnit = this.height / (this.grid.yMax - this.grid.yMin);
    this.xAxis = this.width - (this.grid.xMax * this.xUnit);
    this.yAxis = this.height + (this.grid.yMin * this.yUnit);
    maxDimension = Math.max(this.grid.xMax - this.grid.xMin, this.grid.yMax - this.grid.yMin);
    this.scale = 1 / (Math.log(Math.sqrt(maxDimension)) - 0.5);
    this.addIsland();
    return this.drawGrid();
  };

  ViewHelper.prototype.drawGrid = function() {
    var grid, gridString, increment, mark, multiple, start, stroke, text, xUnits, yUnits, _i, _j, _ref;
    gridString = "M" + this.xAxis + ",0\nL" + this.xAxis + "," + this.height + "\nM0," + this.yAxis + "\nL" + this.width + "," + this.yAxis;
    stroke = 'rgba(255,255,255,0.4)';
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
        text = this.board.text(mark + 6, this.yAxis - 6, Math.round(this.grid.xMin + (mark / this.xUnit)));
        text.attr({
          stroke: stroke,
          fill: stroke
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
        text = this.board.text(this.xAxis + 6, mark - 6, Math.round(this.grid.yMax - (mark / this.yUnit)));
        text.attr({
          stroke: stroke,
          fill: stroke
        });
      }
    }
    grid = this.board.path(gridString);
    return grid.attr({
      stroke: stroke
    });
  };

  ViewHelper.prototype.movePlane = function(x, y, time, next) {
    var h, planePath, scale, transformation, w;
    scale = 0.6;
    transformation = "t" + (x - (this.planeWidth / 2)) + "," + (y - (this.planeHeight / 2)) + "s-" + scale + "," + scale;
    if (!this.plane) {
      planePath = 'm45.80125,3.33402c0.61292,0.46928 1.05152,2.94397 1.0285,5.25969c-0.02302,2.31571 0.88025,4.64063 1.80347,4.95859c1.07606,0.47389 -1.08528,0.4524 -4.94019,-0.04909c-4.62682,-0.50918 -7.87342,-0.07825 -9.7398,1.29276c-2.7988,1.97934 -2.64902,2.44402 2.56464,6.04694c10.58017,7.36176 4.70142,8.53851 -7.58,1.46862c-4.45249,-2.51458 -11.06171,-5.51379 -14.75765,-6.4769c-7.85194,-2.23958 -13.64944,-0.88678 -13.51925,-2.07142c1.88137,-3.08462 5.38157,-1.90437 6.92488,-4.45687c1.87412,-1.08561 1.3257,-1.69121 -1.17471,-4.04786c-2.5984,-2.65056 0.64206,-2.46396 6.1737,0.21575c6.14608,2.99462 26.3761,2.57809 28.87842,-0.63936c2.0361,-2.9133 2.80954,-3.06 4.338,-1.50085z';
      this.plane = this.board.path(planePath);
      this.plane.attr({
        fill: '#000'
      });
      return this.plane.transform(transformation);
    } else {
      w = this.plane.attr('width');
      h = this.plane.attr('height');
      return this.plane.animate({
        transform: transformation
      }, time, 'linear', next);
    }
  };

  ViewHelper.prototype.launchPlane = function() {
    var dX, dY, time, yPos,
      _this = this;
    if (!this.path || !Object.keys(this.path).length) {
      this.calculatePlanePath();
    }
    this.planeXPos = (this.planeXPos || 0) + this.increment;
    yPos = this.path[this.planeXPos];
    if (yPos === void 0 || this.planeXPos > (this.grid.xMax * this.xUnit)) {
      $.timeout(1000, function() {
        return _this.resetPlane();
      });
      return;
    }
    dX = this.increment;
    dY = yPos - this.path[this.planeXPos - this.increment];
    time = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2)) * this.increment;
    return this.movePlane(this.planeXPos + this.xAxis, this.yAxis - yPos, time, function() {
      return _this.launchPlane();
    });
  };

  ViewHelper.prototype.calculatePlanePath = function() {
    var id, lastFormula, xPos, _i, _ref, _ref1, _ref2, _results;
    this.path = {};
    _results = [];
    for (xPos = _i = _ref = this.grid.xMin * this.xUnit, _ref1 = this.grid.xMax * this.xUnit, _ref2 = this.increment; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; xPos = _i += _ref2) {
      if (lastFormula && lastFormula.area(xPos / this.xUnit)) {
        this.path[xPos] = lastFormula.formula(xPos / this.xUnit) * this.yUnit;
        continue;
      }
      _results.push((function() {
        var _results1;
        _results1 = [];
        for (id in this.formulas) {
          if (!this.formulas[id].area(xPos / this.xUnit)) {
            continue;
          }
          this.path[xPos] = this.formulas[id].formula(xPos / this.xUnit) * this.yUnit;
          lastFormula = this.formulas[id];
          break;
        }
        return _results1;
      }).call(this));
    }
    return _results;
  };

  ViewHelper.prototype.resetPlane = function() {
    this.path = null;
    this.planeXPos = null;
    return this.movePlane(this.xAxis, this.yAxis);
  };

  ViewHelper.prototype.plot = function(id, formula, area) {
    var brokenLine, infiniteLine, lastSlope, lastYPos, line, pathString, slope, xPos, yPos, _i, _ref, _ref1;
    if (!formula) {
      return;
    }
    if (this.formulas[id]) {
      this.formulas[id].line.remove();
    }
    this.formulas[id] = {
      formula: formula,
      area: area
    };
    this.activeFormula = this.formulas[id];
    brokenLine = 0;
    infiniteLine = 0;
    pathString = "M0," + this.height;
    for (xPos = _i = _ref = this.grid.xMin * this.xUnit, _ref1 = this.grid.xMax * this.xUnit; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; xPos = _ref <= _ref1 ? ++_i : --_i) {
      lastYPos = yPos;
      yPos = formula(xPos / this.xUnit) * this.yUnit;
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
    line = this.board.path(pathString);
    line.attr({
      stroke: 'rgba(0,0,0,0.1)',
      'stroke-width': 2
    });
    this.formulas[id].line = line;
    return this.resetPlane();
  };

  return ViewHelper;

})();
