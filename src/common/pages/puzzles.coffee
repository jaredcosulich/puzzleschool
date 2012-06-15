soma = require('soma')
wings = require('wings')

soma.chunks
    Puzzles:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({}) ->
            @template = @loadTemplate '/build/common/templates/puzzles.html'

        build: () ->
            @setTitle("Puzzles - The Puzzle School")
            @html = wings.renderTemplate(@template, reviews: REVIEWDATA, labs: LABDATA)
        
soma.views
    Puzzles:
        selector: '#content .puzzle'
        create: ->
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



REVIEWDATA = [{
    title: 'DragonBox'
    website: 'http://dragonboxapp.com/'
    thumbnail: '/assets/images/reviews/dragonbox.jpg'
    company: 'We Want To Know'
    companyWebsite: 'http://wewanttoknow.com'
    material: 'Math, Algebra'
    availability: 'Mobile, Tablet'
    cost: '$2.95 - $5.95'
    overall:
        rating: 4.4
        explanation:
            """
            <p>DragonBox is one of the best apps I've seen for teaching algebra.</p>
            <p>
                They've done a great job of focusing on the puzzle-like aspects of algebra,
                starting with puzzles using colorful icons that are solved like an algebra equation before
                transitioning to equations.
            </p>
            <p>
                The app focuses on solving algebraic equations and does an excellent job of communicating
                both the techniques and the strategies involved with very little instruction. 
            </p>
            <p>
                Unfortunately like most algebraic teaching, the usefulness of algebra is not explored.
                The strategies to solve problems are very effectively taught, but the connection to the real world is ignored.
            </p>
            <p>
                Still the app does a great job of making math feel like an engaging, interesting, and challenging puzzle, as it should.
                It does a good job of giving students a taste of what it feels like to be a professional mathematician.
            </p>
            """
    loveOfLearning:
        rating: 5
        explanation:
            """
            <p>I score DragonBox highly on the "love of learning" scale.</p>
            <p>
                It does an excellent job of making math feel like a puzzle, which is how it feels
                for those who do it professionally. It focuses on the pattern matching that is at the heart
                of professional mathematics.
            </p>
            <p>
                Basically I feel confident that DragonBox is going to increase a student's appreciation
                for math, making it feel more fun and interesting. It's very likely that a student will
                walk away wanting to learn more math.
            </p>
            """
    intuitive:
        rating: 4
        explanation:
            """
            <p>I can't quite give DragonBox 5 stars in the intuitive category, but it's still a very intuitive game.</p>
            <p>The main problem is that the rules seem so arbitrary at first and you're not quite certain why things work they way they do.</p>
            <p>At times it was a bit confusing for me, but I was able to get through it and, once the rules are laid out, it's generally smooth sailing.</p>
            <p>I would imagine most students would be able to work it out, but some may get confused.</p>
            <p>It is still a very intuitive game, definitely more intuitive then a lot of apps.</p>
            """
    engagement:
        rating: 5
        explanation:
            """
            <p>They've done a great job making DragonBox very engaging.</p>
            <p>
                It may not be as engaging as other video games or even something simple like Angry Birds, 
                but it is definitely on the top of the list with regard to educational apps.
            </p>
            <p>
                The best part is that they don't resort to using speed or competition to maintain the engagement,
                just good puzzle mechanics. You have a few simple rules and you have to solve increasingly difficult
                algebraic challenges. It may not sound engaging, but that's the engagement that we really believe in here
                at The Puzzle School.
            </p>            
            """
    practicality:
        rating: 4
        explanation:
            """
            <p>
                DragonBox is a very practical app. Although they do a good job of disguising the arcane looking algebraic equations
                until you're a little further in to the game, they never deviate from the general ideas required to solve equations.
            </p>
            <p>
                There is very little that is artificial or unneccessary in DragonBox. It sticks to the content, presenting it in a 
                way that makes it feel like an engaging puzzle, and we appreciate it for that.
            </p>
            <p>
                The only knock I have against it is that it fails to demonstrate how to actually use algebra in real life. It is
                focused entirely on solving equations, which is certainly a useful skill, but you might walk away from DragonBox
                with no idea of how to use the skill you just learned outside of the game. That's a shame, but not the end of the world.
            </p>
            <p>
                Hopefully they'll build out some more advanced levels that start to use the equation solving skills in more practical
                situations, but, even if they don't, the game does a good enough job of making the equation solving skill fun that it's
                likely that a student will figure out how to apply the skill themself once the game is complete.
            """
    accessibility:
        rating: 4
        explanation:
            """
            <p>The app is available on IOS (iPhone) and Android phones as wel as the iPad.</p>
            <p>
                That should make it accessible to most people, but I would still prefer to see if available on the web for people
                who don't have an iPad and don't want to squint at their phone all the time.
            </p>
            <p>
                Still the game was clearly designed with a small screen in mind and it works very effectively on the iPhone.
            </p>
            <p>
                The cost could be a little bit lower, but most people should be able to afford the $2.99 price tag. There's
                also a more advanced program at the $5.95 price point, which is a little annoying, but still quite affordable.
            </p>
            """
    articles: 
        """
            <p><a href='http://www.wired.com/geekdad/2012/06/dragonbox/all/' target='_blank'>DragonBox: Algebra Beats Angry Birds</a></p>
            <p><a href='http://jaredcosulich.wordpress.com/2012/06/13/dragonbox-algebra-meets-angry-birds/' target='_blank'>DragonBox - Algebra Meets Angry Birds</a></p>
            <p><a href='http://jaredcosulich.wordpress.com/2012/06/13/dragonbox-misses-the-why/' target='_blank'>DragonBox Misses The Why</a></p>
            <br/><br/><br/><br/><br/><br/>
        """
}]

LABDATA = [{
    title: 'Language Scramble'
    website: '/puzzles/language_scramble'
    thumbnail: '/assets/images/reviews/language_scramble.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Foreign Languages'
    availability: 'Web, Mobile, Tablet'
    cost: 'Free'
    overall:
        rating: '4 Stars'
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
    loveOfLearning:
        rating: 4
        explanation:
            """
            <p>Language Scramble makes learning a foreign language feel like a crossword puzzle. From our perspective that's a big win.</p>
            <p>
                In our user tests so far people of all ages have sat down with the game and solved dozens
                of puzzles with no prodding.
            </p>
            <p>
                The game doesn't quite make you feel like an expert (a native speaker), but it would be very difficult if not impossible
                to achieve that with language learning. It does however make learning a language feel like an enjoyable and engaging experience
                rather than hard work.
            </p>
            <p>
                I can't really say that a student will walk away from Language Scramble wanting to learn more about languages. So it's
                not really fostering a love of learning, but it is making learning that is usually very challenging more enjoyable.
            </p>
            """
    intuitive:
        rating: 5
        explanation:
            """
            <p>
                When tested on middle school students the students were able to engage with Language Scramble immediately with no
                explanation.
            </p>
            <p>
                We have seen some adults struggle with it a bit, but generally speaking most people are able to figure it out
                with little to no help. Also there is very little instruction in the game required to get going.
            </p>
            <p>Generally speaking Language Scramble is about intuitive as it gets.</p>
            """
    engagement:
        rating: 4
        explanation:
            """
                <p>
                    Although people seem to engage with Language Scramble right away and solve numerous puzzles with no encouragement
                    (the students we worked with used it for more than half an hour without any sign of boredom or distraction),
                    we generally are not seeing people come back time and time again to learn more.
                </p>
                <p>
                    This may be due, in part, to both the lack of levels (there are only 6 so far and only in Italian), and the lack of
                    accessibility. Even though the game is available on most smart phones through the web browser, it has not yet been finely
                    tuned to work on phones and is not available in any app store. So in order to come back you would need to type in the URL
                    and sign in to the site.
                </p>
                <p>
                    In the future we'll have more levels, more languages, and we'll be making it available in all app stores for easier
                    accessibility. Hopefully that will make it easier for people to reengage with the learning after the first experience.
                </p>
                <p>
                    For now, though, we're very happy to see people engaging with such a minimal app. There's no speed, no competition,
                    just the language learning content. The puzzle dynamics are solid and the feedback loops are tight with immediate
                    feedback each step of the way. We're a big fan of minimal apps that engage effectively without the use of a lot of
                    bells and whistles (badges, bright colors, exciting rewards, etc).
                </p>
            """
    practicality:
        rating: 4
        explanation:
            """
            <p>Coming soon...</p><br/><br/><br/><br/><br/><br/><br/><br/><br/>
            """
    accessibility:
        rating: 3
        explanation:
            """
            <p>Coming soon...</p><br/><br/><br/><br/><br/><br/><br/><br/><br/>
            """
}, {
    title: 'Peanutty!'
    website: 'http://peanutty.org'
    thumbnail: 'http://peanutty.org/src/client/images/simple_bucket.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'Programming'
    availability: 'Web (Chrome only)'
    cost: 'Free'
    overall:
        rating: '3.2 Stars'
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
    loveOfLearning:
        rating: 3
        explanation:
            """
            <p>Coming soon...</p><br/><br/><br/><br/><br/><br/><br/><br/><br/>
            """
    intuitive:
        rating: 3
        explanation:
            """
            <p>Coming soon...</p><br/><br/><br/><br/><br/><br/><br/><br/><br/>
            """
    engagement:
        rating: 3
        explanation:
            """
            <p>Coming soon...</p><br/><br/><br/><br/><br/><br/><br/><br/><br/>
            """
    practicality:
        rating: 5
        explanation:
            """
            <p>Coming soon...</p><br/><br/><br/><br/><br/><br/><br/><br/><br/>
            """
    accessibility:
        rating: 2
        explanation:
            """
            <p>Coming soon...</p><br/><br/><br/><br/><br/><br/><br/><br/><br/>
            """
}, {
    title: 'Upside Down Academy'
    website: 'http://upsidedownacademy.org'
    thumbnail: '/assets/images/reviews/upsidedownacademy.jpg'
    company: 'The Puzzle School'
    companyWebsite: 'http://puzzleschool.com'
    material: 'All Subjects'
    availability: 'Web'
    cost: 'Free'
    overall:
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
    