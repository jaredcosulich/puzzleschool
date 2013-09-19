// Generated by CoffeeScript 1.3.3
var circuitousObject, selector,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

selector = typeof exports !== "undefined" && exports !== null ? exports : provide('./selector', {});

circuitousObject = require('./object');

selector.ITEM_TYPES = ['Battery', 'Resistor', 'Lightbulb'];

selector.Selector = (function(_super) {

  __extends(Selector, _super);

  function Selector(_arg) {
    var selectorHtml;
    this.container = _arg.container, this.add = _arg.add, this.button = _arg.button, selectorHtml = _arg.selectorHtml;
    selectorHtml || (selectorHtml = '<h2>Select An Item</h2>\n<p>Click an item below to add it to the list.</p>');
    this.init(selectorHtml);
  }

  Selector.prototype.init = function(selectorHtml) {
    this.construct(selectorHtml);
    return this.initButton();
  };

  Selector.prototype.construct = function(selectorHtml) {
    var column, columns, item, itemRow, itemTable, row, _fn, _i, _j, _ref,
      _this = this;
    this.dialog = $(document.createElement('DIV'));
    this.dialog.addClass('selector_dialog');
    this.dialog.html(selectorHtml);
    this.dialog.bind('mousedown.do_not_close click.do_not_close mouseup.do_not_close', function(e) {
      return e.stop();
    });
    itemTable = $(document.createElement('TABLE'));
    itemTable.addClass('items');
    columns = Math.ceil(Math.sqrt(selector.ITEM_TYPES.length));
    for (row = _i = 0, _ref = Math.ceil(selector.ITEM_TYPES.length / columns); 0 <= _ref ? _i < _ref : _i > _ref; row = 0 <= _ref ? ++_i : --_i) {
      itemRow = $(document.createElement('TR'));
      _fn = function(item) {
        var itemCell, itemObject;
        itemObject = new circuitous[item.replace(/\s/g, '')]({});
        itemCell = $(document.createElement('TD'));
        itemCell.addClass('item');
        itemCell.width("" + (100 / columns) + "%");
        itemCell.html("" + (itemObject.imageElement()) + "\n<div>" + item + "</div>");
        itemCell.bind('click', function() {
          _this.add(new circuitous[item.replace(/\s/g, '')]({}));
          return _this.hide();
        });
        return itemRow.append(itemCell);
      };
      for (column = _j = 0; 0 <= columns ? _j < columns : _j > columns; column = 0 <= columns ? ++_j : --_j) {
        item = selector.ITEM_TYPES[row * columns + column];
        if (!item) {
          continue;
        }
        _fn(item);
      }
      itemTable.append(itemRow);
    }
    this.dialog.append(itemTable);
    return this.container.append(this.dialog);
  };

  Selector.prototype.overallContainer = function() {
    return this.button.closest('.circuitous');
  };

  Selector.prototype.itemFileName = function(item) {
    return item.toLowerCase().replace(/\s/g, '_');
  };

  Selector.prototype.initButton = function() {
    var _this = this;
    this.button.bind('click.toggle_selector', function() {
      return _this.toggleDialog();
    });
    return this.containerOffset = this.container.offset();
  };

  Selector.prototype.toggleDialog = function() {
    if (parseInt(this.dialog.css('opacity')) > 0) {
      return this.hide();
    } else {
      return this.show();
    }
  };

  Selector.prototype.hide = function() {
    var _this = this;
    $(document.body).unbind('mouseup.hide_selector');
    return this.dialog.animate({
      opacity: 0,
      duration: 250,
      complete: function() {
        return _this.dialog.css({
          top: -10000,
          left: -10000
        });
      }
    });
  };

  Selector.prototype.show = function() {
    var _this = this;
    this.dialog.css({
      top: (this.containerOffset.height - this.dialog.height()) / 2,
      left: (this.containerOffset.width - this.dialog.width()) / 2
    });
    this.dialog.animate({
      opacity: 1,
      duration: 250
    });
    return $.timeout(100, function() {
      return $(document.body).one('mouseup.hide_selector', function() {
        return _this.hide();
      });
    });
  };

  return Selector;

})(circuitousObject.Object);
