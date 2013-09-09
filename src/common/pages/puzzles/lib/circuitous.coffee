circuitous = exports ? provide('./lib/circuitous', {})

for name, fn of require('./circuitous_objects/index')
    circuitous[name] = fn
    
class circuitous.ChunkHelper
    constructor: () ->
    

class circuitous.ViewHelper
    constructor: ({@el}) ->
        @init()
        
    $: (selector) -> $(selector, @el)
        
    init: ->
        @board = new circuitous.Board
            el: @$('.board')
        
    addComponent: (component) ->
        component.appendTo(@board.cells)
        img = component.el.find('img')
        img.bind 'load', =>
            component.el.css(left: -10000)
            component.el.width(img.width())
            component.el.height(img.height())
            $.timeout 10, =>
                component.initCurrent() 
                component.initDrag(
                    component.el, 
                    (component, x, y, stopDrag) => @dragComponent(component, x, y, stopDrag),
                    true,
                    component.dragBuffer
                )
        
    dragComponent: (component, x, y, state) ->
        if state == 'start'
            @board.removeComponent(component)
        else if state == 'stop'
            if not @board.addComponent(component, x, y)
                @board.removeComponent(component)
                component.resetDrag()