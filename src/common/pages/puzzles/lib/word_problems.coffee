wordProblems = exports ? provide('./lib/word_problems', {})
Transformer = require('./transformer').Transformer

class wordProblems.ViewHelper    
    constructor: ({@el, @level}) ->
        @initLevel(@level)
        
    $: (selector) -> @el.find(selector)    
    clientX: (e) => (e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX) - @el.offset().left
    clientY: (e) => (e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY) - @el.offset().top
    
    initLevel: ->
        @$('.problem').html(@highlightProblem(@level.problem))
        @initNumbers()        
        
    highlightProblem: (problem) ->
        problem.replace(/(\d+)/g, '<span class=\'number\'>$1</span>')
        
    initNumbers: ->
        @transformers = {}
        for number, index in @$('.problem .number')
            number = $(number)
            id = new Date().getTime()
            settings = @level.numbers?[index]
            colorIndex = settings?.colorIndex or index + 1
            number.addClass("color_#{colorIndex}")
            number.addClass("number_#{id}")
            @createNumber(number.html(), id, colorIndex, settings?.label)
            
    createNumber: (value, id, colorIndex, label) ->
        number = $(document.createElement('DIV'))
        number.data('id', id)
        number.addClass('number')
        number.addClass("color_#{colorIndex}")
        number.addClass('small')
        number.html """
            <div class='settings'>
                <i class='icon-cog'></i>
            </div>
            <h3><span class='value'>#{value}</span>#{" #{label}" if label}</h3>
            <div class='ranges'></div>
        """
        
        number.bind 'mousedown.drag touchstart.drag', (e) =>
            startX = @clientX(e)
            startY = @clientY(e)
            
            $(document.body).bind 'mousemove.drag touchstart.drag', (e) =>
                currentX = @clientX(e)
                currentY = @clientY(e)
                @transformers[id].translate(currentX - startX, currentY - startY)
                
            $(document.body).one 'mouseup.drag touchend.drag', =>
                $(document.body).unbind 'mousemove.drag touchstart.drag'
                if not @transformers[id].dx and not @transformers[id].dy
                    if number.hasClass('small')
                        number.removeClass('small')
                    else
                        number.addClass('small')
                else
                    @transformers[id].translate(0, 0)
                
        
        @$('.numbers').append(number)
        @setNumber(number, value)
        @transformers[id] = new Transformer(number)
       
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
        container.find('.value').html("#{value}")
        container.data('value', value)
        @$(".problem .number_#{container.data('id')}").html("#{value}")
        
   