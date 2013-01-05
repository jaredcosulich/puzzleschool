dynode = require('dynode')

db = exports

unimoTable = process.env.UNIMO or 'puzzleschool-dev'

dynodeClient = new dynode.Client
    accessKeyId: 'AKIAJ4DV2JSOSNOBJFNA'
    secretAccessKey: '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'
    
getGuid = (table, id) -> table + '-' + id
splitGuid = (guid) -> guid.split('-', 2)

db.createTable = -> throw new Error('In single-table land, tables can\'t be created, destroyed or updated')
db.deleteTable = -> throw new Error('In single-table land, tables can\'t be created, destroyed or updated')
db.updateTable = -> throw new Error('In single-table land, tables can\'t be created, destroyed or updated')

db.nextId = (table, callback) ->
    dynodeClient.updateItem unimoTable, getGuid('ids', table), {id: {add: 1}}, {ReturnValues : "ALL_NEW"}, (err, ret) ->
        return callback.apply(this, arguments) if err
        callback(err, ret.Attributes.id.toString())

db.put = (table, item, callback) ->
    item.createdAt = new Date() unless item.createdAt?
    
    if item.id
        item.guid = getGuid(table, item.id)
        dynodeClient.putItem unimoTable, item, () -> callback(null, item)

    else
        db.nextId table, (err, id) ->
            return callback.apply(this, arguments) if err
            item.id = id
            item.guid = getGuid(table, item.id)
            dynodeClient.putItem unimoTable, item, () -> callback(null, item)

db.get = (table, id, callback) -> dynodeClient.getItem unimoTable, getGuid(table, id), callback

db.update = (table, id, attributes, callback) ->
    attributes.updatedAt = new Date()

    if 'id' of attributes and attributes.id != id
        return callback('Can\'t update id attribute')
        
    if 'guid' of attributes
        delete attributes.guid
        
    dynodeClient.updateItem unimoTable, getGuid(table, id), attributes, {ReturnValues : "ALL_NEW"}, (err, ret) ->
        return callback.apply(this, arguments) if err
        callback(err, ret.Attributes)
        
db.delete = (table, id, callback) ->
    dynodeClient.deleteItem unimoTable, getGuid(table, id), {ReturnValues : "ALL_OLD"}, (err, ret) ->
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
    query[unimoTable] =  { keys: [] }
    for table, ids of tables
        for id in ids
            query[unimoTable].keys.push({hash: getGuid(table, id)})
    
    dynodeClient.batchGetItem query, (err, result) ->
        return callback.apply(this, arguments) if err
        
        # Fix the tables in the result object
        for item in result[unimoTable]
            table = splitGuid(item.guid)[0]
            
            if table of result
                result[table].push(item)
            else
                result[table] = [item]
                
        delete result[unimoTable]
        callback(err, result)

db.scan = (table, options, callback) -> dynodeClient.scan(table, options, callback)