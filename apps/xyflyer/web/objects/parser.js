// Generated by CoffeeScript 1.3.3
var parser, tdop;

parser = typeof exports !== "undefined" && exports !== null ? exports : provide('./parser', {});

tdop = require('./tdop');

parser.parse = function(data) {
  var area, formula, parts;
  try {
    parts = data.replace(/\s/g, '').split(/[{}]/);
    formula = tdop.compileToJs(parts[0]);
    area = parser.calculateArea(parts[1]);
  } catch (err) {

  }
  return [formula, area];
};

parser.calculateArea = function(areaString) {
  var parts;
  if (!areaString || !areaString.length) {
    return (function() {
      return true;
    });
  }
  parts = areaString.replace(/[^=0-9.<>xy-]/g, '').split(/x/);
  return function(x) {
    if (!eval(parts[0] + 'x')) {
      return false;
    }
    if (!eval('x' + parts[1])) {
      return false;
    }
    return true;
  };
};
