gravity = exports ? provide('./lib/gravity', {})
class gravity.ViewHelper

  constructor: ({@el}) ->
    @wells = []
    @asteroids = []
    @initGravityWells()
    @initAsteroids()
    @lastStep = new Date()
    @step()
      
  $: (selector) -> $(selector, @el)

  initAsteroids: ->
    @asteroids.push(new gravity.Asteroid(@el, 100, 100))

  initGravityWells: ->
    @el.bind 'mousedown.well', (e) =>
      well = new gravity.Well(@el, e.offsetX, e.offsetY)
      well.grow()
      @el.bind 'mouseup.well', (e) => well.shrink()
      @wells.push(well)        

  step: ->
    for well in @wells when !well.deleted   
      well.modify() 
      well.affect(@asteroids)

    asteroid.move(new Date() - @lastStep) for asteroid in @asteroids

    @lastStep = new Date()     
    setTimeout(( => @step()), 10)



class gravity.Well
  
  MAX_RADIUS: 25
  MASS_RATIO: 10
  GRAVITATIONAL_CONSTANT: 6.67 * Math.pow(10, -11)
   
  
  constructor: (@container, @x, @y) ->
    @el = $(document.createElement('DIV'))
    @el.addClass('well')
    @el.css(left: @x, top: @y)
    @radius = 0
    @container.append(@el)

  delete: -> 
    @el.remove()
    @deleted = true
    
  grow: -> @rate = 1
    
  shrink: -> @rate = -1
    
  stop: -> delete @rate
    
  modify: ->
    return unless @rate?
    
    @radius += @rate
    
    if @radius > @MAX_RADIUS
      @stop()
      return
      
    if @radius < 0
      @delete()
      
    @el.css(boxShadow: "0px 0 #{@radius*2}px #{@radius}px rgba(255,255,255,0.8)")
    
  affect: (asteroids) ->
    for asteroid in asteroids
      distance = Math.sqrt(Math.pow(@x - asteroid.x, 2) + Math.pow(@y - asteroid.y, 2))
      force = (@GRAVITATIONAL_CONSTANT * asteroid.mass * (@MASS_RATIO * @radius)) / Math.pow(distance, 2)
      console.log(distance, force)
    
    

class gravity.Asteroid
  
  constructor: (@container, @x, @y) ->
    @mass = 10
    @speed = 0.25    
    @direction = 270
    
    @el = $(document.createElement('DIV'))
    @el.addClass('asteroid')
    @container.append(@el)

    @move(1)
    
  move: (time) ->
    distance = @speed * time
    
    radians = @direction * (Math.PI / 180)
    
    @x = @x + (Math.cos(radians) * distance)
    @y = @y + (Math.sin(radians) * distance)      
    if @x > @container.width()
      @x = 0

    if @x < 0
      @x = @container.width()
    
    if @y > @container.height()
      @y = 0
      
    if @y < 0
      @y = @container.height()
      
    @el.css(left: @x, top: @y)
    
  
  
      
    