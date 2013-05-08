transformer = exports ? provide('./transformer', {})

class transformer.Transformer
    constructor: (element) ->
        @el = $(element)
        @dx = 0
        @dy = 0

    run: ->
        @el.css
            webkitTransform:    "matrix(1,0,0,1, #{@dx}, #{@dy})"
            MozTransform:       "matrix(1,0,0,1, #{@dx}px, #{@dy}px)"
            msTransform:        "matrix(1,0,0,1, #{@dx}, #{@dy})"
            OTransform:         "matrix(1,0,0,1, #{@dx}, #{@dy})"
            transform:          "matrix(1,0,0,1, #{@dx}, #{@dy})"

    translate: (dx, dy, adjustment=false) ->
        @["#{if adjustment then 'adjust' else 'set'}Translation"](dx, dy)
        @run()

    adjustTranslation: (dx, dy) ->
        @setTranslation(@dx + dx, @dy + dy)

    setTranslation: (dx, dy) ->
        @dx = dx
        @dy = dy
