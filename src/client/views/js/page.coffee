(($) ->
    views = require('views')
                   
    class views.Page extends views.BaseView
        constructor: (options={}) ->
            super(options)
            $('.nav-item.selected').removeClass('selected')
            $(".nav-item.#{@name}").addClass('selected')
            if @userSignedIn() then $('.user-signed-in').show() else $('.user-signed-in').hide()
        
        renderError: ->
            @el.html('<h2 class="message">An error has occurred.</h2>')
            super
            
)(ender)