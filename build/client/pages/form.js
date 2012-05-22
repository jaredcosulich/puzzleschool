// Generated by CoffeeScript 1.3.1
var soma;

soma = require('soma');

soma.views({
  Form: {
    selector: '#base form',
    create: function() {},
    dataHash: function() {
      var data, field, fields, name, val, _i, _len, _ref;
      data = {};
      fields = this.$('input, select');
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
    }
  },
  FormButton: {
    selector: '#base .submit_feedback',
    create: function() {
      var _this = this;
      if (!this.message) {
        this.message = $(document.createElement('SPAN'));
        this.message.css({
          display: 'none'
        });
        this.message.insertAfter(this.el);
      }
      return this.el.bind('click', function() {
        return _this.el.animate({
          opacity: 0,
          duration: 300,
          complete: function() {
            _this.el.css({
              display: 'none'
            });
            _this.message.css({
              display: 'inline',
              opacity: 0
            });
            _this.message.addClass('submitting');
            _this.message.html(_this.el.data('submitting_text'));
            return _this.message.animate({
              opacity: 1,
              duration: 300
            });
          }
        });
      });
    },
    success: function() {
      var _this = this;
      return this.message.animate({
        opacity: 0,
        duration: 300,
        complete: function() {
          _this.message.removeClass('submitting');
          _this.message.addClass('submitted');
          _this.message.html(_this.el.data('submitted_text'));
          return _this.message.animate({
            opacity: 1,
            duration: 300
          });
        }
      });
    },
    error: function() {
      var errorMessage;
      errorMessage = this.el.data('failed_submission_text');
      alert(errorMessage);
      return this.revert();
    },
    revert: function() {
      var _this = this;
      return this.message.animate({
        opacity: 0,
        duration: 300,
        complete: function() {
          _this.message.css({
            display: 'none'
          });
          _this.el.css({
            display: 'inline',
            opacity: 0
          });
          return _this.el.animate({
            opacity: 1,
            duration: 300
          });
        }
      });
    }
  }
});
