animation = exports ? provide('./animation', {})

class animation.Animation
    constructor: () ->
        
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

        
    start: (@time, @method) ->
        @stopped = false
        @lastTime = null
        @elapsed = 0
        @frame()((t) => @tick(t))
        
    tick: (time) ->
        return if @stopped
        if @lastTime?
            @elapsed += (time - @lastTime)
            portion = @elapsed/@time
            return if @method(portion)

        @lastTime = time    
        setTimeout((=> @frame()((t) => @tick(t))), 0)   
            
    stop: -> @stopped = true