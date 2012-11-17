// Generated by CoffeeScript 1.3.3
var Line, db, requireUser, soma,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Line = require('line').Line;

soma = require('soma');

db = require('../lib/db');

requireUser = require('./lib/decorators').requireUser;

soma.routes({
  '/api/puzzles/:puzzleName': requireUser(function(_arg) {
    var l, puzzleName,
      _this = this;
    puzzleName = _arg.puzzleName;
    return l = new Line({
      error: function(err) {
        console.log('Loading puzzle data failed:', err);
        return _this.sendError();
      }
    }, function() {
      return db.get('user_puzzles', "" + _this.user.id + "/" + puzzleName, l.wait());
    }, function(userPuzzle) {
      _this.userPuzzle = userPuzzle;
      if (!_this.userPuzzle) {
        _this.send({});
        l.stop();
      }
    }, function() {
      return db.multiget('user_puzzle_progress', _this.userPuzzle.levelsPlayed, l.wait());
    }, function(data) {
      var level, _i, _len, _ref;
      _this.userPuzzle.levels = {};
      _ref = data.user_puzzle_progress;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        level = _ref[_i];
        _this.userPuzzle.levels[level.name] = level;
      }
      return delete _this.userPuzzle.levelsPlayed;
    }, function() {
      return _this.send({
        puzzle: _this.userPuzzle
      });
    });
  }),
  '/api/puzzles/:puzzleName/levels': function(_arg) {
    var l, puzzleName,
      _this = this;
    puzzleName = _arg.puzzleName;
    return l = new Line({
      error: function(err) {
        console.log('Loading puzzle data failed:', err);
        return _this.sendError();
      }
    }, function() {
      return db.get('puzzles', "" + puzzleName, l.wait());
    }, function(puzzle) {
      return db.multiget('puzzle_levels', puzzle.levels, l.wait());
    }, function(data) {
      return _this.send({
        levels: data.puzzle_levels || []
      });
    });
  },
  '/api/puzzles/levels/:levelId': function(_arg) {
    var l, levelId,
      _this = this;
    levelId = _arg.levelId;
    return l = new Line({
      error: function(err) {
        console.log('Loading puzzle level data failed:', err);
        return _this.sendError();
      }
    }, function() {
      return db.get('puzzle_levels', levelId, l.wait());
    }, function(level) {
      return _this.send(level);
    });
  },
  '/api/puzzles/:puzzleName/add_level': function(_arg) {
    var l, levelData, puzzleName,
      _this = this;
    puzzleName = _arg.puzzleName;
    levelData = {
      name: this.data.name,
      puzzle: puzzleName,
      instructions: this.data.instructions,
      difficulty: this.data.difficulty
    };
    return l = new Line({
      error: function(err) {
        console.log('Saving puzzle level failed:', err);
        return _this.sendError();
      }
    }, function() {
      return db.put('puzzle_levels', levelData, l.wait());
    }, function(level) {
      _this.level = level;
      return db.update('puzzles', puzzleName, {
        levels: {
          add: [_this.level.id]
        }
      }, l.wait());
    }, function() {
      return _this.send(_this.level);
    });
  },
  '/api/puzzles/:puzzleName/update': requireUser(function(data) {
    var l, levelName, levelUpdate, levelsPlayedUpdates, updates, userPuzzle, _ref,
      _this = this;
    userPuzzle = "" + this.user.id + "/" + data.puzzleName;
    l = new Line({
      error: function(err) {
        console.log('Saving puzzle data failed:', err);
        return _this.sendError();
      }
    });
    if (__indexOf.call(this.user.user_puzzles || [], userPuzzle) < 0) {
      l.add(function() {
        return db.update('users', _this.user.id, {
          user_puzzles: {
            add: [userPuzzle]
          }
        }, l.wait());
      });
    }
    if (this.data.puzzleUpdates) {
      levelsPlayedUpdates = (function() {
        var _ref, _results;
        _ref = this.data.levelUpdates;
        _results = [];
        for (levelName in _ref) {
          updates = _ref[levelName];
          _results.push("" + userPuzzle + "/" + levelName);
        }
        return _results;
      }).call(this);
      if (levelsPlayedUpdates.length) {
        this.data.puzzleUpdates.levelsPlayed = {
          add: levelsPlayedUpdates
        };
      }
      l.add(function() {
        return db.update('user_puzzles', userPuzzle, _this.data.puzzleUpdates, l.wait());
      });
    }
    if (this.data.levelUpdates) {
      _ref = this.data.levelUpdates;
      for (levelName in _ref) {
        levelUpdate = _ref[levelName];
        levelUpdate.name = levelName;
        l.add(function() {
          return db.update('user_puzzle_progress', "" + userPuzzle + "/" + levelName, levelUpdate, l.wait());
        });
      }
    }
    return l.add(function() {
      return _this.send();
    });
  })
});
