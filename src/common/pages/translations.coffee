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
            @html = wings.renderTemplate(@template, @incomplete or {})
        
soma.views
    Translations:
        selector: '#content .translations'
        create: ->
            $('.register_flag').hide()    
            @initShowSection()
            @initSaveButtons()
            @initDatas()
            @initVerification()
            @initForeignNative()
            @$('.bulk_import_button').bind 'click', => @loadData()
            @setLanguage($(input), false) for input in @$('input[name=\'nativeLanguage\']')
        
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
                    
        initForeignNative: ->
            @$('input[name=\'foreignLanguage\']').bind 'keypress', (e) => @setLanguage($(e.currentTarget), true, e.charCode)
            @$('input[name=\'nativeLanguage\']').bind 'keypress', (e) => @setLanguage($(e.currentTarget), false, e.charCode)
        
        setLanguage: (input, foreign, charCode=null) =>
            language = (input.val() or '') + (String.fromCharCode(charCode) or '')
            if language.length
                upperCaseLanguage = language[0].toUpperCase() + language[1..]
                input.closest('form').find("span.#{if foreign then 'foreign' else 'native'}Language").html(upperCaseLanguage)            

        showSection: (sectionName) ->
            @$('#translation_container')[0].className = sectionName
            @loadNoTranslations() if sectionName in ['no_translation']
            @loadNoBundle() if sectionName in ['no_bundle']
            @loadNotNativeVerified() if sectionName in ['not_native_verified']
            @loadNotForeignVerified() if sectionName in ['not_foreign_verified']
            @loadBundleList() if sectionName in ['bundle_list']
                 
        saveNewTranslation: (button) ->
            form = $(button).closest('.form_container').find('form')
            dataHash = form.data('form').dataHash()
            @nativeLanguage = dataHash.nativeLanguage
            @foreignLanguage = dataHash.foreignLanguage
            @bundle = dataHash.bundle if dataHash.bundle?.length
            @bundleDescription = dataHash.bundleDescription if dataHash.bundleDescription?.length
            @bundleNextLevels = dataHash.bundleNextLevels if dataHash.bundleNextLevels?.length
            
            $.ajaj
                url: '/api/language_scramble/translations/save'
                method: 'POST'
                headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                data: dataHash
                success: (data) =>
                    @data = data
                    @clearForm(form)
                    $(button).data('form-button').success()
                    @updateIncomplete()
                    @[$(button).data('callback')]() if $(button).data('callback')
                failure: =>
                    @saveNewTranslation(button)
                    
        clearForm: (form) ->
            form.find('input').val('')
            nativeLanguage = form.find('input[name=\'nativeLanguage\']')
            nativeLanguage.val(@nativeLanguage)
            @setLanguage(nativeLanguage, false)
            foreignLanguage = form.find('input[name=\'foreignLanguage\']')
            foreignLanguage.val(@foreignLanguage)
            @setLanguage(foreignLanguage, true)
            form.find('input[name=\'bundle\']').val(@bundle)
            form.find('input[name=\'bundleDescription\']').val(@bundleDescription)
            form.find('input[name=\'bundleNextLevels\']').val(@bundleNextLevels)
                 
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
            translationArea = dataArea.closest('.translation_area')
            form = translationArea.find('.form_container')
            form.hide()
            dataArea.html('')
            for bundle in bundles
                do (bundle) =>
                    bundleLink = $(document.createElement('A'))
                    bundleLink.html(bundle)
                    bundleLink.bind 'click', => 
                        @latestBundle = bundle
                        @showTranslations(bundleLink.html()) 
                    dataArea.append(bundleLink)
                    
        showTranslations: (bundle) ->            
            bundleDataArea = @$('#translation_container .bundle_list .bundle_data')
            translationArea = bundleDataArea.closest('.translation_area')
            form = translationArea.find('.form_container')
            form.hide()
            @getBundle bundle, (bundleData) =>
                @bundle = bundleData.name
                @bundleDescription = bundleData.description
                @bundleNextLevels = JSON.stringify(bundleData.nextLevels)
                bundleDataArea.show()
                bundleDataArea.html('')
                for translationId in bundleData.translations
                    do (translationId) =>
                        translationLink = $(document.createElement('A'))
                        translationLink.html(translationId)
                        translationLink.bind 'click', =>
                            bundleDataArea.hide()
                            form.show()
                            @displayTranslation(translationArea, translationId)
                        bundleDataArea.append(translationLink)
         
        backBundleList: ->
            if @latestBundle 
                @showTranslations(@latestBundle)      
            else
                @loadBundleList()
                
        displayBundles: (bundles) ->
            return unless bundles?.length
            dataArea = @$('#translation_container .no_bundle .bundles')
            dataArea.html('')
            for bundle in bundles
                dataArea.append("<a>#{bundle.split(/\//)[1].replace(/_/g, ' ')}</a>")
            @initBundles()
            
        setBundle: (bundle) ->
            @$('#translation_container .no_bundle input[name=\'bundle\']').val(bundle)         
                    
        loadNoTranslations: ->
            @loadIncompleteTranslations => @displayNoTranslations()
            
        loadNoBundle: ->
            @loadBundles =>
                @loadIncompleteTranslations => 
                    @displayTranslation(@$('#translation_container .no_bundle'), @data.noBundle[0]) if @data.noBundle?.length
                    
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
                if input.name == 'nativeLanguage' and not data.nativeLanguage
                    $(input).val(@nativeLanguage)
                    @setLanguage($(input), false)
                if input.name == 'foreignLanguage' and not data.foreignLanguage
                    $(input).val(@foreignLanguage)
                    @setLanguage($(input), true)
                if input.name == 'bundle' and not data.bundle
                    $(input).val(@bundle)
                if input.name == 'bundleDescription' and not data.bundleDescription
                    $(input).val(@bundleDescription)
                if input.name == 'bundleNextLevels' and not data.bundleNextLevels
                    $(input).val(@bundleNextLevels)
         
        loadData: ->
            @dataToLoad = []
            eval(@$('.bulk textarea').val())
            for languages of data
                for level of data[languages].levels
                    bundle = data[languages].levels[level]
                    for translation in bundle.data
                        @dataToLoad.push(
                            nativeLanguage: languages.split('_')[0]
                            foreignLanguage: languages.split('_')[1]
                            bundle: bundle.title
                            bundleDescription: bundle.subtitle
                            bundleNextLevels: JSON.stringify(bundle.nextLevels)
                            native: translation.native
                            foreign: translation.foreign
                            nativeSentence: translation.nativeSentence
                            foreignSentence: translation.foreignSentence
                        )
            @pushLoadedData()
        
        pushLoadedData: ->        
            if not @dataToLoad?.length       
                @$('.bulk textarea').val('')
                @$('.bulk_import_button').data('form-button').success()
                return
                
            formContainer = @$('#translation_container .new_translation .form_container')
            @fillInTranslationForm(formContainer, @dataToLoad.pop())
            @$('#translation_container .new_translation .save_button').trigger('click')
          
             
soma.routes
    '/translations': -> new soma.chunks.Translations
    
    
