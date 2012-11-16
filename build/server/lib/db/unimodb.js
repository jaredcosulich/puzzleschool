// Generated by CoffeeScript 1.3.3
var db, dynode, dynodeClient, getGuid, splitGuid, unimoTable;

dynode = require('dynode');

db = exports;

unimoTable = 'puzzleschool-dev';

dynodeClient = new dynode.Client({
  accessKeyId: 'AKIAJ4DV2JSOSNOBJFNA',
  secretAccessKey: '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'
});

getGuid = function(table, id) {
  return table + '-' + id;
};

splitGuid = function(guid) {
  return guid.split('-', 2);
};

db.createTable = function() {
  throw new Error('In single-table land, tables can\'t be created, destroyed or updated');
};

db.deleteTable = function() {
  throw new Error('In single-table land, tables can\'t be created, destroyed or updated');
};

db.updateTable = function() {
  throw new Error('In single-table land, tables can\'t be created, destroyed or updated');
};

db.nextId = function(table, callback) {
  return dynodeClient.updateItem(unimoTable, getGuid('ids', table), {
    id: {
      add: 1
    }
  }, {
    ReturnValues: "ALL_NEW"
  }, function(err, ret) {
    if (err) {
      return callback.apply(this, arguments);
    }
    return callback(err, ret.Attributes.id.toString());
  });
};

db.put = function(table, item, callback) {
  if (item.createdAt == null) {
    item.createdAt = new Date();
  }
  if (item.id) {
    item.guid = getGuid(table, item.id);
    return dynodeClient.putItem(unimoTable, item, function() {
      return callback(null, item);
    });
  } else {
    return db.nextId(table, function(err, id) {
      if (err) {
        return callback.apply(this, arguments);
      }
      item.id = id;
      item.guid = getGuid(table, item.id);
      return dynodeClient.putItem(unimoTable, item, function() {
        return callback(null, item);
      });
    });
  }
};

db.get = function(table, id, callback) {
  return dynodeClient.getItem(unimoTable, getGuid(table, id), callback);
};

db.update = function(table, id, attributes, callback) {
  attributes.updatedAt = new Date();
  if ('id' in attributes && attributes.id !== id) {
    return callback('Can\'t update id attribute');
  }
  if ('guid' in attributes) {
    delete attributes.guid;
  }
  return dynodeClient.updateItem(unimoTable, getGuid(table, id), attributes, {
    ReturnValues: "ALL_NEW"
  }, function(err, ret) {
    if (err) {
      return callback.apply(this, arguments);
    }
    return callback(err, ret.Attributes);
  });
};

db["delete"] = function(table, id, callback) {
  return dynodeClient.deleteItem(unimoTable, getGuid(table, id), {
    ReturnValues: "ALL_OLD"
  }, function(err, ret) {
    if (err) {
      return callback.apply(this, arguments);
    }
    return callback(err, ret.Attributes);
  });
};

db.multiget = function(table, ids, callback) {
  var id, query, tables, _i, _len;
  if (typeof table === 'object') {
    tables = table;
    callback = ids;
  } else {
    tables = {};
    tables[table] = ids;
  }
  query = {};
  query[unimoTable] = {
    keys: []
  };
  for (table in tables) {
    ids = tables[table];
    for (_i = 0, _len = ids.length; _i < _len; _i++) {
      id = ids[_i];
      query[unimoTable].keys.push({
        hash: getGuid(table, id)
      });
    }
  }
  return dynodeClient.batchGetItem(query, function(err, result) {
    var item, _j, _len1, _ref;
    if (err) {
      return callback.apply(this, arguments);
    }
    _ref = result[unimoTable];
    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
      item = _ref[_j];
      table = splitGuid(item.guid)[0];
      if (table in result) {
        result[table].push(item);
      } else {
        result[table] = [item];
      }
    }
    delete result[unimoTable];
    return callback(err, result);
  });
};

db.scan = function(table, options, callback) {
  return dynodeClient.scan(table, options, callback);
};
