xyflyerEditor = exports ? provide('./lib/xyflyer_editor', {})

class xyflyerEditor.EditorHelper
    $: (selector) -> $(selector, @el)

    constructor: ({@el, @equationArea, @boardElement, @objects}) ->
        @rings = []
        @parser = require('./parser')
        @init()
        
    init: ->
        @initBoard({})
                        
        @equations = new xyflyer.Equations
            el: @equationArea
            gameArea: @el
            plot: (id, data) => @plot(id, data)
            submit: => @plane?.launch(true) 

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

    initButtons: ->
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
                @equations.add()
            else    
                alert("You've already added the maximum number of equations.")
                    
        @$('.editor .remove_equation').bind 'click', =>
            if @equations.length <= 1
                alert('You must have at least one equation.')
            else
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
        
        closeDialog = ->
            dialog.animate
                opacity: 0
                duration: 250
                complete: -> dialog.remove()
        
        dialog.find('button').bind 'click', =>
            closeDialog()
            data = {}
            for i in dialog.find('input')
                input = $(i)
                data[input.attr('name')] = (if input.hasClass('number') then parseFloat(input.val()) else input.val())
            callback(data)
            
        dialog.find('a').bind 'click', => closeDialog()
        