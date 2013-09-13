tag = exports ? provide('./tag', {})
circuitousObject = require('./object')

class tag.Tag extends circuitousObject.Object
    constructor: ({@object, show}) ->
        @init()
        if show then @show() else @hide()

    init: ->
        @permanent = false
        @tag = $(document.createElement('DIV'))
        @tag.addClass('tag')

        @tag.bind 'mousedown.toggle_permanence', => 
            @tag.one 'mouseup.toggle_permanence', => @togglePermanentlyOpen()
            $(document.body).bind 'mouseup.toggle_permanence', => @tag.unbind('mouseup.toggle_permanence')
            
        @tag.bind 'mouseover', => 
            return if @permanent
            @enlarge()
        @tag.bind 'mouseout', => 
            return if @permanent
            @shrink()
        
        @content = $(document.createElement('DIV'))
        @content.addClass('content')
        @tag.append(@content)
        
        @smallContent = $(document.createElement('DIV'))
        @smallContent.addClass('small_tag_content')
        @content.append(@smallContent)

        @largeContent = $(document.createElement('DIV'))
        @largeContent.addClass('large_tag_content hidden')
        @content.append(@largeContent)
        
        @object.el.append(@tag)
        @position()
       
    position: ->   
        parentOffset = @object.el.parent().offset()
        if (@object.currentX - parentOffset.left) > (parentOffset.width / 2) - (@object.el.offset().width / 2)
            @tag.addClass('right')
        else
            @tag.removeClass('right')
        
        
    togglePermanentlyOpen: ->
        @permanent = !@permanent
        if @permanent then @enlarge() else @shrink()
    
    enlarge: ->
        @tag.addClass('large')
        @smallContent.addClass('hidden')
        @largeContent.removeClass('hidden')

    shrink: ->
        @tag.removeClass('large')
        @smallContent.removeClass('hidden')
        @largeContent.addClass('hidden')
        
    setInfo: (info) -> @changeContent(info)
    
    changeContent: (info) ->
        return unless (key for key, value of info when value != undefined and @info?[key] != value).length

        @info = info
        
        @smallContent.html("#{@info.current}A")
        @largeContent.html """
            <div class='navigation'><a class='icon-pencil'></a><br/><a class='icon-undo'></a></div>
            #{@info.name}<br/>
            #{@info.current} Amps, 
            #{if @info.voltage then "#{@info.voltage} Volts," else ''} 
            #{@info.resistance} Ohms
        """
        $.timeout 10, => 
            @largeContent.find('.icon-pencil').bind 'mousedown.edit', (e) => 
                e.stop()
                alert('Edit component values coming soon.')
                
            @largeContent.find('.icon-undo').bind 'mousedown.rotate', (e) => 
                e.stop()
                alert('Rotate component coming soon.')

    hide: -> @tag.hide()
    
    show: -> @tag.show()