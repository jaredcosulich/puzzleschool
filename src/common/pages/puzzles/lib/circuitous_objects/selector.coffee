selector = exports ? provide('./selector', {})
circuitousObject = require('./object')

selector.ITEM_TYPES = [
    'Battery'
    'Resistor'
    'Lightbulb'
    'Toggle Switch'
]

class selector.Selector extends circuitousObject.Object
    constructor: ({@add, selectorHtml}) ->
        selectorHtml or= '''
            <h2>Select An Item</h2>
            <p>Click an item below to add it to the list.</p>
        '''
        @init(selectorHtml)

    init: (selectorHtml) ->
        @construct(selectorHtml)
        
    construct: (selectorHtml) ->
        @button = $(document.createElement('A'))
        @button.addClass('selector_button')
        @button.html('+')
        
        @dialog = $(document.createElement('DIV'))
        @dialog.addClass('selector_dialog')
        @dialog.html(selectorHtml)
        @dialog.bind 'mousedown.do_not_close click.do_not_close mouseup.do_not_close', (e) => e.stop()
        
        itemTable = $(document.createElement('TABLE'))
        itemTable.addClass('items')
        columns = Math.ceil(Math.sqrt(selector.ITEM_TYPES.length))
        for row in [0...Math.ceil(selector.ITEM_TYPES.length / columns)]
            itemRow = $(document.createElement('TR'))
            for column in [0...columns]
                do (row, column, columns) =>
                    item = selector.ITEM_TYPES[row * columns + column]
                    itemObject = new circuitous[item.replace(/\s/g, '')]()
                    itemCell = $(document.createElement('TD'))
                    itemCell.addClass('item')
                    itemCell.html """
                        #{itemObject.imageElement()}
                        <div>#{item}</div>
                    """
                    itemCell.bind 'click', => 
                        @add(new circuitous[item.replace(/\s/g, '')]())
                        @hide()
                        
                    itemRow.append(itemCell)
            itemTable.append(itemRow)
        @dialog.append(itemTable)
                
    itemFileName: (item) -> item.toLowerCase().replace(/\s/g, '_')
        
    attachTo: (container) ->
        @container = $(container)
        @button.remove()
        @container.append(@button)
        @button.bind 'click.toggle_selector', => @toggleDialog()
        
        unless @overallContainer
            @overallContainer = @container.closest('.circuitous')
            @overallContainer.append(@dialog)

    toggleDialog: ->
        if parseInt(@dialog.css('opacity')) > 0 then @hide() else @show()
            
    hide: ->
        $(document.body).unbind('mouseup.hide_selector')
        @dialog.animate
            opacity: 0
            duration: 250
            complete: =>
                @dialog.css
                    top: -10000
                    left: -10000
        
    show: ->
        areaOffset = @overallContainer.offset()
        @dialog.css
            top: (areaOffset.height - @dialog.height()) / 2
            left: (areaOffset.width - @dialog.width()) / 2
        
        @dialog.animate(opacity: 1, duration: 250)
        $.timeout 100, => $(document.body).one 'mouseup.hide_selector', => @hide()
        
        