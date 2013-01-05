soma = require('soma')
wings = require('wings')

sortLevels = (levels) ->
    levels.sort (level1,level2) ->
        a = level1.difficulty + level1.name
        b = level2.difficulty + level2.name
        return if a == b then 0 else (if a < b then -1 else 1)

soma.chunks
    Class:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@id}) ->            
            @template = @loadTemplate '/build/common/templates/class.html'
            if @id
                @loadData 
                    url: "/api/classes/info/#{@id}"
                    success: (data) =>
                        @classInfo = data
                        level.classId = @classInfo.id for level in @classInfo.levels or []
                        @classInfo.levels = sortLevels(@classInfo.levels)
                    error: () =>
                        if window?.alert
                            alert('We were unable to load the information for this class. Please check your internet connection.')
                

        build: () ->
            @setTitle("Your Class - The Puzzle School")
            @html = wings.renderTemplate(@template,
                id: @classInfo?.id
                className: @classInfo?.name or 'New Class'
                newClass: !@classInfo?
                fractions_levels: (l for l in @classInfo?.levels when l.puzzle == 'fractions')
                xyflyer_levels: (l for l in @classInfo?.levels when l.puzzle == 'xyflyer')
            )
        
soma.views
    Class:
        selector: '#content .class'
        create: ->
            $('.register_flag').hide()    

            @$('form').bind 'submit', (e) => e.stop()
            @$('button').bind 'click', (e) => e.stop()
            
            @classInfo = 
                id: @el.data('id')
            
            @initSaveClass()
            @initAddALevel()
            
        initSaveClass: ->
            @$('.class_update').bind 'submit', => @saveClass()
            @$('.save_button').bind 'click', => @saveClass()
            @$('.cancel_button').bind 'click', => @go('/')

        saveClass: ->
            dataHash = @$('.class_update').data('form').dataHash()
            dataHash.id = @el.data('id')
            $.ajaj
                url: '/api/classes/update'
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: dataHash
                success: (classInfo) =>
                    @go("/class/#{classInfo.id}")
                
        initAddALevel: ->
            @puzzles = {fractions: {levels: []}, xyflyer: {levels: []}}
                                                        
            @$('.add_a_level').bind 'click', (e) => @displayLevelSelector($(e.currentTarget).data('puzzle'))
                        
            @$('.create_level').bind 'click', (e) =>
                @showNewLevelForm($(e.currentTarget).closest('.level_selector').find('.new_level'))
                            
            @$('.save_new_level_button').bind 'click', (e) => 
                @addNewLevel($(e.currentTarget).closest('.new_level'))
                        
            @$('.cancel_new_level_button').bind 'click', (e) => 
                @hideNewLevelForm($(e.currentTarget).closest('.new_level'))
                
        displayLevels: (puzzle, area) ->
            puzzleName = puzzle
            puzzleName = 'light_it_up' if puzzleName == 'fractions'
            area.html('')
            tableHtml = '''
                <table>
                    <tbody>
                        <th>Name</th>
                        <th>Difficulty</th>
                        <th>Select</th>
            '''

            for level in sortLevels(@puzzles[puzzle].levels)
                levelNameComponents = level.id.split(/\//g)
                tableHtml += """
                    <tr>
                        <td>
                            <a href='/puzzles/#{puzzleName}/#{level.id}' target='_blank'>
                                #{level.name}
                            </a>
                        </td>
                        <td>
                            #{level.difficulty}
                        </td>
                        <td>
                            <a class='select_level' data-level="#{level.id}">
                                Select
                            </a>
                        </td>
                    </tr>
                """
            tableHtml += '</tbody></table>'
            area.html(tableHtml)
            @bindLevelLinks()
        
        bindLevelLinks: ->
            @$('.select_level').unbind 'click'
            @$('.select_level').bind 'click', (e) => 
                @selectLevel($(e.currentTarget).data('level'))
        
        showNewLevelForm: (newLevel) ->
            newLevel.css(display: 'block')
            newLevel.animate(opacity: 1, duration: 250)
        
        hideNewLevelForm: (newLevel) ->
            newLevel.animate
                opacity: 0
                duration: 250
                complete: -> newLevel.css(display: 'none')

        selectLevel: (levelId) ->
            $.ajaj
                url: "/api/classes/levels/add/#{@classInfo.id}"
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: {level: levelId}
                success: (classLevels) =>
                    levelsListHtml = ''
                    for level in sortLevels(classLevels.levels)
                        console.log(level)
                        levelsListHtml += """
                            <li><a href='/puzzles/#{level.puzzle}/#{@classInfo.id}/{level.id}' target='_blank'>
                                #{level.name}
                            </a></li>
                        """                    
                    @$(".class_puzzles .#{puzzle}").html(levelsListHtml)
                    @hideLevelSelector()
        
        addNewLevel: (newLevelContainer) ->
            puzzle = newLevelContainer.data('puzzle').toLowerCase()
            dataHash = newLevelContainer.find('form').data('form').dataHash()
            dataHash.classId = @classInfo.id
            $.ajaj
                url: "/api/puzzles/#{puzzle}/add_level"
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: dataHash
                success: (levelInfo) =>
                    @puzzles[puzzle].levels.push(levelInfo)
                    @displayLevels(puzzle, newLevelContainer.closest('.level_selector').find('.levels'))
                    @hideNewLevelForm(newLevelContainer)
                    
        displayLevelSelector: (puzzle) ->
            @$('.puzzle_name').html(puzzle)
            levelSelector = @$('.level_selector')
            levelSelector.find('.new_level').data('puzzle', puzzle)
            levelSelector.css
                opacity: 0
                top: ($.viewport().height / 2) - (levelSelector.height() / 2) + (window.scrollY)
                left: ($.viewport().width / 2) - (levelSelector.width() / 2)
                    
            levelSelector.animate
                opacity: 1
                duration: 250
            
            levelSelector.bind 'click.level_selector', (e) => e.stop()
            
            $.timeout 10, =>    
                $(document.body).one 'click.level_selector', =>                 
                    levelSelector.animate
                        opacity: 1
                        duration: 250
                        complete: =>
                            levelSelector.css
                                opacity: 0
                                top: -1000
                                left: -1000
                        
                
            lowerPuzzle = puzzle.toLowerCase()
            $.ajaj
                url: "/api/puzzles/#{lowerPuzzle}/levels"
                method: 'GET'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                success: (levelData) =>
                    @puzzles[lowerPuzzle].levels = levelData.levels or []
                    @displayLevels(lowerPuzzle, levelSelector.find('.levels'))
                error: => 
                    levelSelector.find('.levels').html('No levels yet')
                    
        hideLevelSelector: ->
            levelSelector = @$('.level_selector')                    
            levelSelector.animate
                opacity: 0
                duration: 250
                complete: =>
                    levelSelector.css
                        top: -1000
                        left: -1000
                    
            
            
soma.routes
    '/class': -> new soma.chunks.Class
    '/class/:id': ({id}) -> new soma.chunks.Class(id: id)
