spaceFractions = exports ? provide('./lib/space_fractions', {})

OBJECTS = 
    laserLeft:
        image: 'laser_left'
        distribute: true
        distributeDirection: 'left'
        accept: false

    laserRight:
        image: 'laser_right'
        distribute: true
        distributeDirection: 'right'
        accept: false

    laserUp:
        image: 'laser_up'
        distribute: true
        distributeDirection: 'up'
        accept: false

    laserDown:
        image: 'laser_down'
        distribute: true
        distributeDirection: 'down'
        accept: false

    rock1: 
        image: 'rock1'
        distribute: false
        accept: false

    rock2: 
        image: 'rock2'
        distribute: false
        accept: false

class spaceFractions.ChunkHelper
    constructor: (@languages, @levelName, @puzzleData) ->
        @languageData = languageScramble.data[@languages]
        @level = languageScramble.getLevel(@languageData, @levelName)
    

class spaceFractions.ViewHelper
    objects: OBJECTS

    constructor: ({@el}) ->
        for objectType of @objects
            object = @objects[objectType]
            object.image = "/assets/images/puzzles/space_fractions/#{object.image}.png" 
        
        @board = @$('.board')
        
        for square, index in @board.find('.square')
            do (square, index) -> 
                $(square).data('index', index)
                $(square).addClass("index#{index}")
        
    $: (selector) -> $(selector, @el)
    
    addObjectToBoard: (objectType, square) ->
        square = $(square)
        square.html('')
        @removeExistingLaser(square)
        square.addClass('occupied')
        square.data('object_type', objectType)
        object = @objects[objectType]
        objectContainer = $(document.createElement('IMG'))
        objectContainer.attr('src', object.image)
        square.append(objectContainer)
        
        if object.distribute
            square.data('direction', object.distributeDirection)
            @fireLaser(square, object.distributeDirection)
         
    removeExistingLaser: (square) ->
        square = $(square)
        if (existingLaser = @board.find(".laser.index#{square.data('index')}")).length
            existingLaser.remove()
         
    fireLaser: (square) ->
        square = $(square)
        
        @removeExistingLaser(square)
        
        object = square.find('img')
        if not object.height()
            $.timeout 10, => @fireLaser(square, direction)
            return
            
        direction = square.data('direction')
        numerator = square.data('numerator') or 1
        denominator = square.data('denominator') or 1
        laser = $(document.createElement('DIV'))
        laser.addClass("index#{square.data('index')}")
        laser.addClass('laser')
        laser.data('numerator', numerator)
        laser.data('denominator', denominator)
        
        offset = square.offset()
        height = object.height() * (numerator / denominator)
        
        start = square.data('index') + 1
        increment = switch direction
            when 'up' then -1 * start
            when 'down' then start 
            when 'left' then -1
            when 'right' then 1
            
        end = switch direction
            when 'up' then 0
            when 'down' then @board.data('rows') * @board.data('columns')
            when 'left' then Math.floor(start/10) * 10 
            when 'right' then Math.ceil(start/10) * 10 

        width = 0
        for index in [start...end] by increment
            checkSquare = @board.find(".square.index#{index}")
            break if checkSquare.hasClass('occupied')
            width += checkSquare.width()
        
        if direction == 'right'
            laser.css
                height: height
                width: width
                top: offset.top + ((offset.height - height) / 2)
                left: offset.left + offset.width
        
        @board.append(laser)
        