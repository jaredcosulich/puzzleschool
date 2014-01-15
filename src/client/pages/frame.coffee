soma = require('soma')

soma.views
    Frame:
        selector: 'body'
        create: ->
          alert('frame')
          $(document.body).addClass('frame')
