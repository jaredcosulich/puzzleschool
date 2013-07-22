options = exports ? provide('./options', {})
circuitousObject = require('./object')

class options.Options extends circuitousObject.Object
    constructor: ({@el, @rows, @columns, @components, @board}) ->
        @components or= []
        @init()
        
    $: (selector) -> $(selector, @el)   

    init: ->
        @width = @el.width()
        @height = @el.height()
        @construct()
        @initSelector()
        @attachSelector(@$('.empty_option')[0])
        @addComponents()
        
    construct: ->
        for row in [1..@rows]
            optionRow = $(document.createElement('TR'))
            for column in [1..@columns]
                option = $(document.createElement('TD'))
                option.addClass('option')
                option.addClass("option_#{row * column}")
                option.addClass('empty_option')
                option.css
                    width: @width / @columns
                    height: @height / @rows
                optionRow.append(option)
            @el.append(optionRow)
            
    initSelector: ->
        @selector = new circuitous.Selector
            add: (component) => @addComponent(component)
            
    attachSelector: (cell) -> @selector.attachTo(cell)    
    
    addComponents: ->
        return unless @components?.length
        @addComponent(component) for component in @components
    
    addComponent: (component) ->
        @components.push(component)
        @attachSelector(@$('.empty_option')[1])
        emptyOption = $(@$('.empty_option')[0])
        component.appendTo(emptyOption)
        emptyOption.removeClass('empty_option')
        $.timeout 10, => 
            component.initDrag(
                component.el, 
                (component, x, y, stopDrag) => @dragComponent(component, x, y, stopDrag),
                true
            )

    dragComponent: (component, x, y, stopDrag) ->
        if stopDrag
            if not @board.addComponent(component, x, y)
                @board.removeComponent(component)
                component.resetDrag()