// Generated by CoffeeScript 1.3.3
var Line, bcrypt, checkPassword, crypto, db, email, registrationTemplate, requireUser, soma, wings, _ref;

bcrypt = require('bcrypt');

crypto = require('crypto');

Line = require('line').Line;

soma = require('soma');

wings = require('wings');

db = require('../lib/db');

_ref = require('./lib/decorators'), checkPassword = _ref.checkPassword, requireUser = _ref.requireUser;

email = require('./lib/email').email;

registrationTemplate = "{name}, \n\nI just wanted to welcome you to the Puzzle School.\n\nWe're working on a number of different projects, trying to make\nit fun and interesting to learn a variety of material.\n\nPlease don't hesitate to reach out. We love hearing from people.\n\nBest,\n    Jared";

soma.routes({
  '/api/login': checkPassword(function() {
    var l,
      _this = this;
    return l = new Line({
      error: function(err) {
        console.log('Login failed:', err);
        return _this.sendError();
      }
    }, function() {
      return db.get('users', _this.login.user, l.wait());
    }, function(user) {
      _this.user = user;
      _this.cookies.set('user', _this.user, {
        signed: true
      });
      return _this.send();
    });
  }),
  '/api/third_party_login': function() {
    var l,
      _this = this;
    return l = new Line({
      error: function(err) {
        console.log('Third party login failed:', err);
        return _this.sendError();
      }
    }, function() {
      return db.get('users', _this.data.user, l.wait());
    }, function(user) {
      _this.user = user;
      if (_this.user != null) {
        _this.cookies.set('user', _this.user, {
          signed: true
        });
        _this.send({});
        l.stop();
        return;
      }
      return db.put('users', {
        id: _this.data.user
      }, l.wait());
    }, function(user) {
      _this.user = user;
      _this.cookies.set('user', _this.user, {
        signed: true
      });
      return db.update('users', 'data', {
        count: {
          add: 1
        },
        ids: {
          add: [_this.user.id]
        }
      }, l.wait());
    }, function() {
      return email.sendText('The Puzzle School <support@puzzleschool.com>', 'Admin <info@puzzleschool.com>', "New Puzzle School Third Party User", "" + _this.user.id, l.wait());
    }, function() {
      return _this.send();
    });
  },
  '/api/email': function() {
    var l,
      _this = this;
    if (!(this.data.email && /.+@.+\..+/.test(this.data.email))) {
      return this.sendError(new Error('Email was invalid'));
    }
    this.data.email = this.data.email.toLowerCase();
    return l = new Line({
      error: function(err) {
        console.log('Saving email failed:', err);
        return _this.sendError();
      }
    }, function() {
      _this.cookies.set('email', _this.data.email, {
        signed: true
      });
      return db.update('users', 'emails', {
        count: {
          add: 1
        },
        emails: {
          add: [_this.data.email]
        }
      }, l.wait());
    }, function() {
      return email.sendText('The Puzzle School <support@puzzleschool.com>', 'Admin <info@puzzleschool.com>', "New Puzzle School Email", "" + _this.data.email, l.wait());
    }, function() {
      return _this.send();
    });
  },
  '/api/register': function() {
    var l,
      _this = this;
    if (!(this.data.name && /\S{3,}/.test(this.data.name))) {
      return this.sendError(new Error('Name was invalid'));
    }
    if (!(this.data.email && /.+@.+\..+/.test(this.data.email))) {
      return this.sendError(new Error('Email was invalid'));
    }
    if (!(this.data.password && /\S{3,}/.test(this.data.password))) {
      return this.sendError(new Error('Password was invalid'));
    }
    if (!(this.data.year && isFinite(this.data.year))) {
      return this.sendError(new Error('Birthday was invalid'));
    }
    this.data.birthday = "" + this.data.year + "-" + this.data.month + "-" + this.data.day;
    this.data.year = parseInt(this.data.year);
    this.data.month = parseInt(this.data.month || -1);
    this.data.day = parseInt(this.data.day || -1);
    this.data.email = this.data.email.toLowerCase();
    return l = new Line({
      error: function(err) {
        console.log('Registration failed:', err);
        return _this.sendError();
      }
    }, function() {
      db.get('login', _this.data.email, l.wait(function(login) {}));
      if (typeof login !== "undefined" && login !== null) {
        return l.fail('duplicate login');
      }
    }, function() {
      return bcrypt.genSalt(l.wait());
    }, function(salt) {
      return bcrypt.hash(_this.data.password, salt, l.wait());
    }, function(hash) {
      _this.data.password = hash;
      return crypto.randomBytes(16, l.wait());
    }, function(session) {
      var key, user, _i, _len, _ref1;
      user = {
        id: _this.data.email,
        session: session.toString('hex')
      };
      _ref1 = ['name', 'email', 'birthday', 'month', 'day', 'year'];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        key = _ref1[_i];
        user[key] = _this.data[key];
      }
      return db.put('users', user, l.wait());
    }, function(user) {
      _this.user = user;
      _this.cookies.set('user', _this.user, {
        signed: true
      });
      return db.put('login', {
        id: _this.data.email,
        password: _this.data.password,
        user: _this.user.id
      }, l.wait());
    }, function() {
      return db.update('users', 'data', {
        count: {
          add: 1
        },
        ids: {
          add: [_this.user.id]
        }
      }, l.wait());
    }, function() {
      return email.sendText('The Puzzle School <support@puzzleschool.com>', 'Admin <info@puzzleschool.com>', "New Puzzle School User", "" + _this.user.email + ", " + _this.user.name + ", " + _this.user.birthday, l.wait());
    }, function() {
      return _this.send();
    });
  }
});
