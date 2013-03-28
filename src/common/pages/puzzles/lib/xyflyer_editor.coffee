xyflyerEditor = exports ? provide('./lib/xyflyer_editor', {})

class xyflyerEditor.EditorHelper
    $: (selector) -> $(selector, @el)

    constructor: ({@el, @equationArea, @boardElement, @objects, @encode, @islandCoordinates, @grid, @variables, @assets}) ->
        @parser = require('./parser')
        @init()
        
    init: ->
        @variables or= {}
        @rings = []
        @assets or= {}
        @setAsset(asset, index) for asset, index of @assets

        @initBoard({})
                        
        @equations = new xyflyer.Equations
            el: @equationArea
            gameArea: @el
            plot: (id, data) => @plot(id, data)
            submit: => @launch()

        @initButtons()
        @hideInstructions()
        
        editor = @$('.editor')
        @$('.editor').bind 'mousedown.move_editor', (e) =>
            startX = e.clientX
            startY = e.clientY
            startEditorX = parseInt(editor.css('left'))
            startEditorY = parseInt(editor.css('top'))
            
            $(document.body).bind 'mousemove.move_editor', (e) =>
                editor.css
                    left: startEditorX - (startX - e.clientX)
                    top: startEditorY - (startY - e.clientY)
                    
            $(document.body).one 'mouseup.move_editor', =>
                $(document.body).unbind('mousemove.move_editor')
                
                
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
        
        @board.clear() if @board

        @board = new xyflyer.Board
            el: @boardElement 
            objects: @objects
            grid: @grid 
            islandCoordinates: @islandCoordinates
            resetLevel: => @resetLevel()
    
        if @plane
            @plane.setBoard(@board)
            @plane.reset()
        else    
            @plane = new xyflyer.Plane
                board: @board
                objects: @objects
                track: (info) => @trackPlane(info)
                
        ring.setBoard(@board) for ring in @rings
            
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
                @addEquation() 
                @handleModification()
            else    
                alert("You've already added the maximum number of equations.")
                    
        @$('.editor .remove_equation').bind 'click', =>
            if @equations.length <= 1
                alert('You must have at least one equation.')
            else
                alert('Please click on the equation you want to remove.')
                for equation in @equations.equations
                    do (equation) =>
                        equation.el.bind 'mousedown.remove', =>
                            e.el.unbind('mousedown.remove') for e in @equations.equations
                            dropArea.component?.reset() for dropArea in equation.dropAreas                             
                            @equations.remove(equation)
                            @handleModification()

        @$('.editor .add_fragment').bind 'click', =>
            @showDialog
                text: 'What equation fragment do you want to add?'
                fields: [
                    ['fragment', 'Fragment', 'text']
                ]
                callback: (data) => @addEquationComponent(data.fragment) 
            
        @$('.editor .remove_fragment').bind 'click', =>
            alert('Please click on the equation fragment you want to remove.')
            for component in @equations.equationComponents
                do (component) =>
                    component.element.bind 'mousedown.remove', =>
                        c.element.unbind('mousedown.remove') for c in @equations.equationComponents
                        if component.variable
                            delete @variables[component.variable]
                        @equations.removeComponent(component)
                        @handleModification()

        @$('.editor .add_ring').bind 'click', =>
            @showDialog
                text: 'What should the coordinates of this new ring be?'
                fields: [
                    ['x', 'X']
                    ['y', 'Y']
                ]
                callback: (data) => @addRing(data.x, data.y)

        @$('.editor .remove_ring').bind 'click', =>
            alert('Please click on the ring you want to remove.')
            @boardElement.bind 'click.remove_ring', (e) =>
                @boardElement.unbind('click.remove_ring')
                @board.initClicks(@boardElement)
                for ring, index in @rings
                    if ring.touches(e.offsetX,e.offsetY,12,12)
                        @rings.splice(index, 1)
                        ring.remove()
                        @handleModification()
                        return
                alert('No ring detected. Please click \'Remove\' again if you want to remove a ring.')
            @boardElement.unbind('click.showxy')
        
        @$('.editor .change_background').bind 'click', => 
            @showImageDialog "Select The Background Image", 'background', 3, (index) => @setAsset('background', index)

        @$('.editor .change_island').bind 'click', => 
            @showImageDialog "Select The Island Image", 'island', 2, (index) => @setAsset('island', index)

        @$('.editor .change_plane').bind 'click', => 
            @showImageDialog "Select The Plane", 'plane', 2, (index) => @setAsset('plane', index)

        @$('.editor .reset_editor').bind 'click', => 
            location.href = location.pathname if confirm('Are you sure you want to reset the editor?\n\nAll of your changes will be lost.')
        
        @boardElement.bind 'mousedown.dragisland', (e) =>
            xStart = currentX = e.clientX
            yStart = currentY = e.clientY
            elements = @board.paper.getElementsByPoint(e.offsetX, e.offsetY)
            for element in elements when element[0].href?.toString()?.indexOf('island')
                @boardElement.bind 'mousemove.dragisland', (e) =>
                    @board.island.transform("...t#{e.clientX - currentX},#{e.clientY - currentY}")
                    x = @board.screenX(@islandCoordinates.x)+(e.clientX - currentX)
                    y = @board.screenY(@islandCoordinates.y)+(e.clientY - currentY)
                    @plane.move(x, y, 0)
                    @board.islandCoordinates = @islandCoordinates = {x: @board.paperX(x), y: @board.paperY(y)}
                    @board.islandLabel.attr(text: @board.islandText())
                    currentX = e.clientX
                    currentY = e.clientY
                    
                @boardElement.one 'mouseup.dragisland', (e) => 
                    @initBoard({}) if e.clientX != xStart and e.clientY != yStart
                    @boardElement.unbind('mousemove.dragisland')
                    @handleModification()
                    
    addEquation: (equationString, start, solutionComponents) -> 
        if not start
            @showDialog
                text: 'What should this equation start with?'
                fields: [
                    ['start', 'Starting Equation', 'text']
                ]
                callback: (data) => @actuallyAddEquation(equationString, (data.start or '').toLowerCase(), solutionComponents)
        else
            @actuallyAddEquation(equationString, start, solutionComponents)
            
    actuallyAddEquation: (equationString, start, solutionComponents) -> 
        equation = @equations.add(equationString, start, solutionComponents, @variables)  
        for solutionComponent in (solutionComponents or [])
            component = (c for c in @equations.equationComponents when c.equationFragment == solutionComponent.fragment)[0]
            continue if component.after == solutionComponent.after
            accept = @equations.findComponentDropAreaElement(equation, solutionComponent)
            if accept?.length
                do (solutionComponent, component, accept) =>
                    dropArea = (da for da in equation.dropAreas when da.element[0] == accept[0])[0]
                    equation.accept(dropArea, component)
                    component.initMeasurements()
                    component.setDragging()
                    component.element.css(visibility: 'hidden')                    
                    if component.variable
                        setTimeout((=>
                            equation.variables[component.variable].set(@variables[component.variable].solution)
                        ), 100)

        @handleModification()
       
    addEquationComponent: (fragment) -> 
        component = @equations.addComponent(fragment) 
        if (result = ///(^|[^a-w])([a-d])($|[^a-w])///.exec(fragment))
            variable = result[2]
            component.variable = variable
            if not @variables[variable]
                @showDialog
                    text: 'What is the range of this variable?'
                    fields: [
                        ['min', 'From (min)']
                        ['max', 'To (max)']
                        []
                        ['increment', 'By (increment)']
                        ['start', 'Starting At']
                    ]
                    callback: (data) =>
                        @variables[variable] = data
                        for equation in @equations.equations
                            equation.variables or= {}
                            equation.variables[variable] = data
                        @handleModification()
                            
        @handleModification()
                        
    addRing: (x, y) -> 
        if (isNaN(parseInt(x)) or isNaN(parseInt(y)))
            alert('Those coordinates are not valid.')
            return
        @rings.push(new xyflyer.Ring(board: @board, x: x, y: y))
        @handleModification()

    plot: (id, data) ->
        [formula, area] = @parser.parse(data)
        @board.plot(id, formula, area)
        @handleModification()
        
    launch: -> 
        @plane?.launch(true) 
        @handleModification()
        
    resetLevel: ->
        @plane?.reset()
        ring.reset() for ring in @rings
    
    trackPlane: (info) ->
        allPassedThrough = @rings.length > 0
        for ring in @rings
            ring.highlightIfPassingThrough(info) 
            allPassedThrough = false unless ring.passedThrough
        
        @showInstructions() if allPassedThrough

    createDialog: (html, callback) ->
        dialog = $(document.createElement('DIV'))
        dialog.addClass('dialog')
        dialog.html(html)
        
        @el.append(dialog)
        dialog.css(opacity: 0, left: (@el.width()/2) - (dialog.width()/2))
        dialog.animate(opacity: 1, duration: 250, complete: -> dialog.find('input:first-child').focus())
        dialog.bind 'mousedown.dialog', (e) =>
            body = $(document.body)
            leftStart = dialog.offset().left - @el.offset().left
            leftClick = e.clientX
            topStart = dialog.offset().top - @el.offset().top
            topClick = e.clientY
            body.bind 'mousemove.dialog', (e) =>
                return if document.activeElement.type == 'text'
                e.preventDefault() if e.preventDefault
                dialog.css(left: leftStart+(e.clientX-leftClick), top: topStart+(e.clientY-topClick))
                
            body.one 'mouseup', =>
                body.unbind('mousemove.dialog')    
                        
        dialog.find('.cancel_button').bind 'click', => @closeDialog(dialog)
                
        return dialog
        
    closeDialog: (dialog) ->
        dialog.animate
            opacity: 0
            duration: 250
            complete: -> dialog.remove()
        
    showImageDialog: (text, name, count, callback) ->
        html = "<h3>#{text}</h3><table><tbody><tr>"
        
        for index in [1..count]
            html += "<td><div class='image'><img src='https://raw.github.com/jaredcosulich/puzzleschool/redesign/assets/images/puzzles/xyflyer/#{name}#{index}.png' style='opacity: 0'/></div></td>"
        
        html += """
            </tr></tbody></table>
            <a class='blue_button cancel_button'>Cancel</a>
        """
        dialog = @createDialog(html)
        for image in dialog.find('img')
            resize = (image) ->
                height = image.height()
                width = image.width()
                if not height or not width
                    setTimeout((-> resize(image)), 100)
                    return
                    
                if height > 120
                    ratio = 120/height
                    image.height(120)
                    width = width * ratio
                    image.width(width)
            
                if width > 160
                    ratio = 160/width
                    image.width(160)
                    image.height(image.height() * ratio)
                
                image.animate(opacity: 1, duration: 250)
            resize($(image))
                
        
        dialog.find('img').bind 'click', (e) =>
            e.stop()
            $(document.body).unbind('dialog.move')
            @closeDialog(dialog)
            srcComponents = e.currentTarget.src.split('/')
            callback(srcComponents[srcComponents.length - 1].replace(/[^1-9]/g, ''))
        

    showDialog: ({text, fields, callback}) ->
        dialog = @createDialog """
            <h3>#{text}</h3>
            <table><tbody><tr></tr></tbody></table>
            <button class='button'>Save</button> &nbsp; <a class='blue_button cancel_button'>Cancel</a>
        """
        
        for fieldInfo in fields
            if not fieldInfo.length 
                dialog.find('tbody').append('<tr></tr>')
                continue

            lastRow = dialog.find('tr:last-child')
            lastRow.append("<td>#{fieldInfo[1]}:</td><td><input name='#{fieldInfo[0]}' class='#{fieldInfo[2] or 'number'}'/></td>")
        
        dialog.find('button').bind 'click', =>
            @closeDialog(dialog)
            data = {}
            for i in dialog.find('input')
                input = $(i)
                data[input.attr('name')] = (if input.hasClass('number') then parseFloat(input.val()) else input.val())
            callback(data)
            @handleModification()
            
        dialog.find('a').bind 'click', => closeDialog()
        
    setAsset: (type, index) ->
        @assets[type] = index
        src = "https://raw.github.com/jaredcosulich/puzzleschool/redesign/assets/images/puzzles/xyflyer/#{type}#{index}.png"
        switch type
            when 'background'
                @el.css(backgroundImage: "url(#{src})")
            else
                @objects.find(".#{type} img").remove()
                @objects.find(".#{type}").html("<img src='#{src}'/>")
                @initBoard({})
        @handleModification()
                
    constructSolutionComponents: (equation) ->
        solutionComponents = []
        for dae in equation.el.find('div')
            dropArea = (da for da in equation.dropAreas when da.element?[0] == dae)[0] 
            if dropArea?.component
                solutionComponents.push
                    fragment: dropArea.component.equationFragment
                    after: dropArea.component.after
        return solutionComponents
                
    getInstructions: ->
        instructions = {equations: {}, rings: []}
        @coffeeInstructions = """
            {
                id: #{new Date().getTime()}
        """
        
        if @equations
            @coffeeInstructions += "\n\tequations:"
            for equation in @equations.equations
                equationInstructions = instructions.equations[equation.straightFormula()] = {}
                @coffeeInstructions += "\n\t\t'#{equation.straightFormula()}':"
                if equation.startingFragment
                    equationInstructions.start = equation.startingFragment 
                    @coffeeInstructions += "\n\t\t\tstart: '#{equation.startingFragment}'"

                if (solutionComponents = @constructSolutionComponents(equation)).length
                    equationInstructions.solutionComponents = solutionComponents
                    @coffeeInstructions += '\n\t\t\tsolutionComponents: ['
                    for sc in solutionComponents
                        @coffeeInstructions += "\n\t\t\t\t{fragment: '#{sc.fragment}', after: '#{sc.after}'}"
                    @coffeeInstructions += '\n\t\t\t]'
            
            @coffeeInstructions += '\n\tfragments: ['
            instructions.fragments = []
            for component in @equations.equationComponents
                instructions.fragments.push(component.equationFragment)
            @coffeeInstructions += "#{("'#{ec.equationFragment}'" for ec in @equations.equationComponents).join(', ')}]"
            

        @coffeeInstructions += '\n\trings: ['
        for ring in @rings
            instructions.rings.push(x: ring.x, y: ring.y)
            @coffeeInstructions += "\n\t\t{x: #{ring.x}, y: #{ring.y}}"
        @coffeeInstructions += '\n\t]'
            
        instructions.grid = @grid
        @coffeeInstructions += """
        
            grid:
                xMin: #{@grid.xMin}
                xMax: #{@grid.xMax}
                yMin: #{@grid.yMin}
                yMax: #{@grid.yMax}
        """
        
        instructions.islandCoordinates = @islandCoordinates
        @coffeeInstructions += "\n\tislandCoordinates: {x: #{@islandCoordinates.x}, y: #{@islandCoordinates.y}}"
            
        for variable, info of @variables
            if not instructions.variables
                instructions.variables = {}
                @coffeeInstructions += '\n\tvariables: '          
            
            instructions.variables[variable] = 
                start: info.start
                min: info.min
                max: info.max
                increment: info.increment
                solution: (if info.get then info.get() else null)
            @coffeeInstructions += """
            
                    #{variable}:
                        start: #{info.start}
                        min: #{info.min}
                        max: #{info.max}
                        increment: #{info.increment}
                        solution: #{instructions.variables[variable].solution}
            """
            
        for asset, index of @assets 
            if not instructions.assets
                instructions.assets = {}
                @coffeeInstructions += '\n\tassets: '   
            
            instructions.assets[asset] = index
            @coffeeInstructions += "\n\t\t#{asset}: #{index}"
        
        @coffeeInstructions += '\n}'
        return @encode(JSON.stringify(instructions))
        
    handleModification: ->
        @hashInstructions()    
        @hideInstructions()
        
    hashInstructions: ->    
        levelString = @getInstructions()
        window.location.hash = levelString
        
    showInstructions: ->
        return if @instructionsDisplayed
        @instructionsDisplayed = true
        @$('.instructions .invalid').hide()
        @$('.instructions .valid').show()
        href = location.protocol+'//'+location.host+location.pathname
        @$('.instructions .link').val("#{href.replace(/editor/, 'custom')}##{@getInstructions()}")
        @hashInstructions()
        console.log(@coffeeInstructions.replace(/\t/g, '    '))
        
        
    hideInstructions: ->
        @instructionsDisplayed = false
        @$('.instructions .valid').hide()
        @$('.instructions .invalid').show()
        
        
        
        
        