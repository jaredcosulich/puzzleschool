soma = require('soma')
wings = require('wings')

soma.chunks
    Puzzles:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({}) ->
            @template = @loadTemplate '/build/common/templates/puzzles.html'

        build: () ->
            @setTitle("Puzzles - The Puzzle School")
            @html = wings.renderTemplate(@template, labs: LABDATA, other: OTHERDATA)
        
soma.views
    Puzzles:
        selector: '#content .puzzles'
        create: ->
            $('.register_flag').hide()    
            
            @$('.rating p').bind 'click', (e) => @showSection(e.currentTarget)
            
        showSection: (navElement) ->
            @$('.rating p.selected').removeClass('selected')
            selected = navElement.className.replace(/\s/ig, '')
            $(navElement).addClass('selected')
            @$('.explanation.selected').removeClass('selected')
            @$(".explanation.#{selected}").addClass('selected')
                    

soma.routes
    '/labs': -> new soma.chunks.Puzzles
    '/puzzles': -> new soma.chunks.Puzzles

LABDATA = [{
    id: 'circuitous'
    title: 'Circuitous'
    website: '/puzzles/circuitous'
    thumbnail: '/assets/images/reviews/circuitous.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Electrical Circuits'
    availability: 'Web'
    cost: 'Free'
    explanation:
        """
        <p>
            With Circuitous we're exploring a hybrid approach. Circuitous has a full-featured circuit simulator
            that allows you to explore any circuit configuration you want, along with dozens of challenges to
            walk you through the basics of circuits. We've also included a video with each level to help explain
            what is going on.
        </p>
        <p>
            The key philosophy behind Circuitous is to try and make it as effective as possible for people to learn
            about circuits. The combination of simulator with challenges and explantory videos creates a learning
            environment that is enjoyable to use because you can feel yourself figuring it out, confirmed by the
            explanatory videos.
        </p>
        """
},{
    id: 'code'
    title: 'Code Puzzles'
    website: '/puzzles/code'
    thumbnail: '/assets/images/reviews/code.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Programming'
    availability: 'Web'
    cost: 'Free'
    explanation:
        """
        <p>
            Code Puzzles is our attempt to make learning how to program (code) more interesting, engaging,
            and really just more like what it feels like to be a professional programmer.
        </p>
        <p>
            Code Puzzles presents numerous challenges that you solve by writing code.
        </p>
        <p>
            You have access to a brief lesson and a few hints, but you're also encouraged to "google" for more
            information or even the solution to the challenge. As professional programmers we spend much
            of our day googling around, looking for elegant solutions to tricky problems and learning from
            those that have already wrestled with similar challenges.
        </p>
        """
},{
    id: 'xyflyer'
    title: 'XYFlyer'
    website: '/puzzles/xyflyer'
    thumbnail: '/assets/images/reviews/xyflyer.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Graphing Equations'
    availability: 'Web, Mobile, Tablet'
    cost: 'Free'
    explanation:
        """
        <p>
            We had a simple goal with XYFlyer. We wanted to make it easy and fun for anyone to understand
            the basics of equations and graphing.
        </p>
        <p>
            Equations and graphing don't sound like fun? Give it a try and see.
        </p>
        <p>
            We've created over 200 levels that get more and more challenging. 
            At the very least you'll gain a better visual intuition 
            about how equations graph out. You might actually find yourself enjoying it.
        </p>
        <p>
            If you want to play around with creating your own levels, try out the 
            <a href='/puzzles/xyflyer/editor'>Level Editor</a>.
        </p>
        """
},{
    id: 'language_scramble'
    title: 'Language Scramble'
    website: '/puzzles/language_scramble'
    thumbnail: '/assets/images/reviews/language_scramble.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Foreign Languages'
    availability: 'Web, Mobile, Tablet'
    cost: 'Free'
    explanation:
        """
        <p>Language Scramble is a simple puzzle meant to help people learn a new language (right now we just have Italian).</p>
        <p>
            You're presented with a foreign (in this case Italian) word and need to unscramble the letters to 
            form a correct translation in English.
        </p>
        <p>
            It's a little limited right now, focusing on traslation of written words, but has the potential
            to feature images and audio in the future. We're working to develop more levels and languages right now as well.
        </p>
        <p>
            It's also limited in its availability right now. Although it does work on iPhones and iPads, you have to have
            a connection to the internet for it to work, but we're working on fixing that as well.
        </p>
        """
}, {
    id: 'light_it_up'
    title: 'Light It Up'
    website: '/puzzles/light_it_up'
    thumbnail: '/assets/images/reviews/light_it_up.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Fractions'
    availability: 'Web, Mobile, Tablet'
    cost: 'Free'
    explanation:
        """
        <p>
            Light It Up was inspired by the fractions game,
            <a href='/reviews'>Refraction</a>,
            developed by the University of Washington's Center for Game Science.
        </p>
        <p>
            While we loved Refraction, we wanted to make a few changes. 
        </p>
        <ul>
            <li>
                We wanted to create puzzles that would teach students fractions more directly,
                so we reduced the number of obstacles in our levels, making the puzzles more about the
                fractions than the obstacles.
            </li>
            <li>
                We created a <a href='/puzzles/light_it_up/editor' target='_blank'>level editor</a> 
                that allows teachers to easily create custom levels to teach
                a specific fraction-based idea. The level editor also allows students to create their own
                puzzles, improving their mastery of fractions while creating puzzles as well as solving puzzles.
            </li>
            <li>
                We wanted to add in a feature that would walk you through the solution to the puzzle if
                you got stuck. We wanted to make the game more about learning then about solving the
                puzzles, so we focused on creating more levels with the ability to get help on any level
                that is too hard.
            </li>
            <li>
                We wanted to be able to track students as they progress through levels so that we can
                determine if a level is appropriately challenging and improve it if it is not. If you are
                interested in using these tracking features (how long a student spends on a puzzle, how many
                moves they make, whether they complete it or not), let us know.
            </li>
            <li>
                We wanted to developer the program in html and javascript so that it could more easily
                be ported to a native mobile application.
            </li>
        </ul>
        <p>
            Light It Up is still a work in progress, so beware that it may be buggy.
        </p>
        <p>
            You can try creating your own levels with the 
            <a href='/puzzles/light_it_up/editor' target='_blank'>Level Editor</a>.
            Just click on a block on the board to add pieces of your puzzle to the board.
        </p>
        """
}]        

OTHERDATA = [{
    id: 'architect'
    title: 'Architect'
    website: '/puzzles/architect'
    thumbnail: '/assets/images/reviews/architect.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Spatial Skills'
    availability: 'Mobile, Tablet'
    cost: '$0.99'
    explanation:
        """
        <p>
            Architect is not an educational puzzle. It can help develop spatial skills, which have been shown to
            <a href='http://medicalxpress.com/news/2012-07-spatial-skills.html' target='_blank'>improve performance in STEM subjects</a>,
            but does not approach any other educational material.
        </p>
        <p>
            We built Architect to provide a fun starting point for anyone exploring learning through puzzles.
            It is meant to be more fun than educational, but does provide an opportunity to work on spatial skills
            and working memory that can be valuable when trying to solve more educational puzzles.
        </p>
        <p>
            Architect was inspired by Tetris, but was changed to minimize the somewhat stressful aspect of increasingly
            fast falling blocks, making the game more about arranging the pieces to complete the puzzle then about the speed
            with which the pieces are dropping. Along these lines we also added in the pause feature and the ability to
            reorganize any piece at any time.
        </p>
        <p>
            Architect was also built for touchscreens, making the experience a little more tactile than the original Tetris.
            You actually have to grab and move pieces in order to position them.
        </p>
        <p>
            Again Architect is more for fun than our other educational puzzles. We do think there are some educational
            benefits such as developing spatial skills, but we are not promoting it as an educational puzzle.
        """
}, {
    id: 'peanutty'
    title: 'Peanutty!'
    website: 'http://peanutty.org'
    thumbnail: 'http://peanutty.org/src/client/images/simple_bucket.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Programming'
    availability: 'Web (Chrome only)'
    cost: 'Free'
    explanation:
        """
        <p>
            Peanutty! is an experiment in teaching people how to code.
        </p>
        <p>
            People can solve physics-based puzzles sort of like Angry Birds, while watching their actions create code.
        </p>
        <p>
            Once people realize that their actions are creating code they can start to tweak the code and see what happens.
        </p>
        <p>
            Small tweaks lead to larger and larger tweaks until they are capable of designing their own Peanutty levels.
        </p>    
        <p>
            Unfortunately Peanutty! is still a little too hard for most people to engage with for long enough to truly learn 
            how to code, but we think it has the potential to become a great puzzle-like environment for learning to program.
        </p>
        """
}, {
    id: 'upside_down_academy'
    title: 'Upside Down Academy'
    website: 'http://upsidedownacademy.org'
    thumbnail: '/assets/images/reviews/upsidedownacademy.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'All Subjects'
    availability: 'Web'
    cost: 'Free'
    explanation:
        """
        <p>Upside Down Academy isn't a puzzle in itself, but it can help turn any lesson in to a puzzle.</p>
        <p>
            The act of creating something is the ultimate puzzle. Trying to teach someone what ever you have just learned 
            forces you to take look at your learning from the puzzle perspective, analyzing it to figure out the patterns
            that will allow you to teach it to someone else.
        </p>
        <p>
            It takes advantage of the very effective 
            <a href='http://ideas.time.com/2011/11/30/the-protege-effect/' target='_blank'>"Protégé Effect"</a> 
            where teaching material to another person actually helps the teacher learn the material in a very effective manner.
        </p>
        <p>Upside Down Academy provides a place for people to post the lessons they've created where others can see and benefit from them.</p>        
        <p>
            At the end of the day, unfortunately it is unlikely that a student would choose to create a lesson on Upside Down
            Academy unless they are required to do so, which goes against one of the main tenants of The Puzzle School.
        </p>
        """
}]


    