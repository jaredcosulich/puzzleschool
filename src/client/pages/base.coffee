soma = require('soma')
wings = require('wings')

soma.chunks
    Base:
        prepare: ({@content}) ->
            @loadElement 'link', {href: '/assets/images/favicon.ico', rel: 'shortcut icon', type: 'image/x-icon'}
            
            @loadScript '/build/client/pages/base.js'
            @loadScript '/build/client/pages/home.js'
            @loadScript '/build/client/pages/about.js'
            @loadScript '/build/client/pages/labs.js'

            @loadStylesheet '/build/client/css/all.css'
            
            @template = @loadTemplate '/build/client/templates/base.html'
            @loadChunk @content


        build: () ->
            @setTitle('The Puzzle School')
            @html = wings.renderTemplate(@template, content: @content)
            
