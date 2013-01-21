goal = exports ? provide('./goal', {})

class goal.Goal 
    periodicity: 20
    offset: 90
    
    constructor: ({@paper, @radius, @interaction, @test}) -> 
        @init()
        
    init: ->
        @draw()
        setInterval((
            => 
                @interact(@interaction())
                @success() if @test()
            ),
            @periodicity
        )
        
        
    draw: ->
        @image = @paper.set()
        @center = 
            x: (@paper.width - @offset)/2
            y: @paper.height/2
        @circle = @paper.circle(@center.x, @center.y, @radius)
        @circle.attr(fill: 'white')
        @image.push(@circle)
        @lineFrom(60)
        @lineFrom(120)
        @worm()
        @image.toBack()
        
    lineFrom: (angle) ->
        yUnit = 1/(Math.tan(angle * Math.PI/180))
        distance = Math.sqrt(Math.pow(yUnit,2) + 1)
        units = @radius/distance
        startX = @center.x + units
        startY = @center.y + (units * yUnit)
        line = @paper.path """
            M#{startX},#{startY}
            L#{@center.x + @radius + @offset},#{@center.y}
        """
        @image.push(line)
        
    worm: ->
        wormWidth = 90
        startX = @center.x + @radius + @offset - (wormWidth/2)
        @wormPath = """
            M#{startX},#{@center.y}
            c12,-8 18,-12 #{wormWidth/3},3
            c6,6 12,12 #{wormWidth/6},0
            c6,-16 18,-16 #{wormWidth/3},-3
            c4,2 6,3 #{wormWidth/6},3
        """
        
        @animatedPath = """
            M#{startX},#{@center.y}
            c12,8 18,12 #{wormWidth/3},-3
            c6,-6 12,-12 #{wormWidth/6},0
            c6,16 18,16 #{wormWidth/3},3
            c4,-2 6,-3 #{wormWidth/6},-3
        """
        @worm = @paper.path(@wormPath)
        @worm.attr('stroke-width': 6, 'stroke-linecap': 'round')
        
        
    interact: (interaction) ->        
        return if @animating or @interactionState == interaction
        @animating = true
        @interactionState = interaction
        path = if interaction then @animatedPath else @wormPath
        @worm.animate(
            {path: path}, 
            1000
            'linear'
            => @animating = false
        )
        
    success: ->
        console.log('SUCCESS!')
        