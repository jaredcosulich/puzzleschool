crypto = require('crypto')
knox = require('knox')

util = require('../util')

db = exports

knoxClient = knox.createClient
    key: 'AKIAJJEYLSPOX3CMVWOQ'
    secret: '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'
    bucket: 'mingl-data'

db.putFile = (path, data, mimetype, callback) ->
    request = knoxClient.put path,
        'Content-Length': data.length
        'Content-Type': mimetype
        
    request.on 'response', (response) ->
        if response.statusCode != 200
            callback(response.statusCode)
            
        else
            callback(null, path)
    
    request.end(data)

db.getFile = (path, callback) ->
    chunks = []
    
    request = knoxClient.get(path)
    request.on 'response', (response) ->
        if response.statusCode != 200
            callback(response.statusCode)   
            
        else
            response.on 'data', (chunk) ->
                chunks.push(chunk)

            response.on 'end', -> callback(null, util.combineChunks(chunks))    
        
    request.end()

db.putImage = (data, callback) ->
    crypto.randomBytes 6, (err, buf) ->
        path = (Date.now() + buf.toString('hex')).replace(/^(......)(..)(..)(...)(.*)$/g, 'images/$1/$2/$3/$4/$5.jpg')
        db.putFile path, data, 'image/jpeg', callback

db.getImage = (path, callback) -> db.getFile path, callback
