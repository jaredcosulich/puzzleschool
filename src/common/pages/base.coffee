soma = require('soma')
wings = require('wings')

class soma.View extends soma.View
    hashChanges: {}
    registerHashChange: (hash, callback) => @hashChanges[hash.replace(/#/, '')] = callback
        
soma.chunks
    Base:
        shortMonths: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        prepare: ({@content}) ->
            @setMeta('apple-mobile-web-app-capable', 'yes')
            @setMeta('apple-mobile-web-app-status-bar-style', 'black')

            @loadElement 'link', {href: '/assets/images/favicon.ico', rel: 'shortcut icon', type: 'image/x-icon'}
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
            @loadChunk @content


        build: () ->
            data = 
                loggedIn: @cookies.get('user')?
                content: @content
                months: ({ label: @shortMonths[i-1], value: i } for i in [1..12])
                days: [1..31]
                years: [((new Date).getFullYear() - 18)..1900]
            
            @html = wings.renderTemplate(@template, data)
            
soma.views
    Base:
        selector: '#base'
        
        create: ->
            unless window.initialized
                window.initialized = true
                window.postRegistration = []
                $(window).bind 'hashchange', => @onhashchange()
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
            
            @onhashchange()

        onhashchange: () -> callback() if (callback = @hashChanges[location.hash.replace(/#/, '')])
                  
        showRegistration: () ->
            @showModal('.registration_form')
            @$('.registration_form .cancel_button').bind 'click', () => @hideModal('.registration_form')

            submitForm = () =>
                form = @$('.registration_form form')
                $.ajaj
                    url: '/api/register'
                    method: 'POST'
                    data: form.data('form').dataHash()
                    success: () =>
                        @hideModal(form)
                        if window.postRegistration.length
                            (postRegistrationMethod => @checkLoggedIn()) for postRegistrationMethod in window.postRegistration
                        else
                            @checkLoggedIn()
                
            @$('.registration_form input').bind 'keypress', (e) => submitForm() if e.keyCode == 13
            @$('.registration_form .register_button').bind 'click', () => submitForm()
                
        showLogIn: () ->  
            @showModal('.login_form')
            @$('.login_form .cancel_button').bind 'click', () => @hideModal('.login_form')
            loginButton = @$('.login_form .login_button')
            loginButton.bind 'click', () =>
                form = @$('.login_form form')
                $.ajaj
                    url: '/api/login'
                    method: 'POST'
                    data: form.data('form').dataHash()
                    success: () => 
                        @hideModal(form)
                        @checkLoggedIn()
                    error: () => 
                        @$('.login_form .login_button').data('form-button').error()

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
        
        
        showModal: (selector) ->
            @opaqueScreen = $('.opaque_screen')
            @opaqueScreen.css(opacity: 0, top:0, left: 0, width: $(document.body).width(), height: $(document.body).height() + $('#top_nav').height())
            @opaqueScreen.animate
                opacity: 0.75
                duration: 300
                
            modal = @$(selector)
            modal.css
                top: 120
                left: ($(document.body).width() - modal.width()) / 2
            modal.animate
                opacity: 1
                duration: 500

            modal.bind 'click', (e) => e.stop()
            $(@opaqueScreen).bind 'click', () => @hideModal(selector)
        
        hideModal: (selector) ->
            $(@opaqueScreen).unbind 'click'
            modal = if selector instanceof String then @$(selector) else $(selector)
            modal = modal.closest('.modal') unless modal.hasClass('modal')
            @opaqueScreen.animate(opacity:0, duration: 500, complete: () => @opaqueScreen.css(top: -1000, left: -100))
            modal.animate
                opacity: 0
                duration: 500
                complete: () =>
                    modal.css
                        top: -1000
                        left: -1000
                    location.hash = ''
                    
            
