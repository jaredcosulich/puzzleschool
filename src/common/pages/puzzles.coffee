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
    material: 'Algebra'
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
            </p>
            """
    accessibility:
        rating: 4
        explanation:
            """
            <p>The app is available on IOS (iPhone) and Android phones as well as the iPad.</p>
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
}, {
    title: 'Refraction'
    website: 'http://games.cs.washington.edu/Refraction/'
    thumbnail: '/assets/images/reviews/refraction.jpg'
    company: 'UW Center for Game Science'
    companyWebsite: 'http://www.centerforgamescience.org'
    material: 'Fractions'
    availability: 'Web'
    cost: 'Free'
    overall:
        rating: 4.6
        explanation:
            """
            <p>
                Refraction is a fantastic website for teaching fractions.
            </p>
            <p>
                They've done a great job of creating puzzles that teach fractions directly, by dividing up and redirecting
                a laser to power various rocketships. The challenges are excellently produced, getting increasingly harder as you go
                and integrating more and more advanced concepts around fractions.
            </p>
            <p>
                It's free to use and online so easy to access. Really the only downside is that it's built in flash so not only is not
                available in any app store, but you can't use it on an iPhone or iPad.
            </p>
            <p>
                Still this is one of the best sites I've seen overall. Highly recommended. Hopefully they'll create a non-flash version
                soon. If not then we may try to do it for them.
            </p>
            """
    loveOfLearning:
        rating: 5
        explanation:
            """
            <p>
                No problems here. Refractions takes a reasonably challenging topic to understand and makes it engaging and fun
                to interact with. I think most students will walk away from the game with a great understanding of fractions
                and a hunger for more.
            </p>
            <br/><br/><br/>
            """
    intuitive:
        rating: 5
        explanation:
            """
            <p>
                It may be possible to make refraction a bit more intuitive, but it's already very high on the charts.
            </p>
            <p>
                Very little explanation is provided and I would imagine most students will be able to figure it out with
                little or no help.
            </p>
            <p>
                There's very little that students have to understand in refraction outside of how to manipulate fractions,
                which is exactly what we like to see.
            </p>
            """
    engagement:
        rating: 5
        explanation:
            """
            <p>
                Excellent engagement through puzzle mechanics. There are some bells and whistles that I might remove, but
                generally speaking it's all tastefully done and doesn't feel forced at all.
            </p>            
            <p>
                You're just solving fraction based puzzles and, despite that simplistic approach, the engagement is quite
                high. I've already been back to the site a few times just to solve a few more puzzles.
            </p>
            <br/><br/>
            """
    practicality:
        rating: 5
        explanation:
            """
            <p>
                Refraction offers an excellent, practical usage of fractions. Although there is this maze like quality
                to the puzzles, the focus is clearly on the fractions and you're working with them in a way that isn't
                artificial at all. You really need to use fractions to solve these puzzles.
            </p>
            <p>
                Even as someone who is very comfortable with fractions I was challenged figuring out how to get 1/9th and
                1/12th out of the same laser beam.
            </p>
            <p>
                At no point does it ever feel like fractions are being slapped on to another game. The story here is very
                coherent.
            <p>
            <br/><br/><br/>
            """
    accessibility:
        rating: 3
        explanation:
            """ 
            <p>
                This is the biggest problem with Refraction. Since it is built in flash it won't work on all platforms (namely
                iPhone or iPad) and it's not available in any app stores, so taking this on the road requires a laptop and
                an internet connection.
            </p>
            <p>
                I don't think it would be too hard for them to get this working in a way that is more accessible, though. In
                fact we might reach out to them to see if we can do it for them.
            </p>
            <br/><br/><br/><br/>
            """
}, {
    title: 'ST Math'
    website: 'http://web.stmath.com/'
    thumbnail: '/assets/images/reviews/stmath.jpg'
    company: 'MIND Research Institute'
    companyWebsite: 'http://www.mindresearch.net'
    material: 'Math'
    availability: 'Web'
    cost: '???'
    overall:
        rating: 3.8
        explanation:
            """
            <p>
                ST Math stands for Spatial Temporal Math. Basically it teaches a wide range of mathematical concepts 
                without language (no instructions at all), using puzzles that make it easy to learn through trial-and-error.
            </p>
            <p>
                The techniques are backed up by extensive research and have already shown significant success within schools.
                It is one of the most pure examples of puzzles that teach exclusively through trial and error. There are no instructions
                at all, even for the most complicated concepts.
            </p>
            <p>
                Basically we love it.
            </p>
            <p>
                Unfortunately, although the software is built for online distribution, you can't get access to more than a few
                samples without contacting the company. I think this is a real shame. I've contacted them trying to figure out
                why they don't make it more accessible, but for now it's unlikely you'll be able to use ST Math except in the
                classroom.
            </p>
            """
    loveOfLearning:
        rating: 5
        explanation:
            """
            <p>
                From everything I've seen ST Math will absolutely promote a love of learning and a curiosity about everything
                you can do with math. They're work is backed up by a great deal of research, presents puzzle after puzzle,
                teaching complicated mathematical concepts entirely through trial-and-error with no instrucions at all.
            </p>
            <p>
                I haven't seen all of their products, but everything I have seen is very well done and creatively tackles
                a huge range of subjects.
            </p>
            <br/><br/><br/>
            """
    intuitive:
        rating: 4
        explanation:
            """
            <p>
                ST Math's mission to teach without relying on language to provide instruction means it has to be intuitive to work.
            </p>
            <p>
                In my experiences with it I've found that they've achieved this goal most of the time, but that some of the programs
                are still a bit confusing. I hate to complain about it as they are tackling complex matchematical concepts with
                absolutely no instruction, but I still feel they have a little room to improve in this area.
            </p>
            <p>
                I'm guessing they will improve as they can't rely on the crutch of providing instruction. 
            </p>
            """
    engagement:
        rating: 5
        explanation:
            """
            <p>
                The engagement from ST Math is very high quality. Very few bells and whistles. The engagement comes entirely from
                the satisfaction of figuring out the answer without any instruction, learning new matchematical concepts through
                trial-and-error.
            </p>
            <p>
                I could imagine some engagement being diminished due to the occassional puzzle that is too difficult to figure out,
                but I already gave ST Math 4 stars for intuitiveness, so I'm going to leave engagement at 5 stars.
            </p>
            <br/><br/>
            """
    practicality:
        rating: 4
        explanation:
            """
            <p>
                A number of the puzzles I've seen are not as practical as they could be. Although they are teaching very practical
                mathematical concepts, the puzzles themselves tend to be disconnected from any way you would use the mathematical
                concepts in real life.
            <p>
            <p>
                It's not terrible, it's just not giving the student a real practical sense of how one would use the concepts outside
                of ST Math.
            </p>
            <br/><br/><br/>
            """
    accessibility:
        rating: 1
        explanation:
            """ 
            <p>
                This is by far the biggest problem with ST Math. Outside of a few examples and videos you can't actually use their 
                programs without contacting them. I'm not sure if there is a licensing fee or, if there is, how much it would cost,
                but the fact that there programs aren't more accessible is really too bad.
            </p>
            <p>
                I've reached out to them trying to figure out why they are taking this approach when students could be deriving so
                much more value from their software in and outside of school if it were more accessible.
            </p>
            <p>
                In the meantime you may want to talk to your school to recommend they check out ST Math, because, as far as I can tell
                you can't use it without going through a sales process.
            </p>
            <p>
                Real shame.
            </p>
            """
}, {
    title: 'Foldit'
    website: 'http://fold.it'
    thumbnail: '/assets/images/reviews/foldit.jpg'
    company: 'UW Center for Game Science'
    companyWebsite: 'http://www.centerforgamescience.org'
    material: 'Biochemistry'
    availability: 'Web'
    cost: 'Free'
    overall:
        rating: 3
        explanation:
            """
            <p>Foldit is crowd-sourced experiment that lets you try and figure out how to fold proteins to try and discover their optimal folded state.</p>
            <p>
                The puzzle is educational, but doesn't do the best job of providing enough context for someone to walk away with a better understanding
                of the biochemistry they are working with.
            </p>
            <p>
                The site has the great benefit that the puzzles you are solving are actually helping scientists discover cures for diseases such
                as AIDS. In fact, in 2011, players of Foldit helped to decipher the crystal structure of the Mason-Pfizer monkey virus (M-PMV) 
                retroviral protease, an AIDS-causing monkey virus. While the puzzle was available to play for a period of three weeks, 
                players produced an accurate 3D model of the enzyme in just ten days. The problem of how to configure the structure of the enzyme 
                had stumped scientists for 15 years [from <a href='http://en.wikipedia.org/wiki/Foldit' target='_blank'>Wikipedia</a>].
            </p>
            <p>
                Despite that enormously practical benefit of helping to cure AIDS and other diseases, Foldit is not the most practical experience
                for students. Although I'm sure the developers did the best job they could to make the site intuitive and fun, the mechanics
                are still quite clunky and I think it's unlikely that students will stick with it long enough to gain any significant educational
                benefit.
            </p>
            <p>
                I can't quite recommend it, but I do feel it would be a shame if someone didn't try it out based on my recommendation and actually
                loved it and went on to make a significant contribution to science, so maybe give it a shot with the expectation that it probably
                won't click as easily as I would hope.
            </p>
            """
    loveOfLearning:
        rating: 3
        explanation:
            """
            <p>
                Although the opportunity to truly help scientists discover more optimal protein-folding structure could
                really inspire a student to learn more about biochemistry and the uses for the work they do in Foldit,
                I think most students would walk away from Foldit a little discouraged due to the complex nature and lack
                of context in to what is going on.
            </p>
            <p>
                The site could do a better job of providing more context and learning around the puzzle-like elements
                so that students could gain a better understanding of what is going on. I think that would help students
                learn more through the site, become more excited about the science that they are playing with, and encourage
                them to come back for more later.
            <p>
                As it is, though, I can't rate it too highly. It is tempting to given it's actual real-world application, but
                just from playing it myself it relies too much on scores and didn't provide enough context for me to feel
                motivated to continue playing or curious to learn more about the underlying science.
            </p>
            """
    intuitive:
        rating: 3
        explanation:
            """
            <p>
                Foldit does a good job of walking you through the different manipulations you can do the proteins, making
                it relatively easy to advance through a few puzzles, but I never really felt all that comfortable with what I
                was trying to do.
            </p>
            <p>
                The complex nature of the puzzles you are trying to solve and the lack of context the site provides makes it
                feel quite frustrating at points when you can't quite manipulate the proteins in the way that you want, or that,
                when you do manipulate them correctly, you don't get the result you were expecting.
            </p>
            <p>
                A lot of people have been able to figure out Foldit and have gone on to solve very complex protein-folding puzzles,
                so I can't knock it too much, but compared to other educatonal resources, I don't think Foldit is nearly intuitive enough
                to just drop in front of a student and have them run with it.
            </p>
            """
    engagement:
        rating: 3
        explanation:
            """
            <p>Foldit's engagement relies heavily on the idea that you are helping advance science.</p>
            <p>
                The complexity and ambiguity of the puzzles themselves aren't ideal for engagement. Manipulating a puzzle
                can be challenging and solving a puzzle can feel less rewarding than many other puzzles.
            </p>
            <p>
                Still the puzzles are interesting, and the real-world nature of them certainly adds a feeling of purpose
                to the experience.
            </p>
            <p>
                Unfortunately I just don't expect most students to stick it out.
            </p>            
            """
    practicality:
        rating: 4
        explanation:
            """
            <p>
                It doesn't get much more practical than actually contributing to scientific efforts, but from an educational
                perspective, Foldit could use some improvement.
            </p>
            <p>
                I hope some day they'll improve the puzzle to better expose the underlying science and how protein-folding
                fits in to a larger scientific context, but for now the puzzles are fun and there's no dressing up the
                puzzles. What you see is the same thing that a professional scientist may work with, and there's certainly
                a lot of practical benefit in that.
            </p>
            <br/><br/><br/>
            """
    accessibility:
        rating: 2
        explanation:
            """ 
            <p>
                Foldit requires a download in order to run. The download is easy to install and should work on most computers,
                but it's still not as accessible as a web-based application or an app in an app store.
            </p>
            <p>
                2 stars does feel a little bit harsh for a free app that is a simple download, but downloading an app that requires
                registration makes it that much more of a committment just to try it out.
            </p>
            <br/><br/><br/><br/>
            """
    articles: 
        """
        <p><a href='http://en.wikipedia.org/wiki/Foldit' target='_blank'>Wikipedia - Foldit</a></p>
        <p><a href='http://foldit.wikia.com/wiki/Foldit_Wiki' target='_blank'>Foldit Wiki</a></p>
        <p><a href='http://www.scientificamerican.com/article.cfm?id=foldit-gamers-solve-riddle' target='_blank'>Foldit Gamers Solve Riddle of HIV Enzyme within 3 Weeks</a></p>
        <p><a href='http://news.cnet.com/8301-27083_3-20108365-247/foldit-game-leads-to-aids-research-breakthrough/' target='_blank'>Foldit game leads to AIDS research breakthrough</a></p>
        <br/><br/><br/><br/>
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
            <p>Although there's very little to Language Scramble than the languages involved, it still could improve a bit.</p>
            <p>
                To be truly practical as a language learning game we're going to need to have more than just written words to
                translate. Ideally there would be images and spoken words as well, providing a more complete experience of
                the foreign language.
            </p>
            <p>
                Still there are very few bells and whistles distracting from the language learning, so the learning is effective and
                very practical as is.
            <p>
            """
    accessibility:
        rating: 3
        explanation:
            """
            <p>There's still a lot more work to be done to make Language Scramble as accessible as it needs to be.</p>
            <p>
                Although it works well on a computer or through a web browser on an iPad or even the iPhone, it's not yet
                available through any app stores, and the web browser experience requires you to sign in, making it more
                difficult to access the app through your phone or iPad.
            </p>
            <p>
                The experience is also not yet optimized for small screens. So while it works well on an iPad, it leaves a little
                to be desired on a smart phone. It works, but the experience isn't all that great yet.
            </p>
            <p>We're hoping to improve all of this as soon as we can.</p>
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
            <p>
                Unforunately Peanutty! is still a bit too complicated for most students to engage with it beyond the first few
                challanges. We think it has the potential to be a great environment to learn programming, but it's not there yet.
            </p>
            <p>
                At this point I think it's too likely that a student would get overwhelmed and frustrated trying to use Peanutty!
                Some students may be able to figure it out and have a lot of fun with it, but too many may find it confusing, leading
                to a general sense that they're not good at programming. That's exactly what we would like to avoid.
            </p>
            <br/><br/>
            """
    intuitive:
        rating: 3
        explanation:
            """
            <p>
                Alhough Peanutty! has some fun techniques to make it intuitive with very little instruction (namely the ability to
                interact with the environment without coding, but having those interactions produce code), but it's still not nearly
                intuitive enough for prime time.
            </p>
            <p>
                As with the "love of learning" aspect, we hope to improve the intuitiveness of Peanutty! in the near future.
            </p>
            <br/><br/>
            """
    engagement:
        rating: 3
        explanation:
            """
            <p>
                Once again we think Peanutty! has a lot of potential in the engagement arena. Already in tests with high school students
                we've seen a high level of engagement. Unfortunately it rapidly diminished as the activities became too challenging
                too quickly.
            </p>
            <p>Once again we hope to improve this aspect of Peanutty! in the near future as well.</p>
            <br/><br/><br/>
            """
    practicality:
        rating: 5
        explanation:
            """
            <p>
                This is the one area where Peanutty! currently rates very highly. In order to solve problems and create levels in
                Peanutty! students write the same code that I use every day as a professional programmer. There's very little
                between the studens and actual coding. Maybe there should be some more layers of simplification, but as it is
                students get a very practical exposure to programming, how it looks, how to interact with it, etc.
            </p>
            <br/><br/><br/><br/>
            """
    accessibility:
        rating: 2
        explanation:
            """
            <p>
                Peanutty! currently scores pretty low here. It only works on the Chrome browser and isn't accessible on smart phones
                or tablets. Even worse, we're not sure that it's ever going to be accessible on those more mobile devices.
            </p>
            <p>
                The problem is that programming requires a fair amount of typing and we're not really sure that it's going to
                work well with a virtual keyboard. I certainly wouldn't want to program anything substantial on a virtual keyboard.
            </p>
            <p>
                Not only that, but we're not sure how to make it all work on a smaller screen. We want to make sure the environment and
                the code are both visible at all times so that it's easier to make and test changes. We might be able to squeeze it into a
                tablet format, but I doubt it will ever fit on a smart phone's screen.
            </p>
            <br/>
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
    