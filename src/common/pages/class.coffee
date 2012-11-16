soma = require('soma')
wings = require('wings')

soma.chunks
    Class:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@id}) ->            
            @template = @loadTemplate '/build/common/templates/class.html'
            if @id
                @loadData 
                    url: "/api/classes/info/#{@id}"
                    success: (data) =>
                        @classInfo = data
                    error: () =>
                        if window?.alert
                            alert('We were unable to load the information for this class. Please check your internet connection.')
                

        build: () ->
            @setTitle("Your Class - The Puzzle School")
            @html = wings.renderTemplate(@template,
                id: @classInfo?.id
                className: @classInfo?.name or 'New Class'
            )
        
soma.views
    Class:
        selector: '#content .class'
        create: ->
            $('.register_flag').hide()    

            @form = @$('form')
            
            @form.bind 'submit', (e) =>
                e.stop()
                @save()

            @$('.save_button').bind 'click', (e) =>
                e.stop()
                @save()
                
            @$('.cancel_button').bind 'click', (e) => 
                e.stop()
                @go('/')

        save: ->
            dataHash = @form.data('form').dataHash()
            dataHash.id = @el.data('id')
            $.ajaj
                url: '/api/classes/update'
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: dataHash
                success: (classInfo) =>
                    @go("/class/#{classInfo.id}")
                
            
            
            
soma.routes
    '/class': -> new soma.chunks.Class
    '/class/:id': (data) -> new soma.chunks.Class(id: data.id)
