// Generated by CoffeeScript 1.3.3
var LEVELS, soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  History: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function(_arg) {
      this.classId = _arg.classId, this.levelId = _arg.levelId;
      this.template = this.loadTemplate("/build/common/templates/puzzles/history.html");
      return this.loadStylesheet('/build/client/css/puzzles/history.css');
    },
    build: function() {
      this.setTitle("History Inquiry - The Puzzle School");
      return this.html = wings.renderTemplate(this.template);
    }
  }
});

soma.views({
  History: {
    selector: '#content .history',
    create: function() {
      var info, question, _ref, _results,
        _this = this;
      this.levelId = 'Battle of Fort Sumter';
      this.level = LEVELS[this.levelId];
      this.level.description.question = this.levelId;
      this.$('.title').html(this.levelId);
      this.$('.title').bind('click', function() {
        return _this.showAnswer(_this.level.description);
      });
      this.showAnswer(this.level.description);
      _ref = this.level.questions;
      _results = [];
      for (question in _ref) {
        info = _ref[question];
        _results.push(this.createQuestion(question, info));
      }
      return _results;
    },
    createQuestion: function(questionText, info) {
      var question,
        _this = this;
      info.question = questionText;
      question = $(document.createElement('DIV'));
      question.addClass('question');
      question.html(questionText);
      question.bind('click', function() {
        return _this.showAnswer(info);
      });
      return this.$('.navigation').append(question);
    },
    showAnswer: function(_arg) {
      var answer, details, image, question,
        _this = this;
      question = _arg.question, image = _arg.image, answer = _arg.answer;
      details = this.$('.answer');
      details.html('');
      details.append("<h3>" + question + "</h3>");
      if (image != null ? image.length : void 0) {
        details.append("<img src='" + image + "'/>");
      }
      if (answer != null ? answer.length : void 0) {
        details.append("<div>" + answer + "</div>");
      }
      return $.timeout(10, function() {
        var delta, height, img, newHeight, width;
        if ((delta = details.height() - _this.el.height() + 30) > 0) {
          img = details.find('img');
          height = img.height();
          width = img.width();
          newHeight = height - delta;
          return img.css({
            height: newHeight,
            width: width * (newHeight / height)
          });
        }
      });
    }
  }
});

soma.routes({
  '/puzzles/history/:classId/:levelId': function(_arg) {
    var classId, levelId;
    classId = _arg.classId, levelId = _arg.levelId;
    return new soma.chunks.History({
      classId: classId,
      levelId: levelId
    });
  },
  '/puzzles/history/:levelId': function(_arg) {
    var levelId;
    levelId = _arg.levelId;
    return new soma.chunks.History({
      levelId: levelId
    });
  },
  '/puzzles/history': function() {
    return new soma.chunks.History;
  }
});

LEVELS = {
  'Battle of Fort Sumter': {
    description: {
      image: 'http://upload.wikimedia.org/wikipedia/commons/0/05/Sumter.jpg',
      answer: 'The Battle of Fort Sumter was the bombardment and surrender of Fort Sumter, \nnear Charleston, South Carolina, that started the American Civil War.'
    },
    questions: {
      'What year did the battle take place?': {
        image: 'http://upload.wikimedia.org/wikipedia/commons/d/d6/Attack_on_Fort_Sumter.jpg',
        answer: 'Beginning at 4:30 a.m. on April 12, the Confederates bombarded the fort from artillery batteries \nsurrounding the harbor. Although the Union garrison returned fire, they were significantly outgunned and, \nafter 34 hours, on April 14, the Union troops evacuated.',
        questions: {
          'Who was president during the battle?': {
            image: 'http://en.wikipedia.org/wiki/File:Abraham_Lincoln_November_1863.jpg',
            answer: 'Althought Abraham Lincoln was president during the battle, he had been inaugurated just\none month earlier, on March 4. James Buchanan was president during the events that\nled up to the battle.'
          },
          'What events preceded the battle?': {
            image: '',
            answer: 'ANSWER'
          }
        }
      },
      'Why was Fort Sumter so important?': {
        image: 'http://upload.wikimedia.org/wikipedia/commons/7/7e/Sumter1.gif',
        answer: 'South Carolina had recently declared secession from the Union and Fort Sumter dominated the entrance to \nCharleston Harbor. Although it was unfinished, it was designed to be one of the strongest fortresses in \nthe world.'
      },
      'Who led the forces on each side during the battle?': {
        image: 'http://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Pgt_beauregard.jpg/220px-Pgt_beauregard.jpg',
        answer: ''
      },
      'How long did the battle last?': {},
      'What was the result of the battle?': {}
    }
  }
};
