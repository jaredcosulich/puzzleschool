(($) ->
    views = require('views')

    class views.Main extends views.BaseView
        prepare: () ->
            @template = @_requireTemplate('views/html/main.html')
    
        renderView: () ->
            @el.html(@template.render())
                
)(ender)