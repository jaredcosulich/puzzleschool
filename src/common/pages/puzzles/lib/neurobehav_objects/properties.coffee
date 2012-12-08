properties = exports ? provide('./properties', {})

class properties.Properties
    constructor: ({@el}) -> 
        @init()
        
    init: ->
        @nothingSelected = @el.find('.nothing_selected')
        @objectProperties = @el.find('.object_properties')
        @objectType = @el.find('.object_type')
            
    show: (name, @properties) ->
        @nothingSelected.hide()
        @objectProperties.show()
        @objectProperties.html('')
        for propertyId of @properties
            property = @properties[propertyId]
            @objectProperties.append """
                <p>#{property.name}: 
                    <span class='#{propertyId}'>#{property.value}</span> (#{property.unitName})
                </p>
            """
        @objectType.html(name)
            
    hide: ->
        @objectProperties.hide()
        @nothingSelected.show()

    set: (id, value) ->
        @objectProperties.find(".#{id}").html('' + value)
        @properties[id].value = value if @properties