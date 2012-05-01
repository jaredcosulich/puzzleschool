(($) ->
    $('document').ready () ->
        $('body').view
            name: 'Main'
            complete: ->
                $.route.init(true)

        # Stop uncaptured drops
        $('body').bind 'dragenter dragover drop', (event) ->
            event.stopPropagation()
            event.preventDefault()
            return

)(ender)