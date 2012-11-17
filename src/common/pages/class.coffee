soma = require('soma')
wings = require('wings')

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
                        level.classId = @classInfo.id for level in @classInfo.levels
                    error: () =>
                        if window?.alert
                            alert('We were unable to load the information for this class. Please check your internet connection.')
                

        build: () ->
            @setTitle("Your Class - The Puzzle School")
            @html = wings.renderTemplate(@template,
                id: @classInfo?.id
                className: @classInfo?.name or 'New Class'
                newClass: !@classInfo?
                levels: @classInfo?.levels
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
            @puzzles = {fractions: {levels: []}}
                                                        
            @$('.add_a_level').bind 'click', (e) => @displayLevelSelector()
                        
            @$('.create_level').bind 'click', (e) =>
                @showNewLevelForm($(e.currentTarget).closest('.level_selector').find('.new_level'))
                            
            @$('.save_new_level_button').bind 'click', (e) => 
                @addNewLevel($(e.currentTarget).closest('.new_level'))
                        
            @$('.cancel_new_level_button').bind 'click', (e) => 
                @hideNewLevelForm($(e.currentTarget).closest('.new_level'))
                
        displayLevels: (puzzle, area) ->
            area.html('')
            tableHtml = '''
                <table>
                    <tbody>
                        <th>Name</th>
                        <th>Difficulty</th>
                        <th>Select</th>
            '''

            for level in @puzzles[puzzle].levels
                levelNameComponents = level.id.split(/\//g)
                tableHtml += """
                    <tr>
                        <td>
                            <a href='/puzzles/light_it_up/#{level.id}' target='_blank'>
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
                    console.log(classLevels)
        
        addNewLevel: (newLevelContainer) ->
            dataHash = newLevelContainer.find('form').data('form').dataHash()
            dataHash.classId = @classInfo.id
            $.ajaj
                url: '/api/puzzles/fractions/add_level'
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: dataHash
                success: (levelInfo) =>
                    @puzzles.fractions.levels.push(levelInfo)
                    @displayLevels('fractions', newLevelContainer.find('.levels'))
                    @hideNewLevelForm(newLevelContainer)
                    
        displayLevelSelector: () ->
            levelSelector = @$('.level_selector')
            levelSelector.css
                opacity: 0
                top: 100
                left: 100
                    
            levelSelector.animate
                opacity: 1
                duration: 250
                
            $.ajaj
                url: '/api/puzzles/fractions/levels'
                method: 'GET'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                success: (levelData) =>
                    @puzzles.fractions.levels = levelData.levels or []
                    @displayLevels('fractions', levelSelector.find('.levels'))
                error: => 
                    levelSelector.find('.levels').html('No levels yet')
            
            
soma.routes
    '/class': -> new soma.chunks.Class
    '/class/:id': (data) -> new soma.chunks.Class(id: data.id)
