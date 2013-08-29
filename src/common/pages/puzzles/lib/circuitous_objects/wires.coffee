wires = exports ? provide('./wires', {})
Transformer = require('../common_objects/transformer').Transformer
circuitousObject = require('./object')

class wires.Wires extends circuitousObject.Object
    edgeBuffer: 6
    resistance: 0.00001
    electronsPerSegment: 3
    
    constructor: (@board) ->
        @init()

    init: ->
        @info = {all: {}, positions: {}, nodes: {}, node: {}}
        @el = @board.el.find('.wires')
        @electrons = @board.el.find('.electrons')
        @cellDimension = @board.cellDimension
        @board.el.bind 'mousedown.draw_wire', (e) => @initDraw(e)
            
    all: -> @info.all 
        
    initDraw: (e) ->
        $(document.body).one 'mouseup.draw_wire', => 
            $(document.body).unbind('mousemove.draw_wire')
            delete @info.start      
            delete @info.continuation
            delete @info.erasing
            delete @info.lastSegment      
                      
        $(document.body).bind 'mousemove.draw_wire', (e) => @draw(e)
        @draw(e)
        
    draw: (e) ->
        border = @board.border
        coords = @board.roundedCoordinates({x: Client.x(e) - border, y: Client.y(e) - border}, @el.offset())
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
            segment = @erase(@info.start, coords) if existingSegment
        else
            segment = @create(@info.start, coords) unless existingSegment

        @info.lastSegment = segment 
        @info.start = coords

    create: (start, end) ->
        segment = $(document.createElement('DIV'))
        segment.addClass('wire_segment')
        segment.css
            left: Math.min(start.x, end.x)
            top: Math.min(start.y, end.y)

        if Math.abs(start.x - end.x) > Math.abs(start.y - end.y)
            segment.css(left: Math.min(start.x, end.x) + @edgeBuffer)
            segment.width(@cellDimension - (@edgeBuffer * 2))
            segment.addClass('horizontal')
        else
            segment.css(top: Math.min(start.y, end.y) + @edgeBuffer)
            segment.height(@cellDimension - (@edgeBuffer * 2))
            segment.addClass('vertical')

        # position = "#{JSON.stringify(@info.start)} -- #{JSON.stringify(coords)}"
        # segment.bind 'mouseover', => console.log(position)    

        @el.append(segment)
        @recordPosition(segment, start, end)
        @info.continuation = true
        return segment

    erase: (start, end) ->
        return unless (segment = @find(start, end))
        @clearElectrons(segment)
        segment.el.remove()
        @recordPosition(null, start, end)
        @info.erasing = true unless @info.continuation
        return segment.el
        
    labelSegments: (node) ->
        return unless (segmentIds = @info.node[@nodeId(node)])
        directions = []
        for segmentId of segmentIds   
            segment = @info.all[segmentId]
            direction = @segmentDirection(segment, node)
            @removeDirectionLabel(segment, direction)
            if Object.keys(segmentIds).length == 4
                segment.el.addClass("#{direction}_all") 
            else
                directions.push(direction: direction, segment: segment)
            
        if Object.keys(segmentIds).length == 2
            for info in directions
                for info2 in directions
                    if info2.segment.id != info.segment.id
                        info2.segment.el.addClass("#{info2.direction}_#{info.direction}")

        if Object.keys(segmentIds).length == 3
            for info in directions
                if info.segment.horizontal
                    oppositeDirection = (i for i in directions when i.direction == (if info.direction == 'left' then 'right' else 'left'))[0]
                else
                    oppositeDirection = (i for i in directions when i.direction == (if info.direction == 'up' then 'down' else 'up'))[0]
                
                if oppositeDirection
                    info.segment.el.addClass("#{info.direction}_blank_t")
                else
                    info.segment.el.addClass("#{info.direction}_t")
        
        # for segmentId of segmentIds
        #     @board.clearColors()
        #     console.log("coloring #{Object.keys(segmentIds).length}", @info.all[segmentId].el[0].className)
        #     @board.color([segmentId], 1)
        #     debugger
            
    otherNode: (segment, node) ->
        if segment.nodes[0].x == node.x and segment.nodes[0].y == node.y
            return segment.nodes[1]
        else
            return segment.nodes[0]
    
    segmentDirection: (segment, node) ->
        otherNode = @otherNode(segment, node)
        if segment.horizontal
            if node.x > otherNode.x
                return 'right'
            else
                return 'left'
        else
            if node.y > otherNode.y
                return 'down'
            else
                return 'up'
            
    removeDirectionLabel: (segment, direction) ->
        for className in segment.el[0].className.split(/\s/) when className.match("#{direction}_")
            segment.el.removeClass(className) 

    recordPosition: (element, start, end) ->
        # @board.addDot(start)
        # @board.addDot(end)
        @board.changesMade = true
        node1 = @nodeId(start)
        node2 = @nodeId(end)
        
        if element
            segment = 
                id: "wire#{node1}#{node2}"
                el: element
                horizontal: element.hasClass('horizontal')
                resistance: @resistance
                nodes: [start, end]
                
            segment.setCurrent = (current) -> segment.current = current

            @info.all[segment.id] = segment
            
            @info.node[node1] or= {}
            @info.node[node1][segment.id] = true

            @info.node[node2] or= {}
            @info.node[node2][segment.id] = true
            
            @info.nodes[node1] or= {}
            @info.nodes[node1][node2] = segment

            @info.nodes[node2] or= {}
            @info.nodes[node2][node1] = segment
        else
            segment = @info.nodes[node1][node2]
            delete @info.all[segment.id] if segment
            delete @info.node[node1][segment.id]
            delete @info.node[node2][segment.id]
            delete @info.nodes[node1]?[node2]
            delete @info.nodes[node2]?[node1]
    
        @labelSegments(start)
        @labelSegments(end)   
    
    nodeId: (node) -> "#{node.x}:#{node.y}"

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
        electronsSegment.css(top: segment.el.css('top'), left: segment.el.css('left'))
        if segment.horizontal
            electronsSegment.css(left: parseInt(segment.el.css('left')) - @edgeBuffer)
        else
            electronsSegment.css(top: parseInt(segment.el.css('top')) - @edgeBuffer)
        @electrons.append(electronsSegment)
        segment.electrons = {el: electronsSegment, transformer: new Transformer(electronsSegment)}
                
    moveElectrons: (segment, elapsedTime) ->
        totalMovement = ((elapsedTime/100) * Math.abs(segment.current))
        x = y = 0
        if segment.horizontal
            width = segment.el.width() + (@edgeBuffer * 2)
            x = totalMovement % ((width % @cellDimension) * 2) 
            if segment.electrons.el.hasClass('left')
                x = x * -1
        else
            height = segment.el.height() + (@edgeBuffer * 2)
            y = totalMovement % ((height % @cellDimension) * 2) 
            if segment.electrons.el.hasClass('up')
                y = y * -1

        segment.electrons.transformer.translate(x, y)
            
    clearElectrons: (segment) ->
        return unless segment.electrons
        segment.electrons.el.remove()
        delete segment.reverse
        delete segment.electrons
        
    setDirection: (segment) ->
        return if segment.reverse == (reverse = ((segment.direction * segment.current) < 0))
        segment.reverse = reverse
        segment.electrons.el[0].className = 'electrons_segment'        
        if segment.horizontal
            pointedRight = segment.nodes[0].x < segment.nodes[1].x
            pointedRight = !pointedRight if segment.reverse
            segment.electrons.el.addClass(if pointedRight then 'right' else 'left')
            segment.electrons.el.width(@cellDimension)
        else
            pointedDown = segment.nodes[0].y < segment.nodes[1].y
            pointedDown = !pointedDown if segment.reverse
            segment.electrons.el.addClass(if pointedDown then 'down' else 'up')
            segment.electrons.el.height(@cellDimension)
        
    showCurrent: (elapsedTime) ->
        for segmentId, segment of @info.all
            if segment.current
                @initElectrons(segment) 
                @setDirection(segment)
                @moveElectrons(segment, elapsedTime)    
            else
                @clearElectrons(segment)
``