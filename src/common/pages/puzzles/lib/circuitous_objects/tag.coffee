tag = exports ? provide('./tag', {})
circuitousObject = require('./object')

class tag.Tag extends circuitousObject.Object
    constructor: ({@el, @getInfo}) ->
        @init()

    init: ->
        @permanent = false
        @tag = $(document.createElement('DIV'))
        @tag.addClass('tag')
        @tag.bind 'click', =>
            @permanent = !@permanent
            if @permanent then @enlarge() else @shrink()
            
        @tag.bind 'mouseover', => @enlarge() unless @permanent
        @tag.bind 'mouseout', => @shrink() unless @permanent
        
        @content = $(document.createElement('DIV'))
        @content.addClass('content')
        @tag.append(@content)
        
        @smallContent = $(document.createElement('DIV'))
        @smallContent.addClass('small_tag_content')
        @smallContent.html('9A')
        @content.append(@smallContent)

        @largeContent = $(document.createElement('DIV'))
        @largeContent.addClass('large_tag_content hidden')
        @largeContent.html('Lightbulb #1:<br/>5 Ohms, 9 Amps')
        @content.append(@largeContent)
        
        @el.append(@tag)
        
    toggleSize: ->
        if @tag.hasClass('large')
            @shrink
        else
            @enlarge()
    
    enlarge: ->
        @tag.addClass('large')
        @smallContent.addClass('hidden')
        @largeContent.removeClass('hidden')

    shrink: ->
        @tag.removeClass('large')
        @smallContent.removeClass('hidden')
        @largeContent.addClass('hidden')
        
    setInfo: ->