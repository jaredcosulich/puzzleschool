propertiesEditor = exports ? provide('./properties_editor', {})
Slider = require('./slider').Slider

class propertiesEditor.PropertiesEditor
    width: 180
    arrowHeight: 15
    arrowWidth: 20
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
        @x = bbox.x - 24
        @y = bbox.y - (@height + @arrowHeight) 
        @base = @paper.rect(@x, @y, @width, @height, 12)
        @container.push(@base)
        
        startX = bbox.x + (bbox.width/2)
        startY = bbox.y-(@arrowHeight+2)
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
                        val: property.value
                    @container.push(slider.el)
                    
                        
    
    createSlider: (property) ->
            
        
    show: ->
        @createContainer()
        @createProperties()
        
    hide: -> @container.remove()
            
    set: (id, value) ->
        value = parseFloat(value)
        @objectProperties.find(".#{id}").find('input, select').val(value + '')
        @properties[id].value = value if @properties
        
    selectElement: (property) ->
        options = []
        for value in [(property.min or 0)..property.max] by property.unit
            selected = "#{value}" == "#{property.value}"
            options.push("<option value=#{value} #{if selected then 'selected=selected' else ''}>#{value}</option>")
        
        return "<select>#{options.join('')}</select>"
        

