(($) ->
    views = provide('views', {})

    $.ender({ view: (options) -> new views[options.name](options) })
    $.ender({
        view: (options) ->
            @each () ->
                options.el = @
                $.view(options)
    }, true)

    # Overwrite bonzo's removal methods to fire an event on removal, and also unbind event handlers
    {empty, remove, replaceWith} = $('')
    
    triggerRemoveEvent = (els) ->
        els.deepEach (el) ->
            $(el).trigger('remove').unbind()
            return

        return
    
    $.ender({
        empty: () ->
            triggerRemoveEvent(this.children())
            return empty.apply(this, arguments)
        
        remove: () ->
            triggerRemoveEvent(this)
            return remove.apply(this, arguments)
            
        replaceWith: () ->
            triggerRemoveEvent(this)
            return replaceWith.apply(this, arguments)
            
    }, true)
    
    class views.BaseView
        defaultElement: "<div></div>"
        
        constructor: (options={}) ->
            @name = @constructor.name.toLowerCase()
            @options = options
            @el = $(@options.el or @defaultElement)
            @data = @options.data or {}
            @lazy = @options.lazy

            @el.bind('remove', @_onremove)
    
            for event in ['prepare', 'ready', 'render', 'loading', 'error', 'build', 'complete', 'destroy']
                if @options[event]
                    $(@).bind event, @options[event]

            
            @errors = []
            @loading = 0
            @_loadingStarted()
            
            @state('prepare')
            @prepare(@data)
            
            # Give time to bind event handlers
            $.timeout 1, () => @_loadingFinished()

        $: (selector) -> $(selector, @el)

        _onremove: (event) =>
            if event.target is @el[0]
                # Only fire the event handler once
                @el.unbind('remove', @_onremove)
                @destroy()
            
            return
        
        state: (status) ->
            $(@).trigger(@status = status)
        
        destroy: () ->
            @state('destroy')
            $(@).unbind()

            @el.removeClass('view')
            @el.removeClass(@name)
            @el.data('view', null)
            
        prepare: -> # Override
        renderView: -> # Override
        renderLoading: -> @el.addClass('loading')
        renderError: -> @el.addClass('error')

        ready: (e) =>
            return if @status == 'waiting'

            @state('ready')

            if @status == 'loading'
                @el.find('*').animate
                    opacity: 0
                    duration: 250,
                    complete: () => 
                        @render()
                    
            else if not @lazy
                @render()

            return
        
        render: () ->
            @lazy = false
            curView = @el.data('view')
            if curView and curView != this
                curView.destroy()
            
            # Save the current status
            status = @status
            @state('render')
            
            @el.data('view', this)
            @el.empty()

            @el.removeClass('loading')
            @el.removeClass('error')
            @el.addClass('view')
            @el.addClass(@name)

            
            if @loading
                @state(if status != 'complete' then 'loading' else 'waiting')
                @renderLoading()

            else if @errors.length
                @state('error')
                @renderError(@errors)
                
            else
                @state('build')
                @renderView()
                @state('complete')
                
            return @

        _loadingStarted: () ->
            if not @loading++ and @status != 'prepare'
                @render() if not @lazy
    
        _loadingFinished: () ->
            if not --@loading 
                @ready()
    
        _requireElement: (url, tag, type, rel) ->
            urlAttr = (if tag in ['img', 'script'] then 'src' else 'href')
            el = $("#{tag}[#{urlAttr}=\"#{url}\"], #{tag}[data-#{urlAttr}=\"#{url}\"]")
        
            # Check if the element is already loaded (or has been pre-fetched)
            if not el.length
                tag = "style" if tag == "link"
                el = $(document.createElement(tag))
                el.attr("data-#{urlAttr}", url)
                el.attr('rel', rel) if rel
            
                if type
                    # Set the type
                    el.attr('type', type)
                    
                    if type == 'text/javascript'
                        # Loading the script from 'src' makes debugging easier
                        el.attr
                            async: 'async'
                            src: url
                        
                        @_loadingStarted()
                        el.bind 'load', () => @_loadingFinished()
                        el.bind 'abort', () =>
                            @errors.push(['requireElement', url, tag, type, rel])
                            @_loadingFinished()

                        $('head').append(el)
                            
                    else
                        # Load manually using AJAX
                        @_loadingStarted()
                        $.ajax
                            method: 'GET'
                            url: url
                            type: 'html'

                            success: (text) =>
                                el.text(text)
                                $('head').append(el)
                                @_loadingFinished()
        
                            error: (xhr, status, e, data) =>
                                @errors.push(['requireElement', url, tag, type, rel])
                                @_loadingFinished()
                            
                else
                    el.attr(urlAttr, url)
            
                    # We don't need to load data URIs
                    if url.substr(0, 5) != 'data:'
                        @_loadingStarted()
                        el.bind 'load', () => @_loadingFinished()
                        el.bind 'error', () =>
                            @errors.push(['requireElement', url, tag, type, rel])
                            @_loadingFinished()

            else if type? and el.attr('type') == 'text/plain'
                el.detach().attr('type', type).appendTo($('head'))        

            return el

        _requireScript: (url) -> @_requireElement(url, 'script', 'text/javascript')
        _requireStyle: (url) -> @_requireElement(url, 'link', 'text/css', 'stylesheet')
        _requireTemplate: (url) -> @_requireElement(url, 'script', 'text/html')
        _requireImage: (url) -> @_requireElement(url, 'img')
        
        _requireView: (options) ->
            @_loadingStarted()

            options.lazy = true
            view = $.view(options)
            $(view).bind 'ready', () =>
                @_loadingFinished()
                
            return view

        _requireData: (options) ->
            result = {}
            @_loadingStarted()

            options.method ?= 'POST'
            options.type ?= 'json'
            options.headers ?= {}
            
            if options.data and typeof options.data != 'string'
                options.headers['Content-Type'] = 'application/json'
                options.data = JSON.stringify(options.data)
                
            _success = options.success
            _error = options.error
            
            options.success = (data) =>
                for key in data
                    result[key] = data[key]

                _success(data) if _success
                @_loadingFinished()
                
            options.error = (xhr) =>
                @errors.push(['requireData', xhr.status, xhr.response, options])
                _error(xhr, xhr.status, xhr.response) if _error
                @_loadingFinished()
            
            $.ajax(options)

            return result
        
        userSignedIn: () -> ($.cookie('user')? && $.cookie('user').email?)
)(ender)