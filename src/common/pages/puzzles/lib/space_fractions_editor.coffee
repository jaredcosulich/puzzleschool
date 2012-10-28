spaceFractionsEditor = exports ? provide('./lib/space_fractions_editor', {})

class spaceFractionsEditor.EditorHelper
    constructor: ({@el, @viewHelper}) ->
        @initElementSelector()
        @initSquares()
        
    $: (selector) -> $(selector, @el)
    
    initElementSelector: ->
        @elementSelector = $(document.createElement('DIV'))
        @elementSelector.addClass('element_selector')

        @initObjectSelector()
        @initFractionSelector()

        @el.append(@elementSelector)
        
    initObjectSelector: ->    
        objectSelector = $(document.createElement('DIV'))
        objectSelector.addClass('selector')
        objectSelector.addClass('object_selector')
        for objectType of @viewHelper.objects
            do (objectType) =>
                object = @viewHelper.objects[objectType]
                objectContainer = $(document.createElement('DIV'))
                objectContainer.addClass('object')
                objectContainer.data('object_type', objectType)
                objectContainer.bind 'click', => @addObject(objectType)

                objectImage = $(document.createElement('IMG'))
                objectImage.attr('src', object.image)
            
                objectContainer.append(objectImage)
                objectSelector.append(objectContainer)
        @elementSelector.append(objectSelector)
    
    initFractionSelector: ->
        @fractionSelector = $(document.createElement('DIV'))
        @fractionSelector.html """
            <h2>Select A Fraction</h2>
            <p>What fraction of laser should this object use?</p>
            <p>
                <input name='numerator' class='numerator' type='text' value='1'/>
                <span class='solidus'>/</span>
                <input name='denominator' class='denominator' type='text' value='1'/>
            </p>
            <p class='fraction'>Fraction: 1/1 or #{Math.round(1000 * (1/1)) / 1000}</p>
            <button class='set_fraction'>Set</button>
            <br/>
            <p><a class='select_new_object'>< Select a different object</a></p>
        """
        
        @fractionSelector.find('.numerator, .denominator').bind 'keyup', => @displayFractionValue()
        setFraction = @fractionSelector.find('.set_fraction')
        setFraction.bind 'click', =>
            @[setFraction.data('callback')](
                @fractionSelector.find('.numerator').val(), 
                @fractionSelector.find('.denominator').val()
            )
            @closeElementSelector()
                        
        @fractionSelector.find('.select_new_object').bind 'click', => @showSelector('object')
                            
        @fractionSelector.addClass('selector')
        @fractionSelector.addClass('fraction_selector')
        @fractionSelector.hide()
        @elementSelector.append(@fractionSelector)
        
    setFractionValue: (numeratorVal=1, denominatorVal=1) ->
        @fractionSelector.find('.numerator').val(numeratorVal)
        @fractionSelector.find('.denominator').val(denominatorVal)
        @displayFractionValue()

    displayFractionValue: ->
        numeratorVal = @fractionSelector.find('.numerator').val()
        denominatorVal = @fractionSelector.find('.denominator').val()
        @fractionSelector.find('.fraction').html(
            "Fraction: #{numeratorVal}/#{denominatorVal} or #{Math.round(1000 * (numeratorVal/denominatorVal)) / 1000}"
        )
        
    initSquares: ->
        @$('.board .square').bind 'click', (e) =>
            @$('.board .selected').removeClass('selected')
            square = $(e.currentTarget)
            square.addClass('selected')
            @showElementSelector(square)
            
    showElementSelector: (square) ->
        square = $(square)
        offset = square.offset()
        
        @elementSelector.css
            opacity: 0
            top: offset.top + offset.height + 6
            left: offset.left + (offset.width / 2) - (@elementSelector.offset().width / 2)

        @showObjectSelector() 

        @elementSelector.animate
            opacity: 1
            duration: 250
        
            
    closeElementSelector: ->
        @$('.board .selected').removeClass('selected')
        @elementSelector.animate
            opacity: 0
            duration: 250
            complete: =>
                @elementSelector.css
                    top: -1000
                    left: -1000

    addObject: (objectType) ->
        selectedSquare = @$('.board .selected')
        @viewHelper.addObjectToBoard(objectType, selectedSquare)
        
        object = @viewHelper.objects[objectType]
        @showObjectSelector()
        
    showObjectSelector: ->
        selectedSquare = @$('.board .selected')
        
        if not selectedSquare.hasClass('occupied')
            @showSelector('object')
            return
        
        object = @viewHelper.objects[selectedSquare.data('object_type')]
        if (object.distribute and not object.accept) or (object.accept and not object.distribute)
            @setFractionValue(selectedSquare.data('numerator') or 1, selectedSquare.data('denominator') or 1)
            @fractionSelector.find('.set_fraction').data('callback', 'setObjectFraction')
            @showSelector('fraction')
        else
            @closeElementSelector()
        
    setObjectFraction: (numerator, denominator) ->
        selectedSquare = @$('.board .selected')
        selectedSquare.data('numerator', numerator)
        selectedSquare.data('denominator', denominator)
        selectedSquare.attr('title', "Fraction: #{numerator}/#{denominator}")
        @viewHelper.fireLaser(selectedSquare)
            
    showSelector: (selectorPage) ->
        selectors = @elementSelector.find('.selector')
        selector = @elementSelector.find(".#{selectorPage}_selector")
        
        if parseInt(@elementSelector.css('opacity'))
            selectors.animate
                opacity: 0
                duration: 250
                complete: =>
                    selectors.hide()
                    selector.css
                        opacity: 0
                        display: 'block'
                    selector.animate
                        opacity: 1
                        duration: 250
        else   
                selectors.hide()
            selector.css
                opacity: 1
                display: 'block'
        