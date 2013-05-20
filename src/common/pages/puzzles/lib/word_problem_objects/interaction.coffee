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
        
        
    accept: ({number, operator}) ->
        if number
            @numbers.push(number)
        else if operator
            @operators.push(operator)
        @display()
        
    display: ->
        @label.html('')
        @visual.html('')
        if @numbers.length == 1
            @showNumber() 
        else
            @showAddition()
        
        @centerLabel()
        
    centerLabel: ->
        @label.css(marginLeft: (@el.width() - @label.width()) / 2)
        
    showNumber: ->
        number = @numbers[0]
        @label.append(@createReference(number, true))
        @addIcon(number.colorIndex) for i in [1..number.value]
            
    
    createReference: (number, showLabel) ->
        container = $(document.createElement('DIV'))
        container.addClass('container')
        container.addClass("color_#{number.colorIndex}")
        container.html """
            <div class='reference'>
                #{number.value}
                #{if showLabel and number.label then (' ' + number.label) else ''}
            </div>
        """
        return container

    createOperator: (type) ->
        container = $(document.createElement('DIV'))
        container.addClass('container')
        container.html """
            <div class='operator'>#{type}</div>
        """
        return container
                
    addIcon: (colorIndex) ->
        @visual.append("<i class='icon-circle color_#{colorIndex}'></i>")
    
    showAddition: ->
        @addIcon(@numbers[0].colorIndex) for i in [1..@numbers[0].value]
        @visual.append('<div>+</div>')
        @addIcon(@numbers[1].colorIndex) for i in [1..@numbers[1].value]
        @label.append(@createReference(@numbers[0]))
        @label.append(@createOperator('+'))
        @label.append(@createReference(@numbers[1]))
        
        
        
        
        