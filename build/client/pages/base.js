// Generated by CoffeeScript 1.3.1
var soma, wings,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

soma = require('soma');

wings = require('wings');

soma.View = (function(_super) {

  __extends(View, _super);

  View.name = 'View';

  function View() {
    this.registerHashChange = __bind(this.registerHashChange, this);
    return View.__super__.constructor.apply(this, arguments);
  }

  View.prototype.hashChanges = {};

  View.prototype.registerHashChange = function(hash, callback) {
    return this.hashChanges[hash.replace(/#/, '')] = callback;
  };

  return View;

})(soma.View);

soma.chunks({
  Base: {
    shortMonths: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    prepare: function(_arg) {
      this.content = _arg.content;
      this.loadElement('link', {
        href: '/assets/images/favicon.ico',
        rel: 'shortcut icon',
        type: 'image/x-icon'
      });
      this.loadScript('/build/client/pages/base.js');
      this.loadScript('/build/client/pages/home.js');
      this.loadScript('/build/client/pages/about.js');
      this.loadScript('/build/client/pages/labs.js');
      this.loadStylesheet('/build/client/css/all.css');
      this.template = this.loadTemplate('/build/client/templates/base.html');
      return this.loadChunk(this.content);
    },
    build: function() {
      var data, i, _i, _j, _ref, _results, _results1;
      this.setTitle('The Puzzle School');
      data = {
        content: this.content,
        months: (function() {
          var _i, _results;
          _results = [];
          for (i = _i = 1; _i <= 12; i = ++_i) {
            _results.push({
              label: this.shortMonths[i - 1],
              value: i
            });
          }
          return _results;
        }).call(this),
        days: (function() {
          _results = [];
          for (_i = 1; _i <= 31; _i++){ _results.push(_i); }
          return _results;
        }).apply(this),
        years: (function() {
          _results1 = [];
          for (var _j = _ref = (new Date).getFullYear() - 18; _ref <= 1900 ? _j <= 1900 : _j >= 1900; _ref <= 1900 ? _j++ : _j--){ _results1.push(_j); }
          return _results1;
        }).apply(this)
      };
      return this.html = wings.renderTemplate(this.template, data);
    }
  }
});

soma.views({
  Base: {
    selector: '#base',
    create: function() {
      var _this = this;
      this.logIn();
      $(window).bind('hashchange', function() {
        return _this.onhashchange();
      });
      this.registerHashChange('register', function() {
        return _this.register();
      });
      this.$('.register a').bind('click', function() {
        return location.hash = 'register';
      });
      this.$('.close_modal').bind('click', function(e) {
        return _this.hideModal(e.currentTarget);
      });
      this.$('log_out').bind('click', function() {
        return _this.logOut();
      });
      return this.onhashchange();
    },
    onhashchange: function() {
      var callback;
      if ((callback = this.hashChanges[location.hash.replace(/#/, '')])) {
        return callback();
      }
    },
    formData: function(form) {
      var data, field, fields, name, val, _i, _len, _ref;
      data = {};
      fields = $('input, select', form);
      for (_i = 0, _len = fields.length; _i < _len; _i++) {
        field = fields[_i];
        if (((_ref = field.type) !== 'radio' && _ref !== 'checkbox') || field.checked) {
          val = $(field).val();
          if (field.name.slice(-2) === '[]') {
            name = field.name.slice(0, -2);
            if (!(name in data)) {
              data[name] = [];
            }
            data[name].push(val);
          } else {
            data[field.name] = val;
          }
        }
      }
      return data;
    },
    register: function() {
      var registrationForm,
        _this = this;
      registrationForm = this.$('.registration_form');
      registrationForm.css({
        top: 120,
        left: ($(document.body).width() - registrationForm.width()) / 2
      });
      registrationForm.animate({
        opacity: 1,
        duration: 500
      });
      this.$('.registration_form').bind('click', function(e) {
        return e.stopPropagation();
      });
      $(window).bind('click', function() {
        return _this.hideModal('.registration_form');
      });
      this.$('.registration_form .cancel_button').bind('click', function() {
        return _this.hideModal('.registration_form');
      });
      return this.$('.registration_form .register_button').bind('click', function() {
        var form;
        form = _this.$('.registration_form form');
        return $.ajax({
          url: '/api/register',
          method: 'POST',
          data: _this.formData(form),
          success: function() {
            _this.hideModal(form);
            return _this.logIn();
          }
        });
      });
    },
    logOut: function() {
      this.el.removeClass('logged_in');
      this.el.addClass('logged_out');
      this.$('.user_name').html('');
      return this.cookies.set('user', null);
    },
    logIn: function() {
      if ((this.user = this.cookies.get('user')) == null) {
        return;
      }
      this.el.removeClass('logged_out');
      this.el.addClass('logged_in');
      return this.$('.user_name').html(this.user.name);
    },
    hideModal: function(selector) {
      var modal,
        _this = this;
      $(window).unbind('click');
      modal = selector instanceof String ? this.$(selector) : $(selector);
      if (!modal.hasClass('modal')) {
        modal = modal.closest('.modal');
      }
      return modal.animate({
        opacity: 0,
        duration: 500,
        complete: function() {
          return modal.css({
            top: -1000,
            left: -1000
          });
        }
      });
    }
  }
});
