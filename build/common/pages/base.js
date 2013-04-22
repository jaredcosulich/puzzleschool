// Generated by CoffeeScript 1.3.3
var soma, wings,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

soma = require('soma');

wings = require('wings');

soma.View = (function(_super) {

  __extends(View, _super);

  function View() {
    this.registerHashChange = __bind(this.registerHashChange, this);
    return View.__super__.constructor.apply(this, arguments);
  }

  View.prototype.hashChanges = {};

  View.prototype.registerHashChange = function(hash, callback) {
    return this.hashChanges[hash.replace(/#/, '')] = callback;
  };

  View.prototype.showRegistrationFlag = function() {
    var paddingTop, registrationFlag;
    registrationFlag = $('.register_flag');
    paddingTop = registrationFlag.css('paddingTop');
    $.timeout(1000, function() {
      return registrationFlag.animate({
        paddingTop: 45,
        paddingBottom: 45,
        duration: 1000,
        complete: function() {
          var _this = this;
          return $.timeout(1000, function() {
            return registrationFlag.animate({
              paddingTop: paddingTop,
              paddingBottom: paddingTop,
              duration: 1000
            });
          });
        }
      });
    });
    return window.onbeforeunload = function() {
      return 'If you leave this page you\'ll lose your progress.\n\nYou can save your progress by creating an account.';
    };
  };

  View.prototype.showModal = function(selector) {
    var modal,
      _this = this;
    this.opaqueScreen = $('.opaque_screen');
    this.opaqueScreen.css({
      opacity: 0,
      top: 0,
      left: 0,
      width: window.innerWidth,
      height: window.innerHeight + $('#top_nav').height()
    });
    this.opaqueScreen.animate({
      opacity: 0.75,
      duration: 300
    });
    modal = this.$(selector);
    modal.css({
      top: 120,
      left: ($(document.body).width() - modal.width()) / 2
    });
    modal.animate({
      opacity: 1,
      duration: 500
    });
    modal.bind('click', function(e) {
      return e.stop();
    });
    return $(this.opaqueScreen).bind('click', function() {
      return _this.hideModal(selector);
    });
  };

  View.prototype.hideModal = function(selector, callback) {
    var modal,
      _this = this;
    if (!this.opaqueScreen) {
      return;
    }
    $(this.opaqueScreen).unbind('click');
    modal = selector instanceof String ? this.$(selector) : $(selector);
    if (!modal.hasClass('modal')) {
      modal = modal.closest('.modal');
    }
    this.opaqueScreen.animate({
      opacity: 0,
      duration: 500,
      complete: function() {
        return _this.opaqueScreen.css({
          top: -1000,
          left: -100
        });
      }
    });
    return modal.animate({
      opacity: 0,
      duration: 500,
      complete: function() {
        modal.css({
          top: -1000,
          left: -1000
        });
        location.hash = '';
        if (callback) {
          return callback();
        }
      }
    });
  };

  return View;

})(soma.View);

soma.chunks({
  Base: {
    shortMonths: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    prepare: function(_arg) {
      this.content = _arg.content;
      this.setIcon('/assets/images/favicon.ico');
      this.loadElement('link', {
        href: '/assets/images/favicon.ico',
        rel: 'shortcut icon',
        type: 'image/x-icon'
      });
      if (this.badBrowser()) {
        this.template = this.loadTemplate('/build/common/templates/bad_browser.html');
      } else {
        this.setMeta('apple-mobile-web-app-capable', 'yes');
        this.setMeta('apple-mobile-web-app-status-bar-style', 'black');
        this.loadScript('/assets/third_party/rollbar.js');
        this.loadElement("link", {
          rel: 'apple-touch-icon',
          sizes: '57x57',
          href: '/assets/images/touch-icon-iphone.png'
        });
        this.loadElement("link", {
          rel: 'apple-touch-icon',
          sizes: '72x72',
          href: '/assets/images/touch-icon-ipad.png'
        });
        this.loadElement("link", {
          rel: 'apple-touch-icon',
          sizes: '114x114',
          href: '/assets/images/touch-icon-iphone4.png'
        });
        this.loadElement("link", {
          rel: 'apple-touch-startup-image',
          sizes: '1024x748',
          href: '/assets/images/startup1024x748.png'
        });
        this.loadElement("link", {
          rel: 'apple-touch-startup-image',
          sizes: '768x1004',
          href: '/assets/images/startup768x1004.png'
        });
        this.loadElement("link", {
          rel: 'apple-touch-startup-image',
          sizes: '320x460',
          href: '/assets/images/startup320x460.png'
        });
        this.loadStylesheet('/build/client/css/all.css');
        this.loadScript('/build/client/pages/form.js');
        this.loadScript('/build/common/pages/base.js');
        this.loadScript('/assets/analytics.js');
        this.template = this.loadTemplate('/build/common/templates/base.html');
      }
      return this.loadChunk(this.content);
    },
    badBrowser: function() {
      var userAgent, _ref, _ref1;
      userAgent = ((_ref = this.context) != null ? (_ref1 = _ref.request) != null ? _ref1.headers : void 0 : void 0) ? this.context.request.headers['user-agent'] : typeof navigator !== "undefined" && navigator !== null ? navigator.userAgent : void 0;
      if ((userAgent || '').indexOf('MSIE') > -1) {
        return true;
      }
      return false;
    },
    build: function() {
      var data, i, _i, _j, _ref, _results, _results1;
      data = {
        loggedIn: this.cookies.get('user') != null,
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
          for (var _j = _ref = (new Date).getFullYear() - 1; _ref <= 1900 ? _j <= 1900 : _j >= 1900; _ref <= 1900 ? _j++ : _j--){ _results1.push(_j); }
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
      if (!window.initialized) {
        window.initialized = true;
        window.postRegistration = [];
        window.onhashchange = function() {
          return _this.onhashchange();
        };
        if (navigator.userAgent.match(/iP/i)) {
          $(window).bind('resize orientationChanged', function() {
            return $('#top_nav .content').width($.viewport().width);
          });
        }
        if ($.viewport().width < $('#top_nav .content').width()) {
          $(window).trigger('resize');
        }
      }
      this.checkLoggedIn();
      this.$('.log_out').bind('click', function() {
        return _this.logOut();
      });
      this.registerHashChange('register', function() {
        return _this.showRegistration();
      });
      this.$('.register').bind('click', function() {
        return location.hash = 'register';
      });
      this.registerHashChange('login', function() {
        return _this.showLogIn();
      });
      this.$('.log_in').bind('click', function() {
        return location.hash = 'login';
      });
      return this.$('.close_modal').bind('click', function(e) {
        return _this.hideModal(e.currentTarget);
      });
    },
    complete: function() {
      return this.onhashchange();
    },
    onhashchange: function() {
      var callback;
      if ((callback = this.hashChanges[location.hash.replace(/#/, '')])) {
        return callback();
      }
    },
    showRegistration: function() {
      var submitForm,
        _this = this;
      this.showModal('.registration_form');
      this.$('.registration_form .cancel_button').bind('click', function() {
        return _this.hideModal('.registration_form');
      });
      this.$('.registration_form .toggle_login').bind('click', function() {
        return _this.hideModal('.registration_form', function() {
          return location.hash = 'login';
        });
      });
      submitForm = function() {
        var form;
        form = _this.$('.registration_form form');
        return $.ajaj({
          url: '/api/register',
          method: 'POST',
          headers: {
            'X-CSRF-Token': _this.cookies.get('_csrf', {
              raw: true
            })
          },
          data: form.data('form').dataHash(),
          success: function() {
            var go, postRegistrationMethod, _i, _len, _ref, _results;
            _this.$('.registration_form .submit_feedback').data('form-button').success();
            _this.hideModal(form);
            if (window.postRegistration.length) {
              _ref = window.postRegistration;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                postRegistrationMethod = _ref[_i];
                _results.push(postRegistrationMethod(function() {
                  return _this.checkLoggedIn();
                }));
              }
              return _results;
            } else {
              _this.checkLoggedIn();
              if ((go = _this.cookies.get('returnTo'))) {
                _this.cookies.set('returnTo', null);
                return window.location = go;
              }
            }
          },
          error: function() {
            return _this.$('.registration_form .submit_feedback').data('form-button').error();
          }
        });
      };
      this.$('.registration_form input').bind('keypress', function(e) {
        if (e.keyCode === 13) {
          return submitForm();
        }
      });
      return this.$('.registration_form .register_button').bind('click', function() {
        return submitForm();
      });
    },
    showLogIn: function() {
      var loginButton,
        _this = this;
      this.showModal('.login_form');
      this.$('.login_form .cancel_button').bind('click', function() {
        return _this.hideModal('.login_form');
      });
      this.$('.login_form .toggle_registration').bind('click', function() {
        return _this.hideModal('.login_form', function() {
          return location.hash = 'register';
        });
      });
      loginButton = this.$('.login_form .login_button');
      loginButton.bind('click', function() {
        var form;
        form = _this.$('.login_form form');
        return $.ajaj({
          url: '/api/login',
          method: 'POST',
          data: form.data('form').dataHash(),
          headers: {
            'X-CSRF-Token': _this.cookies.get('_csrf', {
              raw: true
            })
          },
          success: function() {
            var go;
            _this.hideModal(form);
            _this.checkLoggedIn();
            if ((go = _this.cookies.get('returnTo'))) {
              _this.cookies.set('returnTo', null);
              return window.location = go;
            }
          },
          error: function() {
            return _this.$('.login_form .login_button').data('form-button').error();
          }
        });
      });
      return this.$('.login_form input').bind('keypress', function(e) {
        if (e.keyCode === 13) {
          return loginButton.trigger('click');
        }
      });
    },
    logOut: function() {
      var _this = this;
      this.cookies.set('user', null);
      return this.$('.logged_in').animate({
        opacity: 0,
        duration: 500,
        complete: function() {
          _this.$('.logged_out').css({
            opacity: 0
          });
          _this.el.removeClass('logged_in');
          _this.el.addClass('logged_out');
          _this.$('.user_name').html('');
          _this.$('.logged_in').css({
            opacity: 1
          });
          return _this.$('.logged_out').animate({
            opacity: 1,
            duration: 500,
            complete: function() {
              return _this.go(location.pathname, true);
            }
          });
        }
      });
    },
    checkLoggedIn: function() {
      var pageTracker;
      if ((this.user = this.cookies.get('user')) == null) {
        return;
      }
      if (this.el.hasClass('logged_out')) {
        this.go(location.pathname, true);
      }
      this.$('.user_name').html(this.user.name);
      try {
        pageTracker = _gat._getTracker("UA-15570848-11");
        pageTracker._trackPageview();
        pageTracker._setVar(this.user.email || this.user.id);
      } catch (e) {

      }
      return window.onbeforeunload = null;
    }
  }
});
