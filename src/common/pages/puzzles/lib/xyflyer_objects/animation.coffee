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
        
    start: () ->
        return if @animating or not @nextAnimation() 
        @stopped = false
        @lastTime = null
        @frame()((t) => @tick(t))
    
    nextAnimation: ->        
        return false unless @animations.length
        @elapsed = if @time then @time - @elapsed else 0
        animation = @animations.splice(0,1)[0]
        @time = animation.time
        @method = animation.method
        @index = animation.index
        return true
        
    tick: (time) ->
        return if @stopped
        @animating = true
        if @lastTime?
            @elapsed += (time - @lastTime)
            portion = @elapsed/@time
            if @method(portion, @time - @elapsed)
                @animating = false
                return if not @nextAnimation()

        @lastTime = time    
        setTimeout((=> @frame()((t) => @tick(t))), 0)   
            
    stop: -> @stopped = true