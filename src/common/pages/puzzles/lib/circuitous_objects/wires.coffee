wires = exports ? provide('./wires', {})
Transformer = require('../common_objects/transformer').Transformer
circuitousObject = require('./object')

class wires.Wires extends circuitousObject.Object
    resistance: 0.00001
    electronsPerSegment: 3
    
    constructor: (@board) ->
        @init()

    init: ->
        @info = {all: {}, positions: {}, nodes: {}}
        @el = @board.el.find('.wires')
        @electrons = @board.el.find('.electrons')
        @cellDimension = @board.cellDimension
        @electrons.bind 'mousedown.draw_wire', (e) =>
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
        @clearElectrons(segment)
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
        electronsSegment = $(document.createElement('DIV'))
        electronsSegment.addClass('electrons_segment')

        reverse = ((segment.direction * segment.current) < 1)        
        if segment.horizontal
            pointedRight = segment.nodes[0].x < segment.nodes[1].x
            pointedRight = !pointedRight if reverse
            electronsSegment.addClass(if pointedRight then 'right' else 'left')
            electronsSegment.width(@cellDimension)
        else
            pointedDown = segment.nodes[0].y < segment.nodes[1].y
            pointedDown = !pointedDown if reverse
            electronsSegment.addClass(if pointedDown then 'down' else 'up')
            electronsSegment.height(@cellDimension)
        
        electronsSegment.css(top: segment.el.css('top'), left: segment.el.css('left'))
        @electrons.append(electronsSegment)
        segment.electrons = {el: electronsSegment, transformer: new Transformer(electronsSegment)}
        
        
    moveElectrons: (segment, elapsedTime) ->
        totalMovement = ((elapsedTime/200) * Math.abs(segment.current))
        x = y = 0
        if segment.horizontal
            pointedRight = 
            width = segment.el.width()
            x = totalMovement % ((width % @cellDimension) * 2) 
            if segment.electrons.el.hasClass('left')
                x = x * -1
        else
            pointedDown = (segment.nodes[0].y < segment.nodes[1].y)
            height = segment.el.height()
            y = totalMovement % ((height % @cellDimension) * 2) 
            if segment.electrons.el.hasClass('up')
                y = y * -1

        segment.electrons.transformer.translate(x, y)
            
    clearElectrons: (segment) ->
        return unless segment.electrons
        segment.electrons.el.remove()
        delete segment.electrons
        
    showCurrent: (elapsedTime) ->
        for segmentId, segment of @info.all
            if segment.current
                @initElectrons(segment) 
                @moveElectrons(segment, elapsedTime)    
            else
                @clearElectrons(segment)
``