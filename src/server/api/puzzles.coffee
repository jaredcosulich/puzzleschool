line = require('line')
soma = require('soma')
db = require('../lib/db')

{requireUser} = require('./lib/decorators')

soma.routes
    '/api/puzzles/:puzzleName': requireUser (puzzleName) ->
        line => db.get 'user_puzzles', "#{@user.id}/#{puzzleName}", line.wait()
        line (@userPuzzle) => 
            if not @userPuzzle
                @send({})
                line.end()
                return
        
        line => db.multiget 'user_puzzle_progress', @userPuzzle.levelsPlayed, line.wait()
        line (data) =>
            @userPuzzle.levels = {}
            (@userPuzzle.levels[level.name] = level) for level in data.user_puzzle_progress
            delete @userPuzzle.levelsPlayed
                
        line.error (err) => @sendError(err, 'Puzzle Info Failed')
        line.run => @send(puzzle: @userPuzzle)
        
    '/api/puzzles/:puzzleName/update': requireUser (puzzleName) ->
        userPuzzle = "#{@user.id}/#{puzzleName}"
        
        unless userPuzzle in (@user.user_puzzles or [])
            line => db.update 'users', @user.id, {user_puzzles: {add: [userPuzzle]}}, line.wait()

        if @data.puzzleUpdates
            levelsPlayedUpdates =  ("#{userPuzzle}/#{levelName}" for levelName, updates of @data.levelUpdates)
            @data.puzzleUpdates.levelsPlayed = {add: levelsPlayedUpdates} if levelsPlayedUpdates.length
            line => db.update 'user_puzzles', userPuzzle, @data.puzzleUpdates, line.wait()

        if @data.levelUpdates
            for levelName, levelUpdate of @data.levelUpdates
                levelUpdate.name = levelName                
                line => db.update 'user_puzzle_progress', "#{userPuzzle}/#{levelName}", levelUpdate, line.wait()

        line.error (err) => @sendError(err, 'Puzzle Update Failed')
        line.run => @send()

