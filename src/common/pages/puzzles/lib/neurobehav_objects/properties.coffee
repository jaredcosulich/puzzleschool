properties = exports ? provide('./properties', {})

class properties.Properties
    constructor: ({@el}) -> 
        @init()
        
    init: ->
        @nothingSelected = @el.find('.nothing_selected')
        @objectProperties = @el.find('.object_properties')
        @objectType = @el.find('.object_type')
            
    show: (name, @properties, setValue) ->
        @nothingSelected.hide()
        @objectProperties.show()
        @objectProperties.html('')
        for propertyId of @properties
            do (propertyId) =>
                property = @properties[propertyId]
                @objectProperties.append """
                    <p>#{property.name}: 
                        <span class='#{propertyId}'>#{@["#{property.type}Element"](property)}</span> (#{property.unitName})
                    </p>
                """
                element = @objectProperties.find(".#{propertyId}").find('input, select')
                element.bind 'change keypress', =>
                    property.value = element.val()
                    property.set(element.val()) if property.set
                
        @objectType.html(name)
            
    hide: ->
        @objectProperties.hide()
        @nothingSelected.show()

    set: (id, value) ->
        @objectProperties.find(".#{id}").find('input, select').val(value + '')
        @properties[id].value = value if @properties
        
    selectElement: (property) ->
        options = []
        for value in [(property.min or 0)..property.max] by property.unit
            selected = "#{value}" == "#{property.value}"
            options.push("<option value=#{value} #{if selected then 'selected=selected' else ''}>#{value}</option>")
        
        return "<select>#{options.join('')}</select>"
        
        