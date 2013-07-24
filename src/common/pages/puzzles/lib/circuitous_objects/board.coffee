board = exports ? provide('./board', {})
circuitousObject = require('./object')
Client = require('../common_objects/client').Client
Animation = require('../common_objects/animation').Animation

class board.Board extends circuitousObject.Object
    cellDimension: 32
    
    constructor: ({@el}) ->
        @circuitInfo = {nodes: {}, sections: {}, components: {}}
        @components = {}
        @init()

    init: ->
        @width = @el.width()
        @height = @el.height()
        @drawGrid()
        @initWire()
        @initElectricity()
        
    drawGrid: ->
        rows = @height / @cellDimension
        columns = @width / @cellDimension
        for row in [1..rows]
            for column in [1..columns]
                cell = $(document.createElement('DIV'))
                cell.addClass('cell')
                cell.css(width: @cellDimension-1, height: @cellDimension-1)
                @el.append(cell)
                
    componentsAndWires: -> 
        all = {}
        all[id] = component for id, component of @components
        for yCoords, nodes of @wireInfo.positions
            for xCoords, wireSegment of nodes
                all[wireSegment.id] = wireSegment
        return all
                
    addComponent: (component, x, y) ->
        component.id = @generateId() unless component.id
        
        offset = @el.offset()
        boardPosition = @boardPosition(x: x, y: y)
        
        onBoardX = 0 < boardPosition.x < @width
        onBoardY = 0 < boardPosition.y < @height
        if onBoardX and onBoardY 
            @components[component.id] = component
            roundedBoardPosition = @roundedCoordinates(boardPosition, component.centerOffset)
            component.positionAt(@componentPosition(roundedBoardPosition))
            # for node in component.currentNodes()
            #     @addDot(@boardPosition(node))
        else
            return false
        return true
            
    removeComponent: (component) -> 
        @components[component.id]?.setCurrent(0)
        delete @components[component.id]
            
    initWire: ->
        @wireInfo = {positions: {}, nodes: {}}
        @el.bind 'mousedown.draw_wire', (e) =>
            $(document.body).one 'mouseup.draw_wire', => 
                $(document.body).unbind('mousemove.draw_wire')
                delete @wireInfo.start      
                delete @wireInfo.continuation
                delete @wireInfo.erasing
                delete @wireInfo.lastSegment      
                          
            $(document.body).bind 'mousemove.draw_wire', (e) => @drawWire(e)
            @drawWire(e)
            
    roundedCoordinates: (coords, offset) ->
        halfDim = @cellDimension / 2
        offsetCoords = 
            x: coords.x - (offset?.left or offset?.x or 0) + halfDim
            y: coords.y - (offset?.top or offset?.y or 0) + halfDim
            
        return {
            x: (Math.round(offsetCoords.x / @cellDimension) * @cellDimension) - halfDim
            y: (Math.round(offsetCoords.y / @cellDimension) * @cellDimension) - halfDim
        }
        
    addDot: ({x, y, color}) ->
        dot =  $(document.createElement('DIV'))
        dot.html('&nbsp;')
        dot.css
            position: 'absolute'
            backgroundColor: color or 'red'
            width: 4
            height: 4
            marginTop: -2
            marginLeft: -2
            left: x
            top: y
            zIndex: 9
        @el.append(dot)
        console.log('dot', x, y, dot)
        
    recordSegmentPosition: (element, start, end) ->
        # @addDot(start)
        # @addDot(end)
        xCoords = [start.x, end.x].sort().join(':')
        yCoords = [start.y, end.y].sort().join(':')
        node1 = "#{start.x}:#{start.y}"
        node2 = "#{end.x}:#{end.y}"
        
        if element
            segment = 
                id: "segment#{node1}#{node2}"
                el: element
                nodes: [start, end]
        
            xCoords = [start.x, end.x].sort().join(':')
            yCoords = [start.y, end.y].sort().join(':')
            @wireInfo.positions[xCoords] or= {}
            @wireInfo.positions[xCoords][yCoords] = segment
        
            @wireInfo.nodes[node1] or= {}
            @wireInfo.nodes[node1][node2] = segment

            @wireInfo.nodes[node2] or= {}
            @wireInfo.nodes[node2][node1] = segment
        else
            delete @wireInfo.positions[xCoords][yCoords]
            delete @wireInfo.nodes[node1][node2]
            delete @wireInfo.nodes[node2][node1]

    getSegmentPosition: (start, end) ->
        @wireInfo.positions[[start.x, end.x].sort().join(':')]?[[start.y, end.y].sort().join(':')]
        
    getSegmentsAt: (node) -> (segment for endPoint, segment of @wireInfo.nodes["#{node.x}:#{node.y}"])  
         
    drawWire: (e) ->
        coords = @roundedCoordinates({x: Client.x(e), y: Client.y(e)}, @el.offset())

        if start = @wireInfo.start
            xDiff = Math.abs(start.x - coords.x)
            yDiff = Math.abs(start.y - coords.y)
                        
            return if xDiff < @cellDimension and yDiff < @cellDimension
            
            xDelta = yDelta = 0
            if xDiff > yDiff
                xDelta = @cellDimension * (if start.x > coords.x then -1 else 1)
            else 
                yDelta = @cellDimension * (if start.y > coords.y then -1 else 1)
                
            for i in [0...Math.floor(Math.max(xDiff, yDiff) / @cellDimension)]
                @createOrEraseWireSegment(x: start.x + xDelta, y: start.y + yDelta)
        else
            @wireInfo.start = coords
            
    createOrEraseWireSegment: (coords) ->
        existingSegment = @getSegmentPosition(@wireInfo.start, coords)

        if @wireInfo.erasing or (existingSegment and (!@wireInfo.continuation or (existingSegment == @wireInfo.lastSegment)))
            segment = @eraseWireSegment(coords) if existingSegment
        else
            segment = @createWireSegment(coords) unless existingSegment
            
        @wireInfo.lastSegment = segment 
        @wireInfo.start = coords
        
    createWireSegment: (coords) ->
        segment = $(document.createElement('DIV'))
        segment.addClass('wire_segment')
        segment.css
            left: Math.min(@wireInfo.start.x, coords.x)
            top: Math.min(@wireInfo.start.y, coords.y)
        
        if Math.abs(@wireInfo.start.x - coords.x) > Math.abs(@wireInfo.start.y - coords.y)
            segment.width(@cellDimension)
            segment.addClass('horizontal')
        else
            segment.height(@cellDimension)
            segment.addClass('vertical')
            
        position = "#{JSON.stringify(@wireInfo.start)} -- #{JSON.stringify(coords)}"
        segment.bind 'mouseover', => console.log(position)    
            
        @el.append(segment)
        @recordSegmentPosition(segment, @wireInfo.start, coords)   
        @wireInfo.continuation = true
        return segment
    
    eraseWireSegment: (coords) ->
        return unless (segment = @getSegmentPosition(@wireInfo.start, coords))
        segment.el.remove()
        @recordSegmentPosition(null, @wireInfo.start, coords)
        @wireInfo.erasing = true unless @wireInfo.continuation
        return segment.el
     
    initElectricity: ->
        @electricalAnimation = new Animation()    
        # @electricalAnimation.start 
        #     method: ({deltaTime, elapsed}) => @moveElectricity(deltaTime, elapsed)
        $('.menu').bind 'click', => @moveElectricity()
        
    moveElectricity: (deltaTime, elapsed) ->
        # @slowTime = (@slowTime or 0) + deltaTime
        # return unless @slowTime > 2000
        # @slowTime -= 2000
        
        for id, piece of @componentsAndWires()
            piece.receivingCurrent = false
            piece.excessiveCurrent = false 
        
        for id, component of @components when component.powerSource
            for negativeTerminal in component.currentNodes('negative')
                @compileSections(@boardPosition(negativeTerminal), component)
                # if (circuit = ).complete
                #     if circuit.totalResistance > 0
                #         amps = component.voltage / circuit.totalResistance
                #         for id of circuit.components  
                #             c = @componentsAndWires()[id] 
                #             c.receivingCurrent = true
                #             c.setCurrent?(amps)                         
                #         console.log('complete', circuit.totalResistance, amps)
                #     else
                #         amps = 'infinite'
                #         for id of circuit.components
                #             c = @componentsAndWires()[id] 
                #             c.excessiveCurrent = true
                #             c.el.addClass('excessive_current')
                #         console.log('complete', circuit.totalResistance, amps)
                # else
                #     console.log('incomplete', circuit)

        for id, piece of @componentsAndWires()
            piece.el.removeClass('excessive_current') unless piece.excessiveCurrent
            piece.setCurrent?(0) unless piece.receivingCurrent
                    
    boardPosition: (componentPosition) ->
        offset = @el.offset()
        position = JSON.parse(JSON.stringify(componentPosition))
        position.x = componentPosition.x - offset.left + 1
        position.y = componentPosition.y - offset.top + 1
        return position
        
    componentPosition: (boardPosition) ->
        offset = @el.offset()
        position = JSON.parse(JSON.stringify(boardPosition))
        position.x = boardPosition.x + offset.left - 1
        position.y = boardPosition.y + offset.top - 1
        return position
        
    compareNodes: (node1, node2) -> node1.x == node2.x and node1.y == node2.y
    
    generateId: -> "#{new Date().getTime()}#{Math.random()}"
    
    newSection: (node) ->
        section = {nodes: [node], totalResistance: 0, components: {}, id: @generateId()}
        return section

    addToSection: (section, node, component) ->
        return false if @circuitInfo.components[component.id]
        
        if component.powerSource and node.negative
            section.negativeComponent = component   

        section.totalResistance += component.resistance or 0            
        section.components[component.id] = true
        @circuitInfo.components[component.id] = section.id unless component.powerSource
        return true
        
    endSection: (section, node, component) ->
        if component.powerSource and node.positive
            section.positiveComponent = component

        section.nodes.push(node)             

        node1Coords = "#{section.nodes[0].x}:#{section.nodes[0].y}"
        node2Coords = "#{section.nodes[1].x}:#{section.nodes[1].y}"
        
        @circuitInfo.sections[section.id] = section        
        @circuitInfo.nodes["node:#{node1Coords}"] or= {}
        @circuitInfo.nodes["node:#{node1Coords}"][section.id] = section
        @circuitInfo.nodes["node:#{node2Coords}"] or= {}
        @circuitInfo.nodes["node:#{node2Coords}"][section.id] = section
        @circuitInfo.nodes["nodes:#{node1Coords}#{node2Coords}"] = section
        @circuitInfo.nodes["nodes:#{node2Coords}#{node1Coords}"] = section

        colors = ['red', 'green', 'yellow', 'purple', 'orange', 'blue']
        for componentId of section.components
            color = colors[Object.keys(@circuitInfo.sections).length - 1]
            @componentsAndWires()[componentId].el.css(backgroundColor: color)
        console.log('end', color, JSON.stringify(section.nodes))
        # debugger
        
    compileSections: (node, component, section=@newSection(node)) ->
        # component.el.css(backgroundColor: 'blue')
        # debugger
        if @addToSection(section, node, component)            
            if (connections = @findConnections(node, component, section)).length == 1
                connection = connections[0]
                if section.components[connection.component.id]
                    @endSection(section, connection.matchingNode, connection.component)
                else
                    return @compileSections(connection.otherNode, connection.component, section)
            else if connections.length > 1
                @endSection(section, node, component)
                for connection in connections
                    parallelSection = @compileSections(connection.otherNode, connection.component)
        else
            @endSection(section, node, component)
    
    findConnections: (node, component, circuit) ->
        connections = []
        for id, c of @components when (c != component and (id == circuit.powerSourceId or !circuit.components[id]))
            for n in (nodes = c.currentNodes())
                matchingNode = @boardPosition(n)
                continue unless @compareNodes(matchingNode, node)
                if nodes.length == 1
                    return [{component: c, matchingNode: matchingNode, otherNode: matchingNode}]                    
                else
                    otherNode = (otherNode for otherNode in nodes when not @compareNodes(matchingNode, otherNode))[0]
                connections.push({component: c, matchingNode: matchingNode, otherNode: @boardPosition(otherNode)})
             
        for segment in @getSegmentsAt(node) when not circuit.components[segment.id]
            matchingNode = (n for n in segment.nodes when @compareNodes(n, node))[0] 
            otherNode = (n for n in segment.nodes when not @compareNodes(n, node))[0]
            connections.push({component: segment, matchingNode: matchingNode, otherNode: otherNode})
         
        return connections