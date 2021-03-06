board = exports ? provide('./board', {})
circuitousObject = require('./object')
Wires = require('./wires').Wires
Analyzer = require('./analyzer').Analyzer
Client = require('../common_objects/client').Client
Animation = require('../common_objects/animation').Animation

class board.Board extends circuitousObject.Object
    cellDimension: 32
    
    constructor: ({@el}) ->
        @init()

    init: ->
        @cells = @el.find('.cells')
        @components = {}
        @changesMade = false
        @width = @cells.width()
        @height = @cells.height()
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
                @cells.append(cell)
          
    addChangeListener: (listener) ->
        @changeListeners or= []
        @changeListeners.push(listener)
     
    recordChange: ->
        @changesMade = true
        if @changeListeners
            $.timeout 250, => listener() for listener in @changeListeners
                
    addComponent: (component, x, y) ->
        @recordChange()
        component.id = @generateId('component') unless component.id

        boardPosition = @boardPosition(x: x, y: y)
        onBoardX = 0 < boardPosition.x < @width
        onBoardY = 0 < boardPosition.y < @height
        if onBoardX and onBoardY 
            @components[component.id] = component
            roundedBoardPosition = @roundedCoordinates(boardPosition, component.centerOffset)
            component.positionAt(@componentPosition(roundedBoardPosition))
            
            component.unbindDrag()
            component.el.bind 'mousedown.perpetuate_board', (e) => @perpetuateDrag(e)
            
            # for node in component.currentNodes()
            #     @addDot(@boardPosition(node))
        else
            return false
            
        return true
            
    perpetuateDrag: (e) ->
        e.stop()
        for cid, c of @components
            return if c.startDrag(e)
        @wires.initDraw(e)
                
            
    removeComponent: (component) -> 
        @recordChange()
        @components[component.id]?.el.unbind('mousedown.perpetuate_board')
        @components[component.id]?.setCurrent(0, true)
        delete @components[component.id]
            
    roundedCoordinates: (coords, offset) ->
        dim = @cellDimension
        halfDim = 0#dim / 2
        offsetCoords = 
            x: coords.x - (offset?.left or offset?.x or 0) + halfDim
            y: coords.y - (offset?.top or offset?.y or 0) + halfDim
            
        return {
            x: (Math.round(offsetCoords.x / dim) * dim) - halfDim
            y: (Math.round(offsetCoords.y / dim) * dim) - halfDim
        }
        
    boardPosition: (componentPosition) ->
        offset = @cells.offset()
        position = JSON.parse(JSON.stringify(componentPosition))
        position.x = componentPosition.x - offset.left
        position.y = componentPosition.y - offset.top 
        return position

    componentPosition: (boardPosition) ->
        offset = @cells.offset()
        position = JSON.parse(JSON.stringify(boardPosition))
        position.x = boardPosition.x + offset.left
        position.y = boardPosition.y + offset.top
        return position

    componentsAndWires: ->
        all = {}
        all[id] = c for id, c of @components
        all[id] = w for id, w of @wires.all()
        return all
    
    initElectricity: ->
        @analyzer = new Analyzer(@)
        @electricalAnimation = new Animation()    
        @electricalAnimation.start 
            method: ({deltaTime, elapsed}) => @moveElectricity(deltaTime, elapsed)
        # $('.menu').bind 'click', => 
        #     @elapsed or= 0
        #     deltaTime = 300
        #     @elapsed += deltaTime            
        #     @moveElectricity(deltaTime, @elapsed)
        
    runAnalysis: ->
        return unless @changesMade
        @changesMade = false
        @analyzedComponentsAndWires = @analyzer.run()
        
    moveElectricity: (deltaTime, elapsed) ->
        return if @movingElectricty
        @movingElectricty = true
        # @slowTime = (@slowTime or 0) + deltaTime
        # return unless @slowTime > 2000
        # @slowTime -= 2000
        
        for id, piece of @componentsAndWires()
            piece.receivingCurrent = false
            piece.excessiveCurrent = false 
        
        @runAnalysis()
        for componentId, componentInfo of @analyzedComponentsAndWires
            continue unless (c = @componentsAndWires()[componentId])    
            c.receivingCurrent = true
            c.setCurrent?(componentInfo.amps)
            if componentInfo.amps == 'infinite'   
                c.excessiveCurrent = true
                c.el.addClass('excessive_current')


        @wires.showCurrent(elapsed)
        
        for id, piece of @componentsAndWires()
            piece.el.removeClass('excessive_current') unless piece.excessiveCurrent
            piece.setCurrent?(0) unless piece.receivingCurrent
        
        $.timeout(50, =>  @movingElectricty = false)
         
    clear: ->
        @wires.clear()
        for id, c of @components
            @removeComponent(c) 
            c.resetDrag()
           
    clearColors: ->
        c.el.css(backgroundColor: null) for id, c of @componentsAndWires()

    color: (componentIds, index) ->
        colors = ['green', 'red', 'yellow', 'purple', 'orange', 'blue', 'brown', 'chartreuse', 'cyan', 'gray', 'khaki', 'pink', 'lavender']
        for componentId in componentIds
            color = colors[index]
            @componentsAndWires()[componentId]?.el?.css(backgroundColor: color)
    
    addDot: ({el, x, y, width, height, color}) ->
        el = @cells if not el
        color = 'red' if not color
        dot =  $(document.createElement('DIV'))
        dot.html('&nbsp;')
        dot.css
            position: 'absolute'
            backgroundColor: color
            width: width or 4
            height: height or 4
            marginTop: if height then 0 else -2
            marginLeft: if width then 0 else -2
            left: x
            top: y
            zIndex: 9
        el.append(dot)
        console.log('dot', x, y, width, height, dot)
