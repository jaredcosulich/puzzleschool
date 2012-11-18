Line = require('line').Line
soma = require('soma')
db = require('../lib/db')

{requireUser} = require('./lib/decorators')

soma.routes
    '/api/events/record': requireUser ->
        eventInfo = 
            userId: @user.id
            classId: @data.classId
            puzzle: @data.puzzle
            levelId: @data.level
            info: @data.info
            type: @data.type
        
        eventInfo.environmentId = "#{@user.id}/#{eventInfo.levelId}"
        eventInfo.environmentId += "/#{eventInfo.classId}" if eventInfo.classId
            
        l = new Line
            error: (err) => 
                console.log('Saving tracking record failed:', err)
                @sendError()
        
            => db.put('events', eventInfo, l.wait())
            (@event) => db.update 'event_lists', eventInfo.environmentId, {events: {add: [event.id]}}
            => db.update 'event_lists', "user-#{eventInfo.userId}", {events: {add: [event.id]}}
            => db.update 'event_lists', "level-#{eventInfo.levelId}", {events: {add: [event.id]}}
        
        if update.classId
            l.add => db.update 'event_lists', "class-#{eventInfo.classId}", {events: {add: [event.id]}}
        
        
    '/api/events/stats/update': requireUser ->
        update = 
            objectTable: @data.objectTable
            objectId: @data.objectId
            
        update[@data.attribute] = {}
        update[@data.attribute][@data.action] = [@data.value]
        
        l = new Line
            error: (err) => 
                console.log('Saving event stats failed:', err)
                @sendError()
        
            => db.update 'event_stats', "#{@data.objectType}/#{@data.objectId}", update, l.wait()
            
            (eventStats) => @send(eventStats)
        
            