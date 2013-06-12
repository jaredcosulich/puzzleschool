shuffle = (array) ->
    top = array.length
    return array if not top

    while(top--) 
        current = Math.floor(Math.random() * (top + 1))
        tmp = array[current]
        array[current] = array[top]
        array[top] = tmp
    return array

countrysideFractions = exports ? provide('./lib/countryside_fractions', {})

LASER_HEIGHT = 20

OBJECTS = 
    rock1: 
        image: 'rock1'
        index: 99999999

    rock2: 
        image: 'rock2'
        index: 999999999

# directional objects
directions = ['up', 'down', 'left',  'right']
for direction, index in directions
    perpendicularDirections = (if index < 2 then directions[2..3] else directions[0..1])
    
    #ships
    OBJECTS["ship_#{direction}"] =
        index: index
        image: "ship_#{direction}"
        tip: 'sensor'
        accept: true
        acceptDirections: [direction]
        states: true
        showFraction: true

    #lasers
    OBJECTS["laser_#{direction}"] =
        index: 10 + index
        image: "laser_#{direction}"
        tip: 'laser'
        distribute: true
        distributeDirections: [direction]
        accept: false
        showFraction: true
        
    # splitters
    OBJECTS["split_#{direction}_#{perpendicularDirections[0]}_#{perpendicularDirections[1]}"] =
        index: 1500 + index
        image: "split_#{direction}_#{perpendicularDirections[0]}_#{perpendicularDirections[1]}"
        tip: 'splitter'
        distribute: true
        distributeDirections: perpendicularDirections
        accept: true
        acceptDirections: [direction]
        denominatorMultiplier: 2
        movable: true
        
    #three-way splitters
    OBJECTS["three_way_split_#{direction}"] =
        index: 2000 + index
        image: "three_way_split_#{direction}"
        tip: 'splitter'
        distribute: true
        distributeDirections: [direction, perpendicularDirections...]
        accept: true
        acceptDirections: [direction]
        denominatorMultiplier: 3
        movable: true

    #two-way adders
    OBJECTS["add_#{perpendicularDirections[0]}_#{perpendicularDirections[1]}_#{direction}"] =
        index: 3000 + index
        image: "add_#{perpendicularDirections[0]}_#{perpendicularDirections[1]}_#{direction}"
        tip: 'adder'
        distribute: true
        distributeDirections: [direction]
        accept: true
        acceptDirections: perpendicularDirections
        additive: true
        movable: true

    #three-way adders
    OBJECTS["three_add_#{direction}"] =
        index: 4000 + index
        image: "three_add_#{direction}"
        tip: 'adder'
        distribute: true
        distributeDirections: [direction]
        accept: true
        acceptDirections: [direction, perpendicularDirections...]
        additive: true
        movable: true
        
    #multipliers
    OBJECTS["multiplier_two_#{direction}"] =
        index: 5000 + index
        image: "multiplier_two_#{direction}"
        tip: 'denominator'
        distribute: true
        distributeDirections: [direction]
        accept: true
        acceptDirections: [direction]
        denominatorMultiplier: 2
        numeratorMultiplier: 2
        movable: true

    OBJECTS["three_multiplier_#{direction}"] =
        index: 5500 + index
        image: "three_multiplier_#{direction}"
        tip: 'denominator'
        distribute: true
        distributeDirections: [direction]
        accept: true
        acceptDirections: [direction]
        denominatorMultiplier: 3
        numeratorMultiplier: 3
        movable: true
        
    for direction2, index2 in directions
        continue if (index < 2 and index2 < 2) or (index > 1 and index2 > 1)
        #turners
        OBJECTS["turn_#{direction}_#{direction2}"] =
            index: 100 + (index * directions.length) + index2
            image: "turn_#{direction}_#{direction2}"
            tip: 'turner'
            distribute: true
            distributeDirections: [direction2]
            accept: true
            acceptDirections: [direction]
            movable: true
            
        #splitters
        OBJECTS["two_split_#{direction}_#{direction2}"] =
            index: 1000 + (index * directions.length) + index2
            image: "two_split_#{direction}_#{direction2}"
            tip: 'splitter'
            distribute: true
            distributeDirections: [direction, direction2]
            accept: true
            acceptDirections: [direction]
            denominatorMultiplier: 2
            movable: true
        
        
class countrysideFractions.ChunkHelper
    objects: OBJECTS
    constructor: () ->
    

class countrysideFractions.ViewHelper
    baseFolder: '/assets/images/puzzles/countryside_fractions/'
    objects: OBJECTS

    constructor: ({@el, @rows, @columns, @registerEvent}) ->
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
        
        for row in [0...6]
            for column in [0...4]
                index = (row * 4) + column
                square = $(document.createElement('DIV'))
                square.addClass('square')
                square.data('index', index)
                square.addClass("index#{index}")
                @options.append(square)
        
    initHint: -> @$('.hint').bind 'click.hint', => @showHint()
    
    findGoodHintOption: (square) ->
        o = square
        for obj in @solution.objects when obj.type == square.data('objectType')
            s = @board.find(".square.index#{obj.index}")
            continue if not s.length
            continue if s.data('objectType') == obj.type
            [o, s] = @findGoodHintOption(s) if s.data('objectType')
            return [o, s]
        return [o, $(@options.find('.square:not(.occupied)')[0])]
    
    findHint: ->
        for object in @solution.objects
            square = @board.find(".square.index#{object.index}")
            continue if not square.length
            continue if square.data('objectType') == object.type
            if square.data('objectType')
                [option, square] = @findGoodHintOption(square)
            else
                option = $(@options.find(".square.#{object.type}")[0])

            if not option?.length
                boardOptions = @board.find(".square.#{object.type}")
                for boardOption in boardOptions
                    if (o.type for o in @solution.objects when o.index == $(boardOption).data('index'))[0] != object.type
                        option = $(boardOption)
                        break
            
            return [option, square]
            
        
    
    showHint: (option, square) ->        
        [option, square] = @findHint() if not option or not square

        if option?.length
            option.addClass('highlighted')
            dragMessage = @$('.hint_drag_message')
            dragMessage.css
                left: option.offset().left + (option.width() / 2) - (dragMessage.width() / 2)
                top: option.offset().top + option.height()
            dragMessage.animate
                opacity: 1
                duration: 250
                
            objectType = option.data('objectType')
            option.bind 'mousedown.hint touchstart.hint', =>
                body = $(document.body)
                body.bind 'mouseup.hint touchend.hint', => body.unbind('mousemove.hint touchmove.hint')
                body.bind 'mousemove.hint touchmove.hint', => @moveHint(option, square, objectType)   
            
            @registerEvent
                type: 'hint'
                info: 
                    fromSquare: option.data('index')
                    fromArea: (if option.parent().hasClass('board') then 'board' else 'options')
                    toSquare: square.data('index')
                    toArea: (if square.parent().hasClass('board') then 'board' else 'options')
                    objectType: objectType
                    time: new Date()
                      
                
    moveHint: (option, square, objectType) ->
        option.unbind('mousedown.hint touchstart.hint')

        body = $(document.body)
        body.unbind('mouseup.hint touchend.hint')
        body.unbind('mousemove.hint touchmove.hint')
        
        dragMessage = @$('.hint_drag_message')
        dragMessage.css(opacity: 0)
        @$('.square.highlighted').removeClass('highlighted') 
        square.addClass('highlighted')
        dropMessage = @$('.hint_drop_message')
        dropMessage.css
            left: square.offset().left + (square.width() / 2) - (dropMessage.width() / 2)
            top: square.offset().top + square.height()
        dropMessage.animate
            opacity: 1
            duration: 250
        
        @hideHint(square, objectType)

        $(document.body).one 'mouseup.hint touchend.hint', => @hideHint(square, objectType, true)                        
        
        
    hideHint: (square, type, force) ->
        return if not @$('.square.highlighted').length and not force
        unless square.hasClass(type) or force
            $.timeout 500, => @hideHint(square, type)
            return

        $(document.body).unbind('mouseup.hint touchend.hint')                     
        @$('.hint_message').animate
            opacity: 0
            duration: 250
        @$('.square.highlighted').removeClass('highlighted')                                
        

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
            
            if (square.find('img').attr('src') or '').indexOf("#{objectMeta.image}_#{state}") == -1
                square.find('img').attr('src', "#{@baseFolder}#{objectMeta.image}_#{state}.png")
        else
            if (square.find('img').attr('src') or '').indexOf(objectMeta.image) == -1
                square.find('img').attr('src', "#{@baseFolder}#{objectMeta.image}.png")
        
        square.find('img').bind "mousedown", (e) -> e.preventDefault() if e.preventDefault
        
        
    showFraction: (squareOrLaser) ->
        return unless squareOrLaser.parent().length
        if not squareOrLaser.height()
            $.timeout 50, => @showFraction(squareOrLaser)
            return
            
        squareOrLaser.find('.fraction').off().remove()
        fraction = $(document.createElement('DIV'))
        numerator = squareOrLaser.data('fullNumerator') or squareOrLaser.data('numerator') or 1
        denominator = squareOrLaser.data('fullDenominator') or squareOrLaser.data('denominator') or 1
        fraction.html("#{numerator}/#{denominator}")
        fraction.addClass('fraction')
        if squareOrLaser.hasClass('laser')
            beam = squareOrLaser.find('.beam')
            beam.append(fraction)
            
            css = {}
            if beam.width() > beam.height()
                css.top = (beam.height() / 2) - (fraction.height() / 2)
                pos = fraction.width() + 3
                if beam.width() > @board.find('.square').width()
                    pos += (beam.width() / 2) - (fraction.width() / 2)

                css[if beam.hasClass('left') then 'right' else 'left'] = pos
            else
                css.left = (beam.width() / 2) - (fraction.width() / 2)
                pos = fraction.height() + 3
                if beam.height() > @board.find('.square').height()
                    pos += (beam.height() / 2) - (fraction.height() / 2)

                css[if beam.hasClass('up') then 'bottom' else 'top'] = pos
            
            fraction.css(css)
        else
            squareOrLaser.append(fraction)
    
    clientX: (e) => e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX
    clientY: (e) => e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY
    
    initMovableObject: (square, callback) ->
        square = $(square)
        objectType = square.data('objectType')
        objectMeta = @objects[objectType]
        moveObject = (e) =>
            e.preventDefault() if e.preventDefault
            return if @movingObject
            @movingObject = true
            
            @$('.square.selected').removeClass('selected')
            
            body = $(document.body)
            data = JSON.parse(JSON.stringify(square.data()))
            
            movingObject = undefined
            move = (e) =>
                e.preventDefault() if e.preventDefault
                
                square.unbind 'mouseup.tip touchend.tip'
                
                if movingObject == undefined
                    movingObject = $(square.find('img')[0])
                    @el.append(movingObject)
                    movingObject.addClass('movable_object')
                    @removeObjectFromSquare(square)

                return unless movingObject

                left = @clientX(e) - (square.width() / 2)
                top = @clientY(e) - (square.height() / 2)
                movingObject.css
                    left: left
                    top: top
                for boardSquare in @el.find('.square:not(.occupied)')
                    offset = $(boardSquare).offset()
                    if @clientX(e) >= offset.left and
                       @clientX(e) < offset.left + offset.width and
                       @clientY(e) >= offset.top and
                       @clientY(e) < offset.top + offset.height
                        $(boardSquare).addClass('selected')
                    else
                        $(boardSquare).removeClass('selected')
                
            body.bind 'mousemove.move touchmove.move', (e) => move(e)

            endMove = (e) =>
                e.preventDefault() if e.preventDefault
                body.unbind 'mousemove.move touchmove.move' 
                selectedSquare = @$('.square.selected')
                selectedSquare = square if not selectedSquare?.length
                @el.find('.movable_object').off().remove()

                if movingObject
                    image = movingObject
                    movingObject = null
                    image.removeClass('movable_object')
                    @addObjectToSquare(objectType, selectedSquare, image)
                    selectedSquare.removeClass('selected')

                    @registerEvent
                        type: 'move'
                        info: 
                            start: square.data('index')
                            end: selectedSquare.data('index')
                            objectType: objectType
                            time: new Date()
                            
                else
                    @initMovableObject(square, callback)

                @movingObject = false
                callback(selectedSquare, data, image) if callback
                
            body.one 'mouseup.move touchend.move', (e) => endMove(e)
                
        square.unbind 'mousedown.move touchstart.move'
        square.one 'mousedown.move touchstart.move', (e) => moveObject(e)
        
    
    addObjectToSquare: (objectType, square, image) ->
        square = $(square)
        square.html('')

        image = $(document.createElement('IMG')) unless image
        square.append(image)
        
        @removeExistingLasers(square)
        square.addClass('occupied')
        square.addClass(objectType)
        square.data('objectType', objectType)
        objectMeta = @objects[objectType]
        
        @showFraction(square) if objectMeta.showFraction
            
        laserData = JSON.parse(square.data('lasers') or '{}')
        
        if objectMeta.accept
            square.data('acceptDirections', JSON.stringify(objectMeta.acceptDirections))
            square.data('numeratorMultiplier', objectMeta.numeratorMultiplier or 1)        
            square.data('denominatorMultiplier', objectMeta.denominatorMultiplier or 1) 
            square.data('additive', true) if objectMeta.additive       
            for direction in objectMeta.acceptDirections
                if laserData[direction]
                    square.data('numerator', laserData[direction].numerator)
                    square.data('denominator', laserData[direction].denominator)
                        
        for direction of laserData
            @fireLaser(@board.find(".square.index#{laserData[direction].index}"))
                    
        if objectMeta.distribute
            square.data('distributeDirections', JSON.stringify(objectMeta.distributeDirections))
            @fireLaser(square)
            
        @initMovableObject(square) if objectMeta.movable
                    
        square.bind 'mouseup.tip touchend.tip', => @showTip(square)
            
        @setObjectImage(square)
        
    showTip: (square) ->
        square = $(square)
        return unless square.hasClass('occupied')
        square.unbind 'mouseup.tip touchend.tip'
        objectMeta = @objects[square.data('objectType')]
        if (tip = @$(".tip.#{objectMeta.tip}")).length
            offset = square.offset()
            tip.css
                opacity: 0
                top: offset.top + offset.height + 6
                left: offset.left + (offset.width / 2) - (tip.offset().width / 2)

            tip.animate
                opacity: 1
                duration: 250
        
        $.timeout 10, =>
            $(document.body).one 'mouseup.tip touchend.tip', =>
                tip.animate
                    opacity: 0
                    duration: 250
                    complete: =>
                        square.bind 'mouseup.tip touchend.tip', => @showTip(square)
                        tip.css
                            top: -1000
                            left: -1000
                        
                    
        
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
        return if square.parent()[0].className != @board[0].className
        squareIndex = square.data('index')
        if (existingLasers = @board.find(".laser.laser#{squareIndex}")).length
            existingLasers.off().remove()
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
                    for direction of laserData
                        @fireLaser(@$(".index#{laserData[direction].index}"))
                        

    checkSuccess: ->
        for square in @board.find('.square.occupied') when square.className.indexOf('ship') > -1
            return if $(square).html().indexOf('full') == -1

        successMessage = @$('.success')
            
        $.timeout 500, () =>
            successMessage.css
                top: @el.offset().top + (@el.height() / 2) - (successMessage.height() / 2)
                left: @el.offset().left + (@el.width() / 2) - (successMessage.width() / 2)
            successMessage.animate
                opacity: 1
                duration: 500
            
            @board.one 'click.level_selector', =>
                @$('.level_selector_link').css
                    top: @board.offset().top
                    left: @board.offset().left
                @$('.level_selector_link').animate
                    opacity: 1
                    duration: 500
                    
                successMessage.animate
                    opacity: 0
                    duration: 500
        
            @registerEvent
                type: 'success'
                info: 
                    time: new Date()
    
    
    loadToPlay: (data) ->
        @loading = true
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

                @showFraction(square) if objectMeta.showFraction
                @setObjectImage(square)
                @fireLaser(square)

        for type in shuffle(movableObjects)
            square = @options.find(".square:not(.occupied)")[0]
            @addObjectToSquare(type, square)  
            
        if not @solution.verified
            $.timeout 200, ->
                alert('This level has not been verified as solvable.\n\nIt\'s possible that a solution may not exist')
            
        @loading = false
        @checkSuccess()
        
    fireLaser: (square) ->
        square = $(square)

        return unless square.parent()[0].className == @board[0].className
        
        @removeExistingLasers(square)

        return unless (distributeDirections = JSON.parse(square.data('distributeDirections') or null))
        if (acceptDirections = JSON.parse(square.data('acceptDirections') or null))
            return unless (laserData = JSON.parse(square.data('lasers') or null))
            for acceptDirection in acceptDirections
                return unless laserData[acceptDirection]
                    
        if square.data('additive')
            for acceptDirection in acceptDirections
                numerator = (numerator or 0) + laserData[acceptDirection].numerator
                return if (denominator and laserData[acceptDirection].denominator != denominator)
                denominator = laserData[acceptDirection].denominator
        else
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
                when 'up' then -1
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
                        
            @board.append(laser)
            @showFraction(laser)

            
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
            @checkSuccess() unless @loading
            @fireLaser(checkSquare)
        return false if occupied
        return true



