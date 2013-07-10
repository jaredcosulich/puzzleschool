soma = require('soma')
wings = require('wings')

soma.chunks
    Circuitous:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/circuitous.html"
            
            @loadScript '/build/common/pages/puzzles/lib/circuitous.js'
            
            @loadStylesheet '/build/client/css/puzzles/circuitous.css'     
            
                      
        build: ->
            @setTitle("Circuitous - The Puzzle School")
            @loadElement("link", {rel: 'img_src', href: 'http://www.puzzleschool.com/assets/images/reviews/xyflyer.jpg'})
            
            @setMeta('og:title', 'Circuitous - The Puzzle School')            
            @setMeta('og:url', 'http://www.puzzleschool.com/puzzles/circuitous')
            @setMeta('og:image', 'http://www.puzzleschool.com/assets/images/reviews/circuitous.jpg')
            @setMeta('og:site_name', 'The Puzzle School')
            @setMeta('og:description', 'Explore circuits through simple challenges you can solve in creative ways.')
            @setMeta('description', 'Explore circuits through simple challenges you can solve in creative ways.')
            
            @html = wings.renderTemplate(@template)
            
        
soma.views
    Circuitous:
        selector: '#content .circuitous'
        create: ->
        
        
            
soma.routes
    '/puzzles/circuitous/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Circuitous
            classId: classId
            levelId: levelId

    '/puzzles/circuitous/:levelId': ({levelId}) -> 
        new soma.chunks.Circuitous
            levelId: levelId
    
    '/puzzles/circuitous': -> new soma.chunks.Circuitous

