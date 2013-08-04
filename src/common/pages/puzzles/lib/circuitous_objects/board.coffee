board = exports ? provide('./board', {})
circuitousObject = require('./object')
Wires = require('./wires').Wires
Analyzer = require('./analyzer').Analyzer
Client = require('../common_objects/client').Client
Animation = require('../common_objects/animation').Animation

class board.Board extends circuitousObject.Object
    constructor: ({@el, @cellDimension}) ->
        @init()

    init: ->
        @components = {}
        @width = @el.width()
        @height = @el.height()
        @drawGrid()
        @initElectricity()
        @wires = new Wires(@)
        
    drawGrid: ->
        rows = @height / @cellDimension
        columns = @width / @cellDimension
        for row in [1..rows]
            for column in [1..columns]
                cell = $(document.createElement('DIV'))
                cell.addClass('cell')
                cell.css(width: @cellDimension-1, height: @cellDimension-1)
                @el.append(cell)
                
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
            
    roundedCoordinates: (coords, offset) ->
        halfDim = @cellDimension / 2
        offsetCoords = 
            x: coords.x - (offset?.left or offset?.x or 0) + halfDim
            y: coords.y - (offset?.top or offset?.y or 0) + halfDim
            
        return {
            x: (Math.round(offsetCoords.x / @cellDimension) * @cellDimension) - halfDim
            y: (Math.round(offsetCoords.y / @cellDimension) * @cellDimension) - halfDim
        }
        
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

    componentsAndWires: ->
        all = {}
        all[id] = c for id, c of @components
        all[id] = w for id, w of @wires.all()
        return all
    
    initElectricity: ->
        @analyzer = new Analyzer(@)
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
        
        circuit = @analyzer.run()
        if circuit and circuit.complete
            for section in circuit.sections
                for id of section.components
                    continue unless (c = @componentsAndWires()[id])                     
                    if section.amps == 'infinite'   
                        c.excessiveCurrent = true
                        c.el.addClass('excessive_current')
                    else
                        c.receivingCurrent = true
                        c.setCurrent?(section.amps)
        
        for id, piece of @componentsAndWires()
            piece.el.removeClass('excessive_current') unless piece.excessiveCurrent
            piece.setCurrent?(0) unless piece.receivingCurrent
            
    clearColors: ->
        c.el.css(backgroundColor: null) for id, c of @componentsAndWires()

    color: (componentIds, index) ->
        colors = ['red', 'green', 'yellow', 'purple', 'orange', 'blue', 'brown', 'chartreuse', 'cyan', 'gray', 'khaki', 'pink', 'lavender']
        for componentId in componentIds
            color = colors[index]
            @componentsAndWires()[componentId]?.el?.css(backgroundColor: color)
    
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
