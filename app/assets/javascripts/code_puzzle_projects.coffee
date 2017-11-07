# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

COMMANDS = [
  ["A1", "50"]
  ["A4", "90"],
  ["A1", "50"]
]

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
  userFunctions: {}
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

  SETTINGS.currentPoint = [Math.round(SETTINGS.width/2), Math.round(SETTINGS.height/2)]
  SETTINGS.context.translate(0.5, 0.5)

  initArrow()

  executeNextCommand()
  SETTINGS.executionInterval = setInterval(( ->
    executeNextCommand()
  ), 500)

initArrow = ->
  SETTINGS.arrowContext.restore()
  SETTINGS.arrowContext.clearRect(0, 0, SETTINGS.width, SETTINGS.height)
  SETTINGS.arrowContext.fillStyle = "red"
  SETTINGS.arrowContext.save()
  drawArrow()

executeNextCommand = ->
  if SETTINGS.executionIndex >= COMMANDS.length
    clearInterval(SETTINGS.executionInterval)
    return

  command = COMMANDS[SETTINGS.executionIndex]
  SETTINGS.executionIndex += 1
  executeCommand(command[0], command[1])

executeCommand = (code, param) ->
  methodName = FUNCTIONS[code].method
  paramNumber = parseFloat(param)

  # if (SETTINGS.currentFunction?)
  #   if (methodName == "endFunction")
  #     SETTINGS.delete('currentFunction')
  #   else
  #     SETTINGS.userFunctions[SETTINGS.currentFunction].push( ->
  #       executeCommand(code, param)
  #     )
  #     return 0

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
      # case "penUp":
      #     penIsDown = false
      # case "penDown":
      #     penIsDown = true
      # case "penSize":
      #     penSize = paramNumber
      #     permanentPathComponents.append(PermanentPathComponent(
      #         size: penSize,
      #         color: penColor,
      #         path: UIBezierPath(),
      #         fillPoint: nil
      #     ))
      # case "penColor":
      #     penColor = ImageProcessor.colorFrom(text: param)
      #     permanentPathComponents.append(PermanentPathComponent(
      #         size: penSize,
      #         color: penColor,
      #         path: UIBezierPath(),
      #         fillPoint: nil
      #     ))
      # case "fillColor":
      #     fillColor = ImageProcessor.colorFrom(text: param)
      #     fill = true
      #     permanentPathComponents.append(PermanentPathComponent(
      #         size: nil,
      #         color: fillColor,
      #         path: nil,
      #         fillPoint: currentPoint
      #     ))
      #     permanentPathComponents.append(PermanentPathComponent(
      #         size: penSize,
      #         color: penColor,
      #         path: UIBezierPath(),
      #         fillPoint: nil
      #     ))
      # case "loop":
      #     return Int(paramNumber)
      # case "endLoop":
      #     return -1
      # case "function":
      #     if let functionSteps = userDefinedFunctions[paramNumber] {
      #         var loops = [Loop]()
      #         var index = -1
      #         while index < functionSteps.count - 1 {
      #             index += 1
      #             let loopCount = functionSteps[index]()
      #             if loopCount > 0 {
      #                 loops.append(Loop(startingIndex: index, count: loopCount))
      #             } else if loopCount < 0 {
      #                 let loopIndex = loops.last!.increment()
      #                 if loopIndex == -1 {
      #                     _ = loops.popLast()
      #                 } else {
      #                     index = loopIndex
      #                 }
      #             }
      #         }
      #     } else {
      #         userDefinedFunctions[paramNumber] = [() -> Int]()
      #         currentUserDefinedFunction = paramNumber
      #     }
      #     return 0
    else
      print("Method Not Found")

  drawArrow(nextPoint, SETTINGS.currentAngle)

  if SETTINGS.currentPoint != nextPoint
    SETTINGS.context.beginPath()
    SETTINGS.context.moveTo(SETTINGS.currentPoint[0], SETTINGS.currentPoint[1])
    SETTINGS.context.lineTo(nextPoint[0], nextPoint[1])
    SETTINGS.currentPoint = nextPoint
    SETTINGS.context.stroke()

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



calculateXDistance = (distance, angle) ->
  adjustedAngle = angle % 360

  if adjustedAngle == 90 || adjustedAngle == 270
    return 0
  else if adjustedAngle == 0
    return distance * -1
  else if adjustedAngle == 180.0
    return distance

  return cos(adjustedAngle * (Math.pi / 180.0)) * distance * -1

calculateYDistance = (distance, angle) ->
  adjustedAngle = angle % 360

  if adjustedAngle == 0.0 || adjustedAngle == 180.0
    return 0
  else if (adjustedAngle == 270.0)
    return distance
  else if (adjustedAngle == 90.0)
    return distance * -1

  return sin(adjustedAngle * (Math.pi / 180.0)) * distance * -1

calculatePoint = (point, distance, angle) ->
  xDistance = calculateXDistance(distance, angle) / SETTINGS.startingZoom
  yDistance = calculateYDistance(distance, angle) / SETTINGS.startingZoom
  return [point[0] + xDistance, point[1] + yDistance]


$(document).on "turbolinks:load", -> init()
