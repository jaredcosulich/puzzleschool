shuffle = (array) ->
    top = array.length
    return array if not top

    while(top--) 
        current = Math.floor(Math.random() * (top + 1))
        tmp = array[current]
        array[current] = array[top]
        array[top] = tmp
    return array

spaceFractions = exports ? provide('./lib/space_fractions', {})

LASER_HEIGHT = 20

OBJECTS = 
    rock1: 
        image: 'rock1'
        index: -1

    rock2: 
        image: 'rock2'
        index: -2

# directional objects
directions = ['up', 'down', 'left',  'right']
for direction, index in directions
    #ships
    OBJECTS["ship_#{direction}"] =
        index: index
        image: "ship_#{direction}"
        accept: true
        acceptDirections: [direction]
        states: true
        showFraction: true

    #lasers
    OBJECTS["laser_#{direction}"] =
        index: 10 + index
        image: "laser_#{direction}"
        distribute: true
        distributeDirections: [direction]
        accept: false
        showFraction: true
        
    #three-way splitters
    OBJECTS["three_way_split_#{direction}"] =
        index: 10000 + index
        image: "three_way_split_#{direction}"
        distribute: true
        distributeDirections: [direction, (if index < 2 then directions[2..3] else directions[0..1])...]
        accept: true
        acceptDirections: [direction]
        denominatorMultiplier: 3
        movable: true
        
    for direction2, index2 in directions
        continue if (index < 2 and index2 < 2) or (index > 1 and index2 > 1)
        #turners
        OBJECTS["turn_#{direction}_#{direction2}"] =
            index: 100 + (index * directions.length) + index2
            image: "turn_#{direction}_#{direction2}"
            distribute: true
            distributeDirections: [direction2]
            accept: true
            acceptDirections: [direction]
            movable: true
            
        #splitters
        OBJECTS["two_split_#{direction}_#{direction2}"] =
            index: 1000 + (index * directions.length) + index2
            image: "two_split_#{direction}_#{direction2}"
            distribute: true
            distributeDirections: [direction, direction2]
            accept: true
            acceptDirections: [direction]
            denominatorMultiplier: 2
            movable: true
        
        
class spaceFractions.ChunkHelper
    objects: OBJECTS
    constructor: () ->
    

class spaceFractions.ViewHelper
    baseFolder: '/assets/images/puzzles/space_fractions/'
    objects: OBJECTS

    constructor: ({@el, @rows, @columns}) ->
        @initBoard()
        @initOptions()
        @initHint()
        
        window.onresize = =>
            for square in @board.find('.square.occupied')
                @fireLaser(square)

    $: (selector) -> $(selector, @el)

    initBoard: ->
        @board = @$('.board')
        @board.html('')
        
        for row in [0...@rows]
            for column in [0...@columns]
                index = (row * @rows) + column
                square = $(document.createElement('DIV'))
                square.addClass('square')
                square.data('index', index)
                square.addClass("index#{index}")
                @board.append(square)

    initOptions: ->
        @options = @$('.options')
        @options.html('')
        
        for row in [0...7]
            for column in [0...4]
                index = (row * 3) + column
                square = $(document.createElement('DIV'))
                square.addClass('square')
                square.data('index', index)
                square.addClass("index#{index}")
                @options.append(square)
        
    initHint: ->
        @$('.hint').bind 'click', =>
            for object in @solution.objects
                square = @board.find(".square.index#{object.index}")
                if square.length and square.data('objectType') != object.type
                    option = $(@options.find(".square.#{object.type}")[0])
                    if not option?.length
                        boardOptions = @board.find(".square.#{object.type}")
                        for boardOption in boardOptions
                            if (o.type for o in @solution.objects when o.index == $(boardOption).data('index'))[0] != object.type
                                option = $(boardOption)
                                break
                                
                    if option?.length
                        option.addClass('selected')
                        dragMessage = @$('.hint_drag_message')
                        dragMessage.css
                            left: option.offset().left + (option.width() / 2) - (dragMessage.width() / 2)
                            top: option.offset().top + option.height()
                        dragMessage.animate
                            opacity: 1
                            duration: 250
                            
                        option.one 'mousedown', =>
                            dragMessage.css(opacity: 0)
                            square.addClass('permanently_selected')
                            dropMessage = @$('.hint_drop_message')
                            dropMessage.css
                                left: square.offset().left + (square.width() / 2) - (dropMessage.width() / 2)
                                top: square.offset().top + square.height()
                            dropMessage.animate
                                opacity: 1
                                duration: 250
                                
                            hideHint = () =>  
                                unless square.hasClass(object.type)
                                    $.timeout 50, => hideHint()
                                    return
                                @$('.hint_message').animate
                                    opacity: 0
                                    duration: 250
                                @$('.square.permanently_selected').removeClass('permanently_selected')                                
                            hideHint()
                            
                        return        

    setObjectImage: (square) ->
        objectType = square.data('objectType')
        objectMeta = @objects[objectType]
        return unless objectMeta
        if objectMeta.states
            laserData = JSON.parse(square.data('lasers') or '{}')
            acceptedLaser = laserData[objectMeta.acceptDirections[0]]
            totalLaser = if acceptedLaser then (acceptedLaser.numerator/acceptedLaser.denominator) else 0
            fraction = parseInt(square.data('fullNumerator'))/parseInt(square.data('fullDenominator'))
            fraction = 1 if isNaN(fraction)
            if totalLaser == 0
                state = 'empty'
            else if totalLaser < fraction
                state = 'under'
            else if totalLaser == fraction
                state = 'full'
            else if totalLaser > fraction
                state = 'over'
            
            square.find('img').attr('src', "#{@baseFolder}#{objectMeta.image}_#{state}.png")
        else
            square.find('img').attr('src', "#{@baseFolder}#{objectMeta.image}.png")
        
        square.find('img').bind "mousedown", (e) -> 
            e.preventDefault() if e.preventDefault
            return false
        
        
    showFraction: (squareOrLaser) ->
        if not squareOrLaser.height()
            $.timeout 50, => @showFraction(squareOrLaser)
            return
            
        squareOrLaser.find('.fraction').remove()
        fraction = $(document.createElement('DIV'))
        numerator = squareOrLaser.data('fullNumerator') or squareOrLaser.data('numerator') or 1
        denominator = squareOrLaser.data('fullDenominator') or squareOrLaser.data('denominator') or 1
        fraction.html("#{numerator}/#{denominator}")
        fraction.addClass('fraction')
        if squareOrLaser.hasClass('laser')
            beam = squareOrLaser.find('.beam')
            beam.append(fraction)
            fraction.css
                top: (beam.height() / 2) - (fraction.height() / 2)
                left: (beam.width() / 2) - (fraction.width() / 2)
        else
            squareOrLaser.append(fraction)
    
    initMovableObject: (square) ->
        objectType = square.data('objectType')
        objectMeta = @objects[objectType]
        moveObject = (e) =>
            e.preventDefault() if e.preventDefault?
            return if @movingObject
            @movingObject = true
            movingObject = square.find('img')
            @el.append(movingObject)
            movingObject.addClass('movable_object')
            movingObject.css
                left: e.clientX - (square.width() / 2)
                top: e.clientY - (square.height() / 2)

            @removeObjectFromSquare(square)
            
            body = $(document.body)
            
            move = (e) =>
                e.preventDefault() if e.preventDefault
                return unless movingObject
                left = e.clientX - (square.width() / 2)
                top = e.clientY - (square.height() / 2)
                movingObject.css
                    left: left
                    top: top
                for boardSquare in @el.find('.square:not(.occupied)')
                    offset = $(boardSquare).offset()
                    if e.clientX >= offset.left and
                       e.clientX < offset.left + offset.width and
                       e.clientY >= offset.top and
                       e.clientY < offset.top + offset.height
                        $(boardSquare).addClass('selected')
                    else
                        $(boardSquare).removeClass('selected')
                
            body.bind 'mousemove', (e) => move(e)
            body.bind 'touchmove', (e) => move(e)

            endMove = (e) =>
                e.preventDefault() if e.preventDefault
                image = movingObject
                movingObject = null
                @el.find('.movable_object').remove()
                body.unbind 'mousemove'        
                body.unbind 'mouseup'
                body.unbind 'touchmove'        
                body.unbind 'touchend'
                selectedSquare = @$('.square.selected')
                selectedSquare = square if not selectedSquare?.length
                image.removeClass('movable_object')
                @addObjectToSquare(objectType, selectedSquare, image)
                selectedSquare.removeClass('selected')
                for occupiedSquare in @$('.square.occupied')
                    occupiedSquare = $(occupiedSquare)
                    occupiedSquare.removeClass('occupied') unless occupiedSquare.find('img').length
                @movingObject = false
                
            body.bind 'mouseup', (e) => endMove(e)
            body.bind 'touchend', (e) => endMove(e)
                
        square.one 'mousedown', (e) => moveObject(e)
        square.one 'touchstart', (e) => moveObject(e)
        
    
    addObjectToSquare: (objectType, square, image) ->
        square = $(square)
        square.html('')
        @removeExistingLasers(square)
        square.addClass('occupied')
        square.addClass(objectType)
        square.data('objectType', objectType)
        object = @objects[objectType]
        image = $(document.createElement('IMG')) unless image
        square.append(image)
        
        @showFraction(square) if object.showFraction
            
        laserData = JSON.parse(square.data('lasers') or '{}')
        
        if object.accept
            square.data('acceptDirections', JSON.stringify(object.acceptDirections))
            square.data('numeratorMultiplier', object.numeratorMultiplier or 1)        
            square.data('denominatorMultiplier', object.denominatorMultiplier or 1)        
            for direction in object.acceptDirections
                if laserData[direction]
                    square.data('numerator', laserData[direction].numerator)
                    square.data('denominator', laserData[direction].denominator)
                        
        for direction of laserData
            @fireLaser(@board.find(".square.index#{laserData[direction].index}"))
                    
        if object.distribute
            square.data('distributeDirections', JSON.stringify(object.distributeDirections))
            @fireLaser(square)
            
        if object.movable
            @initMovableObject(square)
            
        @setObjectImage(square)
        
    removeObjectFromSquare: (square) ->
        square = $(square)
        return unless square.data('objectType')
        @removeExistingLasers(square)
        square.html('')
        square.removeClass('occupied')
        square.removeClass(square.data('objectType'))

        for attr of square.data() when attr not in ['index', 'nodeUid', 'lasers']
            square.data(attr, null)

        laserData = JSON.parse(square.data('lasers') or '{}')
        for direction of laserData
            @fireLaser(@$(".index#{laserData[direction].index}"))

             
    removeExistingLasers: (square) ->
        square = $(square)
        squareIndex = square.data('index')
        if (existingLasers = @board.find(".laser.laser#{squareIndex}")).length
            existingLasers.remove()
            for laserSquare in @board.find(".square.laser#{squareIndex}")
                laserSquare = $(laserSquare)
                laserSquare.removeClass("laser#{squareIndex}")
                laserData = JSON.parse(laserSquare.data('lasers'))
                delete laserData[laserSquare.data("laser#{squareIndex}")]
                laserSquare.data('lasers', JSON.stringify(laserData))
                laserSquare.data("laser#{squareIndex}", null)
                if laserSquare.hasClass('occupied')
                    @setObjectImage(laserSquare)                
                    @removeExistingLasers(laserSquare)

    checkLaserPath: (checkSquare, squareIndex, direction, numerator, denominator) ->
        occupied = checkSquare.hasClass('occupied')
        acceptDirections = JSON.parse(checkSquare.data('acceptDirections') or null)
        return false if occupied and not acceptDirections
        laserData = JSON.parse(checkSquare.data('lasers') or '{}')
        laserData[direction] = 
            index: squareIndex
            numerator: numerator
            denominator: denominator
        checkSquare.data('lasers', JSON.stringify(laserData))
        checkSquare.data("laser#{squareIndex}", direction)
        checkSquare.addClass("laser#{squareIndex}")
        if direction in (acceptDirections or [])
            checkSquare.data('numerator', numerator)
            checkSquare.data('denominator', denominator)
            @setObjectImage(checkSquare)
            @checkSuccess()
            @fireLaser(checkSquare)
        return false if occupied
        return true
        
    checkSuccess: ->
        for square in @$('.square.occupied') when square.className.indexOf('ship') > -1
            return if $(square).html().indexOf('full') == -1
            
        successMessage = @$('.success')
        successMessage.css
            top: @el.offset().top + (@el.height() / 2) - (successMessage.height() / 2)
            left: @el.offset().left + (@el.width() / 2) - (successMessage.width() / 2)
        successMessage.animate
            opacity: 1
            duration: 500
    
    loadToPlay: (data) ->
        @solution = JSON.parse(data)
        movableObjects = []
        for object in @solution.objects
            objectMeta = @objects[object.type]
            if objectMeta.movable
                movableObjects.push(object.type)
            else
                square = @board.find(".square.index#{object.index}")
                @addObjectToSquare(object.type, square)
                for attr of object when attr not in ['type', 'index']
                    square.data(attr, object[attr])

                @showFraction(square)
                @setObjectImage(square)
                @fireLaser(square)

        for type in shuffle(movableObjects)
            square = @options.find(".square:not(.occupied)")[0]
            @addObjectToSquare(type, square)  
            
        if not @solution.verified
            alert('This level has not been verified as solvable.\n\nIt\'s possible that a solution may not exist')
            
            
    fireLaser: (square) ->
        square = $(square)
        
        @removeExistingLasers(square)

        return unless (distributeDirections = JSON.parse(square.data('distributeDirections') or null))
        if (acceptDirections = JSON.parse(square.data('acceptDirections') or null))
            return unless (laserData = JSON.parse(square.data('lasers') or null))
            for acceptDirection in acceptDirections
                return unless laserData[acceptDirection]
            
        numerator = (square.data('numerator') or 1) * (square.data('numeratorMultiplier') or 1)
        denominator = (square.data('denominator') or 1) * (square.data('denominatorMultiplier') or 1)
        squareIndex = square.data('index')
        
        for distributeDirection in distributeDirections
            laser = $(document.createElement('DIV'))
            laser.html('<div class=\'beam\'></div>')
            laser.addClass('laser')
            laser.addClass("laser#{squareIndex}")
            laser.addClass(distributeDirection)
            laser.data('numerator', numerator)
            laser.data('denominator', denominator)

            increment = switch distributeDirection
                when 'up' then -1 * @columns
                when 'down' then @columns
                when 'left' then -1
                when 'right' then 1

            start = square.data('index') + increment
            
            end = switch distributeDirection
                when 'up' then 0
                when 'down' then @board.find('.square').length
                when 'left' then (Math.floor(start/@columns) * @columns) - 1
                when 'right' then Math.ceil(start/@columns) * @columns 

            offset = square.offset()
            beam = laser.find('.beam')
            
            if distributeDirection == 'left' or distributeDirection == 'right'
                height = LASER_HEIGHT * (numerator / denominator)
                width = 0
                for index in [start...end] by increment
                    checkSquare = @board.find(".square.index#{index}")
                    break unless @checkLaserPath(checkSquare, squareIndex, distributeDirection, numerator, denominator)
                    width += checkSquare.width()
            else
                width = LASER_HEIGHT * (numerator / denominator)
                height = 0
                for index in [start...end] by increment
                    checkSquare = @board.find(".square.index#{index}")
                    break unless @checkLaserPath(checkSquare, squareIndex, distributeDirection, numerator, denominator)
                    height += checkSquare.height()
            
            beam.addClass(distributeDirection)
            beam.css
                height: height
                width: width
                        
            if distributeDirection == 'right'
                laser.css
                    top: offset.top + ((offset.height - height) / 2) - LASER_HEIGHT
                    left: offset.left + offset.width
            else if distributeDirection == 'left'
                laser.css
                    top: offset.top + ((offset.height - height) / 2) - LASER_HEIGHT
                    left: offset.left - width
            else if distributeDirection == 'up'
                laser.css
                    top: offset.top - height
                    left: offset.left + ((offset.width - width) / 2) - LASER_HEIGHT
            else if distributeDirection == 'down'
                laser.css
                    top: offset.top + offset.height
                    left: offset.left + ((offset.width - width) / 2) - LASER_HEIGHT
            
            @showFraction(laser)
            
            @board.append(laser)

