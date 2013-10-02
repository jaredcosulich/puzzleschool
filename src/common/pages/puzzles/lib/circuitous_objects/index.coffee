circuitous_objects = exports ? provide('./circuitous_objects/index', {})

for name, fn of require('./board')
    circuitous_objects[name] = fn

for name, fn of require('./battery')
    circuitous_objects[name] = fn

for name, fn of require('./lightbulb')
    circuitous_objects[name] = fn

for name, fn of require('./light_emitting_diode')
    circuitous_objects[name] = fn

for name, fn of require('./resistor')
    circuitous_objects[name] = fn

for name, fn of require('./toggle_switch')
    circuitous_objects[name] = fn

for name, fn of require('./ohms_law_worksheet')
    circuitous_objects[name] = fn

for name, fn of require('./menu')
    circuitous_objects[name] = fn

for name, fn of require('./options')
    circuitous_objects[name] = fn

for name, fn of require('./selector')
    circuitous_objects[name] = fn

