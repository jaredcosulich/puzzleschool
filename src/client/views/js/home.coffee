(($) ->
    views = require('views')

    class views.Home extends views.Page
        prepare: () ->
            @template = @_requireTemplate('views/html/home.html')
    
        renderView: () ->
            @el.html(@template.render())     
    
    $.route.add
        '': (type) ->
            $('#content').view
                name: 'Home'

)(ender)