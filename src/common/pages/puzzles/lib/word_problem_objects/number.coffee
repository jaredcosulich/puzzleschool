number = exports ? provide('./number', {})
Transformer = require('../common_objects/transformer').Transformer
Client = require('../common_objects/client').Client

class number.Number
    constructor: ({@container, @problemNumber, @id, @value, @colorIndex, @label}) ->
        @init()
        
    init: ->    
        number = $(document.createElement('DIV'))
        number.data('id', @id)
        number.addClass('number')
        number.addClass("color_#{@colorIndex}")
        number.addClass('small')
        number.html """
            <div class='settings'>
                <i class='icon-cog'></i>
            </div>
            <h3><span class='value'>#{@value}</span>#{" #{@label}" if @label}</h3>
            <div class='ranges'></div>
        """

        @transformer = new Transformer(number)
        number.bind 'mousedown.drag touchstart.drag', (e) =>
            startX = Client.x(e, @container)
            startY = Client.y(e, @container)

            $(document.body).bind 'mousemove.drag touchstart.drag', (e) =>
                currentX = Client.x(e, @container)
                currentY = Client.y(e, @container)
                @transformer.translate(currentX - startX, currentY - startY)

            $(document.body).one 'mouseup.drag touchend.drag', =>
                $(document.body).unbind 'mousemove.drag touchstart.drag'
                if not @transformer.dx and not @transformer.dy
                    if number.hasClass('small')
                        number.removeClass('small')
                    else
                        number.addClass('small')
                else
                    @transformer.translate(0, 0)

        @container.append(number)
        @setNumber(number, @value)

    createRange: (container, magnitude) ->
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
                    digits = @getDigits(@getNumber(container))
                    changingDigit = digits.length - magnitude - 1
                    digits[changingDigit] = if parseInt(digits[changingDigit]) == i then i - 1 else i
                    if digits[changingDigit] == 0 and parseInt(digits[changingDigit + 1]) == 0 
                        digits[changingDigit + 1] = 9
                    @setNumber(container, digits.join(''))

        container.find('.ranges').prepend(range)
        return range

    getNumber: (container) -> container.data('value')    
    getDigits: (number) -> number.toString().match(/\d/g)

    setNumber: (container, value) ->             
        value = parseInt(value)
        digits = @getDigits(value)
        for range in container.find('.range')
            $(range).remove() if parseInt($(range).data('magnitude')) >= digits.length

        for digit, m in digits
            magnitude = digits.length - m - 1
            unless (range = container.find(".range_#{magnitude}")).length
                range = @createRange(container, magnitude, digit)

            range.css(fontSize: 50 - (10 * m))

            for index, i in range.find('.index')
                index = $(index)
                if (i + 1) > parseInt(digit)
                    index.removeClass('icon-circle')
                    index.addClass('icon-circle-blank') unless index.hasClass('icon-circle-blank')
                else
                    index.removeClass('icon-circle-blank')
                    index.addClass('icon-circle') unless index.hasClass('icon-circle')
        container.find('.value').html("#{@value}")
        container.data('value', @value)
        @problemNumber.html("#{@value}")
