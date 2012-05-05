crypto = require('crypto')
riak = require('riak-js')

db = exports

riakClient = new riak.getClient()

db.putFile = (path, data, mimetype, callback) ->
    riakClient.saveLarge path, data, (err, meta) ->
        return callback.apply(this, arguments) if err
        callback(null, path)

db.getFile = (path, callback) ->
    riakClient.getLarge path, (err, data, meta) ->
        return callback.apply(this, arguments) if err
        callback(null, data)

db.putImage = (data, callback) ->
    crypto.randomBytes 6, (err, buf) ->
        path = (Date.now() + buf.toString('hex')).replace(/^(......)(..)(..)(...)(.*)$/g, 'images-$1-$2-$3-$4-$5.jpg')
        db.putFile path, data, 'image/jpeg', callback

db.getImage = (path, callback) -> db.getFile path, callback
