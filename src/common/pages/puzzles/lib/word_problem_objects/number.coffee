number = exports ? provide('./number', {})
Transformer = require('../common_objects/transformer').Transformer
Client = require('../common_objects/client').Client

class number.Number
    constructor: ({@container, @problemNumber, @id, @value, @colorIndex, @label, @drop}) ->
        @init()
        
    $: (selector) -> @el.find(selector)    
    
    init: ->    
        @el = $(document.createElement('DIV'))
        @el.data('id', @id)
        @el.addClass('number')
        @el.addClass("color_#{@colorIndex}")
        @el.addClass('small')
        @el.html """
            <div class='settings'>
                <i class='icon-cog'></i>
                <i class='icon-move'></i>
            </div>
            <h3><span class='value'>#{@value}</span>#{" #{@label}" if @label}</h3>
            <div class='ranges'></div>
        """

        @transformer = new Transformer(@el)
        @el.bind 'mousedown.drag touchstart.drag', (e) =>
            startX = Client.x(e, @container)
            startY = Client.y(e, @container)

            $(document.body).bind 'mousemove.drag touchstart.drag', (e) =>
                currentX = Client.x(e, @container)
                currentY = Client.y(e, @container)
                @transformer.translate(currentX - startX, currentY - startY)

            $(document.body).one 'mouseup.drag touchend.drag',(e) =>
                $(document.body).unbind 'mousemove.drag touchstart.drag'
                if not @transformer.dx and not @transformer.dy
                    if @el.hasClass('small')
                        @el.removeClass('small')
                    else
                        @el.addClass('small')
                else
                    @drop(@, Client.x(e, @container), Client.y(e, @container))
                    @transformer.translate(0, 0)

        @container.append(@el)
        @set(@value)

    createRange: (magnitude) ->
        range = $(document.createElement('DIV'))
        range.addClass('range')
        range.addClass("range_#{magnitude}")
        range.data('magnitude', magnitude)
        for i in [1..10]
            do (i) =>
                index = $(document.createElement('DIV'))
                index.addClass('index')
                label = $(document.createElement('DIV'))
                label.addClass('label')
                label.html("#{i * Math.pow(10, magnitude)}")
                index.append(label)
                range.append(index)
                index.bind 'click', => 
                    digits = @asDigits()
                    changingDigit = digits.length - magnitude - 1
                    digits[changingDigit] = if parseInt(digits[changingDigit]) == i then i - 1 else i
                    if digits[changingDigit] == 0 and parseInt(digits[changingDigit + 1]) == 0 
                        digits[changingDigit + 1] = 9
                    @set(digits.join(''))

        @$('.ranges').prepend(range)
        return range

    asDigits: -> @value.toString().match(/\d/g)

    set: (value) ->             
        @value = parseInt(value)
        digits = @asDigits()
        for range in @$('.range')
            $(range).remove() if parseInt($(range).data('magnitude')) >= digits.length

        for digit, m in digits
            magnitude = digits.length - m - 1
            unless (range = @$(".range_#{magnitude}")).length
                range = @createRange(magnitude, digit)

            range.css(fontSize: 50 - (10 * m))

            for index, i in range.find('.index')
                index = $(index)
                if (i + 1) > parseInt(digit)
                    index.removeClass('icon-circle')
                    index.addClass('icon-circle-blank') unless index.hasClass('icon-circle-blank')
                else
                    index.removeClass('icon-circle-blank')
                    index.addClass('icon-circle') unless index.hasClass('icon-circle')
        @$('.value').html("#{@value}")
        @el.data('value', @value)
        @problemNumber.html("#{@value}")
