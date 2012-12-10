object = exports ? provide('./object', {})

class object.Object
    periodicity: 20
    baseFolder: '/assets/images/puzzles/neurobehav/'
    
    constructor: ({@id, @paper, @position, @propertyUI}) -> @init()
        
    copyProperties: (propertyList) ->
        properties = JSON.parse(JSON.stringify(propertyList))
        for propertyId of properties
            do (propertyId) =>
                if (setFunction = properties[propertyId].set)
                    properties[propertyId].set = (val) => @[setFunction](val)
        return properties
        
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
        if element.forEach
            glow = @paper.set()
            element.forEach (e) => glow.push(e.glow(width: 20, fill: true, color: 'red'))
        else
            glow = element.glow(width: 20, fill: true, color: 'red')
        glow.attr(opacity: 0)
        
        s = @paper.set()
        s.push(glow)
        s.push(element)
        s.attr(cursor: 'pointer')
        s.hover(
            () => glow.attr(opacity: 0.04),
            () => glow.attr(opacity: 0) unless element.propertiesDisplayed
        )
        element.propertiesGlow = glow
        return s
            
    initProperties: (properties=@properties, element=@image) ->
        element.properties = properties
        elementAndGlow = @initPropertiesGlow(element)

        elementAndGlow.click => @propertiesClick(element)
        return element.propertiesGlow
        
    propertiesClick: (element=@image, display) ->
        return if element.noClick and not display
        if display or !element.propertiesDisplayed
            @showProperties(element)
        else
            @hideProperties(element)
            
    showProperties: (element=@image) ->
        element.propertiesGlow.attr(opacity: 0.04) 
        previouslySelectedElement = @propertyUI.show(element, element.objectName, element.properties)
        if previouslySelectedElement and previouslySelectedElement != element
            @hideProperties(previouslySelectedElement)
        element.propertiesDisplayed = true
        
    hideProperties: (element=@image) ->
        element.propertiesGlow.attr(opacity: 0) 
        @propertyUI.hide(element)
        element.propertiesDisplayed = false
        
            
