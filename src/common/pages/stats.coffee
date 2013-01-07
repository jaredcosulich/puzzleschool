soma = require('soma')
wings = require('wings')

sortLevels = (levels) ->
    levels.sort (level1,level2) ->
        a = level1.difficulty + level1.name
        b = level2.difficulty + level2.name
        return if a == b then 0 else (if a < b then -1 else 1)

soma.chunks
    Stats:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, page}) ->      
            @page = parseInt(page or 0)
                  
            @template = @loadTemplate '/build/common/templates/stats.html'

            @loadData 
                url: "/api/classes/info/#{@classId}"
                success: (data) =>
                    @classInfo = data
                    @classInfo.levels = sortLevels(@classInfo.levels)

                    levelClassInfos = [{objectType: 'class', objectId: @classId}]
                    for level in @classInfo.levels
                        levelClassInfos.push({objectType: 'level_class', objectId: "#{level.id}/#{@classId}"})
                            
                    @loadData 
                        url: "/api/stats"
                        data: {objectInfos: levelClassInfos}
                        success: (levelClassStats) =>
                            userIdHash = {}
                            for stats in levelClassStats.stats
                                userIdHash[userId] = true for userId in (stats.users or [])
                            @users = (userId for userId of userIdHash)[(@page*5)...(@page+1)*5]
                            @nextPage = true if @users.length >= (@page+1)*5
                            
                            userLevelClassInfos = []
                            for level in @classInfo.levels
                                for userId in @users
                                    userLevelClassInfos.push(
                                        objectType: 'user_level_class'
                                        objectId: "#{userId}/#{level.id}/#{@classId}"
                                    )
                            
                            @stats = []
                            for i in [0..userLevelClassInfos.length] by 100
                                @loadData 
                                    url: "/api/stats"
                                    data: {objectInfos: userLevelClassInfos[i...i+100]}
                                    success: (userLevelClassStats) =>
                                        statsHash = {}
                                        for stat in userLevelClassStats.stats
                                            userId = stat.objectId.split('/')[0]
                                            levelId = stat.objectId.split('/')[1]
                                            statsHash[levelId] or= {}
                                            statsHash[levelId][userId] = stat
                                        
                                        for level in @classInfo.levels
                                            userInfo = []
                                            for userId in @users
                                                userStat = statsHash[level.id]?[userId]
                                                duration = (userStat?.duration or 0)
                                                seconds = Math.round(duration / 1000)
                                                minutes = Math.floor(seconds / 60)
                                                seconds = seconds - (minutes * 60)
                                                userInfo.push
                                                    level: level.name
                                                    user: userId
                                                    attempted: (if userStat then true else false)
                                                    moves: userStat?.moves or 0
                                                    hints: userStat?.hints or 0
                                                    success: (if userStat?.success?.length then true else false)
                                                    successClass: (if userStat?.hints?.length then 'hard' else userStat?.challenge?[0])
                                                    duration: "#{minutes} min, #{seconds} sec"
                                                    assessment: userStat?.challenge?.length
                                                    challenge: userStat?.challenge?[0] 
                                                    
                                            @stats.push
                                                levelName: level.name
                                                users: userInfo
                                        
                                error: () =>
                                    if window?.alert
                                        alert('We were unable to load stats for this class. Please check your internet connection.')
                                
                        error: () =>
                            if window?.alert
                                alert('We were unable to load stats for this class. Please check your internet connection.')
                
                error: () =>
                    if window?.alert
                        alert('We were unable to load info for this class. Please check your internet connection.')
                

        build: () ->
            @setTitle("Stats - The Puzzle School")
            @html = wings.renderTemplate(@template,
                className: @classInfo.name
                users: @users
                stats: @stats
                nextPage: @nextPage
                nextPageLink: "/stats/#{@classId}/{@page + 1}"
            )
        
soma.views
    Stats:
        selector: '#content .stats'
        create: ->
            $('.register_flag').hide()    

            
soma.routes
    '/stats/class/:classId': ({classId}) -> new soma.chunks.Stats(classId: classId)
    '/stats/class/:classId/:page': ({classId, page}) -> new soma.chunks.Stats(classId: classId, page: page)
        
        