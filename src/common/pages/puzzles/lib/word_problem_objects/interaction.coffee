interaction = exports ? provide('./interaction', {})

class interaction.Interaction
    constructor: ({@container}) ->
        @numbers = []
        @init()
        
    init: ->    
        @el = $(document.createElement('DIV'))
        @el.addClass('interaction')
        
        @label = $(document.createElement('DIV'))
        @label.addClass('label')
        @el.append(@label)

        @visual = $(document.createElement('DIV'))
        @visual.addClass('visual')
        @el.append(@visual)

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
        @numbers.push(number)
        @display()
        
    display: ->
        @label.html('')
        @visual.html('')
        if @numbers.length == 1
            @showNumber() 
            return
            
        @showAddition()
        
    showNumber: ->
        number = @numbers[0]
        @label.html("#{number.value}#{' ' + number.label if number.label}")
        for i in [1..number.value]
            @visual.append("<i class='icon-circle color_#{number.colorIndex}'></i>")
                
    showAddition: ->
        @showNumber()
        addedNumber = @numbers[1]
        @visual.append('<div>+</div>')
        for i in [1..addedNumber.value]
            @visual.append("<i class='icon-circle color_#{addedNumber.colorIndex}'></i>")
        @label.html("#{@numbers[0].value} + #{addedNumber.value} = #{@numbers[0].value + addedNumber.value}")
        
        
        
        