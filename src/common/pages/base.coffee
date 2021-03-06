soma = require('soma')
wings = require('wings')

class soma.View extends soma.View
    hashChanges: {}
    registerHashChange: (hash, callback) => @hashChanges[hash.replace(/#/, '')] = callback
    showRegistrationFlag: ->
        registrationFlag = $('.register_flag')
        paddingTop = registrationFlag.css('paddingTop')
        $.timeout 1000, ->
            registrationFlag.animate
                paddingTop: 45
                paddingBottom: 45
                duration: 1000
                complete: ->
                    $.timeout 1000, =>
                        registrationFlag.animate
                            paddingTop: paddingTop
                            paddingBottom: paddingTop
                            duration: 1000
            
        window.onbeforeunload = -> 
            return '''
                If you leave this page you\'ll lose your progress.
                
                You can save your progress by creating an account.
            '''

    showModal: (selector) ->
        @opaqueScreen = $('.opaque_screen')
        @opaqueScreen.css(opacity: 0, top:0, left: 0, width: $(document.body).width(), height: $(document.body).height() + 300 + $('#top_nav').height())
        @opaqueScreen.animate
            opacity: 0.75
            duration: 300

        modal = @$(selector)
        modal.css
            top: 120 + $(document.body).scrollTop()
            left: ($(document.body).width() - modal.width()) / 2
        modal.animate
            opacity: 1
            duration: 500

        modal.bind 'click', (e) => e.stop()
        $(@opaqueScreen).bind 'click', () => @hideModal(selector)

    hideModal: (selector, callback) ->
        return unless @opaqueScreen
        $(@opaqueScreen).unbind 'click'
        modal = if selector instanceof String then @$(selector) else $(selector)
        modal = modal.closest('.modal') unless modal.hasClass('modal')
        @opaqueScreen.animate(opacity:0, duration: 500, complete: () => @opaqueScreen.css(top: -10000, left: -10000))
        modal.animate
            opacity: 0
            duration: 500
            complete: () =>
                modal.css
                    top: -10000
                    left: -10000
                location.hash = '' if location.hash.length
                callback() if callback

        
soma.chunks
    Base:
        shortMonths: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        prepare: ({@content}) ->
            @setIcon('/assets/images/favicon.ico')
            @loadElement 'link', {href: '/assets/images/favicon.ico', rel: 'shortcut icon', type: 'image/x-icon'}

            if @badBrowser()
                @template = @loadTemplate '/build/common/templates/bad_browser.html'
            else
                @setMeta('apple-mobile-web-app-capable', 'yes')
                @setMeta('apple-mobile-web-app-status-bar-style', 'black')
                @setMeta(name: 'og:type', property: 'og:type', content: 'website')            
                @setMeta(name: 'og:site_name', property: 'og:site_name', content: 'The Puzzle School')
            
                @loadScript '/assets/third_party/rollbar.js'

                @loadElement("link", {rel: 'apple-touch-icon', sizes: '57x57', href: '/assets/images/touch-icon-iphone.png'})
                @loadElement("link", {rel: 'apple-touch-icon', sizes: '72x72', href: '/assets/images/touch-icon-ipad.png'})
                @loadElement("link", {rel: 'apple-touch-icon', sizes: '114x114', href: '/assets/images/touch-icon-iphone4.png'})
                @loadElement("link", {rel: 'apple-touch-startup-image', sizes: '1024x748', href: '/assets/images/startup1024x748.png'})
                @loadElement("link", {rel: 'apple-touch-startup-image', sizes: '768x1004', href: '/assets/images/startup768x1004.png'})
                @loadElement("link", {rel: 'apple-touch-startup-image', sizes: '320x460', href: '/assets/images/startup320x460.png'})

                @loadStylesheet '/build/client/css/all.css'

                @loadScript '/build/client/pages/form.js'

                @loadScript '/build/common/pages/base.js'

                @loadScript '/assets/analytics.js'
                        
                @template = @loadTemplate '/build/common/templates/base.html'
                @emailSubscriptionTemplate = @loadTemplate '/build/common/templates/_email_subscription.html'
                
            @loadChunk @content

        badBrowser: ->
            userAgent = if @context?.request?.headers then @context.request.headers['user-agent'] else navigator?.userAgent
            return true if (userAgent or '').indexOf('MSIE') > -1
            return false
            
        build: () ->
            data = 
                loggedIn: @cookies.get('user')?
                content: @content
                months: ({ label: @shortMonths[i-1], value: i } for i in [1..12])
                days: [1..31]
                years: [((new Date).getFullYear() - 1)..1900]
                emailSubscription: if @badBrowser() then '' else wings.renderTemplate(@emailSubscriptionTemplate)
            
            @html = wings.renderTemplate(@template, data)
            
soma.views
    Base:
        selector: '#base'
        
        create: ->
            unless window.initialized
                window.initialized = true
                window.postRegistration = []
                window.onhashchange = () => @onhashchange()
                if navigator.userAgent.match(/iP/i)
                    $(window).bind 'resize orientationChanged', =>
                        $('#top_nav .content').width($.viewport().width)
                $(window).trigger('resize') if $.viewport().width < $('#top_nav .content').width()
            
            @checkLoggedIn()
            @$('.log_out').bind 'click', => @logOut()

            @registerHashChange 'register', => @showRegistration()
            @$('.register').bind 'click', => location.hash = 'register'

            @registerHashChange 'login', => @showLogIn()
            @$('.log_in').bind 'click', => location.hash = 'login'
            
            @$('.close_modal').bind 'click', (e) => @hideModal(e.currentTarget)
            
            @initEmailSubscription()
            
        complete: -> @onhashchange()

        onhashchange: () -> callback() if (callback = @hashChanges[location.hash.replace(/#/, '')])
                 
        showRegistration: () ->
            @showModal('.registration_form')
            @$('.registration_form .cancel_button').bind 'click', () => @hideModal('.registration_form')
            @$('.registration_form .toggle_login').bind 'click', => 
                @hideModal('.registration_form', => location.hash = 'login')

            submitForm = () =>
                form = @$('.registration_form form')
                $.ajaj
                    url: '/api/register'
                    method: 'POST'
                    headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                    data: form.data('form').dataHash()
                    success: () =>
                        @$('.registration_form .submit_feedback').data('form-button').success()
                        @hideModal(form)
                        if window.postRegistration.length
                            (postRegistrationMethod => @checkLoggedIn()) for postRegistrationMethod in window.postRegistration
                        else
                            @checkLoggedIn()
                            if (go = @cookies.get('returnTo'))
                                @cookies.set('returnTo', null)
                                window.location = go
                    error: =>
                        @$('.registration_form .submit_feedback').data('form-button').error()
                
            @$('.registration_form input').bind 'keypress', (e) => submitForm() if e.keyCode == 13
            @$('.registration_form .register_button').bind 'click', () => submitForm()
                
        showLogIn: () ->  
            @showModal('.login_form')
            @$('.login_form .cancel_button').bind 'click', => @hideModal('.login_form')
            @$('.login_form .toggle_registration').bind 'click', => 
                @hideModal('.login_form', => location.hash = 'register')
            
            loginButton = @$('.login_form .login_button')
            loginButton.bind 'click', () =>
                form = @$('.login_form form')
                $.ajaj
                    url: '/api/login'
                    method: 'POST'
                    data: form.data('form').dataHash()
                    headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }                        
                    success: () => 
                        @hideModal(form)
                        @checkLoggedIn()
                        if (go = @cookies.get('returnTo'))
                            @cookies.set('returnTo', null)
                            window.location = go
                            
                    error: () => 
                        loginButton.data('form-button')?.error()

            @$('.login_form input').bind 'keypress', (e) => loginButton.trigger('click') if e.keyCode == 13
                
            
        logOut: () ->
            @cookies.set('user', null)
            @$('.logged_in').animate
                opacity: 0
                duration: 500
                complete: =>
                    @$('.logged_out').css(opacity: 0)
                    @el.removeClass('logged_in')
                    @el.addClass('logged_out')
                    @$('.user_name').html('')
                    @$('.logged_in').css(opacity: 1)    
                    @$('.logged_out').animate
                        opacity: 1
                        duration: 500
                        complete: => @go(location.pathname, true)
                
        checkLoggedIn: () ->
            return unless (@user = @cookies.get('user'))?
            
            if @el.hasClass('logged_out')
                @go(location.pathname, true)
            
            @$('.user_name').html(@user.name)
            
            try  
                pageTracker = _gat._getTracker("UA-15570848-11"); 
                pageTracker._trackPageview(); 
                pageTracker._setVar(@user.email or @user.id); 
            catch e
            
            window.onbeforeunload = null
        
        
        initEmailSubscription: ->
            container = $('.email_subscription_form')
            submitEmail = =>                
                email =  $(container.find('input').map(((a) -> a), ((a) -> $(a).val().length))[0]).val()
                
                if not email.length
                    container.find('.submit_feedback').data('form-button').error()
                    return
                    
                $.ajaj
                    url: '/api/email'
                    method: 'POST'
                    headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                    data: email: email
                    success: () =>
                        container.find('.submit_feedback').data('form-button').success()
                        setTimeout((-> 
                            container.animate
                                opacity: 0
                                duration: 500
                                complete: -> 
                                    container.html("<p class='success'>Success. We'll send updates to #{email}.</p>")
                                    container.animate(opacity: 1, duration: 500)    
                        ), 1000)
                    error: =>
                        container.find('.submit_feedback').data('form-button').error()

            container.find('input').bind 'keypress', (e) => submitEmail() if e.keyCode == 13
            container.find('.subscribe_button').bind 'click', () => submitEmail()
    
                    
            
