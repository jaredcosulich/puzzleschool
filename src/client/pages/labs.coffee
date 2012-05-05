soma = require('soma')
wings = require('wings')

soma.chunks
    Labs:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: () ->
            @template = @loadTemplate '/build/client/templates/labs.html'

        build: () ->
            @setTitle("Labs - The Puzzle School")
            @html = wings.renderTemplate(@template)
        
soma.views
    Labs:
        selector: '#content .labs'
        create: ->
            
soma.routes
    '/labs': -> new soma.chunks.Labs
