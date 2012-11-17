Line = require('line').Line
soma = require('soma')
db = require('../lib/db')

{requireUser} = require('./lib/decorators')

soma.routes
    '/api/puzzles/:puzzleName': requireUser ({puzzleName}) ->
        l = new Line
            error: (err) => 
                console.log('Loading puzzle data failed:', err)
                @sendError()

            => db.get 'user_puzzles', "#{@user.id}/#{puzzleName}", l.wait()
            
            (@userPuzzle) => 
                if not @userPuzzle
                    @send({})
                    l.stop()
                    return
        
            => db.multiget 'user_puzzle_progress', @userPuzzle.levelsPlayed, l.wait()
            
            (data) =>
                @userPuzzle.levels = {}
                (@userPuzzle.levels[level.name] = level) for level in data.user_puzzle_progress
                delete @userPuzzle.levelsPlayed
                
            => @send(puzzle: @userPuzzle)

            
    '/api/puzzles/:puzzleName/levels': ({puzzleName}) ->
        l = new Line
            error: (err) => 
                console.log('Loading puzzle data failed:', err)
                @sendError()

            => db.get 'puzzles', "#{puzzleName}", l.wait()
            (puzzle) => db.multiget 'puzzle_levels', puzzle.levels, l.wait()

            (data) => 
                @send(levels: data.puzzle_levels or []) 

    '/api/puzzles/:puzzleName/levels/:className/:levelName': ({puzzleName, className, levelName}) ->
        l = new Line
            error: (err) => 
                console.log('Loading puzzle level data failed:', err)
                @sendError()

            => db.get 'puzzle_levels', "#{puzzleName}/#{className}/#{levelName}", l.wait()

            (level) => @send(level) 

    '/api/puzzles/:puzzleName/add_level': ({puzzleName}) ->
        levelData = 
            id: "#{puzzleName}/#{@data.classId}/#{@data.name.replace(/\s/g, '_')}"
            class: @data.classId
            name: @data.name
            instructions: @data.instructions
            difficulty: @data.difficulty
        
        l = new Line
            error: (err) => 
                console.log('Saving puzzle level failed:', err)
                @sendError()

            => db.update 'puzzle_levels', levelData.id, levelData, l.wait()
            (@level) => db.update 'puzzles', puzzleName, {levels: {add: [@level.id]}}, l.wait()

            => @send(@level)
        
    '/api/puzzles/:puzzleName/update': requireUser (data) ->
        userPuzzle = "#{@user.id}/#{data.puzzleName}"

        l = new Line
            error: (err) => 
                console.log('Saving puzzle data failed:', err)
                @sendError()
                
        unless userPuzzle in (@user.user_puzzles or [])
            l.add => db.update 'users', @user.id, {user_puzzles: {add: [userPuzzle]}}, l.wait()

        if @data.puzzleUpdates
            levelsPlayedUpdates =  ("#{userPuzzle}/#{levelName}" for levelName, updates of @data.levelUpdates)
            @data.puzzleUpdates.levelsPlayed = {add: levelsPlayedUpdates} if levelsPlayedUpdates.length
            l.add => db.update 'user_puzzles', userPuzzle, @data.puzzleUpdates, l.wait()

        if @data.levelUpdates
            for levelName, levelUpdate of @data.levelUpdates
                levelUpdate.name = levelName                
                l.add => db.update 'user_puzzle_progress', "#{userPuzzle}/#{levelName}", levelUpdate, l.wait()

        l.add => @send()    

        