soma = require('soma')

soma.views
    LocalStorage:
        selector: 'body'
        create: ->
            try 
                window.hasLocalStorage = window.localStorage?
                if window.hasLocalStorage?
                    window.setLocalStorage = (name, item) => window.localStorage.setItem(name, if item? then JSON.stringify(item) else null)
                    window.getLocalStorage = (name) => JSON.parse(window.localStorage.getItem(name))
                    window.getAndSyncCookiesAndLocalStorage = (name) =>
                        value = @cookies.get(name)
                        if not value and window.hasLocalStorage
                            value = window.getLocalStorage(name)
                            @cookies.set(name, value)
                        window.setLocalStorage(name, value)
                        return value
                        
            catch e
                window.hasLocalStorage = false
