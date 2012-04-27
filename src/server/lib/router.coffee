crypto = require('crypto')
events = require('events')
querystring = require('querystring')
url = require('url')

Cookies = require('cookies')

db = require('./db')

keymaster = null
exports.init = (callback) ->
    keymaster = new KeyMaster
    keymaster.init callback

routes = []
exports.add = (_routes) ->
    for expr, fn of _routes
        routes.push(new Route(expr, fn))
        
    return
        
exports.handle = (request, response) ->
    context = new Context(request, response)
    context.on 'route', () ->
        for route in routes
            if (m = route.pattern.exec(context.path))
                matched = true
                route.fn.apply(context, m.slice(1))

        if not matched
            context.sendNotFound()

    context.begin()
    return


class KeyMaster
    init: (callback) ->
        # Fix this later
        @keys = ['sadasfas']
        process.nextTick callback
        return
    
    sign: (data, key=@keys[0]) -> crypto.createHmac('sha1', key).update(data).digest('hex')
    verify: (data, hash) -> @keys.some((key) -> @sign(data, key) == hash)


class Route
    _transformations: [
        [ # Escape URL Special Characters
            /([?=,\/])/g
            '\\$1'
        ],

        [ # Named Parameters
            /:([\w\d]+)/g
            '([^/]*)'
        ],
        
        [ # Splat Parameters
            /\*([\w\d]+)/g
            '(.*?)'
        ],
    ]

    constructor: (@expr, @fn) ->
        pattern = @expr
        for [transformer, replacement] in @_transformations
            pattern = pattern.replace(transformer, replacement)
            
        @pattern = new RegExp("^#{pattern}$")


class Context extends events.EventEmitter
    constructor: (@request, @response) ->
        urlParsed = url.parse(@request.url, true)
        for key of urlParsed
            @[key] = urlParsed[key]

        @cookies = new Cookies(@request, @response, keymaster)
        @uid = @cookies.get('uid')
        return
        
    begin: () ->
        contentType = @request.headers['content-type']
        contentType = contentType.split(/;/)[0] if contentType
        switch contentType
            when undefined, 'application/x-www-form-urlencoded' then @_readUrlEncoded()
            when 'application/json' then @_readJSON()
            when 'application/octet-stream', 'multipart/form-data' then @_readFiles()
            
        return
    
    sendJSON: (obj) ->
        body = JSON.stringify(obj)
        @response.setHeader('Content-Type', 'application/json')
        @response.setHeader('Content-Length', Buffer.byteLength(body))
        @response.end(body)
        return
    
    sendText: (body='', contentType='text/html') ->
        @response.setHeader('Content-Type', contentType)
        @response.setHeader('Content-Length', Buffer.byteLength(body))
        @response.end(body)
        return
    
    sendBinary: (body, contentType='application/octet-stream') ->
        @response.setHeader('Content-Type', contentType)
        @response.setHeader('Content-Length', body.length)
        @response.end(body)
        return
    
    sendError: (err, body='') ->
        console.log(err, err.stack) if err
        @response.statusCode = 500
        @response.setHeader('Content-Type', 'text/plain')
        @response.setHeader('Content-Length', Buffer.byteLength(body))
        @response.end(body)
        return
    
    sendNotFound: (body='', contentType='text/html') ->
        console.log("404", body)
        @response.statusCode = 404
        @response.setHeader('Content-Type', contentType)
        @response.setHeader('Content-Length', Buffer.byteLength(body))
        @response.end(body)
        return
    
    redirect: (path) ->
        @response.statusCode = 303
        @response.setHeader('Location', path)
        @response.end()
        return
    
    _readJSON: () ->
        chunks = []
        @request.on 'data', (chunk) => chunks.push(chunk)
        @request.on 'end', () => @emit 'route', (@data = JSON.parse(chunks.join("")))
        return
        
    _readUrlEncoded: () ->
        chunks = []
        @request.on 'data', (chunk) => chunks.push(chunk)
        @request.on 'end', () => @emit 'route', (@data = querystring.parse(chunks.join("")))
        return
        