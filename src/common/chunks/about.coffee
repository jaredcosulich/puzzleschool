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
            
soma.views
    About:
        selector: '#content .about'
        create: ->
            $('.register_flag').hide()    
            
            for moreLink in @$('.more')
                do (moreLink) =>
                    moreLink = $(moreLink)
                    moreLink.bind 'click', =>
                        moreLink.hide()
                        moreLink.closest('.about_text').find('.hidden').show()

        
soma.routes
    '/about': -> new soma.chunks.About
