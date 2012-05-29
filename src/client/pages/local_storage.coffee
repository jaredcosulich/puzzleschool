try 
    window.hasLocalStorage = window.localStorage?
    if window.hasLocalStorage?
        window.setLocalStorage = (name, item) => window.localStorage.setItem(name, JSON.stringify(item))
        window.getLocalStorage = (name) => JSON.parse(window.localStorage.getItem(name))
catch e
    window.hasLocalStorage = false
