Line = require('line').Line
soma = require('soma')
db = require('../lib/db')

{requireUser} = require('./lib/decorators')

soma.routes
    '/api/stats/update': requireUser ->
        l = new Line
            error: (err) => 
                console.log('Saving stats failed:', err)
                @sendError()
    
        for statUpdateInfo in @data.updates
            do (statUpdateInfo) =>
                statUpdateInfo = JSON.parse(statUpdateInfo)
                update = 
                    objectType: statUpdateInfo.objectType
                    objectId: statUpdateInfo.objectId
            
                for action in statUpdateInfo.actions
                    update[action.attribute] = {}
                    update[action.attribute][action.action] = action.value
        
                l.add => db.update 'stats', "#{update.objectType}/#{update.objectId}", update, l.wait()
            
        l.add => @send()
        

    '/api/stats': requireUser ->
        objectIds = []
        
        for objectInfo in @data.objectInfos
            objectIds.push("#{objectInfo.objectType}/#{objectInfo.objectId}")
        
        l = new Line
            error: (err) => 
                console.log('Retrieving stats failed:', err)
                @sendError()
    
            => db.multiget 'stats', objectIds, l.wait()
        
            (stats) => @send(stats)