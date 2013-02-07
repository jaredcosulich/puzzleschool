line = require('line')
soma = require('soma')
wings = require('wings')

soma.chunk
    template: 
    title: 
    description:
    data: =>
        
    
    
    
    ->
        @loadFile , l.wait('template', 'x', 'y')

    =>
        @setTitle('The Puzzle School')
        callback(null, wings.renderTemplate(l.results.x))

