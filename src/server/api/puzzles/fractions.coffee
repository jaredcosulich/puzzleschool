Line = require('line').Line
soma = require('soma')
db = require('../lib/db')

{requireUser} = require('./lib/decorators')

soma.routes
    '/api/fractions/update_level': ->
        levelInfo = 
            levelName: @data.level
            levelInstructions: @data.instructions
            levelDifficulty: @data.difficulty
        
        
        l = new Line
            error: (err) => 
                console.log('Saving level failed:', err)
                @sendError()
        
        l.add =>         
            db.update( 
                'fractions_levels', 
                levelInfo.levelName, 
                levelInfo, 
                l.wait()
            )
            
        l.add => @send()

    '/api/fractions/level/:id': ({id}) ->
        l = new Line
            error: (err) => 
                console.log('Unable to retrieve level:', err)
                @sendError()
        
        l.add =>         
            db.get( 
                'fractions_levels', 
                id, 
                l.wait()
            )
        
        l.add (levelInfo) => @send(levelInfo)         
        