spaceFractions = exports ? provide('./lib/space_fractions', {})

LASER_HEIGHT = 24

OBJECTS = 
    rock1: 
        image: 'rock1'
        index: 999999

    rock2: 
        image: 'rock2'
        index: 1000000

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

    #lasers
    OBJECTS["laser_#{direction}"] =
        index: 10 + index
        image: "laser_#{direction}"
        distribute: true
        distributeDirections: [direction]
        accept: false
        
        
    for direction2, index2 in directions
        continue if (index < 2 and index2 < 2) or (index > 1 and index2 > 1)
        #turners
        OBJECTS["turn_#{direction}_#{direction2}"] =
            index: 100 + index2
            image: "turn_#{direction}_#{direction2}"
            distribute: true
            distributeDirections: [direction2]
            accept: true
            acceptDirections: [direction]
        
class spaceFractions.ChunkHelper
    constructor: () ->
    

class spaceFractions.ViewHelper
    objects: OBJECTS
    baseFolder: '/assets/images/puzzles/space_fractions/'

    constructor: ({@el, @rows, @columns}) ->
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
                
    $: (selector) -> $(selector, @el)
    
    setObjectImage: (square) ->
        object = @objects[square.data('object_type')]
        return unless object
        if object.states
            laserData = JSON.parse(square.data('lasers') or '{}')
            acceptedLaser = laserData[object.acceptDirections[0]]
            totalLaser = if acceptedLaser then (acceptedLaser.numerator/acceptedLaser.denominator) else 0
            fraction = parseInt(square.data('fullNumerator'))/parseInt(square.data('fullDenominator'))
            if totalLaser == 0
                state = 'empty'
            else if totalLaser < fraction
                state = 'under'
            else if totalLaser == fraction
                state = 'full'
            else if totalLaser > fraction
                state = 'over'
            
            square.find('img').attr('src', @baseFolder + object.image + '_' + state + '.png')
        else
            square.find('img').attr('src', @baseFolder + object.image + '.png')
        
    
    addObjectToBoard: (objectType, square) ->
        square = $(square)
        square.html('')
        @removeExistingLasers(square)
        square.addClass('occupied')
        square.data('object_type', objectType)
        object = @objects[objectType]
        objectContainer = $(document.createElement('IMG'))
        square.append(objectContainer)
        
        laserData = JSON.parse(square.data('lasers') or '{}')
        
        if object.accept
            square.data('acceptDirections', JSON.stringify(object.acceptDirections))        
            for direction in object.acceptDirections
                if laserData[direction]
                    square.data('numerator', laserData[direction].numerator)
                    square.data('denominator', laserData[direction].denominator)
                        
        for direction of laserData
            @fireLaser(@board.find(".square.index#{laserData[direction].index}"))
                    
        if object.distribute
            square.data('distributeDirections', JSON.stringify(object.distributeDirections))
            @fireLaser(square)
            
        @setObjectImage(square)
        
        
    removeObjectFromBoard: (square) ->
        @removeExistingLasers(square)
        square.html('')
        square.removeClass('occupied')
        square.data('object_type', null)
        square.data('acceptDirections', null)
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
                laserSquare.data('lasers', null)
                laserSquare.data("laser#{squareIndex}", null)
                if laserSquare.hasClass('occupied')
                    @setObjectImage(laserSquare)                
                    @removeExistingLasers(laserSquare)
         
    fireLaser: (square) ->
        square = $(square)
        
        @removeExistingLasers(square)

        return unless (distributeDirections = JSON.parse(square.data('distributeDirections') or null))
        if (acceptDirections = JSON.parse(square.data('acceptDirections') or null))
            return unless (laserData = JSON.parse(square.data('lasers') or null))
            for direction in acceptDirections
                return unless laserData[direction]
            
        numerator = square.data('numerator') or 1
        denominator = square.data('denominator') or 1
        squareIndex = square.data('index')

        checkPath = (checkSquare, squareIndex, direction) =>
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
                @fireLaser(checkSquare)
            return false if occupied
            return true
        
        for direction in distributeDirections
            laser = $(document.createElement('DIV'))
            laser.addClass('laser')
            laser.addClass("laser#{squareIndex}")
            laser.data('numerator', numerator)
            laser.data('denominator', denominator)

            increment = switch direction
                when 'up' then -1 * @columns
                when 'down' then @columns
                when 'left' then -1
                when 'right' then 1

            start = square.data('index') + increment
            
            end = switch direction
                when 'up' then 0
                when 'down' then @board.find('.square').length
                when 'left' then (Math.floor(start/@columns) * @columns) - 1
                when 'right' then Math.ceil(start/@columns) * @columns 

            offset = square.offset()
        
            if direction == 'left' or direction == 'right'
                height = LASER_HEIGHT * (numerator / denominator)
                width = 0
                for index in [start...end] by increment
                    checkSquare = @board.find(".square.index#{index}")
                    break unless checkPath(checkSquare, squareIndex, direction)
                    width += checkSquare.width()
            else
                width = LASER_HEIGHT * (numerator / denominator)
                height = 0
                for index in [start...end] by increment
                    checkSquare = @board.find(".square.index#{index}")
                    break unless checkPath(checkSquare, squareIndex, direction)
                    height += checkSquare.height()
            
            laser.css
                height: height
                width: width

            if direction == 'right'
                laser.css
                    top: offset.top + ((offset.height - height) / 2)
                    left: offset.left + offset.width
            else if direction == 'left'
                laser.css
                    top: offset.top + ((offset.height - height) / 2)
                    left: offset.left - width
            else if direction == 'up'
                laser.css
                    top: offset.top - height
                    left: offset.left + ((offset.width - width) / 2)
            else if direction == 'down'
                laser.css
                    top: offset.top + offset.height
                    left: offset.left + ((offset.width - width) / 2)
        
            @board.append(laser)
        