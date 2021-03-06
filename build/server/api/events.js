// Generated by CoffeeScript 1.3.3
var Line, db, requireUser, soma;

Line = require('line').Line;

soma = require('soma');

db = require('../lib/db');

requireUser = require('./lib/decorators').requireUser;

soma.routes({
  '/api/events/create': requireUser(function() {
    var event, l, _fn, _i, _len, _ref,
      _this = this;
    l = new Line({
      error: function(err) {
        console.log('Saving event record failed:', err);
        return _this.sendError();
      }
    });
    _ref = this.data.events;
    _fn = function(event) {
      var eventInfo;
      eventInfo = {
        userId: _this.user.id,
        puzzle: event.puzzle,
        levelId: event.levelId,
        info: event.info,
        type: event.type
      };
      if (event.classId) {
        eventInfo.classId = event.classId;
      }
      eventInfo.environmentId = "" + _this.user.id + "/" + eventInfo.levelId;
      if (eventInfo.classId) {
        eventInfo.environmentId += "/" + eventInfo.classId;
      }
      l.add(function() {
        return db.put('events', eventInfo, l.wait());
      });
      return l.add(function(event) {
        _this.event = event;
        _this.listUpdate = {
          events: {
            add: [_this.event.id]
          }
        };
        return db.update('event_lists', eventInfo.environmentId, _this.listUpdate, l.wait());
      });
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      event = _ref[_i];
      _fn(event);
    }
    return l.add(function() {
      return _this.send();
    });
  })
});
