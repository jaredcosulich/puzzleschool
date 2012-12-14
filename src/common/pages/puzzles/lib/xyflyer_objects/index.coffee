xyflyer_objects = exports ? provide('./xyflyer_objects/index', {})

for name, fn of require('./board')
    xyflyer_objects[name] = fn

for name, fn of require('./plane')
    xyflyer_objects[name] = fn


