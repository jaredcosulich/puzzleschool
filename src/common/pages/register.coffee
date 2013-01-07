soma = require('soma')
wings = require('wings')

soma.chunks
    Register:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ->
            @template = @loadTemplate '/build/common/templates/home.html'

        build: () ->
            @setTitle('The Puzzle School')
            @html = wings.renderTemplate(@template)
        
soma.views
    Register:
        selector: '#content .home'
        create: ->
            $('.register_flag').hide()
            $('#base').data('base').showRegistration()

soma.routes
    '/register': -> new soma.chunks.Register
