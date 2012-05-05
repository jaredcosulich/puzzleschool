dynode = require('dynode')

db = exports

dynodeClient = new dynode.Client
    accessKeyId: 'AKIAJJEYLSPOX3CMVWOQ'
    secretAccessKey: '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'

db.createTable = (args...) -> dynodeClient.createTable(args...)
db.deleteTable = (args...) -> dynodeClient.deleteTable(args...)
db.updateTable = (args...) -> dynodeClient.updateTable(args...)

db.nextId = (table, callback) -> 
    dynodeClient.updateItem 'ids', table, {id: {add: 1}}, {ReturnValues : "ALL_NEW"}, (err, ret) ->
        return callback.apply(this, arguments) if err
        callback(err, ret.Attributes.id.toString())

db.put = (table, item, callback) ->
    item.createdAt = new Date() unless item.createdAt?
    
    if item.id
        dynodeClient.putItem table, item, () -> callback(null, item)

    else
        db.nextId table, (err, id) ->
            return callback.apply(this, arguments) if err
            item['id'] = id
            dynodeClient.putItem table, item, () -> callback(null, item)

db.get = (table, id, callback) -> dynodeClient.getItem table, id, callback

db.update = (table, id, attributes, callback) ->
    attributes.updatedAt = new Date()
    
    if 'id' of attributes
        return callback('Can\'t update id attribute') if attributes.id != id
        restoreId = true
        delete attributes.id
        
    dynodeClient.updateItem table, id, attributes, {ReturnValues : "ALL_NEW"}, (err, ret) ->
        return callback.apply(this, arguments) if err
        callback(err, ret.Attributes)
        
    if restoreId
        attributes.id = id

db.delete = (table, id, callback) ->
    dynode.deleteItem table, id, {ReturnValues : "ALL_OLD"}, (err, ret) ->
        return callback.apply(this, arguments) if err
        callback(err, ret.Attributes)

db.multiget = (table, ids, callback) ->
    if typeof table == 'object'
        # Two argument form, so adjust the args
        tables = table
        callback = ids
    else
        tables = {}
        tables[table] = ids
    
    query = {}
    for table, ids of tables
        query[table] = { keys: [] }
        for id in ids
            query[table].keys.push({ hash: id })

    dynodeClient.batchGetItem(query, callback)
