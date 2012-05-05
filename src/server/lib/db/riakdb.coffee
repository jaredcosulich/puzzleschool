line = require('line')
riak = require('riak-js')

db = exports

riakClient = new riak.getClient()

encodeId = (id) -> encodeURIComponent(id)
decodeId = (id) -> decodeURIComponent(id)

# Fix these
db.createTable = () ->
db.deleteTable = (table, callback) -> 
    stream = riakClient.keys(table, {keys: 'stream'})
    stream.on 'keys', (ids) ->
        for id in ids
            do (id) ->
                line ->
                    db.delete table, id, line.wait()
                line ->
                    setTimeout line.wait(), 500
    stream.on 'end', () ->
        line.error callback
        line.run -> callback(null)
    
    stream.start()
    
db.serialize = (item) ->
    for key, value of item
        if Array.isArray(value)
            for object, index in value
                value[index] = object.toString() unless typeof object == 'number'
        else if typeof value == 'object'        
            item[key] = value.toString()
    return item
    
db.nextId = (table, callback) -> 
    riakClient.get 'ids', table, (err, id, meta) ->
        if err
            if err.statusCode == 404
                id = 0
            else
                return callback.apply(this, arguments) if err

        riakClient.save 'ids', table, (++id).toString(), meta, (err, meta) ->
            return callback.apply(this, arguments) if err
            callback(null, id.toString())

db.put = (table, item, callback) ->
    item.createdAt = new Date() unless item.createdAt?
    
    if item.id
        riakClient.save table, encodeId(item.id), db.serialize(item), (err, meta) ->
            return callback.apply(this, arguments) if err
            callback(null, item)
            
    else
        db.nextId table, (err, id) ->
            return callback.apply(this, arguments) if err
            item.id = id
            riakClient.save table, encodeId(item.id), db.serialize(item), (err, meta) ->
                return callback.apply(this, arguments) if err
                callback(null, item)

db.get = (table, id, callback) ->
    riakClient.get table, encodeId(id), (err, item, meta) ->
        if err
            if err.statusCode == 404
                err = null
                item = {}
            else
                return callback.apply(this, arguments) if err
                
        item.id = decodeId(item.id) if item.id?
        callback(null, item)

db.updateExisting = (table, id, item, attributes, callback) ->
    for key, value of attributes
        if typeof value == 'object'
            if value.add
                if not item[key]
                    item[key] = (if Array.isArray(value.add) then [] else 0)

                if Array.isArray(item[key])
                    for el in value.add
                        if el not in item[key]
                            item[key].push(el)
                    attributes[key] = item[key]

                else if typeof item[key] == 'number'
                    attributes[key] = item[key] + value.add
                
            else if value.delete
                if Array.isArray(item[key])
                    attributes[key] = (el for el in item[key] when el not in value.delete)
                else if typeof item[key] == 'number'
                    attributes[key] = item[key] - value.delete
                

    riakClient.save table, encodeId(id), db.serialize(attributes), (err, item, meta) ->
        return callback.apply(this, arguments) if err
        db.get(table, id, callback)


db.update = (table, id, attributes, callback) ->
    attributes.updatedAt = new Date()
    
    if 'id' of attributes
        return callback('Can\'t update id attribute') if attributes.id != id
        
    riakClient.get table, encodeId(id), (err, item, meta) ->
        if err
            if err.statusCode == 404
                db.put table, {id: id}, (err, item) ->
                    return callback.apply(this, arguments) if err
                    db.updateExisting(table, id, item, attributes, callback)
            else
                return callback.apply(this, arguments) if err
        else
            db.updateExisting(table, id, item, attributes, callback)
        

db.delete = (table, id, callback) ->
    riakClient.remove table, encodeId(id), (err, item, meta) ->
        return callback.apply(this, arguments) if err
        callback(null, item)

db.multiget = (table, ids, callback) ->
    if typeof table == 'object'
        # Two argument form, so adjust the args
        tables = table
        callback = ids
    else
        tables = {}
        tables[table] = ids

    results = {}
    for table, ids of tables
        results[table] = []
        
        for id in ids
            do (id) ->
                line -> db.get table, id, line.wait()
                line (item) -> results[table].push(item)
                    
    line.error callback
    line.run ->
        callback(null, results)
        return results
