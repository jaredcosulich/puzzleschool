fs = require('fs')
url = require('url')
express = require('express')

router = require('./lib/router')
router.init ->
    require('./api/user')

    app = express.createServer()
        
    app.configure () ->
        app.use(express.static(__dirname + '/../client'))
        app.use(express.errorHandler(dumpExceptions: true, showStack: true))
    
    app.get '*', (req, res) -> 
        context = router.handle(req, res)
        context.emit 'route'

    app.listen(process.env.PORT || 5000)
    console.log("Listening on port #{process.env.PORT || 5000}")