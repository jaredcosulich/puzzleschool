// Generated by CoffeeScript 1.3.3
var soma;

soma = require('soma');

soma.views({
  Frame: {
    selector: 'body',
    create: function() {
      return $(document.body).addClass('frame');
    }
  }
});
