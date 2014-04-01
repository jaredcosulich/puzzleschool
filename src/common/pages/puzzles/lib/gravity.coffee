gravity = exports ? provide('./lib/gravity', {})
class gravity.ViewHelper

  MAX_RADIUS: 25

  constructor: ({@el}) ->
    @initGravityWell()
      
  $: (selector) -> $(selector, @el)

  initGravityWell: ->
    @modifyWells()
    @el.bind 'mousedown.well', (e) =>
      well = @createWell(e.offsetX, e.offsetY)        
      @growWell(well)
      @el.bind 'mouseup.well', (e) => @shrinkWell(well)

      
  createWell: (x, y)->
    well = $(document.createElement('DIV'))
    well.addClass('well')
    well.css(left: x, top: y)
    well.data('radius', 0)
    $('.wells').append(well)
    return well
    
  deleteWell: (well) -> well.remove()
    
  modifyWells: ->
    for wellElement in $('.wells .well')
      well = $(wellElement)
      radius = parseInt(well.data('radius') or 0)
      
      grow = well.data('grow')
      
      continue unless grow
      
      radius += parseInt(grow)
      if radius > @MAX_RADIUS
        @stopWell(well)
        continue
        
      if radius < 0
        @deleteWell(well)
        continue
        
      well.css(boxShadow: "0px 0 #{radius*2}px #{radius}px rgba(255,255,255,0.8)")
      well.data('radius', radius)
    setTimeout(( => @modifyWells()), 10)
          
  growWell: (well) -> well.data('grow', 1)
    
  shrinkWell: (well) -> well.data('grow', -1)    
    
  stopWell: (well) -> well.data('grow', null)