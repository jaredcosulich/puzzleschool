// Generated by CoffeeScript 1.3.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

(function($) {
  var views;
  views = require('views');
  return views.Main = (function(_super) {

    __extends(Main, _super);

    Main.name = 'Main';

    function Main() {
      return Main.__super__.constructor.apply(this, arguments);
    }

    Main.prototype.prepare = function() {
      return this.template = this._requireTemplate('views/html/main.html');
    };

    Main.prototype.renderView = function() {
      return this.el.html(this.template.render());
    };

    return Main;

  })(views.BaseView);
})(ender);
