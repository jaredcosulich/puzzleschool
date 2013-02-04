transformer = exports ? provide('./transformer', {})

class transformer.Transformer
    constructor: (element) ->
        @el = $(element)
        @dx = 0
        @dy = 0

        # backface-visibility:hidden;
        # -webkit-backface-visibility:hidden; /* Chrome and Safari */
        # -moz-backface-visibility:hidden; /* Firefox */
                
    run: ->
        @el.css
            backfaceVisibility:         'hidden'
            webkitBackfaceVisibility:   'hidden'
            MozBackfaceVisibility:      'hidden'
            webkitTransform:    "matrix(1,0,0,1, #{@dx}, #{@dy})"
            MozTransform:       "matrix(1,0,0,1, #{@dx}px, #{@dy}px)"
            msTransform:        "matrix(1,0,0,1, #{@dx}, #{@dy})"
            OTransform:         "matrix(1,0,0,1, #{@dx}, #{@dy})"
            transform:          "matrix(1,0,0,1, #{@dx}, #{@dy})"

    end: -> 
        @el.css
            backfaceVisibility:         'visible'
            webkitBackfaceVisibility:   'visible'
            MozBackfaceVisibility:      'visible'
            
    translate: (dx, dy, adjustment=false) ->
        @["#{if adjustment then 'adjust' else 'set'}Translation"](dx, dy)
        @run()

    adjustTranslation: (dx, dy) ->
        @setTranslation(@dx + dx, @dy + dy)

    setTranslation: (dx, dy) ->
        @dx = dx
        @dy = dy
    