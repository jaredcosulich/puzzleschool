xyflyerEditor = exports ? provide('./lib/xyflyer_editor', {})

class xyflyerEditor.EditorHelper
    $: (selector) -> $(selector, @el)

    constructor: ({@el, @equationArea, @boardElement, @objects}) ->
        @rings = []
        @parser = require('./parser')
        @init()
        
    init: ->
        @initBoard
            grid: 
                xMin: -10
                xMax: 10
                yMin: -10
                yMax: 10 
            islandCoordinates: {x: 0, y: 0}
                        
        @equations = new xyflyer.Equations
            el: @equationArea
            gameArea: @el
            plot: (id, data) => @plot(id, data)
            submit: => @plane?.launch(true) 

        @equations.add()
        
        @initButtons()
            
    initBoard: ({grid, islandCoordinates}) ->
        @board.paper.clear() if @board
        
        @board = new xyflyer.Board
            boardElement: @boardElement 
            objects: @objects
            grid: grid 
            islandCoordinates: islandCoordinates
            resetLevel: => @resetLevel()
    
        @plane = new xyflyer.Plane
            board: @board
            track: (info) => @trackPlane(info)

    initButtons: ->
        @$('.editor .add_equation').bind 'click', =>
            if @equations.length < 3
                @equations.add()
            else    
                alert("You've already added the maximum number of equations.")
                    
        @$('.editor .remove_equation').bind 'click', =>
            if @equations.length <= 1
                alert('You must have at least one equation.')
            else
                equation = @equations.remove()

        @$('.editor .add_fragment').bind 'click', =>
            @equations.addComponent(prompt('What equation fragment do you want to add?'))
            
        @$('.editor .remove_fragment').bind 'click', =>
            alert('Please click on the equation fragment you want to remove.')
            for component in @equations.equationComponents
                component.element.bind 'click.remove', =>
                    c.element.unbind('click.remove') for c in @equations.equationComponents
                    @equations.removeComponent(component)

        @$('.editor .add_ring').bind 'click', =>
            x = prompt('What is the x coordinate of this ring?')
            y = prompt('What is the y coordinate of this ring?')
            @rings.push(
                new xyflyer.Ring
                    board: @board
                    x: x
                    y: y
            )

        @$('.editor .remove_ring').bind 'click', =>

            
    plot: (id, data) ->
        [formula, area] = @parser.parse(data)
        @board.plot(id, formula, area)
        
    resetLevel: ->
        @plane.reset()
        ring.reset() for ring in @rings
    
    trackPlane: (info) ->
        allPassedThrough = @rings.length > 0
        for ring in @rings
            ring.highlightIfPassingThrough(info) 
            allPassedThrough = false unless ring.passedThrough
#        @completeLevel() if allPassedThrough

     