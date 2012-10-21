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
            @initDatas()
            @initVerification()
        
        initShowSection: ->
            for link in @$('.show_translation')
                do (link) =>
                    @registerHashChange link.id, => @showSection(link.id)
                    @$(link).bind 'click', => location.hash = link.id
                        

        initSaveButtons: ->
            for button in @$('.save_button')     
                do (button) => $(button).bind 'click', => 
                    @saveNewTranslation(button)     

        initDatas: ->
            for dataLink in @$('.data a')
                do (dataLink) => $(dataLink).bind 'click', => 
                    @displayData(dataLink)   
                    
        initBundles: ->
            for bundle in @$('.bundles a')
                do (bundle) => $(bundle).bind 'click', => 
                    @setBundle($(bundle).html())   
                    
        initVerification: ->
            for verifyButton in @$('.verify_button')
                do (verifyButton) => $(verifyButton).bind 'click', =>
                    form = $(verifyButton).closest('.form_container').find('form')
                    form.find('.verification_field').val('1')
                    @saveNewTranslation(verifyButton) 
                    

        
        showSection: (sectionName) ->
            @$('#translation_container')[0].className = sectionName
            @loadNoTranslations() if sectionName in ['no_translation']
            @loadNoBundle() if sectionName in ['no_bundle']
            @loadNotNativeVerified() if sectionName in ['not_native_verified']
            @loadNotForeignVerified() if sectionName in ['not_foreign_verified']
            @loadBundleList() if sectionName in ['bundle_list']
                 
        saveNewTranslation: (button) ->
            form = $(button).closest('.form_container').find('form')
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


        getBundleList: (callback) ->
            $.ajaj
                url: '/api/language_scramble/bundles'
                method: 'GET'
                success: (bundles) =>
                    callback(bundles)
                    
        getBundle: (name, callback) ->
            $.ajaj
                url: "/api/language_scramble/bundle/#{name}"
                method: 'GET'
                success: (bundle) =>
                    callback(bundle)

        loadBundles: (callback) ->
            @getBundleList (bundles) =>
                @displayBundles(bundles)
                callback()
                    
        loadBundleList: ->
            @getBundleList (bundles) =>
                @displayBundleList(bundles)

        displayBundleList: (bundles) ->
            return unless bundles?.length
            dataArea = @$('#translation_container .bundle_list .bundle_list')
            dataArea.html('')
            for bundle in bundles
                do (bundle) =>
                    dataArea.append("<a>#{bundle}</a>")
                    bundleLink = dataArea.lastChild
                    bundleLink.bind 'click', =>
                        
                    
        displayBundles: (bundles) ->
            return unless bundles?.length
            dataArea = @$('#translation_container .no_bundle .bundles')
            dataArea.html('')
            for bundle in bundles
                dataArea.append("<a>#{bundle}</a>")
            @initBundles()
            
        setBundle: (bundle) ->
            @$('#translation_container .no_bundle .data').closest('.translation_area').find('input[name=\'bundle\']').val(bundle)         
                    
        loadNoTranslations: ->
            @loadIncompleteTranslations => @displayNoTranslations()
            
        loadNoBundle: ->
            @loadBundles =>
                @loadIncompleteTranslations => 
                    @displayTranslation(@$('.no_bundle'), @data.noBundle[0])
                    
        loadNotNativeVerified: ->
            @loadIncompleteTranslations => 
                @displayNotNativeVerifieds()

        loadNotForeignVerified: ->
            @loadIncompleteTranslations => 
                @displayNotForeignVerifieds()

        updateIncomplete: ->    
            @$('.no_translation_count').html("#{@data.noTranslation?.length or 0}")
            @$('.no_bundle_count').html("#{@data.noBundle?.length or 0}")
            @$('.not_native_verified_count').html("#{@data.notNativeVerified?.length or 0}")
            @$('.not_foreign_verified_count').html("#{@data.notForeignVerified?.length or 0}")
            
        displayTranslation: (area, id) ->
            $.ajaj
                url: "/api/language_scramble/translation/#{id}"
                method: 'GET'
                success: (translation) =>
                    @fillInTranslationForm(area.find('.form_container'), translation) 
            
        displayNoTranslations: ->
            return unless @data.noTranslation
            dataArea = @$('#translation_container .no_translation .data')
            dataArea.html('')
            for noTranslation in @data.noTranslation
                dataArea.append("<a>#{noTranslation}</a>")
            @initDatas()
            @displayData(dataArea.find('a')[0])

        displayNotNativeVerifieds: ->
            dataArea = @$('#translation_container .not_native_verified .data')
            dataArea.html('')
            for notVerified in @data.notNativeVerified
                dataArea.append("<a>#{notVerified}</a>")
            @initDatas()
            @displayData(dataArea.find('a')[0])

        displayNotForeignVerifieds: ->
            dataArea = @$('#translation_container .not_foreign_verified .data')
            dataArea.html('')
            for notVerified in @data.notForeignVerified
                dataArea.append("<a>#{notVerified}</a>")
            @initDatas()
            @displayData(dataArea.find('a')[0])
            
        displayData: (element) ->
            area = $(element).closest('.translation_area')
            formContainer = area.find('.form_container')
            if (html = $(element).html()).indexOf('{') == 0
                data = JSON.parse(html)
                @fillInTranslationForm(formContainer, data)
            else
                @displayTranslation(area, html)

        fillInTranslationForm: (formContainer, data) ->
            for input in formContainer.find('input')
                $(input).val(data[input.name] or '')
                $(input).val(JSON.stringify(data)) if input.name == 'noTranslation'
             
soma.routes
    '/translations': -> new soma.chunks.Translations
