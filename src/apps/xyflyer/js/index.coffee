window.app = 
    initialize: ->
        if not (@width = window.innerWidth or window.landwidth) or not (@height = window.innerHeight or window.landheight) or @width < @height
            $.timeout 100, -> window.app.initialize()
            return
            
        document.addEventListener('touchmove', ((e) => e.preventDefault()), false)
        xyflyer = require('./lib/xyflyer')
        
        @el = $('.xyflyer')
        @el.bind('touchstart', (e) -> e.preventDefault() if e.preventDefault)
        @originalHtml = @el.html()

        @levelId = 1
        @load()

    $: (selector) -> $(selector, @el)
        
    load: ->
        @el.html(@originalHtml)
        @data = LEVELS[@levelId]

        if not @data
            @showMessage('exit')
            return

        @helper = new xyflyer.ViewHelper
            el: $(@selector)
            boardElement: @$('.board')
            objects: @$('.objects')
            equationArea: @$('.equation_area')
            grid: @data.grid
            islandCoordinates: @data.islandCoordinates
            nextLevel: => @nextLevel()

        @loadLevel()    

    loadLevel: ->
        for equation, info of @data?.equations or {'': {}}
            @helper.addEquation(equation, info.start, info.solutionComponents, @data?.variables)    

        for ring in @data?.rings or []
            @helper.addRing(ring.x, ring.y)

        if @data?.fragments
            for fragment in @data.fragments
                @helper.addEquationComponent(fragment)
        else if @levelId != 'editor'
            @$('.possible_fragments').hide()


    centerAndShow: (element, board) ->
        offset = element.offset()
        boardOffset = @$('.board').offset()
        areaOffset = @el.offset()

        element.css
            opacity: 0
            top: (boardOffset.top - areaOffset.top) + (boardOffset.height/2) - (offset.height/2)
            left: (boardOffset.left - areaOffset.left) + (boardOffset.width/2) - (offset.width/2)

        element.animate
            opacity: 0.9
            duration: 500              

    showMessage: (type) ->
        equationArea = @$('.equation_area')
        equationArea.html(@$(".#{type}_message").html())
        equationArea.css(padding: '0 12px', textAlign: 'center')
        path = '/puzzles/xyflyer/1'
        if @isIos()
            equationArea.find('.button').attr('href', path) 
        else
            equationArea.find('.button').bind 'click', => @go(path)


    nextLevel: ->
        complete = @$('.complete')
        @centerAndShow(complete)

        @$('.launch').unbind('mousedown.launch touchstart.launch')
        @$('.launch').html('Success! Go To The Next Level >')
        @$('.go').one 'touchstart.go', =>
            @levelId += 1
            @load()
        

