line = require('line')
soma = require('soma')
wings = require('wings')

soma.chunks
    Base:
        shortMonths: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

        prepare: ({@content}) ->
            @setIcon('/assets/images/favicon.ico')
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
                years: [((new Date).getFullYear() - 1)..1900]
            
            @html = wings.renderTemplate(@template, data)
