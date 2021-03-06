soma = require('soma')
wings = require('wings')

soma.chunks
    Account:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: () ->            
            @template = @loadTemplate '/build/common/templates/account.html'

        build: () ->
            @setTitle("Your Account - The Puzzle School")
            @html = wings.renderTemplate(@template)
        
soma.views
    Account:
        selector: '#content .account'
        create: ->
            $('.register_flag').hide()    
            
soma.routes
    '/account': -> new soma.chunks.Account
