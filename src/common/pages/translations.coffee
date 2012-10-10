soma = require('soma')
wings = require('wings')

soma.chunks
    Translations:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: () ->            
            @template = @loadTemplate '/build/common/templates/translations.html'
            @loadData 
                url: '/api/language_scramble/translations/incomplete'
                success: (@incomplete) =>
                    @incomplete.noTranslationCount = @incomplete.noTranslation?.length or 0
                    @incomplete.noBundleCount = @incomplete.noBundle?.length or 0
                    @incomplete.notNativeVerifiedCount = @incomplete.notNativeVerified?.length or 0
                    @incomplete.notForeignVerifiedCount = @incomplete.notForeignVerified?.length or 0

        build: () ->
            @setTitle("Translations - The Puzzle School")
            @html = wings.renderTemplate(@template, @incomplete)
        
soma.views
    Translations:
        selector: '#content .translations'
        create: ->
            $('.register_flag').hide()    
            @initShowSection()
            @initSaveButtons()
            @initNoTranslation()
        
        initShowSection: ->
            for link in @$('.show_translation')
                do (link) =>
                    @registerHashChange link.id, => @showSection(link.id)
                    @$(link).bind 'click', => 
                        location.hash = link.id
                        @loadNoTranslations() if link.id in ['no_translation']
                        @loadNoBundle() if link.id in ['no_bundle']

        initSaveButtons: ->
            for button in @$('.save_button')     
                do (button) => $(button).bind 'click', => 
                    @saveNewTranslation(button)     

        initNoTranslation: ->
            for noTranslation in @$('.no_translations a')
                do (noTranslation) => $(noTranslation).bind 'click', => 
                    @displayNoTranslation(noTranslation)   
                    
        initBundles: ->
            for bundle in @$('.bundles a')
                do (bundle) => $(bundle).bind 'click', => 
                    console.log(bundle)
                    @setBundle($(bundle).html())   
            
        
        showSection: (sectionName) ->
            @$('#translation_container')[0].className = sectionName
                 
        saveNewTranslation: (button) ->
            form = $(button).closest('.translation_area').find('form')
            $.ajaj
                url: '/api/language_scramble/translations/save'
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: form.data('form').dataHash()
                success: (data) =>
                    @data = data
                    form.find('input').val('')
                    $(button).data('form-button').success()
                    @updateIncomplete()
                    @[$(button).data('callback')]() if $(button).data('callback')
                 
        loadIncompleteTranslations: (callback) ->
            $.ajaj
                url: '/api/language_scramble/translations/incomplete'
                method: 'GET'
                success: (data) =>
                    @data = data
                    callback()

        loadBundles: (callback) ->
            $.ajaj
                url: '/api/language_scramble/bundles'
                method: 'GET'
                success: (bundles) =>
                    @displayBundles(bundles)
                    callback()
                    
        displayBundles: (bundles) ->
            return unless bundles?.length
            @$('.bundles').html('')
            for bundle in bundles
                @$('.bundles').append("<a>#{bundle}</a>")
            @initBundles()
            
        setBundle: (bundle) ->
            console.log(bundle)
            @$('.bundles').closest('.translation_area').find('input[name=\'bundle\']').val(bundle)         
                    
        loadNoTranslations: ->
            @loadIncompleteTranslations => @displayNoTranslations()
            
        loadNoBundle: ->
            @loadBundles =>
                @loadIncompleteTranslations => 
                    @displayNoBundle()

        updateIncomplete: ->    
            @$('.no_translation_count').html("#{@data.noTranslation?.length or 0}")
            @$('.no_bundle_count').html("#{@data.noBundle?.length or 0}")
            @$('.not_native_verified_count').html("#{@data.notNativeVerified?.length or 0}")
            @$('.not_foreign_verified_count').html("#{@data.notForeignVerified?.length or 0}")
            
        displayNoBundle: ->
            $.ajaj
                url: "/api/language_scramble/translation/#{@data.noBundle[0]}"
                method: 'GET'
                success: (translation) =>
                    @fillInTranslationForm(@$('.no_bundle .form_container'), translation) 
            
        displayNoTranslations: ->
            return unless @data.noTranslation
            @$('.no_translations').html('')
            for noTranslation in @data.noTranslation
                @$('.no_translations').append("<a>#{noTranslation}</a>")
            @initNoTranslation()

        displayNoTranslation: (element) ->
            formContainer = $(element).closest('.translation_area').find('.form_container')
            formContainer.css('display', 'block')
            data = JSON.parse($(element).html())
            @fillInTranslationForm(formContainer, data)

        fillInTranslationForm: (formContainer, data) ->
            for input in formContainer.find('input')
                $(input).val(data[input.name])
                $(input).val(JSON.stringify(data)) if input.name == 'noTranslation'
             
soma.routes
    '/translations': -> new soma.chunks.Translations
