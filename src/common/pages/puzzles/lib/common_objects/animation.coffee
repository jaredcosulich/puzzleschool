animation = exports ? provide('../common_objects/animation', {})

class animation.Animation
    constructor: (@calculation=false) ->
        @animations = []
        @animationIndex = 0
        @id = new Date().getTime()
        
    frame: ->
        if @calculation
            (callback) ->
                window.setTimeout((->
                    callback(+new Date())
                ), 11)
        else
            return window.requestAnimationFrame  ||
                   window.webkitRequestAnimationFrame ||
                   window.mozRequestAnimationFrame    ||
                   window.oRequestAnimationFrame      ||
                   window.msRequestAnimationFrame     ||
                   (callback) ->
                       window.setTimeout((->
                           callback(+new Date())
                       ), 11)

    queueAnimation: (time, method) ->  
        @animations.push
            method: method
            time: time
            index: @animationIndex += 1
        
    start: ({time, method}) ->
        if method
            @method = method
            @time = time
        else
            return unless @nextAnimation() 
        
        @stopped = false
        @lastTime = null
        @elapsed = 0
        @frame()((t) => @tick(t))
    
    nextAnimation: ->        
        return false unless @animations.length
        animation = @animations.splice(0,1)[0]
        @time = animation.time
        @method = animation.method
        @index = animation.index
        return true
        
    tick: (time) ->
        return if @stopped
        if @lastTime?
            deltaTime = (time - @lastTime)
            @elapsed += deltaTime
            
            if !@time or @elapsed <= @time
                portion = @elapsed/@time if @time
                @method
                    deltaTime: deltaTime
                    portion: portion 
                    elapsed: @elapsed 
                    
            else if @animations.length    
                @elapsed -= @time
                @nextAnimation()
                
            else
                @method(time, 1)
                return

        @lastTime = time    
        setTimeout((=> @frame()((t) => @tick(t))), 0)   
            
    stop: -> @stopped = true