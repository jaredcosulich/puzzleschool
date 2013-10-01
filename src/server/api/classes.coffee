Line = require('line').Line
soma = require('soma')
db = require('../lib/db')

{requireUser} = require('./lib/decorators')

soma.routes
    '/api/classes/update': requireUser ->
        classInfo = 
            name: @data.name
            user: @user.id
            
        delete @data.id unless @data.id?.length
        
        l = new Line
            error: (err) => 
                console.log('Saving class failed:', err)
                @sendError()
        
            =>
                if @data.id
                    db.update('classes', @data.id, classInfo, l.wait())
                else
                    db.put('classes', classInfo, l.wait())

            (classInfo) => @send(classInfo)
        
        
    '/api/classes/info/:id': requireUser ({id}) ->
        l = new Line
            error: (err) => 
                console.log('Retrieving class failed:', err)
                @sendError()
        
            => db.get('classes', id, l.wait())
                
            (@classInfo) =>
                if not @classInfo.levels?.length
                    @send(@classInfo)
                    l.stop()
                    return
                    
                db.multiget 'puzzle_levels', @classInfo.levels, l.wait()
                    
            (levelInfo) => 
                for levelInfo in levelInfo.puzzle_levels
                    @classInfo.levels[@classInfo.levels.indexOf(parseInt(levelInfo.id))] = levelInfo
                         
                @send(@classInfo)
            
            
    '/api/classes/levels/:action/:classId': requireUser ({action, classId}) ->
        update = {levels: {}}
        update.levels[action] = [@data.level]
        
        l = new Line
            error: (err) => 
                console.log('Saving level to class failed:', err)
                @sendError()
        
            => db.update('classes', classId, update, l.wait())
        
            (classInfo) => db.multiget 'puzzle_levels', classInfo.levels, l.wait()
                
            (puzzleInfo) => @send(levels: puzzleInfo.puzzle_levels or [])        

    
    '/api/classes/students/:action': requireUser ({action}) ->
        update = {students: {}}
        update.students[action] = [@user.id]
    
        l = new Line
            error: (err) => 
                console.log('Saving student for class failed:', err)
                @sendError()
    
            => db.update('classes', id, update, l.wait())
    
            (classInfo) => @send(students: classInfo.students or [])        
            
            
            
            