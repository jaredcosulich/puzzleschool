animation = exports ? provide('./animation', {})

class animation.Animation
    constructor: () ->
        @animations = []
        @animationIndex = 0
        
    frame: ->
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
        
    start: (time, method) ->
        if time and method
            @time = time
            @method = method
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
            @elapsed += (time - @lastTime)
            
            if @elapsed <= @time
                portion = @elapsed/@time
                @method(portion) 
            else if @animations.length    
                @elapsed -= @time
                @nextAnimation()
            else
                @method(1)
                return

        @lastTime = time    
        setTimeout((=> @frame()((t) => @tick(t))), 0)   
            
    stop: -> @stopped = true