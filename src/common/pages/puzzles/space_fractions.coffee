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

            spaceFractions = require('./lib/space_fractions')
            @chunkHelper = new spaceFractions.ChunkHelper()
            
            objectImages = []
            for object of @chunkHelper.objects
                if @chunkHelper.objects[object].states
                    for state in ['empty', 'under', 'full', 'over']
                        objectImages.push(@chunkHelper.objects[object].image + "_#{state}")
                else
                    objectImages.push(@chunkHelper.objects[object].image)
            
            
            rows = ({columns: [0...10]} for row in [0...10])
            @html = wings.renderTemplate(@template,
                levelName: (@levelName or '')
                custom: @levelName == 'custom'
                rows: rows
                objectImages: objectImages
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

            levelName = @el.data('level_name')
            if levelName == 'editor'
                spaceFractionsEditor = require('./lib/space_fractions_editor')
                @editor = new spaceFractionsEditor.EditorHelper
                    el: $(@selector)
                    viewHelper: @viewHelper
            else if levelName == 'custom'
                @$('.load_to_play').bind 'click', =>
                    @viewHelper.loadToPlay(@$('.level_description').val())
            
            if window.location.hash
                level = decodeURIComponent(window.location.hash.replace(/^#/, ''))
                if levelName == 'editor'
                    @editor.levelDescription.val(level)
                    @editor.load()
                else
                    @viewHelper.loadToPlay(level)

soma.routes
    '/puzzles/space_fractions/:levelName': ({levelName}) -> 
        new soma.chunks.SpaceFractions
            levelName: levelName
    
    '/puzzles/space_fractions': -> new soma.chunks.SpaceFractions
            
