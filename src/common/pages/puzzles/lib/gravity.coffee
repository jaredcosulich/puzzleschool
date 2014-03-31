gravity = exports ? provide('./lib/gravity', {})
class gravity.ViewHelper

  MAX_RADIUS: 40

  constructor: ({@el}) ->
    @initGravityWell()
      
  $: (selector) -> $(selector, @el)

  initGravityWell: ->
    @el.bind 'mousedown.well', (e) =>
      well = @createWell(e.offsetX, e.offsetY)        
      @el.bind 'mouseup.well', (e) => @stopWell(well)

      
  createWell: (x, y)->
    well = $(document.createElement('DIV'))
    well.addClass('well')
    well.css(left: x, top: y)
    $('.wells').append(well)
    @modifyWell(well, 0)
    return well
    
  modifyWell: (well, radius) ->
    return if well.data('stopped')?
    radius += 1
    return if radius > @MAX_RADIUS
    well.css(boxShadow: "0px 0 #{radius*2}px #{radius}px rgba(255,255,255,1)")
    setTimeout(( => @modifyWell(well, radius)), radius*2)
    
  stopWell: (well) -> well.data('stopped', true)