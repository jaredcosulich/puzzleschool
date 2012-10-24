Line = require('line').Line
soma = require('soma')
db = require('../lib/db')

{requireUser} = require('./lib/decorators')

soma.routes
    '/api/language_scramble/translation/:id': ({id}) ->
        l = new Line
            error: (err) => 
                console.log('Error locating translation:', err)
                @sendError()

            -> db.get 'language_scramble_translations', id, @wait()
            
            (translation) => @send(translation)
            
    '/api/language_scramble/bundles': ->
        l = new Line
            error: (err) => 
                console.log('Error retrieving bundles:', err)
                @sendError()

            -> db.get 'language_scramble_translation_lists', 'bundles', @wait()

            (bundles) => @send(bundles?.bundles or [])

    '/api/language_scramble/bundle/:languages/:bundleName': ({languages, bundleName}) ->
        l = new Line
            error: (err) => 
                console.log('Error retrieving bundles:', err)
                @sendError()

            -> db.get 'language_scramble_translation_bundles', "#{languages}/#{bundleName}", @wait()
            
            (bundle) => @send(bundle or {})

        
    '/api/language_scramble/translations/save': () ->
        translation = {}
        translation.nativeLanguage = @data.nativeLanguage if @data.nativeLanguage?.length
        translation.foreignLanguage = @data.foreignLanguage if @data.foreignLanguage?.length
        translation.native = @data.native if @data.native?.length
        translation.foreign = @data.foreign if @data.foreign?.length
        translation.nativeSentence = @data.nativeSentence if @data.nativeSentence?.length
        translation.foreignSentence = @data.foreignSentence if @data.foreignSentence?.length
        translation.nativeVerified = @data.nativeVerified if @data.nativeVerified?.length
        translation.foreignVerified = @data.foreignVerified if @data.foreignVerified?.length
        translation.bundle = @data.bundle if @data.bundle?.length
        bundleDescription = @data.bundleDescription if @data.bundleDescription?.length

        languages = "#{translation.nativeLanguage}-#{translation.foreignLanguage}"
        languageBundle = "#{languages}/#{translation.bundle.replace(/\s/g, '_')}" if translation.bundle

        l = new Line
            error: (err) => 
                console.log('Saving translation failed:', err)
                @sendError()
           
        translated = (translation.native and translation.foreign)
        incompleteUpdates = {noTranslation: {}}

        if not translated
            incompleteUpdates.noTranslation.add = [JSON.stringify(translation)]            
        else
            if @data.noTranslation
                incompleteUpdates.noTranslation.delete = [@data.noTranslation]             
            else
                delete incompleteUpdates.noTranslation
                
            translation.id = "#{@data.native.replace(/\W/g, '_')}-#{translation.foreign.replace(/\W/g, '_')}"
            existingTranslation = null
            l.add => db.get 'language_scramble_translations', translation.id, l.wait()

            l.add (existing) =>
                existingTranslation = existing or {}
                if existingTranslation.native != translation.native or
                   existingTranslation.nativeSentence != translation.nativeSentence
                    translation.nativeVerified = 0

                if existingTranslation.foreign != translation.foreign or
                   existingTranslation.foreignSentence != translation.foreignSentence
                    translation.foreignVerified = 0
                    
                incompleteUpdates.notNativeVerified = {}
                incompleteUpdates.notNativeVerified["#{if translation.nativeVerified then 'delete' else 'add'}"] = [translation.id]

                incompleteUpdates.notForeignVerified = {}
                incompleteUpdates.notForeignVerified["#{if translation.foreignVerified then 'delete' else 'add'}"] = [translation.id]

                if existingTranslation.bundle
                    existingLanguageBundle = "#{existingTranslation.nativeLanguage}-#{existingTranslation.foreignLanguage}/#{existingTranslation.bundle.replace(/\s/g, '_')}"

                db.update 'language_scramble_translations', translation.id, translation, l.wait()

            l.add =>
                if existingTranslation.bundle and existingTranslation.bundle != translation.bundle
                    db.update( 
                        'language_scramble_translation_bundles', 
                        existingTranslation.bundle, 
                        {translations: {delete: [translation.id]}}, 
                        l.wait()
                    )

            l.add (bundleInfo) =>
                if bundleInfo and bundleInfo.translations and not bundleInfo.translations.length
                    db.delete( 
                        'language_scramble_translation_bundles', 
                        existingLanguageBundle,
                        =>
                            db.update(
                                'language_scramble_translation_lists', {
                                    languages: {delete: [existingLanguageBundle]}
                                    'bundles': {delete: [existingLanguageBundle]}
                                },
                                l.wait()
                            )
                    )

            l.add =>
                if not translation.bundle
                    incompleteUpdates.noBundle = {add: [translation.id]}                    
                else if existingTranslation.bundle != translation.bundle or bundleDescription?.length
                    incompleteUpdates.noBundle = {delete: [translation.id]}
                    
                    bundleUpdate = 
                        name: translation.bundle
                        translations: {add: [translation.id]}
                    bundleUpdate.description = bundleDescription if bundleDescription?.length
                        
                    db.update(
                        'language_scramble_translation_bundles', 
                        languageBundle, 
                        bundleUpdate,
                        l.wait()
                    )                    

            l.add =>
                if translation.nativeLanguage and translation.foreignLanguage and translation.bundle
                    listUpdates = {}
                    listUpdates['languages'] = {add: [languages]}
                    listUpdates[languages] = {add: [languageBundle]}
                    listUpdates['bundles'] = {add: [languageBundle]}
                    db.update(
                        'language_scramble_translation_lists', 
                        'bundles', 
                        listUpdates,
                        l.wait()
                    )                    

        l.add =>
            db.update( 
                'language_scramble_translation_lists', 
                'incomplete',
                incompleteUpdates, 
                l.wait()
            )
    
        l.add (incompleteStats) => @send(incompleteStats)
        
    '/api/language_scramble/translations/incomplete': () ->        
        l = new Line
            error: (err) => 
                console.log('Unable to load incomplete translation data:', err)
                @send({})
                
            => db.get 'language_scramble_translation_lists', 'incomplete', l.wait()
            
            (incomplete) => @send(incomplete)
            
        
        