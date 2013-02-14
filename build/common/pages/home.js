// Generated by CoffeeScript 1.3.3
var soma, wings;

soma = require('soma');

wings = require('wings');

soma.chunks({
  Home: {
    meta: function() {
      return new soma.chunks.Base({
        content: this
      });
    },
    prepare: function() {
      return this.template = this.loadTemplate('/build/common/templates/home.html');
    },
    build: function() {
      this.setTitle('The Puzzle School');
      return this.html = wings.renderTemplate(this.template);
    }
  }
});

soma.views({
  Home: {
    selector: '#content .home',
    create: function() {
      var _this = this;
      $('.register_flag').hide();
      return this.$('.examples a').bind('click', function(e) {
        var close, example, offset;
        offset = $(e.currentTarget).offset();
        example = $("div." + e.currentTarget.className);
        close = function() {
          return example.animate({
            opacity: 0,
            duration: 300,
            complete: function() {
              return example.css({
                top: -1000
              });
            }
          });
        };
        if (example.css('opacity') > 0) {
          return close();
        } else {
          example.css({
            top: offset.top + offset.height
          });
          example.animate({
            opacity: 1,
            duration: 300
          });
          return $.timeout(100, function() {
            return $(document.body).one('click', close);
          });
        }
      });
    }
  }
});

soma.routes({
  '': function() {
    return new soma.chunks.Home;
  },
  '/': function() {
    return new soma.chunks.Home;
  }
});
