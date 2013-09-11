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

        @selector = new circuitous.Selector
            add: (component) => @addComponent(component, true)
            button: @$('.add_component')
            selectorHtml: 'Add Another Component'            
        
    addComponent: (component, onBoard=false) ->
        component.appendTo(@board.cells)
        component.setName("#{component.constructor.name} ##{1}")
        img = component.el.find('img')
        component.el.css(left: if onBoard then 10 else -10000)
        img.bind 'load', =>
            component.el.width(img.width())
            component.el.height(img.height())
            $.timeout 10, =>
                component.initCurrent()
                component.initTag() 
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
                
