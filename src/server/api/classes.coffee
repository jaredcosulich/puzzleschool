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
        
        l.add =>
            if @data.id
                db.update('classes', @data.id, classInfo, l.wait())
            else
                db.put('classes', classInfo, l.wait())

        l.add (classInfo) => @send(classInfo)
        
        
    '/api/classes/info/:id': requireUser ({id}) ->
        l = new Line
            error: (err) => 
                console.log('Retrieving class failed:', err)
                @sendError()
        
        l.add => db.get('classes', id, l.wait())
        l.add (classInfo) => @send(classInfo)
            
            
    '/api/classes/levels/:action/:id': requireUser ({action, id}) ->
        update = {levels: {}}
        update.levels[action] = [@data.level]
        
        l = new Line
            error: (err) => 
                console.log('Saving level to class failed:', err)
                @sendError()
        
        l.add =>         
            db.update( 
                'classes', 
                id, 
                update, 
                l.wait()
            )
        
        l.add => @send()
        
    
    '/api/classes/students/:action': requireUser ({action}) ->
        update = {students: {}}
        update.students[action] = [@user.id]
    
        l = new Line
            error: (err) => 
                console.log('Saving student for class failed:', err)
                @sendError()
    
        l.add =>         
            db.update( 
                'classes', 
                id, 
                update, 
                l.wait()
            )
    
        l.add => @send()        