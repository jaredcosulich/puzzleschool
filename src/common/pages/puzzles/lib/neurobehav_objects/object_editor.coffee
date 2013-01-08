objectEditor = exports ? provide('./object_editor', {})

class objectEditor.ObjectEditor
    constructor: ({@el}) -> 
        @init()
        
    $: (selector) -> @el.find(selector)
    
    init: ->
        @explicitContent = @$('.explicit_content')
        @nothingSelected = @$('.nothing_selected')
        @objectProperties = @$('.object_properties')
        @objectType = @$('.object_type')
            
    show: (element, @name, @properties) ->
        @hideExtraContent()
        @explicitContent.html(@properties.description)

        previouslySelectedElement = @element
        @element = element
        @nothingSelected.hide()
        @objectProperties.show()
        @objectProperties.html('')
        for propertyId of @properties
            continue if propertyId == 'description'
            do (propertyId) =>
                property = @properties[propertyId]
                @objectProperties.append """
                    <p>#{property.name}: 
                        <span class='#{propertyId}'>#{@["#{property.type}Element"](property)}</span> (#{property.unitName})
                    </p>
                """
                input = @objectProperties.find(".#{propertyId}").find('input, select')
                input.bind 'change keypress', =>
                    value = parseFloat(input.val())
                    property.value = value
                    property.set(value) if property.set
                
        @objectType.html(@name)
        return previouslySelectedElement
        
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
        
    showExtraContent: (html) ->
        @extraContent = html
        content = $(document.createElement('DIV'))
        content.html(html)
        content.addClass('extra_content')
        content.height(0)
        @el.append(content)
        content.animate
            height: @el.height()
            duration: 750

    hideExtraContent: ->
        @extraContent = null
        @$('.extra_content').animate
            height: 0
            duration: 250
            complete: =>
                @$('.extra_content').remove()
            
        
        
        