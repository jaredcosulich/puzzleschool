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
  width: 600,
  height: 400,
  currentAngle: 90,
  startingZoom: 1,
  zoom: 1,
  executionIndex: 0,
  penSize: 1,
  penColor: [0, 0, 0],
  penIsDown: true,
  loops: [],
  userFunctions: {},
}

init = ->
  SETTINGS.width = $('.canvas').width()
  SETTINGS.height = $('.canvas').height()

  drawingCanvas = $('#drawing_canvas')[0]
  drawingCanvas.width = SETTINGS.width
  drawingCanvas.height = SETTINGS.height
  SETTINGS.context = drawingCanvas.getContext('2d')

  arrowCanvas = $('#arrow_canvas')[0]
  arrowCanvas.width = SETTINGS.width
  arrowCanvas.height = SETTINGS.height
  SETTINGS.arrowContext = arrowCanvas.getContext('2d')

  initCards()

  SETTINGS.currentPoint = [Math.round(SETTINGS.width/2), Math.round(SETTINGS.height/2)]
  SETTINGS.context.translate(0.5, 0.5)

  initArrow()

  executeNextCard()
  SETTINGS.executionInterval = setInterval(( =>
    executeNextCard()
  ), 1000)

initCards = ->
  SETTINGS.cards = ($(card).data() for card in $('.card'))
  for card in SETTINGS.cards
    $("#card_#{card.id}").css(opacity: 0.2)

initArrow = ->
  SETTINGS.arrowContext.restore()
  SETTINGS.arrowContext.clearRect(0, 0, SETTINGS.width, SETTINGS.height)
  SETTINGS.arrowContext.fillStyle = "red"
  SETTINGS.arrowContext.save()
  drawArrow()

executeNextCard = ->
  if SETTINGS.executionIndex >= SETTINGS.cards.length
    clearInterval(SETTINGS.executionInterval)
    return

  card = SETTINGS.cards[SETTINGS.executionIndex]
  highlightCard(card)
  nextIndex = executeCard(card)
  if nextIndex > -1
    SETTINGS.executionIndex = nextIndex
  else
    SETTINGS.executionIndex += 1


highlightCard = (card) ->
  $(".cards .card").animate({
    opacity: 0.2
  }, 100)

  cardElement = $("#card_#{card.id}")
  cardElement.animate({
    opacity: 1
  }, 100)

  container = cardElement.closest('.cards-container')
  left = cardElement.offset().left + container.scrollLeft() - (container.width() / 2) - (cardElement.width() * 3 / 4)
  container.animate({
      scrollLeft: left
  }, 100)

  info = FUNCTIONS[card.code]
  if info.color
    $(".signature").html(info.name)
    console.log("rgb(#{colorFromParam(card.param).join(',')})")
    $(".signature-color").css(backgroundColor: "rgb(#{colorFromParam(card.param).join(',')})")
    $(".signature-color").show()
  else
    $(".signature").html("#{info.name} #{card.param}")
    $(".signature-color").hide()

executeCard = (card) ->
  methodName = FUNCTIONS[card.code].method
  paramNumber = parseFloat(card.param)

  if SETTINGS.currentFunction?
    if (methodName == "endFunction")
      delete SETTINGS['currentFunction']
    else
      SETTINGS.userFunctions[SETTINGS.currentFunction].push( =>
        executeCard(card)
      )
    return -1

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
        {start: SETTINGS.executionIndex, completed: 0, total: paramNumber}
      )
    when "endLoop"
      currentLoop = SETTINGS.loops[SETTINGS.loops.length - 1]
      currentLoop.completed += 1
      if currentLoop.completed == currentLoop.total
        SETTINGS.loops.pop()
      else
        return currentLoop.start + 1
    when "function"
      userFunction =  SETTINGS.userFunctions[card.param]
      if userFunction?
        index = 0
        while index <= userFunction.length - 1
          nextIndex = userFunction[index]()
          if nextIndex > -1
            index = nextIndex - SETTINGS.executionIndex + 1
          else
            index += 1

      else
        SETTINGS.userFunctions[card.param] = []
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

  return -1

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


$(document).on "turbolinks:load", -> init()
