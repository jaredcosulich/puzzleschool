// Generated by CoffeeScript 1.3.3
var code;

code = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/code', {});

code.ViewHelper = (function() {

  function ViewHelper(_arg) {
    this.el = _arg.el, this.completeLevel = _arg.completeLevel;
  }

  ViewHelper.prototype.$ = function(selector) {
    return this.el.find(selector);
  };

  ViewHelper.prototype.initLevel = function(level) {
    var _this = this;
    this.level = level;
    this.initChallenge();
    this.initDescription();
    this.initHints();
    this.initTests();
    this.initEditors();
    this.setOutput();
    return window.retest = function() {
      return _this.test();
    };
  };

  ViewHelper.prototype.initEditors = function() {
    var editor, _fn, _i, _len, _ref,
      _this = this;
    this.editors = [];
    _ref = this.level.editors;
    _fn = function(editor) {
      var aceEditor, editorContainer;
      editorContainer = $(document.createElement('DIV'));
      editorContainer.addClass('editor_container');
      editorContainer.html("<div class='editor_header'>\n    <div class='type'>" + editor.type + "</div>\n    <div class='title'>" + editor.title + "</div>\n</div>\n<div class='editor'></div>");
      _this.$('.editors').append(editorContainer);
      editorContainer.find('.editor_header').bind('click', function() {
        return _this.selectEditor(editor);
      });
      editor.container = editorContainer;
      aceEditor = ace.edit(editorContainer.find('.editor')[0]);
      aceEditor.getSession().setMode("ace/mode/" + editor.type);
      aceEditor.getSession().setUseWrapMode(true);
      aceEditor.setValue(editor.code);
      aceEditor.clearSelection();
      aceEditor.getSession().on('change', function(e) {
        _this.setOutput();
        return _this.test();
      });
      return editor.aceEditor = aceEditor;
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      editor = _ref[_i];
      _fn(editor);
    }
    return this.selectEditor(this.level.editors[0]);
  };

  ViewHelper.prototype.selectEditor = function(editor) {
    var editorContainer, _i, _len, _ref, _results;
    _ref = this.$('.editor_container');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      editorContainer = _ref[_i];
      editorContainer = $(editorContainer);
      editorContainer.removeClass('selected');
      if (editorContainer.find('.title').html() === editor.container.find('.title').html()) {
        _results.push(editor.container.addClass('selected'));
      } else {
        _results.push(this.$('.editors').prepend(editorContainer));
      }
    }
    return _results;
  };

  ViewHelper.prototype.initChallenge = function() {
    return this.$('.challenge .text').html("<b>The Challenge</b>: " + this.level.challenge);
  };

  ViewHelper.prototype.initSection = function(className) {
    var content, height, link;
    link = this.$(".links ." + className);
    content = this.$("div." + className);
    height = content.height();
    content.css({
      height: 0,
      display: 'none'
    });
    return link.bind('click', function() {
      if (content.css('display') === 'block') {
        return;
      }
      content.css({
        display: 'block'
      });
      link.addClass('selected');
      return content.animate({
        height: height,
        duration: 250,
        complete: function() {
          $(document.body).one('click', function() {
            link.removeClass('selected');
            return content.animate({
              height: 0,
              duration: 250,
              complete: function() {
                return content.css({
                  display: 'none'
                });
              }
            });
          });
          return content.bind('click', function(e) {
            return e.stop();
          });
        }
      });
    });
  };

  ViewHelper.prototype.initDescription = function() {
    this.$('div.description .inside').html(this.level.description);
    return this.initSection('description');
  };

  ViewHelper.prototype.initHints = function() {
    var hint, index, _fn, _i, _len, _ref;
    _ref = this.level.hints;
    _fn = function(hint) {
      var hintElement;
      hintElement = $(document.createElement('DIV'));
      hintElement.addClass('hint');
      hintElement.html("<a class='reveal'>Reveal Hint " + (index + 1) + "</a>\n<p class='hint_content'>" + hint + "</p>");
      this.$('div.hints .inside').append(hintElement);
      return hintElement.find('.reveal').bind('click', function() {
        return hintElement.find('.hint_content').animate({
          opacity: 1,
          duration: 500
        });
      });
    };
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      hint = _ref[index];
      _fn(hint);
    }
    return this.initSection('hints');
  };

  ViewHelper.prototype.initTests = function() {
    var testInfo, _fn, _i, _len, _ref,
      _this = this;
    _ref = this.level.tests;
    _fn = function(testInfo) {
      return _this.$('div.tests .inside').prepend("<p class='test wrong'>" + testInfo.description + "</p>");
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      testInfo = _ref[_i];
      _fn(testInfo);
    }
    return this.initSection('tests');
  };

  ViewHelper.prototype.setOutput = function() {
    var baseHTML, editor, frameDocElement, script, _i, _len, _ref, _results;
    frameDocElement = $(this.$('.output')[0].contentDocument.documentElement);
    baseHTML = ((function() {
      var _i, _len, _ref, _results;
      _ref = this.level.editors;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        editor = _ref[_i];
        if (editor.type === 'html') {
          _results.push(editor);
        }
      }
      return _results;
    }).call(this))[0].aceEditor.getValue();
    frameDocElement.html(baseHTML);
    _ref = this.level.editors;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      editor = _ref[_i];
      if (editor.type === 'javascript') {
        script = $(document.createElement('SCRIPT'));
        script.attr('type', 'text/javascript');
        script.html(editor.aceEditor.getValue());
        _results.push(frameDocElement.find('head').append(script));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  ViewHelper.prototype.test = function() {
    var allTestsPassed, cleanHtml, frame, frameBody, frameDoc, testElement, testInfo, _i, _j, _len, _len1, _ref, _ref1;
    frame = this.$('.output')[0];
    frameDoc = frame.contentDocument || frame.contentWindow.document;
    frameBody = $(frameDoc.body);
    cleanHtml = function(html) {
      return html.replace(/^\s*/, '').replace(/\s*$/, '').replace(/\s*\n\s*/, ' ').toLowerCase();
    };
    allTestsPassed = true;
    _ref = this.level.tests;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      testInfo = _ref[_i];
      _ref1 = this.$('.tests .test');
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        testElement = _ref1[_j];
        if ($(testElement).html() === testInfo.description) {
          if (testInfo.test({
            body: frameBody,
            cleanHtml: cleanHtml
          })) {
            $(testElement).removeClass('wrong');
            $(testElement).addClass('correct');
          } else {
            allTestsPassed = false;
            $(testElement).removeClass('correct');
            $(testElement).addClass('wrong');
          }
        }
      }
    }
    if (allTestsPassed) {
      return this.completeLevel();
    }
  };

  return ViewHelper;

})();
