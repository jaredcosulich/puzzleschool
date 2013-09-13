selector = exports ? provide('./selector', {})
circuitousObject = require('./object')

selector.ITEM_TYPES = [
    'Battery'
    'Resistor'
    'Lightbulb'
    # 'Light Emitting Diode'
    # 'Toggle Switch'
]

class selector.Selector extends circuitousObject.Object
    constructor: ({@container, @add, @button, selectorHtml}) ->
        selectorHtml or= '''
            <h2>Select An Item</h2>
            <p>Click an item below to add it to the list.</p>
        '''
        @init(selectorHtml)

    init: (selectorHtml) ->
        @construct(selectorHtml)
        @initButton()
        
    construct: (selectorHtml) ->
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
                item = selector.ITEM_TYPES[row * columns + column]
                continue if not item
                do (item) =>
                    itemObject = new circuitous[item.replace(/\s/g, '')]()
                    itemCell = $(document.createElement('TD'))
                    itemCell.addClass('item')
                    itemCell.width("#{100 / columns}%")
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
        @container.append(@dialog)
                
    overallContainer: -> @button.closest('.circuitous')            
    
    itemFileName: (item) -> item.toLowerCase().replace(/\s/g, '_')
        
    initButton: () ->
        @button.bind 'click.toggle_selector', => @toggleDialog()
        @containerOffset = @container.offset()

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
        @dialog.css
            top: (@containerOffset.height - @dialog.height()) / 2
            left: (@containerOffset.width - @dialog.width()) / 2
        
        @dialog.animate(opacity: 1, duration: 250)
        $.timeout 100, => $(document.body).one 'mouseup.hide_selector', => @hide()
        
        