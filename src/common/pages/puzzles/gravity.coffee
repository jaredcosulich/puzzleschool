soma = require('soma')
wings = require('wings')

soma.chunks
    Gravity:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({}) ->
            @template = @loadTemplate '/build/common/templates/puzzles/gravity.html'
            @loadScript '/build/common/pages/puzzles/lib/gravity.js'
            @loadStylesheet '/build/client/css/puzzles/gravity.css'     

        build: () ->
            @setTitle("Gravity - The Puzzle School")
            @html = wings.renderTemplate(@template)
        
soma.views
    Gravity:
        selector: '#content .gravity'
        create: ->
            $('.register_flag').hide()    
            
            gravity = require('./lib/gravity')
            @viewHelper = new gravity.ViewHelper
                el: $(@selector)
            

soma.routes
    '/puzzles/gravity': -> new soma.chunks.Gravity


