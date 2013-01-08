neurobehav_objects = exports ? provide('./neurobehav_objects/index', {})

for name, fn of require('./object_editor')
    neurobehav_objects[name] = fn

for name, fn of require('./game')
    neurobehav_objects[name] = fn

for name, fn of require('./object')
    neurobehav_objects[name] = fn

for name, fn of require('./neuron')
    neurobehav_objects[name] = fn

for name, fn of require('./stimulus')
    neurobehav_objects[name] = fn

for name, fn of require('./oscilloscope')
    neurobehav_objects[name] = fn
