goal = exports ? provide('./goal', {})

class goal.Goal 
    offset: 90
    
    constructor: ({@paper, @radius}) -> 
        @init()
        
    init: ->
        @draw()
        
    draw: ->
        @image = @paper.set()
        @centerX = (@paper.width - @offset)/2
        @centerY = @paper.height/2
        @circle = @paper.circle(@centerX, @centerY, @radius)
        @circle.attr(fill: 'white')
        @image.push(@circle)
        @lineFrom(60)
        @lineFrom(120)
        @image.toBack()
        
    lineFrom: (angle) ->
        yUnit = 1/(Math.tan(angle * Math.PI/180))
        distance = Math.sqrt(Math.pow(yUnit,2) + 1)
        units = @radius/distance
        startX = @centerX + units
        startY = @centerY + (units * yUnit)
        line = @paper.path """
            M#{startX},#{startY}
            L#{@centerX + @radius + @offset},#{@centerY}
        """
        @image.push(line)
        