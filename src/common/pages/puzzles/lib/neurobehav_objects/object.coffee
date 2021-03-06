object = exports ? provide('./object', {})
PropertiesEditor = require('./properties_editor').PropertiesEditor
Bubble = require('./bubble').Bubble

class object.Object
    periodicity: 20
    baseFolder: '/assets/images/puzzles/neurobehav/'
    
    constructor: ({@id, @paper, @position, @description}) -> 
        @properties = @setProperties(@propertyList)
        @init()
        @initDescriptionIcon()
        
    setProperties: (propertyList) ->
        properties = if propertyList then JSON.parse(JSON.stringify(propertyList)) else {}
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
        @setImage()
        
        return @image
        
    draw: -> @setImage()
            
    setImage: ->
        set = (element) =>
            element.objectType = @objectType
            element.objectName = @objectName
            element.object = @
            
        set(@image)
        if @image.type == 'set'
            set(item) for item in @image.items
        
    init: -> raise("no init method for #{@objectType}")
    
    initMoveGlow: (element) ->
        glow = @paper.set()
        for item in element.items or [element]
            glow.push(item.glow(width: 20, fill: true, color: 'yellow'))
            
        glow.attr(opacity: 0, cursor: 'move')
        set = @paper.set()
        if element.type == 'set'
            set.push(item) for item in element.items
        else
            set.push(element)
        set.push(glow)
        set.hover(
            () => glow.attr(opacity: 0.04),
            () => glow.attr(opacity: 0)
        )
        glow.toFront()
        element.toFront()
        return glow
        
    initDescriptionIcon: () ->
        icon = @paper.set()

        image = @paper.path """
            M16,1.466C7.973,1.466,1.466,7.973,1.466,16c0,8.027,6.507,14.534,14.534,14.534c8.027,0,14.534-6.507,14.534-14.534C30.534,7.973,24.027,1.466,16,1.466z M17.328,24.371h-2.707v-2.596h2.707V24.371zM17.328,19.003v0.858h-2.707v-1.057c0-3.19,3.63-3.696,3.63-5.963c0-1.034-0.924-1.826-2.134-1.826c-1.254,0-2.354,0.924-2.354,0.924l-1.541-1.915c0,0,1.519-1.584,4.137-1.584c2.487,0,4.796,1.54,4.796,4.136C21.156,16.208,17.328,16.627,17.328,19.003z        
        """
        image.attr(fill: "#000", stroke: "none")
        icon.push(image)
        @image.push(image) if @image?.type == 'set'

        glow = image.glow(width: 10, fill: true, color: 'red')
        glow.attr(opacity: 0)
        icon.push(glow)

        icon.transform("t#{@position.left+@centerOffset-8},#{@position.top-27}s0.5")
        icon.attr(cursor: 'pointer')
        icon.hover(
            () => glow.attr(opacity: 0.04),
            () => glow.attr(opacity: 0)
        )
        
        bbox = icon.getBBox()
        @descriptionBubble = new Bubble
            paper: @paper, 
            x: bbox.x + bbox.width
            y: bbox.y + (bbox.height/2)
            width: 300
            height: 300
            position: 'right'
            html: @description
        
        icon.click => 
            if @descriptionBubble.visible
                @descriptionBubble.hide()
            else
                @descriptionBubble.show()

        return icon    

    initPropertiesIcon: (element) ->
        icon = @paper.set()
            
        image = @paper.path """
           M16,1.466C7.973,1.466,1.466,7.973,1.466,16c0,8.027,6.507,14.534,14.534,14.534c8.027,0,14.534-6.507,14.534-14.534C30.534,7.973,24.027,1.466,16,1.466zM24.386,14.968c-1.451,1.669-3.706,2.221-5.685,1.586l-7.188,8.266c-0.766,0.88-2.099,0.97-2.979,0.205s-0.973-2.099-0.208-2.979l7.198-8.275c-0.893-1.865-0.657-4.164,0.787-5.824c1.367-1.575,3.453-2.151,5.348-1.674l-2.754,3.212l0.901,2.621l2.722,0.529l2.761-3.22C26.037,11.229,25.762,13.387,24.386,14.968z        
        """
        image.attr(fill: "#000", stroke: "none")
        icon.push(image)
        @image.push(image) if @image?.type == 'set'
        
        glow = image.glow(width: 10, fill: true, color: 'red')
        glow.attr(opacity: 0)
        icon.push(glow)
        
        icon.transform("t#{@position.left+@centerOffset-26},#{@position.top-27}s0.5")
        icon.attr(cursor: 'pointer')
        icon.hover(
            () => glow.attr(opacity: 0.04),
            () => glow.attr(opacity: 0) unless element.propertiesDisplayed
        )
        
        return icon    
            
    initPropertiesEditor: (icon) ->
        return if not @image
        @propertiesEditor = new PropertiesEditor
            element: icon
            paper: @paper
            properties: @properties
            name: @objectName
            
    initProperties: (properties=@properties, element=@image) ->
        icon = @initPropertiesIcon(element)
        @initPropertiesEditor(icon)
        icon.click => @propertiesEditor.toggle()
            
            
