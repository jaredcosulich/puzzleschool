soma = require('soma')
wings = require('wings')

sortLevels = (levels) ->
    levels.sort (level1,level2) ->
        a = level1.difficulty + level1.id
        b = level2.difficulty + level2.id
        return if a == b then 0 else (if a < b then -1 else 1)

soma.chunks
    Stats:
        pageSize: 10
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
                    for info in @classInfo.levels
                        levelId = info.id or info
                        levelClassInfos.push({objectType: 'level_class', objectId: "#{levelId}/#{@classId}"})
                            
                    @loadData 
                        url: "/api/stats"
                        data: {objectInfos: levelClassInfos}
                        success: (levelClassStats) =>
                            userIdHash = {}
                            for stats in levelClassStats.stats
                                userIdHash[userId] = true for userId in (stats.users or [])
                            @users = (userId for userId of userIdHash).sort()
                            @nextPage = true if @users.length >= (@page+1)*@pageSize
                            
                            userLevelClassInfos = []
                            for info in @classInfo.levels
                                levelId = info.id or info
                                for userId in @users[@pageSize * @page...@pageSize * (@page + 1)]
                                    userLevelClassInfos.push(
                                        objectType: 'user_level_class'
                                        objectId: "#{userId}/#{levelId}/#{@classId}"
                                    )
                            
                            @statsHash = {}
                            for i in [0..userLevelClassInfos.length] by 100
                                @loadData 
                                    url: "/api/stats"
                                    data: {objectInfos: userLevelClassInfos[i...i+100]}
                                    success: (userLevelClassStats) =>
                                        for stat in userLevelClassStats.stats
                                            userId = stat.objectId.split('/')[0]
                                            levelId = stat.objectId.split('/')[1]
                                            @statsHash[userId] or= {}

                                            duration = (stat.duration or 0)
                                            seconds = Math.round(duration / 1000)
                                            minutes = Math.floor(seconds / 60)
                                            seconds = seconds - (minutes * 60)
                                            @statsHash[userId][levelId] = 
                                                level: levelId
                                                user: userId
                                                attempted: true
                                                moves: stat.moves or 0
                                                hints: stat.hints or 0
                                                success: (if stat.success?.length then true else false)
                                                successClass: (if stat.hints?.length then 'hard' else stat.challenge?[0])
                                                duration: "#{minutes} min, #{seconds} sec"
                                                assessment: stat.challenge?.length
                                                challenge: stat.challenge?[0] 
                                                    
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
            @stats = []
            for user, levelInfo of @statsHash
                levels = []
                for info in @classInfo.levels
                    levelId = info.id or info
                    info = levelInfo[levelId] or {user: user, attempted: false, moves: 0, hints: 0, success: false}
                    info.level = info.name or levelId
                    levels.push(info)
                @stats.push
                    user: user
                    levels: levels
                    
            @stats.sort((a,b) -> (if a.user > b.user then 1 else (if a.user < b.user then -1 else 0)))

            @setTitle("Stats - The Puzzle School")
            @html = wings.renderTemplate(@template,
                className: @classInfo.name
                users: @users
                stats: @stats
                nextPage: @nextPage
                nextPageLink: "/stats/class/#{@classId}/#{@page + 1}"            
                previousPage: @page > 0
                previousPageLink: "/stats/class/#{@classId}/#{@page - 1}"            
            )
        
soma.views
    Stats:
        selector: '#content .stats'
        create: ->
            $('.register_flag').hide()    

            
soma.routes
    '/stats/class/:classId': ({classId}) -> new soma.chunks.Stats(classId: classId)
    '/stats/class/:classId/:page': ({classId, page}) -> new soma.chunks.Stats(classId: classId, page: page)
        
        