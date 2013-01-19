propertiesEditor = exports ? provide('./properties_editor', {})
Bubble = require('./bubble').Bubble
Slider = require('./slider').Slider

class propertiesEditor.PropertiesEditor
    width: 210
    spacing: 20
    backgroundColor: '#49494A'
    
    constructor: ({@element, @paper, @properties, @name}) -> 
        @init()
        
    $: (selector) -> @el.find(selector)
    
    init: ->
        @height = (Object.keys(@properties).length * @spacing) + (@spacing*2)
        bbox = @element.getBBox()                
        @bubble = new Bubble
            paper: @paper
            x: bbox.x + (bbox.width/2)
            y: bbox.y
            width: @width
            height: @height
            
        
    createProperties: (container) ->
        bbox = container.getBBox()
        title = @paper.text(bbox.x + (@width/2), bbox.y + 18, @name)
        title.attr(fill: 'white', stroke: 'none', 'font-size': 14)
        container.push(title)
        propertiesDisplayed = 0
        for propertyId, property of @properties
            do (property) =>    
                y = bbox.y + (@spacing*2) + (propertiesDisplayed * @spacing)
                name = @paper.text(bbox.x + 12, y, property.name.toLowerCase())
                name.attr
                    fill: '#ccc'
                    stroke: 'none'
                    'font-size': 12, 
                    'font-weight': 1
                    'text-anchor': 'start'
                container.push(name)
                propertiesDisplayed += 1
                
                if property.type == 'slider'
                    slider = new Slider
                        paper: @paper
                        x: bbox.x + 72
                        y: y
                        width: 60
                        min: 0
                        max: property.max
                        unit: property.unit
                    slider.addListener (value) =>   
                        property.value = value
                        @display(property)
                        
                    property.object = slider
                    container.push(slider.el)
                @display(property, container, bbox.x + 144, y)
                    
    display: (property, container, x, y) ->
        text = "#{property.value} #{property.unitName}"
        if property.display
            property.display.attr(text: text)
        else
            property.display = @paper.text(x, y, text)
            property.display.attr(fill: '#F6E631', stroke: 'none', 'font-size': 11, 'text-anchor': 'start')
            container.push(property.display)
        property.set(property.value) if property.set
        
    show: -> 
        @bubble.show
            content: (container) => @createProperties(container)
            callback: => property.object?.set(property.value) for propertyId, property of @properties

        
    hide: -> 
        @bubble.hide
            callback: =>
                property.display = null for propertyId, property of @properties
        
    toggle: -> if @bubble.visible then @hide() else @show()
            
    set: (id, value) ->
        value = parseFloat(value)
        property = @properties[id]
        return if property.value == value
        property.value = value
        property.object?.set(value)
        @display(property)
        
    selectElement: (property) ->
        options = []
        for value in [(property.min or 0)..property.max] by property.unit
            selected = "#{value}" == "#{property.value}"
            options.push("<option value=#{value} #{if selected then 'selected=selected' else ''}>#{value}</option>")
        
        return "<select>#{options.join('')}</select>"
        

