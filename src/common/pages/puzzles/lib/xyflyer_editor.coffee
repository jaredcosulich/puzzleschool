xyflyerEditor = exports ? provide('./lib/xyflyer_editor', {})

class xyflyerEditor.EditorHelper
    $: (selector) -> $(selector, @el)

    constructor: ({@el, @equationArea, @boardElement, @objects, @encode, @islandCoordinates, @grid, @variables}) ->
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
            
        @variables or= {}

        @initButtons()
        @hideInstructions()
            
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
                equation = @equations.remove()
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
                        return
                alert('No ring detected. Please click \'Remove\' again if you want to remove a ring.')
                @handleModification()
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
                    
    addEquation: (equationString, start, solutionComponents) -> 
        if not start
            @showDialog
                text: 'What should this equation start with?'
                fields: [
                    ['start', 'Starting Equation', 'text']
                ]
                callback: (data) => @actuallyAddEquation(equationString, data.start, solutionComponents)
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
                    
    displayVariables: ->
        
    
    addRing: (x, y) -> 
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
            @handleModification()
            
        dialog.find('a').bind 'click', => closeDialog()
    
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
                equations:
                    
        """
        
        for equation in @equations.equations
            equationInstructions = instructions.equations[equation.straightFormula()] = {}
            @coffeeInstructions += "'#{equation.straightFormula()}':"
            if equation.startingFragment
                equationInstructions.start = equation.startingFragment 
                @coffeeInstructions += "\n\t\t\tstart: '#{equation.startingFragment}'"

            if (solutionComponents = @constructSolutionComponents(equation)).length
                equationInstructions.solutionComponents = solutionComponents
                @coffeeInstructions += '\n\t\t\tsolutionComponents: ['
                for sc in solutionComponents
                    @coffeeInstructions += "\n\t\t\t\t{fragment: '#{sc.fragment}', after: '#{sc.after}'}"
                @coffeeInstructions += '\n\t\t\t]'

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
            

        @coffeeInstructions += '\n\tfragments: ['
        instructions.fragments = []
        for component in @equations.equationComponents
            instructions.fragments.push(component.equationFragment)
        @coffeeInstructions += "#{("'#{ec.equationFragment}'" for ec in @equations.equationComponents).join(', ')}]"

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
            
                    '#{variable}':
                        start: #{info.start}
                        min: #{info.min}
                        max: #{info.max}
                        increment: #{info.increment}
                        solution: #{instructions.variables[variable].solution}
            """
        
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
        
        
        
        
        