gravity = exports ? provide('./lib/gravity', {})
class gravity.ViewHelper

  constructor: ({@el}) ->
    @wells = []
    @initGravityWell()
      
  $: (selector) -> $(selector, @el)

  initGravityWell: ->
    @modifyWells()
    @el.bind 'mousedown.well', (e) =>
      well = new gravity.Well(@el, e.offsetX, e.offsetY)
      well.grow()
      @el.bind 'mouseup.well', (e) => well.shrink()
      @wells.push(well)        

  modifyWells: ->
    well.modify() for well in @wells      
    setTimeout(( => @modifyWells()), 10)



class gravity.Well
  MAX_RADIUS: 25
  constructor: (@container, @x, @y) ->
    @el = $(document.createElement('DIV'))
    @el.addClass('well')
    @el.css(left: x, top: y)
    @radius = 0
    @container.append(@el)

  delete: -> @el.remove()
  
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
    
    
    
    
    