properties = exports ? provide('./properties', {})

class properties.Properties
    constructor: ({@el, @initDescription}) -> 
        @init()
        
    init: ->
        @nothingSelected = @el.find('.nothing_selected')
        @objectProperties = @el.find('.object_properties')
        @objectType = @el.find('.object_type')
            
    show: (element, @name, @properties) ->
        previouslySelectedElement = @element
        @element = element
        @nothingSelected.hide()
        @objectProperties.show()
        @objectProperties.html(@formatDescription(@properties.description))
        for propertyId of @properties
            continue if propertyId == 'description'
            do (propertyId) =>
                property = @properties[propertyId]
                @objectProperties.append """
                    <p>#{property.name}: 
                        <span class='#{propertyId}'>#{@["#{property.type}Element"](property)}</span> (#{property.unitName})
                    </p>
                """
                element = @objectProperties.find(".#{propertyId}").find('input, select')
                element.bind 'change keypress', =>
                    value = parseFloat(element.val())
                    property.value = value
                    property.set(value) if property.set
                
        @objectType.html(@name)
        @initDescription()
        return previouslySelectedElement
        
    formatDescription: (description) ->
        description = description.replace(/^\s+/, '')
        return '' unless description?.length
        return description if description.length < 22
        brief = description[0...40].replace(/<[^>]+\>/, '')
        return """ 
            #{brief}... (<a class='read_more_description'>more</a>)
            <div class='more_description'><h4>#{@name}</h4>#{description}</div>
        """
            
    hide: (element) ->
        return if element and element != @element
        @objectProperties.hide()
        @nothingSelected.show()

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
        
        