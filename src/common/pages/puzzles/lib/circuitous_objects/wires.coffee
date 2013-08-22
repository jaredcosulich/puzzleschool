wires = exports ? provide('./wires', {})
Transformer = require('../common_objects/transformer').Transformer
circuitousObject = require('./object')

class wires.Wires extends circuitousObject.Object
    resistance: 0.00001
    electronsPerSegment: 2
    
    constructor: (@board) ->
        @init()

    init: ->
        @info = {all: {}, positions: {}, nodes: {}}
        @el = @board.el
        @cellDimension = @board.cellDimension
        @el.bind 'mousedown.draw_wire', (e) =>
            $(document.body).one 'mouseup.draw_wire', => 
                $(document.body).unbind('mousemove.draw_wire')
                delete @info.start      
                delete @info.continuation
                delete @info.erasing
                delete @info.lastSegment      
                          
            $(document.body).bind 'mousemove.draw_wire', (e) => @draw(e)
            @draw(e)
            
    all: -> @info.all 
        
    draw: (e) ->
        coords = @board.roundedCoordinates({x: Client.x(e), y: Client.y(e)}, @el.offset())
        if start = @info.start
            xDiff = Math.abs(start.x - coords.x)
            yDiff = Math.abs(start.y - coords.y)

            return if xDiff < @cellDimension and yDiff < @cellDimension

            xDelta = yDelta = 0
            if xDiff > yDiff
                xDelta = @cellDimension * (if start.x > coords.x then -1 else 1)
            else 
                yDelta = @cellDimension * (if start.y > coords.y then -1 else 1)
            
            for i in [1..Math.floor(Math.max(xDiff, yDiff) / @cellDimension)]
                @createOrErase(x: start.x + xDelta * i, y: start.y + yDelta * i)
        else
            @info.start = coords

    createOrErase: (coords) ->
        existingSegment = @find(@info.start, coords)

        if @info.erasing or (existingSegment and (!@info.continuation or (existingSegment == @info.lastSegment)))
            segment = @erase(coords) if existingSegment
        else
            segment = @create(coords) unless existingSegment

        @info.lastSegment = segment 
        @info.start = coords

    create: (coords) ->
        segment = $(document.createElement('DIV'))
        segment.addClass('wire_segment')
        segment.css
            left: Math.min(@info.start.x, coords.x)
            top: Math.min(@info.start.y, coords.y)

        if Math.abs(@info.start.x - coords.x) > Math.abs(@info.start.y - coords.y)
            segment.width(@cellDimension)
            segment.addClass('horizontal')
        else
            segment.height(@cellDimension)
            segment.addClass('vertical')

        # position = "#{JSON.stringify(@info.start)} -- #{JSON.stringify(coords)}"
        # segment.bind 'mouseover', => console.log(position)    

        @el.append(segment)
        @recordPosition(segment, @info.start, coords)   
        @info.continuation = true
        return segment

    erase: (coords) ->
        return unless (segment = @find(@info.start, coords))
        segment.el.remove()
        @recordPosition(null, @info.start, coords)
        @info.erasing = true unless @info.continuation
        return segment.el

    recordPosition: (element, start, end) ->
        # @board.addDot(start)
        # @board.addDot(end)
        @board.changesMade = true
        node1 = "#{start.x}:#{start.y}"
        node2 = "#{end.x}:#{end.y}"
        
        if element
            segment = 
                id: "wire#{node1}#{node2}"
                el: element
                horizontal: element.hasClass('horizontal')
                resistance: @resistance
                nodes: [start, end]
                
            segment.setCurrent = (current) -> segment.current = current

            @info.all[segment.id] = segment
            
            @info.nodes[node1] or= {}
            @info.nodes[node1][node2] = segment

            @info.nodes[node2] or= {}
            @info.nodes[node2][node1] = segment
        else
            segment = @info.nodes[node1][node2]
            delete @info.all[segment.id] if segment
            delete @info.nodes[node1]?[node2]
            delete @info.nodes[node2]?[node1]

    find: (start, end=null) ->
        node1 = "#{start.x}:#{start.y}"
        
        if end
            node2 = "#{end.x}:#{end.y}" 
            @info.nodes[node1]?[node2] or @info.nodes[node2]?[node1]
        else
            (segment for endPoint, segment of @info.nodes[node1]) 
            
    initElectrons: (segment) ->
        return if segment.electrons
        segment.electrons = []
        electrons = $(document.createElement('DIV'))
        electrons.addClass('electrons')
        for i in [1..@electronsPerSegment]
            electron = $(document.createElement('DIV'))
            electron.addClass('electron')
            
            if segment.horizontal
                electron.css(left: (segment.el.width() / (@electronsPerSegment + 1)) * i)
            else
                electron.css(top: (segment.el.height() / (@electronsPerSegment + 1)) * i)
            
            electrons.append(electron)
            segment.electrons.push(el: electron, transformer: new Transformer(electron))

        segment.el.append(electrons)
    
    moveElectrons: (segment, elapsedTime) ->
        totalMovement = ((elapsedTime/500) * segment.current)
        reverse = (segment.nodes[0].x < segment.nodes[1].x) or (segment.nodes[0].y < segment.nodes[1].y)
        for electron in segment.electrons
            x = y = 0
            if segment.horizontal
                left = parseInt(electron.el.css('left'))
                width = segment.el.width()
                if reverse
                    x = (((width - left) - totalMovement) % width) + (width - left)
                else
                    x = ((left + totalMovement) % width) - left          
            else
                top = parseInt(electron.el.css('top'))
                height = segment.el.height()
                if reverse
                    y = (((height - top) - totalMovement) % height) + (height - top)
                else
                    y = ((top + totalMovement) % height) - top          

            electron.transformer.translate(x, y)
            
    clearElectrons: (segment) ->
        electron.el.remove() for electron in (segment?.electrons or [])
        delete segment.electrons
        
    showCurrent: (elapsedTime) ->
        for segmentId, segment of @info.all        
            if segment.current
                @initElectrons(segment) 
                @moveElectrons(segment, elapsedTime)    
            else
                @clearElectrons(segment)
``