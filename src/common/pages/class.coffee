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
                    error: () =>
                        if window?.alert
                            alert('We were unable to load the information for this class. Please check your internet connection.')
                

        build: () ->
            @setTitle("Your Class - The Puzzle School")
            @html = wings.renderTemplate(@template,
                id: @classInfo?.id
                className: @classInfo?.name or 'New Class'
                newClass: !@classInfo?
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
                    
            displayLevels = (puzzle, area) =>
                area.html('')
                tableHtml = '''
                    <table>
                        <tbody>
                            <th>Name</th>
                            <th>Difficulty</th>
                '''
                
                for level in @puzzles[puzzle].levels
                    levelNameComponents = level.id.split(/\//g)
                    tableHtml += """
                        <tr>
                            <td>
                                <a href='/puzzles/light_it_up/#{levelNameComponents[1..2].join('/')}' target='_blank'>
                                    #{levelNameComponents[2]}
                                </a>
                            </td>
                            <td>
                                #{level.difficulty}
                            </td>
                        </tr>
                    """
                tableHtml += '</tbody></table>'
                area.html(tableHtml)
                    
            @$('.add_a_level').bind 'click', (e) =>
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
                        displayLevels('fractions', levelSelector.find('.levels'))
                    error: => 
                        levelSelector.find('.levels').html('No levels yet')
                        
            @$('.create_level').bind 'click', (e) =>
                link = $(e.currentTarget)
                newLevel = link.closest('.level_selector').find('.new_level')
                newLevel.css(display: 'block')
                newLevel.animate(opacity: 1, duration: 250)
            
            hideNewLevel = (newLevel) =>
                newLevel.animate
                    opacity: 0
                    duration: 250
                    complete: -> newLevel.css(display: 'none')
                
            @$('.save_new_level_button').bind 'click', (e) =>
                newLevel = $(e.currentTarget).closest('.new_level')
                dataHash = newLevel.find('form').data('form').dataHash()
                dataHash.classId = @classInfo.id
                $.ajaj
                    url: '/api/puzzles/fractions/add_level'
                    method: 'POST'
                    headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                    data: dataHash
                    success: (levelInfo) =>
                        @puzzles.fractions.levels.push(levelInfo)
                        displayLevels('fractions', newLevel.find('.levels'))
                        hideNewLevel(newLevel)
                        
            @$('.cancel_new_level_button').bind 'click', (e) => 
                hideNewLevel($(e.currentTarget).closest('.new_level'))
            
            
soma.routes
    '/class': -> new soma.chunks.Class
    '/class/:id': (data) -> new soma.chunks.Class(id: data.id)
