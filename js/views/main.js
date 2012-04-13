var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
(function($) {
  var views;
  views = require('views');
  return views.Main = (function() {
    __extends(Main, views.BaseView);
    function Main() {
      Main.__super__.constructor.apply(this, arguments);
    }
    Main.prototype.prepare = function() {
      return this.template = this._requireTemplate('templates/main.html');
    };
    Main.prototype.renderView = function() {
      var data, navItems;
      navItems = [
        {
          label: 'game',
          icon: 'butterfly'
        }, {
          label: 'browse',
          icon: 'look'
        }, {
          label: 'matches',
          icon: 'star'
        }, {
          label: 'mail',
          icon: 'mail'
        }, {
          label: 'profile',
          icon: 'profile'
        }
      ];
      data = {
        navItems: navItems
      };
      return this.el.html(this.template.render(data));
    };
    return Main;
  })();
})(ender);