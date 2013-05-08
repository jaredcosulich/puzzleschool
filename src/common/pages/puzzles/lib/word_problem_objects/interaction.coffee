interaction = exports ? provide('./interaction', {})

class interaction.Interaction
    constructor: ({@container}) ->
        @init()
        
    init: ->    
        @el = $(document.createElement('DIV'))
        @el.addClass('interaction')
        @el.html '''
            <div class='label'>
                9 - 6 = 4
            </div>
            <div class='visual'></div>
        '''
        @container.append(@el)
    
    over: (x, y, highlight) ->
        offset = @el.offset()
        
        over = x > offset.left and
               x < offset.left + offset.width and
               y > offset.top and
               y < offset.top + offset.height
        
        if highlight and over
            @el.addClass('highlight')
        else 
            @el.removeClass('highlight')
        
        return over
        
        
    accept: (number) ->
        
