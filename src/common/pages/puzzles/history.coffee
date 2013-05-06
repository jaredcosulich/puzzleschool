soma = require('soma')
wings = require('wings')

soma.chunks
    History:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/history.html"
            
            @loadStylesheet '/build/client/css/puzzles/history.css'     
            
        build: ->
            @setTitle("History Inquiry - The Puzzle School")
            
            @html = wings.renderTemplate(@template)
        
soma.views
    History:
        selector: '#content .history'
        create: ->
            @levelId = 'Battle of Fort Sumter'
            @level = LEVELS[@levelId]
            @level.description.question = @levelId
            
            @$('.title').html(@levelId)
            @$('.title').bind 'click', => @showAnswer(@level.description)
            @showAnswer(@level.description)
            
            @createQuestion(question, info) for question, info of @level.questions
            
        createQuestion: (questionText, info) ->
            info.question = questionText
            question = $(document.createElement('DIV'))
            question.addClass('question')
            question.html(questionText)

            question.bind 'click', => @showAnswer(info)
                
            @$('.navigation').append(question)
            
        showAnswer: ({question, image, answer}) ->
            details = @$('.answer')
            details.html('')
            details.append("<h3>#{question}</h3>")
            details.append("<img src='#{image}'/>") if image?.length
            details.append("<div>#{answer}</div>") if answer?.length
            
            $.timeout 10, =>
                if (delta = details.height() - @el.height() + 30) > 0 
                  img = details.find('img')
                  height = img.height()
                  width = img.width()
                  newHeight = height - delta
                  img.css
                    height: newHeight
                    width:  width * (newHeight / height)

soma.routes
    '/puzzles/history/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.History
            classId: classId
            levelId: levelId

    '/puzzles/history/:levelId': ({levelId}) -> 
        new soma.chunks.History
            levelId: levelId
    
    '/puzzles/history': -> new soma.chunks.History

LEVELS = 
    'Battle of Fort Sumter':
        description: 
            image: 'http://upload.wikimedia.org/wikipedia/commons/0/05/Sumter.jpg'
            answer: '''
            The Battle of Fort Sumter was the bombardment and surrender of Fort Sumter, 
            near Charleston, South Carolina, that started the American Civil War.
            '''
        questions:
            'What year did the battle take place?':
                image: 'http://upload.wikimedia.org/wikipedia/commons/d/d6/Attack_on_Fort_Sumter.jpg'
                answer: '''
                Beginning at 4:30 a.m. on April 12, the Confederates bombarded the fort from artillery batteries 
                surrounding the harbor. Although the Union garrison returned fire, they were significantly outgunned and, 
                after 34 hours, on April 14, the Union troops evacuated.
                '''
                questions:
                    'Who was president during the battle?':
                        image: 'http://en.wikipedia.org/wiki/File:Abraham_Lincoln_November_1863.jpg'
                        answer: '''
                        Althought Abraham Lincoln was president during the battle, he had been inaugurated just
                        one month earlier, on March 4. James Buchanan was president during the events that
                        led up to the battle.
                        '''
                    'What events preceded the battle?':
                        image: ''
                        answer: '''
                        ANSWER
                        '''
            'Why was Fort Sumter so important?':
                image: 'http://upload.wikimedia.org/wikipedia/commons/7/7e/Sumter1.gif'
                answer: '''
                South Carolina had recently declared secession from the Union and Fort Sumter dominated the entrance to 
                Charleston Harbor. Although it was unfinished, it was designed to be one of the strongest fortresses in 
                the world.
                '''
            'Who led the forces on each side during the battle?':
                image: 'http://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Pgt_beauregard.jpg/220px-Pgt_beauregard.jpg'
                answer: '''
                
                '''
            'How long did the battle last?': {}
            'What was the result of the battle?': {}
            
            
            
            
            
            
            
            
            
            
            
            
            