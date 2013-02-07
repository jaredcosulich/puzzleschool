soma = require('soma')

decamelize = (s) -> s and s.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()
class soma.View
    constructor: ->
        # Convenience methods
        dataName = decamelize(@constructor.name)

        @el = $(@selector)
        @el.data(dataName, this)
        @el.one 'remove', (event) =>
            if event.target is @el[0]
                @el.data(dataName, null)
                
        @create

    $: (selector) -> $(selector, @el)

    hashChanges: {}
    registerHashChange: (hash, callback) => @hashChanges[hash.replace(/#/, '')] = callback


soma.routes '/common/pages/base.js',    
    '': '/common/pages/home.js'
