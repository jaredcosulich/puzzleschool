db = exports

for name, fn of require('./unimodb')
    db[name] = fn

for name, fn of require('./knoxblob')
    db[name] = fn

