Line = require('line').Line
soma = require('soma')
db = require('../lib/db')

{requireUser} = require('./lib/decorators')

soma.routes
    '/api/events/create': requireUser ->
        l = new Line
            error: (err) => 
                console.log('Saving event record failed:', err)
                @sendError()

        for event in @data.events
            do (event) =>
                eventInfo = 
                    userId: @user.id
                    puzzle: event.puzzle
                    levelId:event.levelId
                    info: event.info
                    type: event.type
        
                eventInfo.classId = event.classId if event.classId
            
                eventInfo.environmentId = "#{@user.id}/#{eventInfo.levelId}"
                eventInfo.environmentId += "/#{eventInfo.classId}" if eventInfo.classId
                   
                l.add => db.put('events', eventInfo, l.wait())
                l.add (@event) =>
                    @listUpdate = {events: {add: [@event.id]}} 
                    db.update 'event_lists', eventInfo.environmentId, @listUpdate, l.wait()
        
        l.add => @send()