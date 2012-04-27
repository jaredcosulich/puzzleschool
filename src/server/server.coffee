fs = require('fs')
http = require('http')
url = require('url')

router = require('./lib/router')

router.init ->
    require('./api/user')

    server = http.createServer (request, response) ->
        router.handle(request, response)
            
    server.listen(process.env.PORT || 8000)