neurobehav = exports ? provide('./lib/neurobehav', {})

for name, fn of require('./neurobehav_objects/index')
    neurobehav[name] = fn

