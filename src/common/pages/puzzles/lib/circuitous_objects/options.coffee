options = exports ? provide('./options', {})
circuitousObject = require('./object')

class options.Options extends circuitousObject.Object
    constructor: ({@el, @rows, @columns, @items}) ->
        @items or= []
        @init()
        
    $: (selector) -> $(selector, @el)   

    init: ->
        @width = @el.width()
        @height = @el.height()
        @construct()
        @initSelector()
        @attachSelector(@$('.empty_option')[0])
        @addItems()
        
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
            add: (item) => @addItem(item)
            
    attachSelector: (cell) -> @selector.attachTo(cell)    
    
    addItems: ->
        return unless @items?.length
        @addItem(item) for item in @items
    
    addItem: (item) ->
        @items.push(item)
        @attachSelector(@$('.empty_option')[1])
        emptyOption = $(@$('.empty_option')[0])
        emptyOption.append(item.imageElement())
        emptyOption.removeClass('empty_option')