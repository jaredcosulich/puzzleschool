soma = require('soma')
wings = require('wings')

soma.chunks
    Home:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: () ->
            @template = @loadTemplate '/build/common/templates/home.html'
            @emailSubscriptionTemplate = @loadTemplate '/build/common/templates/_email_subscription.html'

        build: () ->
            @setTitle('The Puzzle School')
            @setMeta('og:title', 'The Puzzle School')            
            @setMeta('og:url', 'http://www.puzzleschool.com')
            @setMeta('og:image', 'http://www.puzzleschool.com/assets/images/logo_med.png')
            @setMeta('og:site_name', 'The Puzzle School')
            @setMeta('og:description', 'An Exploration of Learning Through Puzzles')
            
            @html = wings.renderTemplate(@template, emailSubscription: wings.renderTemplate(@emailSubscriptionTemplate))
        
soma.views
    Home:
        selector: '#content .home'
        create: ->
            $('.register_flag').hide()    
            @$('.examples a').bind 'click', (e) =>
                offset = $(e.currentTarget).offset()
                example = $("div.#{e.currentTarget.className}")
                    
                close = ->
                    example.animate
                        opacity: 0
                        duration: 300
                        complete: ->
                            example.css(top: -1000)
                
                if example.css('opacity') > 0
                    close()
                else        
                    example.css(left: offset.left - (example.width()/3), top: offset.top + offset.height)
                    example.animate(opacity: 1, duration: 300)                   
                    $.timeout 100, -> $(document.body).one 'click', close
            
soma.routes
    '': -> new soma.chunks.Home
    '/': -> new soma.chunks.Home
