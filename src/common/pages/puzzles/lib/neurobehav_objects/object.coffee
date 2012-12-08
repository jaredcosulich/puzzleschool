object = exports ? provide('./object', {})

class object.Object
    periodicity: 20
    baseFolder: '/assets/images/puzzles/neurobehav/'
    
    constructor: ({@id, @paper, @position, @propertiesArea, @setProperty}) -> @init()
        
    createImage: ->
        @image = @paper.image(
            "#{@baseFolder}#{@imageSrc}", 
            @position.left, 
            @position.top, 
            @fullWidth or @width, 
            @fullHeight or @height
        )
        @image.objectType = @objectType
        @image.objectName = @objectName
        @image.object = @
        
        return @image
        
    init: -> raise("no init method for #{@objectType}")

    initMoveGlow: (element) ->
        glow = element.glow(width: 30, fill: true, color: 'yellow')
        glow.attr(opacity: 0, cursor: 'move')
        set = @paper.set()
        set.push(element)
        set.push(glow)
        set.hover(
            () => glow.attr(opacity: 0.04),
            () => glow.attr(opacity: 0)
        )
        glow.toFront()
        element.toFront()
        return glow
        
    initPropertiesGlow: (element=@image) ->
        element.propertiesGlow.remove() if element.propertiesGlow
        element.attr(cursor: 'pointer')
        if element.forEach
            glow = @paper.set()
            element.forEach (e) => glow.push(e.glow(width: 20, fill: true, color: 'red'))
        else
            glow = element.glow(width: 20, fill: true, color: 'red')
        glow.hide()
        
        element.hover(
            () => glow.show(),
            () => glow.hide() unless element.propertiesDisplayed
        )
        element.propertiesGlow = glow
        return glow
            
    initProperties: (properties, element=@image) ->
        element.properties = JSON.parse(JSON.stringify(properties))
        @initPropertiesGlow(element)

        element.click => @propertiesClick(element)
        return element.propertiesGlow
        
    propertiesClick: (element=@image) =>
        return if element.noClick
        if element.propertiesDisplayed
            element.propertiesGlow.hide()
            @hideProperties(element)
        else
            element.propertiesGlow.show()
            @showProperties(element)
            
    showProperties: (element=@image) ->
        return if element.propertiesDisplayed
        element.propertiesDisplayed = true
        @propertiesArea.find('.nothing_selected').hide()
        (ui = @propertiesArea.find('.object_properties')).show()
        ui.html('')
        for property of element.properties
            ui.append """
                <p>#{element.properties[property].name}: 
                    <span class='#{property}'>#{element.properties[property].value}</span>
                </p>
            """
        @propertiesArea.find('.object_type').html(element.objectName)
            
    hideProperties: (element=@image) ->
        return unless element.propertiesDisplayed
        element.propertiesDisplayed = false
        @propertiesArea.find('.object_properties').hide()
        @propertiesArea.find('.nothing_selected').show()
