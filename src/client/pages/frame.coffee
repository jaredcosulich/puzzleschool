soma = require('soma')

soma.views
    Frame:
        selector: 'body'
        create: ->
          $(document.body).addClass('frame')
