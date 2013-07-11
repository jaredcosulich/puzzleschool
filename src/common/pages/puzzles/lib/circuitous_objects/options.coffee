options = exports ? provide('./options', {})
circuitousObject = require('./object')

class options.Options extends circuitousObject.Object
    constructor: ({@el, @rows, @columns, @items}) ->
        @init()
        
    $: (selector) -> $(selector, @el)   

    init: ->
        @width = @el.width()
        @height = @el.height()
        @construct()
        @initSelector()
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
            
        @selector.attachTo(@$('.empty_option')[0])
    
    addItems: ->
        return unless @items?.length
        @addItem(item) for item in @items
    
    addItem: (item) ->
        console.log(item)