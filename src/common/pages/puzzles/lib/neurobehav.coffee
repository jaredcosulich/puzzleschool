neurobehav = exports ? provide('./lib/neurobehav', {})

class neurobehav.ChunkHelper
    constructor: () ->

class neurobehav.ViewHelper
    baseFolder: '/assets/images/puzzles/neurobehav/'

    constructor: ({@el}) ->
        @initBoard()
        @initOscillator()

    $: (selector) -> $(selector, @el)

    initBoard: ->
        @board = @$('.board')
        @board.html('')
        
    initOscillator: ->
        @oscillator = new neurobehav.Oscillator(@$('.oscillator'))
        

class neurobehav.Oscillator
    axisLineCount: 5.0
    
    constructor: (@container, @range, @threshold, @takeReading) ->
        @init()
        @drawGrid()
        @takeReading = -> return (if Math.random() < 0.1 then 160 else 30)
        @fire()
        
    init: ->
        backgroundCanvas = document.createElement('CANVAS')
        @container.append(backgroundCanvas)
        @width = backgroundCanvas.width = $(backgroundCanvas).width()
        @height = backgroundCanvas.height = $(backgroundCanvas).height()   
        @backgroundContext = backgroundCanvas.getContext('2d')

        voltageCanvas = document.createElement('CANVAS')
        @container.append(voltageCanvas)
        voltageCanvas.width = $(voltageCanvas).width()
        voltageCanvas.height = $(voltageCanvas).height()   
        @voltageContext = voltageCanvas.getContext('2d')

        @voltageContext.strokeStyle = 'rgba(255, 92, 92, 1)'    
        @voltageContext.lineWidth = 1
        
    fire: () ->
        voltage = @height - @takeReading()
        @firePosition or= 0
        if @firePosition > @width
            @voltageContext.clearRect(0, 0, @width, @height)
            @firePosition = 0

        @voltageContext.beginPath()
        @voltageContext.moveTo(@firePosition, @lastVoltage or @height)
        @firePosition += 5
        @voltageContext.lineTo(@firePosition, voltage)
        @voltageContext.stroke()
        @voltageContext.closePath()
        @lastVoltage = voltage
        $.timeout 100, => @fire()
        
        
    drawGrid: ->
        @backgroundContext.strokeStyle = 'rgba(0, 0, 0, 0.4)'    
        # @backgroundContext.fillStyle = 'rgba(255,255,255,0.4)'    
        # @backgroundContext.font = 'normal 12px sans-serif'    
        @backgroundContext.lineWidth = 1
        @backgroundContext.beginPath()
        
        for y in [1...@height] by (@height / @axisLineCount)
            @backgroundContext.moveTo(0, y)
            @backgroundContext.lineTo(@width, y)

        @backgroundContext.stroke()
        @backgroundContext.closePath()        
        
    
        




