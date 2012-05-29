soma = require('soma')
wings = require('wings')

soma.chunks
    About:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: () ->
            @template = @loadTemplate '/build/common/templates/about.html'

        build: () ->
            @setTitle("About - The Puzzle School")
            @html = wings.renderTemplate(@template)
        
soma.routes
    '/about': -> new soma.chunks.About
