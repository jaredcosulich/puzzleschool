soma = require('soma')
wings = require('wings')

soma.chunks
    Home:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: () ->
            @template = @loadTemplate '/build/common/templates/home.html'

        build: () ->
            @setTitle('The Puzzle School')
            @html = wings.renderTemplate(@template)
        

soma.routes
    '': -> new soma.chunks.Home
    '/': -> new soma.chunks.Home
