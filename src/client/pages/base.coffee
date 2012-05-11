soma = require('soma')
wings = require('wings')


class soma.View extends soma.View
    hashChanges: {}
    registerHashChange: (hash, callback) => @hashChanges[hash.replace(/#/, '')] = callback
    
soma.chunks
    Base:
        shortMonths: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        prepare: ({@content}) ->
            @loadElement 'link', {href: '/assets/images/favicon.ico', rel: 'shortcut icon', type: 'image/x-icon'}
            
            @loadScript '/build/client/pages/base.js'
            @loadScript '/build/client/pages/home.js'
            @loadScript '/build/client/pages/about.js'
            @loadScript '/build/client/pages/labs.js'

            @loadStylesheet '/build/client/css/all.css'
            
            @template = @loadTemplate '/build/client/templates/base.html'
            @loadChunk @content


        build: () ->
            @setTitle('The Puzzle School')
            data = 
                content: @content
                months: ({ label: @shortMonths[i-1], value: i } for i in [1..12])
                days: [1..31]
                years: [((new Date).getFullYear() - 18)..1900]
            
            @html = wings.renderTemplate(@template, data)
            
soma.views
    Base:
        selector: '#base'
        
        create: ->
            @logIn()
            
            $(window).bind 'hashchange', => @onhashchange()
            
            @registerHashChange 'register', => @register()
            @$('.register a').bind 'click', => location.hash = 'register'
            
            @$('.close_modal').bind 'click', (e) => @hideModal(e.currentTarget)
            
            @$('log_out').bind 'click', => @logOut()

            @onhashchange()

        onhashchange: () -> callback() if (callback = @hashChanges[location.hash.replace(/#/, '')])
                  
        formData: (form) ->
            data = {}
            fields = $('input, select', form)
            for field in fields
                if field.type not in ['radio', 'checkbox'] or field.checked
                    val = $(field).val()

                    if field.name.slice(-2) == '[]'
                        name = field.name.slice(0, -2)
                        if name not of data
                            data[name] = []

                        data[name].push(val)

                    else
                        data[field.name] = val
            return data
                  
                            
        register: () ->
            registrationForm = @$('.registration_form')
            registrationForm.css
                top: 120
                left: ($(document.body).width() - registrationForm.width()) / 2
            registrationForm.animate
                opacity: 1
                duration: 500

            @$('.registration_form').bind 'click', (e) => e.stopPropagation()
            $(window).bind 'click', () => @hideModal('.registration_form')
            @$('.registration_form .cancel_button').bind 'click', () => @hideModal('.registration_form')

            @$('.registration_form .register_button').bind 'click', () =>
                form = @$('.registration_form form')
                $.ajax
                    url: '/api/register'
                    method: 'POST'
                    data: @formData(form)
                    success: () => 
                        @hideModal(form)
                        @logIn()
                
        logOut: () ->
            @el.removeClass('logged_in')
            @el.addClass('logged_out')
            @$('.user_name').html('')
            @cookies.set('user', null)
                
        logIn: () ->
            return unless (@user = @cookies.get('user'))?
            @el.removeClass('logged_out')
            @el.addClass('logged_in')
            @$('.user_name').html(@user.name)
        
        hideModal: (selector) ->
            $(window).unbind 'click'
            modal = if selector instanceof String then @$(selector) else $(selector)
            modal = modal.closest('.modal') unless modal.hasClass('modal')
            modal.animate
                opacity: 0
                duration: 500
                complete: () =>
                    modal.css
                        top: -1000
                        left: -1000
                    # location.hash = ''
                    
            
            
                
