word_problem_objects = exports ? provide('./word_problem_objects/index', {})

for name, fn of require('./number')
    word_problem_objects[name] = fn

