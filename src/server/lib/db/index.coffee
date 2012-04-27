db = exports

for name, fn of require('./unimodb')
    db[name] = fn
