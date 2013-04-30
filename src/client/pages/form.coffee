soma = require('soma')

soma.views
    Form:
        selector: '#base form'
        create: ->
        dataHash: ->
            data = {}
            fields = @$('input, textarea, select')
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
            
    FormButton:
        selector: '#base .submit_feedback'
        create: -> 
            unless @message
                @message = $(document.createElement('SPAN'))
                @message.css(display: 'none')
                @message.insertAfter(@el)
                
            @el.unbind 'click.submit_feedback'
            @el.bind 'click.submit_feedback', =>
                @el.animate
                    opacity: 0
                    duration: 300
                    complete: =>
                        @el.css(display: 'none')
                        @message.css(display: 'inline', opacity: 0)
                        @message.addClass('submitting')
                        @message.html(@el.data('submitting_text'))
                        @message.animate
                            opacity: 1
                            duration: 300

        success: ->
            @message.animate
                opacity: 0
                duration: 300
                complete: =>
                    @message.removeClass('submitting')
                    @message.addClass('submitted')
                    @message.html(@el.data('submitted_text'))
                    @message.animate
                        opacity: 1
                        duration: 300
                        complete: =>
                            $.timeout 1000, => @revert()
          
        error: ->
            errorMessage = @el.data('failed_submission_text')
            alert(errorMessage)
            @revert()
              
        revert: ->
            @message.animate
                opacity: 0
                duration: 300
                complete: =>
                    @message.removeClass('submitting')
                    @message.removeClass('submitted')
                    @message.css(display: 'none')
                    @el.css(display: 'inline', opacity: 0)
                    @el.animate
                        opacity: 1
                        duration: 300
            