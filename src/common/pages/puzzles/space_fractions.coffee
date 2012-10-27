soma = require('soma')
wings = require('wings')

soma.chunks
    SpaceFractions:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@levelName}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/space_fractions.html"
            @loadScript '/build/common/pages/puzzles/lib/space_fractions.js'
            @loadScript '/build/common/pages/puzzles/lib/space_fractions_editor.js'  if @levelName == 'editor'
            @loadStylesheet '/build/client/css/puzzles/space_fractions.css'
            

        build: ->
            @setTitle("Space Fractions - The Puzzle School")

            languageScramble = require('./lib/language_scramble')
            
            rows = ({columns: [0...10]} for row in [0...10])
            @html = wings.renderTemplate(@template,
                levelName: (@levelName or '')
                rows: rows
            )
            
            
        
soma.views
    SpaceFractions:
        selector: '#content .space_fractions'
        create: ->
            spaceFractions = require('./lib/space_fractions')
            @viewHelper = new spaceFractions.ViewHelper
                el: $(@selector)

            if @el.data('level_name') == 'editor'
                spaceFractionsEditor = require('./lib/space_fractions_editor')
                @editor = new spaceFractionsEditor.EditorHelper
                    el: $(@selector)
                    viewHelper: @viewHelper
            
            

soma.routes
    '/puzzles/space_fractions/:levelName': ({levelName}) -> 
        new soma.chunks.SpaceFractions
            levelName: levelName
    
    '/puzzles/space_fractions': -> new soma.chunks.SpaceFractions
            
