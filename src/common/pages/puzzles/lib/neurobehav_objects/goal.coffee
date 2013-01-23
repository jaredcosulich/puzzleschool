goal = exports ? provide('./goal', {})

class goal.Goal 
    periodicity: 20
    offset: 90
    
    constructor: ({@paper, @radius, @interaction, @test, @html, @onSuccess}) -> 
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
        @initWorm()
        @initMessage()
        
        
    draw: ->
        @image = @paper.set()
        @center = 
            x: (@paper.width - @offset)/2
            y: @paper.height/2
        @circle = @paper.circle(@center.x, @center.y, @radius)
        @circle.attr(fill: 'white')
        @image.push(@circle)
        @littleCircle = @paper.circle(@center.x + @radius + @offset, @center.y, 3)
        @littleCircle.attr(fill: 'white')
        @image.push(@littleCircle)
        @lineFrom(60)
        @lineFrom(120)
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
        
    initWorm: ->
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
            c12,6 18,4 #{wormWidth/3},-1
            c6,-2 12,-1 #{wormWidth/6},1
            c6,4 18,6 #{wormWidth/3},1
            c4,-2 6,-3 #{wormWidth/6},-2
        """
        @worm = @paper.path(@wormPath)
        @worm.attr('stroke-width': 8, 'stroke-linecap': 'round', stroke: '#411B17')
        @worm.toBack()
        
    initMessage: ->
        width = 60
        height = 18
        x = @center.x + @radius + @offset - (width/2)
        y = @center.y - (height*2)

        @icon = @paper.set()

        background = @paper.rect(x, y, width, height, 6)
        background.attr(fill: 'black')

        glow = background.glow(width: 10, fill: true, color: 'red')
        glow.attr(opacity: 0)

        @icon.push(glow)
        @icon.push(background)
        
        text = @paper.text(x+(width/2), y+(height/2), 'The Goal')
        text.attr(fill: 'white', stroke: 'none')
        @icon.push(text)
        
        @icon.attr(cursor: 'pointer')
        @icon.hover(
            () => glow.attr(opacity: 0.04),
            () => glow.attr(opacity: 0)
        )
        
        bbox = @icon.getBBox()
        @goalBubble = new Bubble
            paper: @paper, 
            x: bbox.x 
            y: bbox.y + (bbox.height/2)
            width: 400
            height: 400
            arrowOffset: 180
            position: 'left'
            html: @html
        
        @icon.click => 
            if @goalBubble.visible
                @goalBubble.hide()
            else
                @goalBubble.show()
            
    display: -> @goalBubble.show()
        
    interact: (interaction) ->        
        return if @animating or @interactionState == interaction
        @animating = true
        @interactionState = interaction
        path = if interaction then @animatedPath else @wormPath
        @worm.animate(
            {path: path}, 
            300
            'ease-out'
            => @animating = false
        )
        
    success: ->
        return if @successAchieved
        if @animating
            setTimeout((=> @success()), 100)
            return
        @successAchieved = true
        @onSuccess(@goalBubble) if @onSuccess
        # $(document.body).unbind('mousedown.hide_bubble')
        