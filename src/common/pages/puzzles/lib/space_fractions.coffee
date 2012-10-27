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
            do (square, index) -> $(square).data('index', index)
        
    $: (selector) -> $(selector, @el)
    
    addObjectToBoard: (objectType, square) ->
        square.html('')
        square.addClass('occupied')
        object = @objects[objectType]
        objectContainer = $(document.createElement('IMG'))
        objectContainer.attr('src', object.image)
        square.append(objectContainer)
        
        if object.distribute
            square.data('direction', object.distributeDirection)
            @fireLaser(square, object.distributeDirection)
         
    fireLaser: (square) ->
        square = $(square)
        
        if (existingLaser = @board.find(".laser.index#{square.data('index')}")).length
            console.log(square.data('index'), existingLaser[0].className)
            existingLaser.remove()
        
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
        if direction == 'right'
            laser.css
                height: height
                width: 300
                top: offset.top + ((offset.height - height) / 2)
                left: offset.left + offset.width
        
        @board.append(laser)
        