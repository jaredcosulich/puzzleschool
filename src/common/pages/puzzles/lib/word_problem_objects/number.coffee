number = exports ? provide('./number', {})
Component = require('./component').Component

class number.Number extends Component
    constructor: ({@id, @value, @colorIndex, @label, @problemNumber, container, drag}) ->
        super(container: container, drag: drag)
        @init()
        @initClick()
        
        @draggable = @el
        @initDrag()
        
    init: ->    
        @el.data('id', @id)
        @el.addClass('number')
        @el.addClass("color_#{@colorIndex}")
        @el.addClass('small')
        @el.html """
            <div class='settings'>
                <i class='icon-caret-up'></i>
                <i class='icon-cog'></i>
                <i class='icon-move'></i>
            </div>
            <h3><span class='value'>#{@value}</span>#{" #{@label}" if @label}</h3>
            <div class='ranges'></div>
        """

        @el.find('.icon-caret-up').bind 'click', => @el.addClass('small')

        @set(@value)
        
    initClick: ->
        @el.bind 'mousedown.enlarge touchstart.enlarge', (e) =>
            $(document.body).one 'mouseup.enlarge touchend.enlarge',(e) =>
                unless @transformer.dx or @transformer.dy
                    @el.removeClass('small') if @el.hasClass('small')

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
        
        if digits.length > 4
            digits = [digits[0...digits.length-4].join(''), digits[digits.length-4..digits.length]...]

        for range in @$('.range')
            $(range).remove() if parseInt($(range).data('magnitude')) >= digits.length

        for digit, m in digits
            magnitude = digits.length - m - 1
            unless (range = @$(".range_#{magnitude}")).length
                range = @createRange(magnitude, digit)

            range.css(fontSize: (10 * (magnitude + 2)))

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
