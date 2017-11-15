# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

FUNCTIONS = {
  "A1": {
      name: "Move Forward",
      method: "moveForward",
      paramCount: 1,
      color: false
  },
  "A2": {
      name: "Move Backward",
      method: "moveBackward",
      paramCount: 1,
      color: false
  },
  "A3": {
      name: "Rotate Right",
      method: "rotateRight",
      paramCount: 1,
      color: false
  },
  "A4": {
      name: "Rotate Left",
      method: "rotateLeft",
      paramCount: 1,
      color: false
  },
  "A5": {
      name: "Fill Color",
      method: "fillColor",
      paramCount: 0,
      color: true
  },
  "P1": {
      name: "Pen Up",
      method: "penUp",
      paramCount: 0,
      color: false
  },
  "P2": {
      name: "Pen Down",
      method: "penDown",
      paramCount: 0,
      color: false
  },
  "P3": {
      name: "Pen Size",
      method: "penSize",
      paramCount: 1,
      color: false
  },
  "P4": {
      name: "Pen Color",
      method: "penColor",
      paramCount: 0,
      color: true
  },
  "F1": {
      name: "Function",
      method: "function",
      paramCount: 1,
      color: false
  },
  "F2": {
      name: "End Function",
      method: "endFunction",
      paramCount:0,
      color: false
  },
  "L1": {
      name: "Loop",
      method: "loop",
      paramCount:1,
      color: false
  },
  "L2": {
      name: "End Loop",
      method: "endLoop",
      paramCount:0,
      color: false
  }
}

SETTINGS = {
  speed: 500,
  cardHeight: 180,
  startingZoom: 1,
  zoom: 1,
  executionIndex: 0,
  currentAngle: 90,
  penSize: 1,
  penColor: [0, 0, 0],
  penIsDown: true,
  loops: [],
  userFunctions: {},
}

initCodePuzzle = ->
  return unless $('.codepuzzle').length

  initCanvas()
  initCards()

  reset()

  initArrow()

  playCard(0, true)
  play()

  $('.play').click ->
    play()

  $('.pause').click ->
    clearInterval(SETTINGS.executionInterval)
    delete SETTINGS.executionInterval

  $('.speed').change ->
    switch $('.speed').find(":selected").text()
      when "Slow" then SETTINGS.speed = 1000
      when "Fast" then SETTINGS.speed = 200
      when "Very Fast" then SETTINGS.speed = 50
      else SETTINGS.speed = 0

    if SETTINGS.executionInterval?
      clearInterval(SETTINGS.executionInterval)
      play()

play = ->
  SETTINGS.executionInterval = setInterval(( =>
    if SETTINGS.speed == 0
      clearInterval(SETTINGS.executionInterval)
      delete SETTINGS.executionInterval
      lastCardIndex = SETTINGS.cards.length - 1
      executeUpTo(lastCardIndex)
      highlightCard(lastCardIndex, true)
      displaySignature(lastCardIndex)
    else
      executeNextCard()
  ), SETTINGS.speed)


reset = ->
  SETTINGS.context.restore()
  SETTINGS.context.clearRect(0, 0, SETTINGS.width, SETTINGS.height)
  SETTINGS.context.save()
  SETTINGS.currentPoint = [Math.round(SETTINGS.width/2), Math.round(SETTINGS.height/2)]
  SETTINGS.context.translate(0.5, 0.5)
  SETTINGS.executionIndex = 0
  SETTINGS.currentAngle = 90
  SETTINGS.penSize = 1
  SETTINGS.penColor = [0, 0, 0]
  SETTINGS.penIsDown = true
  SETTINGS.loops = []
  SETTINGS.userFunctions = {}
  delete SETTINGS.currentFunction
  clearInterval(SETTINGS.executionInterval)
  delete SETTINGS.executionInterval

initCanvas = ->
  SETTINGS.width = $('.canvas').width()
  SETTINGS.height = $('.canvas').height()

  canvasContainer = $('.canvas-container')
  canvasContainer.height($(window).height())
  canvasContainer.scrollLeft((SETTINGS.width - canvasContainer.width()) / 2)
  canvasContainer.scrollTop((SETTINGS.height - canvasContainer.height()) / 2)

  drawingCanvas = $('#drawing_canvas')[0]
  drawingCanvas.width = SETTINGS.width
  drawingCanvas.height = SETTINGS.height
  SETTINGS.context = drawingCanvas.getContext('2d')

  arrowCanvas = $('#arrow_canvas')[0]
  arrowCanvas.width = SETTINGS.width
  arrowCanvas.height = SETTINGS.height
  SETTINGS.arrowContext = arrowCanvas.getContext('2d')

  # SETTINGS.context.scale(0.5, 0.5)
  # SETTINGS.arrowContext.scale(0.5, 0.5)

  mouseAt = (e) ->
    return {
      x: e.pageX - canvasContainer.offset().left + canvasContainer.scrollLeft()
      y: e.pageY - canvasContainer.offset().top + canvasContainer.scrollTop()
    }

  mousedownAt = {}
  canvasContainer.on 'mousedown', (e) ->
    mousedownAt = mouseAt(e)

  $(window).on 'mouseup', ->
    mousedownAt = {}

  canvasContainer.on 'mousemove', (e) ->
    return unless mousedownAt.x?
    canvasContainer.scrollTop(canvasContainer.scrollTop() + (mousedownAt.y - mouseAt(e).y))
    canvasContainer.scrollLeft(canvasContainer.scrollLeft() + (mousedownAt.x - mouseAt(e).x))
    mousedownAt = mouseAt(e)

initCards = ->
  $('.cards-container').height($(window).height() * 0.7)

  SETTINGS.cards = ($(card).data() for card in $('.card'))

  for card in SETTINGS.cards
    cardElement = $("#card_#{card.id}")
    cardElement.css(opacity: 0.2)
    cardElement.on 'dragstart', -> return false

  container = $('.cards-container')

  mouseAt = (e) ->
    return e.pageY - container.offset().top + container.scrollTop()

  mousedownAt = -1
  container.on 'mousedown', (e) ->
    clearInterval(SETTINGS.executionInterval)
    delete SETTINGS.executionInterval
    $(".cards-container, .cards, .card").stop()
    mousedownAt = mouseAt(e)

  $(window).on 'mouseup', ->
    mousedownAt = -1

  container.on 'mousemove', (e) ->
    return unless mousedownAt > -1
    container.scrollTop(container.scrollTop() + (mousedownAt - mouseAt(e)))
    mousedownAt = mouseAt(e)

  container.on 'click', (e) ->
    return if scrolling
    cardIndex = cardIndexAt(mouseAt(e))
    executeUpTo(cardIndex)
    highlightCard(cardIndex, true)
    displaySignature(cardIndex)

  scrolling = false
  container.on 'scroll', ->
    return unless mousedownAt > -1
    scrolling = true
    setTimeout(( => scrolling = false), 500)
    center = container.scrollTop() + (container.height() / 2)
    cardIndex = cardIndexAt(center)
    executeUpTo(cardIndex)
    highlightCard(cardIndex, true, false)
    displaySignature(cardIndex)


cardIndexAt = (yPosition) ->
  container = $('.cards-container')
  for cardElement, index in container.find('.card')
    cardElement = $(cardElement)
    top = container.scrollTop() + cardElement.offset().top - container.offset().top
    bottom = top + SETTINGS.cardHeight
    if top < yPosition && bottom > yPosition
      return index

initArrow = ->
  SETTINGS.arrowContext.restore()
  SETTINGS.arrowContext.clearRect(0, 0, SETTINGS.width, SETTINGS.height)
  SETTINGS.arrowContext.fillStyle = "red"
  SETTINGS.arrowContext.save()
  drawArrow()

active = (index) ->
  card = SETTINGS.cards[index]
  return true unless card?
  return true if card.active
  $(".cards .card").data(active: false)
  $("#card_#{card.id}").data(active: true)
  return false

executeNextCard = ->
  if SETTINGS.executionIndex >= SETTINGS.cards.length
    clearInterval(SETTINGS.executionInterval)
    delete SETTINGS.executionInterval
    return

  playCard(SETTINGS.executionIndex)

executeUpTo = (endIndex) ->
  return if active(endIndex)
  reset()

  index = 0
  while index <= endIndex
    index += executeCard(index)

  SETTINGS.executionIndex = endIndex + 1

playCard = (index, instant=false) ->
  card = SETTINGS.cards[index]
  return unless card?

  return if active(index)
  highlightCard(index, instant)

  SETTINGS.executionIndex += executeCard(index, instant)

  displaySignature(index)


displaySignature = (index) ->
  card = SETTINGS.cards[index]
  return unless card?

  info = FUNCTIONS[card.code]
  if info.color
    $(".signature").html(info.name)
    $(".signature-color").css(backgroundColor: "rgb(#{colorFromParam(card.param).join(',')})")
    $(".signature-color").show()
  else
    $(".signature").html("#{info.name} #{card.param}")
    $(".signature-color").hide()


highlightCard = (index, instant=false, scroll=true) ->
  card = SETTINGS.cards[index]
  return unless card?

  $(".cards .card").css(opacity: 0.2)

  cardElement = $("#card_#{card.id}")
  cardElement.animate({
    opacity: 1
  }, (if instant then 0 else SETTINGS.speed / 2))

  if scroll
    container = cardElement.closest('.cards-container')
    top = container.scrollTop() + cardElement.position().top - (container.height() / 2) + (SETTINGS.cardHeight / 2)
    container.animate({
        scrollTop: top
    }, (if instant then 0 else SETTINGS.speed / 2))


executeCard = (index, instant=false) ->
  card = SETTINGS.cards[index]
  return unless card?

  methodName = FUNCTIONS[card.code].method
  paramNumber = parseFloat(card.param)

  if SETTINGS.currentFunction?
    if (methodName == "endFunction")
      delete SETTINGS['currentFunction']
    else
      SETTINGS.userFunctions[SETTINGS.currentFunction].functions.push( =>
        executeCard(index)
      )
    return 1

  nextPoint = SETTINGS.currentPoint
  fill = false
  fillColor = "red"

  switch methodName
    when "moveForward"
      nextPoint = calculatePoint(SETTINGS.currentPoint, paramNumber, SETTINGS.currentAngle)
    when "moveBackward"
      nextPoint = calculatePoint(SETTINGS.currentPoint, paramNumber * -1, SETTINGS.currentAngle)
    when "rotateRight"
      SETTINGS.currentAngle += paramNumber
    when "rotateLeft"
      SETTINGS.currentAngle -= paramNumber
    when "penUp"
      SETTINGS.penIsDown = false
    when "penDown"
      SETTINGS.penIsDown = true
    when "penSize"
      SETTINGS.penSize = paramNumber
    when "penColor"
      SETTINGS.penColor = colorFromParam(card.param)
    when "fillColor"
      SETTINGS.fillColor = colorFromParam(card.param)
      fill = true
    when "loop"
      SETTINGS.loops.push(
        {start: index + 1, completed: 0, total: paramNumber}
      )
    when "endLoop"
      currentLoop = SETTINGS.loops[SETTINGS.loops.length - 1]
      currentLoop.completed += 1
      if currentLoop.completed == currentLoop.total
        SETTINGS.loops.pop()
      else
        return currentLoop.start - index
    when "function"
      userFunction = SETTINGS.userFunctions[card.param]
      if userFunction?
        functionIndex = 0
        while functionIndex <= userFunction.functions.length - 1
          functionIndex += userFunction.functions[functionIndex]()

      else
        SETTINGS.userFunctions[card.param] = {start: index, functions: []}
        SETTINGS.currentFunction = card.param
    else
      print("Method Not Found")

  drawArrow(nextPoint, SETTINGS.currentAngle)

  if SETTINGS.penIsDown
    if SETTINGS.currentPoint != nextPoint
      SETTINGS.context.lineWidth = SETTINGS.penSize
      SETTINGS.context.strokeStyle = "rgb(#{SETTINGS.penColor.join(',')})"
      SETTINGS.context.beginPath()
      SETTINGS.context.moveTo(SETTINGS.currentPoint[0], SETTINGS.currentPoint[1])
      SETTINGS.context.lineTo(nextPoint[0], nextPoint[1])
      SETTINGS.context.stroke()

  if fill
    ImageProcessing.fill(
      SETTINGS.context.canvas,
      SETTINGS.fillColor,
      nextPoint[0],
      nextPoint[1]
    )

  SETTINGS.currentPoint = nextPoint

  return 1


drawArrow = (point=SETTINGS.currentPoint, angle=SETTINGS.currentAngle) ->
  width = 7
  height = 15
  SETTINGS.arrowContext.restore()
  SETTINGS.arrowContext.clearRect(0, 0, SETTINGS.width, SETTINGS.height)
  SETTINGS.arrowContext.save()
  SETTINGS.arrowContext.translate(point[0], point[1])
  SETTINGS.arrowContext.rotate((angle - 90) * Math.PI / 180)
  SETTINGS.arrowContext.translate(width * -1, height * -1)
  SETTINGS.arrowContext.beginPath()
  SETTINGS.arrowContext.moveTo(0, height)
  SETTINGS.arrowContext.lineTo(width, 0)
  SETTINGS.arrowContext.lineTo(width * 2, height)
  SETTINGS.arrowContext.closePath()
  SETTINGS.arrowContext.fill()
  SETTINGS.arrowContext.stroke()

colorFromParam = (param) ->
  Math.floor(colorValue * 255) for colorValue in param.split(/\s/)[1..-2]

calculateXDistance = (distance, angle) ->
  adjustedAngle = angle % 360

  if adjustedAngle == 90 || adjustedAngle == 270
    return 0
  else if adjustedAngle == 0
    return distance * -1
  else if adjustedAngle == 180
    return distance

  return Math.cos(adjustedAngle * (Math.PI / 180)) * distance * -1

calculateYDistance = (distance, angle) ->
  adjustedAngle = angle % 360

  if adjustedAngle == 0.0 || adjustedAngle == 180
    return 0
  else if (adjustedAngle == 270)
    return distance
  else if (adjustedAngle == 90)
    return distance * -1

  return Math.sin(adjustedAngle * (Math.PI / 180)) * distance * -1

calculatePoint = (point, distance, angle) ->
  xDistance = calculateXDistance(distance, angle) / SETTINGS.startingZoom
  yDistance = calculateYDistance(distance, angle) / SETTINGS.startingZoom
  return [point[0] + xDistance, point[1] + yDistance]

$(document).on "turbolinks:load", initCodePuzzle
