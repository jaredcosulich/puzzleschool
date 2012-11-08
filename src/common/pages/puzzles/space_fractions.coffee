soma = require('soma')
wings = require('wings')

soma.chunks
    SpaceFractions:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@levelName}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/space_fractions.html"
            @loadScript '/build/common/pages/puzzles/lib/space_fractions.js'
            if @levelName == 'editor'
                @loadScript '/build/common/pages/puzzles/lib/space_fractions_editor.js' 
            @loadStylesheet '/build/client/css/puzzles/space_fractions.css'            

        build: ->
            @setTitle("Space Fractions - The Puzzle School")
            
            rows = ({columns: [0...10]} for row in [0...10])
            @html = wings.renderTemplate(@template,
                levelName: (@levelName or '')
                custom: @levelName == 'custom'
                editor: @levelName == 'editor'
                intro: !@levelName?.length
                rows: rows
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
                
            levelName = @el.data('level_name')
            if not levelName?.length
                introMessage = @$('.intro')
                introMessage.css
                    top: @el.offset().top + (@el.height() / 2) - (introMessage.height() / 2)
                    left: @el.offset().left + (@el.width() / 2) - (introMessage.width() / 2)
                introMessage.animate
                    opacity: 1
                    duration: 500
                
            else if levelName == 'editor'
                spaceFractionsEditor = require('./lib/space_fractions_editor')
                @editor = new spaceFractionsEditor.EditorHelper
                    el: $(@selector)
                    viewHelper: @viewHelper
                    encodeMethod: (json) => @encode(json)
                @$('.load_custom_level_data').bind 'click', => 
                    @$('.level_editor').css(height: 'auto')
                    @$('.load_custom_level_data').hide()
                    
            else if levelName == 'custom'
                @$('.load_custom_level_data').bind 'click', => 
                    @$('.custom_level').css(height: 'auto')
                    @$('.load_custom_level_data').hide()
                    
                @$('.load_to_play').bind 'click', =>
                    @viewHelper.loadToPlay(@$('.level_description').val())
            
            if window.location.hash
                level = @decode(decodeURIComponent(window.location.hash.replace(/^#/, '')))
                if levelName == 'editor'
                    @editor.levelDescription.val(level)
                    @editor.load()
                else
                    @$('.level_description').val(level)
                    @viewHelper.loadToPlay(level)

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
    '/puzzles/space_fractions/:levelName': ({levelName}) -> 
        new soma.chunks.SpaceFractions
            levelName: levelName
    
    '/puzzles/space_fractions': -> new soma.chunks.SpaceFractions

    '/puzzles/light_it_up/:levelName': ({levelName}) -> 
        new soma.chunks.SpaceFractions
            levelName: levelName
    
    '/puzzles/light_it_up': -> new soma.chunks.SpaceFractions
            
