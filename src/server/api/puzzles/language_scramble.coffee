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

            (bundles) => @send(bundles?.bundleList or [])

        
    '/api/language_scramble/translations/save': () ->
        translation = {}
        translation.native = @data.native if @data.native?.length
        translation.foreign = @data.foreign if @data.foreign?.length
        translation.nativeSentence = @data.nativeSentence if @data.nativeSentence?.length
        translation.foreignSentence = @data.foreignSentence if @data.foreignSentence?.length

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
            translation.bundle = @data.bundle if @data.bundle?.length
            translation.nativeVerificationCount = @data.nativeVerificationCount if @data.nativeVerificationCount?.length
            translation.foreignVerificationCount = @data.foreignVerificationCount if @data.foreignVerificationCount?.length

            existingTranslation = null
            l.add => db.get 'language_scramble_translations', translation.id, l.wait()

            l.add (existing) =>
                existingTranslation = existing or {}
                if existingTranslation.native != translation.native or
                   existingTranslation.nativeSentence != translation.nativeSentence
                    translation.nativeVerificationCount = 0

                if existingTranslation.foreign != translation.foreign or
                   existingTranslation.foreignSentence != translation.foreignSentence
                    translation.foreignVerificationCount = 0

                incompleteUpdates.notNativeVerified = {}
                incompleteUpdates.notNativeVerified["#{if translation.nativeVerificationCount then 'delete' else 'add'}"] = [translation.id]

                incompleteUpdates.notForeignVerified = {}
                incompleteUpdates.notForeignVerified["#{if translation.foreignVerificationCount then 'delete' else 'add'}"] = [translation.id]

                db.update 'language_scramble_translations', translation.id, translation, l.wait()

            l.add =>
                if existingTranslation.bundle and existingTranslation.bundle != translation.bundle
                    bundleUpdate = {}
                    bundleUpdate["#{existingTranslation.bundle}"] = {delete: [translation.id]}
                    db.update( 
                        'language_scramble_translation_lists', 
                        'bundles', 
                        bundleUpdate, 
                        l.wait()
                    )
            
            l.add =>
                if not translation.bundle
                    incompleteUpdates.noBundle = {add: [translation.id]}                    
                else if existingTranslation.bundle != translation.bundle
                    incompleteUpdates.noBundle = {delete: [translation.id]}
                    bundleUpdate = {}
                    bundleUpdate["#{translation.bundle}"] = {add: [translation.id]}
                    bundleUpdate['bundleList'] = {add: [translation.bundle]}
                    db.update(
                        'language_scramble_translation_lists', 
                        'bundles', 
                        bundleUpdate,
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
                @sendError()
                
            => db.get 'language_scramble_translation_lists', 'incomplete', l.wait()
            
            (incomplete) => @send(incomplete)
            
        
        