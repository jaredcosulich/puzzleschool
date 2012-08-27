soma = require('soma')
wings = require('wings')

soma.chunks
    Architect:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({}) ->
            @template = @loadTemplate '/build/common/templates/puzzles/architect.html'

        build: () ->
            @setTitle("Architect - The Puzzle School")
            @html = wings.renderTemplate(@template)
        
soma.routes
    '/puzzles/architect': -> new soma.chunks.Architect
