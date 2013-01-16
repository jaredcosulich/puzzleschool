xyflyerEditor = exports ? provide('./lib/xyflyer_editor', {})

class xyflyerEditor.EditorHelper
    $: (selector) -> $(selector, @el)

    constructor: ({@el, @equationArea, @boardElement, @objects, @encode}) ->
        @rings = []
        @parser = require('./parser')
        @init()
        
    init: ->
        @initBoard({})
                        
        @equations = new xyflyer.Equations
            el: @equationArea
            gameArea: @el
            plot: (id, data) => @plot(id, data)
            submit: => @launch()

        @equations.add()
        
        @initButtons()
            
    initBoard: ({grid, islandCoordinates}) ->
        if grid
            @grid = grid
        else if not @grid
            @grid = 
                xMin: -10
                xMax: 10
                yMin: -10
                yMax: 10 
            
        if islandCoordinates
            @islandCoordinates = islandCoordinates
        else if not @islandCoordinates
            @islandCoordinates = {x: 0, y: 0} 
        
        @board.paper.clear() if @board
        
        @board = new xyflyer.Board
            boardElement: @boardElement 
            objects: @objects
            grid: @grid 
            islandCoordinates: @islandCoordinates
            resetLevel: => @resetLevel()
    
        @plane = new xyflyer.Plane
            board: @board
            track: (info) => @trackPlane(info)
            
        if @equations
            @equations.plotFormula(equation) for equation in @equations?.equations

    initButtons: ->
        if not @board?.island
            $.timeout 100, => @initButtons()
            return
            
        @$('.editor .edit_board').bind 'click', =>
            @showDialog
                text: 'What should the bounds of the board be?'
                fields: [
                    ['xMin', 'Minimum X']
                    ['xMax', 'Maximum X']
                    []
                    ['yMin', 'Minimum Y']
                    ['yMax', 'Maximum Y']
                ]
                callback: (data) => @initBoard(grid: data)            

        @$('.editor .edit_island').bind 'click', =>
            @showDialog
                text: 'What should the coordinates of the island be?'
                fields: [
                    ['x', 'X']
                    ['y', 'Y']
                ]
                callback: (data) => @initBoard(islandCoordinates: data)            

        @$('.editor .add_equation').bind 'click', =>
            if @equations.length < 3
                @hideInstructions()
                @equations.add()
            else    
                alert("You've already added the maximum number of equations.")
                    
        @$('.editor .remove_equation').bind 'click', =>
            if @equations.length <= 1
                alert('You must have at least one equation.')
            else
                @hideInstructions()
                equation = @equations.remove()

        @$('.editor .add_fragment').bind 'click', =>
            @showDialog
                text: 'What equation fragment do you want to add?'
                fields: [
                    ['fragment', 'Fragment', 'text']
                ]
                callback: (data) => @equations.addComponent(data.fragment)  
            
        @$('.editor .remove_fragment').bind 'click', =>
            alert('Please click on the equation fragment you want to remove.')
            for component in @equations.equationComponents
                component.element.bind 'click.remove', =>
                    @hideInstructions()
                    c.element.unbind('click.remove') for c in @equations.equationComponents
                    @equations.removeComponent(component)

        @$('.editor .add_ring').bind 'click', =>
            @showDialog
                text: 'What should the coordinates of this new ring be?'
                fields: [
                    ['x', 'X']
                    ['y', 'Y']
                ]
                callback: (data) => 
                    @rings.push(
                        new xyflyer.Ring
                            board: @board
                            x: data.x
                            y: data.y
                    )

        @$('.editor .remove_ring').bind 'click', =>
            alert('Please click on the ring you want to remove.')
            @boardElement.bind 'click.remove_ring', (e) =>
                @hideInstructions()
                @boardElement.unbind('click.remove_ring')
                @board.initClicks(@boardElement)
                for ring, index in @rings
                    if ring.touches(e.offsetX,e.offsetY,12,12)
                        @rings.splice(index, 1)
                        ring.image.remove()
                        ring.label.remove()
                        return
                alert('No ring detected. Please click \'Remove\' again if you want to remove a ring.')
            @boardElement.unbind('click.showxy')
        
        @boardElement.bind 'mousedown.dragisland', (e) =>
            elements = @board.paper.getElementsByPoint(e.offsetX, e.offsetY)
            for element in elements when element[0].href?.toString()?.indexOf('island')
                xStart = e.clientX
                yStart = e.clientY
                @boardElement.bind 'mousemove.dragisland', (e) =>
                    @board.island.transform("...t#{e.clientX - xStart},#{e.clientY - yStart}")
                    x = @board.screenX(@islandCoordinates.x)+(e.clientX - xStart)
                    y = @board.screenY(@islandCoordinates.y)+(e.clientY - yStart)
                    @plane.move(x, y, 0)
                    @board.islandCoordinates = @islandCoordinates = {x: @board.paperX(x), y: @board.paperY(y)}
                    @board.islandLabel.attr(text: @board.islandText())
                    xStart = e.clientX
                    yStart = e.clientY
                    
                @boardElement.one 'mouseup.dragisland', => 
                    @initBoard({})
                    @boardElement.unbind('mousemove.dragisland')
                    
                
    plot: (id, data) ->
        [formula, area] = @parser.parse(data)
        @board.plot(id, formula, area)
        
    launch: -> @plane?.launch(true) 
        
    resetLevel: ->
        @plane.reset()
        ring.reset() for ring in @rings
    
    trackPlane: (info) ->
        allPassedThrough = @rings.length > 0
        for ring in @rings
            ring.highlightIfPassingThrough(info) 
            allPassedThrough = false unless ring.passedThrough
        @showInstructions() if allPassedThrough

    showDialog: ({text, fields, callback}) ->
        dialog = $(document.createElement('DIV'))
        dialog.addClass('dialog')
        dialog.html """
            <h3>#{text}</h3>
            <table><tbody><tr></tr></tbody></table>
            <button class='button'>Save</button> &nbsp; <a class='blue_button'>Cancel</a>
        """
        for fieldInfo in fields
            if not fieldInfo.length 
                dialog.find('tbody').append('<tr></tr>')
                continue

            lastRow = dialog.find('tr:last-child')
            lastRow.append("<td>#{fieldInfo[1]}:</td><td><input name='#{fieldInfo[0]}' class='#{fieldInfo[2] or 'number'}'/></td>")
        @el.append(dialog)
        dialog.css(opacity: 0, left: (@el.width()/2) - (dialog.width()/2))
        dialog.animate(opacity: 1, duration: 250, complete: -> dialog.find('input:first-child').focus())
        dialog.bind 'mousedown', (e) =>
            e.preventDefault() if e.preventDefault
            body = $(document.body)
            leftStart = dialog.offset().left - @el.offset().left
            leftClick = e.clientX
            topStart = dialog.offset().top - @el.offset().top
            topClick = e.clientY
            body.bind 'mousemove.dialog', (e) =>
                e.preventDefault() if e.preventDefault
                dialog.css(left: leftStart+(e.clientX-leftClick), top: topStart+(e.clientY-topClick))
                
            body.one 'mouseup', =>
                body.unbind('mousemove.dialog')    
        
        closeDialog = ->
            dialog.animate
                opacity: 0
                duration: 250
                complete: -> dialog.remove()
        
        dialog.find('button').bind 'click', =>
            @hideInstructions()
            closeDialog()
            data = {}
            for i in dialog.find('input')
                input = $(i)
                data[input.attr('name')] = (if input.hasClass('number') then parseFloat(input.val()) else input.val())
            callback(data)
            
        dialog.find('a').bind 'click', => closeDialog()
        
    showInstructions: ->
        @$('.instructions p').hide()
        @$('.instructions input').show()
        instructions = {equations: {}, rings: []}
        
        for equation in @equations.equations
            instructions.equations[equation.straightFormula()] = {}
            
        instructions.grid = @grid
        
        instructions.islandCoordinates = @islandCoordinates
        
        for ring in @rings
            instructions.rings.push(x: ring.x, y: ring.y)
            
        for component in @equations.equationComponents
            instructions.fragments or= []
            instructions.fragments.push(component.equationFragment)
            
        @$('.instructions input').val(JSON.stringify(instructions))
        
    hideInstructions: ->
        @$('.instructions input').hide()
        @$('.instructions p').show()
        
        
        
        
        