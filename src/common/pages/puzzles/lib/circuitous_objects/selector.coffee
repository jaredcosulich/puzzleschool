selector = exports ? provide('./selector', {})
circuitousObject = require('./object')

class selector.Selector extends circuitousObject.Object
    constructor: ({@add}) ->
        @init()

    init: ->
        @construct()
        
    construct: ->
        @el = $(document.createElement('DIV'))
        @el.addClass('selector')
        
        @button = $(document.createElement('A'))
        @button.addClass('button')
        @button.html('+')
        @el.append(@button)
        
        @dialog = $(document.createElement('DIV'))
        @dialog.addClass('dialog')
        @el.append(@dialog)
        
        
    attachTo: (container) ->
        container = $(container)
        @el.remove()
        container.append(@el)
