propertiesEditor = exports ? provide('./properties_editor', {})
Slider = require('./slider').Slider

class propertiesEditor.PropertiesEditor
    width: 210
    arrowHeight: 15
    arrowWidth: 20
    arrowOffset: 24
    spacing: 20
    backgroundColor: '#49494A'
    
    constructor: ({@element, @paper, @properties, @name}) -> 
        @init()
        
    $: (selector) -> @el.find(selector)
    
    init: ->
        @height = (Object.keys(@properties).length * @spacing) + (@spacing*2)
        
    createContainer: ->    
        @container = @paper.set()
        bbox = @element.getBBox()        
        @x = bbox.x - @arrowOffset
        @y = bbox.y - (@height + @arrowHeight) 
        @base = @paper.rect(@x, @y, @width, @height, 12)
        @container.push(@base)
        
        start = @start()
        startX = start.x
        startY = start.y-(@arrowHeight+2)
        @arrow = @paper.path """
            M#{startX-(@arrowWidth/2)},#{startY}
            L#{startX},#{startY+@arrowHeight}
            L#{startX+(@arrowWidth/2)},#{startY}
        """
        @container.push(@arrow)
        @container.attr(fill: @backgroundColor, stroke: 'none')
        @container.toFront()

    createProperties: ->
        title = @paper.text(@x + (@width/2), @y + 18, @name)
        title.attr(fill: 'white', stroke: 'none', 'font-size': 14)
        @container.push(title)
        propertiesDisplayed = 0
        for propertyId, property of @properties
            do (property) =>    
                y = @y + (@spacing*2) + (propertiesDisplayed * @spacing)
                name = @paper.text(@x + 12, y, property.name.toLowerCase())
                name.attr
                    fill: '#ccc'
                    stroke: 'none'
                    'font-size': 12, 
                    'font-weight': 1
                    'text-anchor': 'start'
                @container.push(name)
                propertiesDisplayed += 1
                
                if property.type == 'slider'
                    slider = new Slider
                        paper: @paper
                        x: @x + 72
                        y: y
                        width: 60
                        min: 0
                        max: property.max
                        unit: property.unit
                    slider.addListener (value) =>   
                        property.value = value
                        @display(property)
                        
                    property.object = slider
                    @container.push(slider.el)
                @display(property, @x + 144, y)
                    
    start: ->
        bbox = @element.getBBox()
        return {
            x: bbox.x + (bbox.width/2)
            y: bbox.y - 3
        }
        
    display: (property, x, y) ->
        text = "#{property.value} #{property.unitName}"
        if property.display
            property.display.attr(text: text)
        else
            property.display = @paper.text(x, y, text)
            property.display.attr(fill: '#F6E631', stroke: 'none', 'font-size': 11, 'text-anchor': 'start')
            @container.push(property.display)
        property.set(property.value) if property.set
        
    show: ->
        return if @container
        @createContainer()
        @createProperties()
        start = @start()
        @container.attr(transform: "s0,0,#{start.x},#{start.y}")
        @container.animate(
            {transform: "s1"}, 
            100, 
            'linear',
            => property.object?.set(property.value) for propertyId, property of @properties
        )
        
    hide: -> 
        return unless @container
        start = @start()
        @container.animate(
            {transform: "s0,0,#{start.x},#{start.y}"}, 
            100, 
            'linear', 
            => 
                @container.remove()
                @container = null
                property.display = null for propertyId, property of @properties
        )
        
    toggle: -> if @container? then @hide() else @show()
            
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
        

