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
            selectorHtml: '<h2>Add Another Component</h2>' 
            
        @initValues()           
        
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
                component.initTag(@$('.show_values').hasClass('on')) 
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
        component.tag?.position()
    
    initValues: ->
        showValues = @$('.show_values')
        showValues.bind 'click.toggle_values touchstart.toggle_values', => 
            hideValues = showValues.hasClass('on')
            showValues.removeClass(if hideValues then 'on' else 'off')
            showValues.addClass(if hideValues then 'off' else 'on')
            for cid, component of @board.components
                component.tag[if hideValues then 'hide' else 'show']()
        
    showAllLevels: ->
        
        
    showLevel: ->
        
