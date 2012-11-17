soma = require('soma')
wings = require('wings')

soma.chunks
    SpaceFractions:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@className, @levelName}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/space_fractions.html"
            @loadScript '/build/common/pages/puzzles/lib/space_fractions.js'
            if @levelName == 'editor'
                @loadScript '/build/common/pages/puzzles/lib/space_fractions_editor.js' 
            @loadStylesheet '/build/client/css/puzzles/space_fractions.css'     
            
            @loadData 
                url: "/api/puzzles/fractions/levels/#{@className}/#{@levelName}"
                success: (@levelInfo) => 
                error: () =>
                    if window?.alert
                        alert('We were unable to load the information for this level. Please check your internet connection.')
                   
        build: ->
            @setTitle("Light It Up - The Puzzle School")
            
            rows = ({columns: [0...10]} for row in [0...10])
            @html = wings.renderTemplate(@template,
                levelName: (@levelName or '')
                custom: @levelName == 'custom'
                editor: @levelName == 'editor'
                rows: rows
                instructions: @levelInfo?.instructions
            )
            
        
soma.views
    SpaceFractions:
        selector: '#content .space_fractions'
        create: ->
            spaceFractions = require('./lib/space_fractions')
            @viewHelper = new spaceFractions.ViewHelper
                el: $(@selector)
                rows: 10
                columns: 10
                
            @initEncode()

            @levelName = @el.data('level_name')
            if not @levelName?.length
                introMessage = @$('.intro')
                introMessage.css
                    top: ($.viewport().height / 2) - (introMessage.height() / 2) + (window.scrollY)
                    left: ($.viewport().width / 2) - (introMessage.width() / 2)
                
                introMessage.animate
                    opacity: 1
                    duration: 500
                
            else if @levelName == 'editor'
                spaceFractionsEditor = require('./lib/space_fractions_editor')
                @editor = new spaceFractionsEditor.EditorHelper
                    el: $(@selector)
                    viewHelper: @viewHelper
                    encodeMethod: (json) => @encode(json)
                @$('.load_custom_level_data').bind 'click', => 
                    @$('.level_editor').css(height: 'auto')
                    @$('.load_custom_level_data').hide()
                    
            else if @levelName == 'custom'
                window.onhashchange = -> window.location.reload()
                @$('.load_custom_level_data').bind 'click', => 
                    @$('.custom_level').css(height: 'auto')
                    @$('.load_custom_level_data').hide()
                    
                @$('.load_to_play').bind 'click', =>
                    @viewHelper.loadToPlay(@$('.level_description').val())
            
            @loadLevelData(window.location.hash or @$('.level_instructions').html())
            
            @initInstructions()
                    
        loadLevelData: (instructions) ->
            return if not instructions?.length
            level = @decode(decodeURIComponent(instructions.replace(/^#/, '')))
            if @levelName == 'editor'
                @editor.levelDescription.val(level)
                @editor.load()
            else
                @$('.level_description').val(level)
                @viewHelper.loadToPlay(level)

        initInstructions: ->
            @$('.instructions_link').bind 'click', =>
                instructions = @$('.instructions')
                instructions.css
                    top: ($.viewport().height / 2) - (instructions.height() / 2) + (window.scrollY)
                    left: ($.viewport().width / 2) - (instructions.width() / 2)

                instructions.animate
                    opacity: 1
                    duration: 500
                    
                $.timeout 10, ->
                    $(document.body).one 'click', -> 
                        instructions.animate
                            opacity: 0
                            duration: 500
                            complete: ->
                                instructions.css
                                    top: -1000
                                    left: -1000
                
        initEncode: ->
            @encodeMap =
                '"objects"': '~o'
                '"type"': '~t'
                '"index"': '~i'
                '"numerator"': '~n'
                '"denominator"': '~d'
                '"fullNumerator"': '~fN'
                '"fullDenominator"': '~fD'
                '"verified"': '~v'
                'true': '~u'
                'false': '~f'
            for object of @viewHelper.objects
                @encodeMap['"' + object + '"'] = "!#{object.split(/_/ig).map((section) -> return section[0]).join('')}"
            
            @extraEncodeMap = 
                ':': '-'
                '"': '*'
                ',': "'"
                '=': '+'
                '{': '('
                '}': ')'
                
        encode: (json) ->
            for encode in (key for key of @encodeMap).sort((a,b) => b.length - a.length)
                regExp = new RegExp(encode,'g')
                json = json.replace(regExp, @encodeMap[encode])
            for extraEncode of @extraEncodeMap
                regExp = new RegExp('\\' + extraEncode,'g')
                json = json.replace(regExp, @extraEncodeMap[extraEncode])
            return json
            
        decode: (json) ->
            for encode in (key for key of @encodeMap).sort((a,b) => b.length - a.length)
                regExp = new RegExp(@encodeMap[encode],'g')
                json = json.replace(regExp, encode)
            for extraEncode of @extraEncodeMap
                regExp = new RegExp('\\' + @extraEncodeMap[extraEncode],'g')
                json = json.replace(regExp, extraEncode)
            return json
            
soma.routes
    '/puzzles/space_fractions/:className/:levelName': ({className, levelName}) -> 
        new soma.chunks.SpaceFractions
            className: className
            levelName: levelName
    
    '/puzzles/space_fractions': -> new soma.chunks.SpaceFractions

    '/puzzles/light_it_up/:className/:levelName': ({className, levelName}) -> 
        new soma.chunks.SpaceFractions
            className: className
            levelName: levelName
    
    '/puzzles/light_it_up': -> new soma.chunks.SpaceFractions
            
