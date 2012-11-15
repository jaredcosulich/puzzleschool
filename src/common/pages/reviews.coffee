# BigSeed: https://itunes.apple.com/us/app/bigseed/id482245645?mt=8
# GoGoGames: http://hackeducation.com/2012/10/31/app-of-the-month-october-2012/
# Stack the States: https://itunes.apple.com/us/app/stack-the-states/id381342267?mt=8
# Hax Attacks: https://itunes.apple.com/ua/app/hax-attacks/id556677673?mt=8
# Build With Chrome http://www.buildwithchrome.com/
# Lightbot: http://armorgames.com/play/6061/light-bot-20
# NAND to Tetris: http://www.nand2tetris.org/course.php
# Memrise: http://www.memrise.com/
# Teach with Portals: http://www.teachwithportals.com/
# Popcorn Maker: https://popcorn.webmaker.org/templates/basic/?savedDataUrl=projects/stop-and-frisk.json

soma = require('soma')
wings = require('wings')

soma.chunks
    Reviews:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({}) ->
            @template = @loadTemplate '/build/common/templates/reviews.html'

        build: () ->
            @setTitle("Reviews - The Puzzle School")
            @html = wings.renderTemplate(@template, reviews: REVIEWDATA)
        
soma.views
    Reviews:
        selector: '#content .reviews'
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
    '/reviews': -> new soma.chunks.Reviews


REVIEWDATA = [{
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
            <p>DragonBox is one of the best apps I've seen for teaching the strategies required to solve algebric equations.</p>
            <p>
                They've done a great job of focusing on the puzzle-like aspects of algebra,
                starting with puzzles using colorful icons that represent variables before
                transitioning to actual equations.
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
            <p><a href='http://kk.org/cooltools/archives/6504' target='_blank'>Trick Kids Into Learning Algebra</a></p>
            
            <br/><br/><br/><br/><br/><br/>
        """
}, {
    title: 'CargoBot'
    website: 'http://twolivesleft.com/CargoBot/'
    thumbnail: '/assets/images/reviews/cargobot.jpg'
    company: 'Two Lives Left'
    companyWebsite: 'hhttp://twolivesleft.com/'
    material: 'Basic Programming'
    availability: 'iPad'
    cost: 'Free'
    overall:
        rating: 4.2
        explanation:
            """
            <p>
                CargoBot is a simple puzzle game that teaches the basics of programming (loops and conditional statements).
            </p>
            <p>
                That may sound intimidating, but they've created a great trial-and-error environment with a simple tool box
                that lets you learn the basics of these concepts without writing any programming.
            </p>
            <p>
                You basically try to move boxes around by programming a crane to pick up, move, and drop boxes to solve the
                puzzle. It's a very practical way to approach introductory programming, it's presented in a great trial-and-error
                environment, and is quite engaging.
            </p>
            <p>
                Really the only two knocks against it are that the puzzles get a little too hard a little too fast,
                which could result in excessive frustration or even someone giving up, and it is only available iPad, 
                which means you can't play it at all unless you own an iPad.
            </p>
            <p>
                It is free, though, so if you own an iPad I would highly recommend CargoBot. I think it's 
                very likely that a student will leave CargoBot wanting to learn more about programming so they can do 
                more interesting things than just solve puzzles in CargoBot. That's the most important factor from my perspective.
            </p>
            """
    loveOfLearning:
        rating: 4
        explanation:
            """
            <p>
                I think CargoBot represents an excellent introduction to programming and should leave students hungry for more.
            </p>
            <p>
                The fact that you're using programming to control a "physical" object (the crane) helps to explain what we use
                programming for and should lead to creative connections about controlling other things.
            </p>
            <p>
                The only knock I give it is that it may get too hard too fast, which could lead to frustration. Even as a
                professional programmer I struggled with some of the puzzles and at points questioned whether there was
                a mistake or not. That isn't a good sign and would make me a bit nervous about a less experienced student
                getting too frustrated and actually giving up.
            </p>
            <p>
                Overall, though, that concern is a minor one and can be moderated with a little outside help if it becomes an
                issue. I think it's much more likely that a student walks away wanting to learn more programming after playing
                CargoBot.
            </p>
            """
    intuitive:
        rating: 4
        explanation:
            """
            <p>
                CargoBot isn't quite as intuitive as I would like, but it's still very good. It requires a fair amount of
                explanation to get started with it, which is a negative, but the explanations are provided within the tutorial
                levels, so they're atleast provided with a great deal of context. 
            </p>
            <p>
                It's pretty hard to teach programming without any explanation and they do a good job of minimizing it, using
                a great trial-and-error environment complete with debugging tools. Overall they've done an excellent job making
                CargoBot intuitive enough that anyone should be able to figure it out with very little if any outside help.
            </p>
            """
    engagement:
        rating: 5
        explanation:
            """
            <p>
                CargoBot is an excellent puzzle environment. It provides quality challenges (maybe they get a bit too hard too quickly) 
                and a great trial-and-error environment. I found myself getting hooked on a number of the challenges, even
                racing back to try a solution after I'd given up on getting the full 3 stars on one puzzle.
            </p>
            <p>
                Again the only knock might be that it gets too hard too fast, but with engagement that might actually be a plus.
                It's a fine line and I'd rather see them add in more puzzles to make the progress a little more granular, but
                as it is I do think it's a very engaging experience.
            </p>
            """
    practicality:
        rating: 5
        explanation:
            """
            <p>
                CargoBot demonstrates a clearly practical usage of programming. You're programming a crane that moves boxes from
                one place to another. That's an actual use of programming in the real world and provides a clear introduction
                to not only programming, but why you would want to use programming in the real world.
            </p>
            <br/><br/><br/><br/><br/>
            """
    accessibility:
        rating: 3
        explanation:
            """ 
            <p>
                CargoBot is only available on the iPad, which makes it completely inaccessible unless you own an iPad.
            </p>
            <p>
                Hopefully they'll at least introduce a version that can work on mobile phones in the future, but, since
                the company that created it only built CargoBot as a demo of what their primary product can build (it's a
                program that helps people develop apps), I'm not sure they're going to prioritize further development
                of CargoBot.
            </p>
            <p>
                Still, it is free. So, if you own an iPad, it doesn't get any more accessible. For those without an iPad,
                though, you're out of luck for now.
            </p>
            <br/><br/>
            """
    articles:
        """
            <p><a href='http://jayisgames.com/archives/2012/05/cargo-bot.php' target='_blank'>CargoBot Walk Through</a></p>
            <p><a href='http://www.engadget.com/2012/04/24/cargo-bot-for-ipad-video/' target='_blank'>CargoBot - Engadget Review</a></p>
            <br/><br/><br/><br/><br/><br/><br/><br/>
        """

}, {
    title: 'Shikaku'
    website: 'http://itunes.apple.com/us/app/shikaku-free/id355469616?mt=8'
    thumbnail: '/assets/images/reviews/shikaku.jpg'
    company: 'Nikoli'
    companyWebsite: 'http://www.nikoli.com'
    material: 'Multiplication / Factors'
    availability: 'Web, Mobile, Paper'
    cost: 'Free - $5.99'
    overall:
        rating: 4
        explanation:
            """
            <p>
                Shikaku is from the same people who created Sudoku and has a very similar style to it. Unlike, Sudoku, though,
                Shikaku introduces some basic multiplication.
            </p>
            <p>
                In order to solve the puzzles you need to create squares or rectangles that add up in area to the number
                they encompass. So in order to satisfy a "12" box you could fill in a 12x1 area or a 3x4 area or a 6x2 area.
            </p>
            <p>
                Just like Sudoku, the engagement level is high. It's a quality puzzle that will likely entertain adults as
                well as students. 
            </p>
            <p>
                Really the only drawback is that there is limited learning available. It's good practice for basic multiplication
                and factors, providing feedback on whether the area filled in satisfies the number's requirement, but most of the
                puzzles don't go above 9 and those that do don't seem to go above 16 or so, so you're not going to get in to
                larger numbers at all.
            </p>
            <p>
                If the puzzles involved a wider range of numbers then Shikaku would be a better tool for learning multiplication
                and factors. If it were to do that, though, the puzzles may become too challenging.
                As it is it's still a great fun puzzle that uses basic multiplication.
            </p>
            """
    loveOfLearning:
        rating: 3
        explanation:
            """
            <p>
                Shikaku is a great puzzle game. It's very likely that people will enjoy playing it just because it's a
                fun puzzle, much like Sudoku. That said, the educational content (outside of the standard benefits of
                these types of puzzles) is a little limited and I kind of doubt that a student would walk away wanting
                to learn more about multiplication of factors. 
            </p>
            <p>
                Still I think there is significant educational value for someone who is just starting to learn about 
                multiplication and factors. The feedback in the puzzle is a little subtle, but it is there, and the puzzles
                are high quality so once someone gets a hang of it they will likely stick with it and could gain a great
                understanding of some basic multiplication and factors. 
            </p>
            """
    intuitive:
        rating: 4
        explanation:
            """
            <p>
                Shikaku is a very intuitive puzzle, but you will probably need to watch a video to understand how it works.
            </p>
            <p>
                In fact I would recommend the video in 
                <a href='http://mrhodotnet.blogspot.com/2011/12/shikaku.html' target='_blank'>this blog</a>.
            </p>
            <p>
                The feedback loops in the puzzle that show you whether the rectangle you've filled is appropriate is also
                a little subtle, making the puzzle a little less intuitive.
            </p>
            <p>
                Overall, though it shouldn't take long to get the hang of Shikaku and then you're off and running.
            </p>
            """
    engagement:
        rating: 5
        explanation:
            """
            <p>
                Shikaku, like Sudoku, can be very addictive. The puzzles are fun to solve and range nicely in difficulty.
            </p>
            <p>
                There's a very good chance that once you get in to them you'll want to continue solving harder and harder
                puzzles. There's not much more you can ask for from an extremely simple puzzle.
            </p>
            """
    practicality:
        rating: 3
        explanation:
            """
            <p>
                The biggest knock against Shikaku is that it's a little limited in the educational department. Although
                it is a very simple and effective puzzle environment for exploring factors, while the puzzles get harder
                the educational content remains fairly constant.
            </p>
            <p>
                Which isn't to say it's not worth playing, I just wouldn't expect a student to come away with a real expertise
                of factors once they've played for a while.
            </p>

            <br/><br/><br/>
            """
    accessibility:
        rating: 5
        explanation:
            """ 
            <p>
                Shikaku is available on the web in various free forms as well as in most app stores (iPhone, iPad, Android), so you
                shouldn't have too much trouble finding a free version for any device. You can also pay to get more puzzles through
                most of the app stores. 
            </p>
            <p>
                There are also books you can buy to play Shikaku in the same way that so many people play Sudoku.
            </p>
            <p>
                So you should be able to find a way to play Shikaku on your favorite device or just with pen and paper.
            </p>
            <br/><br/>
            """
    articles: 
        """
        <p><a href='http://mrhodotnet.blogspot.com/2011/12/shikaku.html' target='_blank'>Shikaku blog post</a></p>
        <p><a href='http://www.nikoli.co.jp/en/puzzles/shikaku.html' target='_blank'>Shikaku from Nikoli</a></p>
        <p><a href='http://www.puzzle-shikaku.com/' target='_blank'>Free, online Shikaku Puzzles</a></p>
        <p><a href='http://itunes.apple.com/us/app/shikaku-free/id355469616?mt=8' target='_blank'>Shikaku - iTunes App Store</a></p>
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
    articles:
        """
            <p><a href='https://www.edsurge.com/st-math#/default' target='_blank'>ST Math - EdSurge Review</a></p>
            <p><a href='https://www.youtube.com/watch?feature=player_embedded&v=2VLje8QRrwg' target='_blank'>ST Math - TedX Talk</a></p>
            <p><a href='http://www.youtube.com/watch?v=t4P5XlfzliM' target='_blank'>ST Math Promotional Video</a></p>
            <br/><br/><br/><br/><br/><br/>
        """
}, {
    title: 'Lure of the Labyrinth'
    website: 'http://labyrinth.thinkport.org'
    thumbnail: '/assets/images/reviews/lureofthelabyrinth.jpg'
    company: 'Maryland Public Television, MIT'
    companyWebsite: 'http://wewanttoknow.com'
    material: 'Pre-Algebra'
    availability: 'Web'
    cost: 'Free'
    overall:
        rating: 3.6
        explanation:
            """
            <p>
                Lure of the Labrynth is a game with numerous math-based puzzles for teaching pre-algebra, tied
                together by a comic-like storyline revolving around a lost pet.
            </p>
            <p>
                The game has a very high production value. Clearly a lot of work went in to developing it. The story
                line could work well, although I didn't really get caught up in it. The puzzles are well-done, but they
                aren't quite granular enough, making them a bit too challenging.
            </p>
            <p>
                It seems like a lot of work went in to the production of the game when I would have prefered
                more work go in to the intuitiveness of the game and the puzzles.
            </p>
            <p>
                Like any quality puzzle I would recommend giving them a shot with any student, especially since this
                one is free and the production value is quite high. Unfortunately, I don't have a whole lot of confidence 
                that students will engage with this game enough unless they get caught up in the story, which could happen.
            </p>
            <p>
                The puzzles themselves are, like most puzzles, an engaging way to practice pre-algebra concepts, such as
                proportions, but they don't really make any attempt to teach the concepts, or at least the feedback
                loops are not tight enough to facilitate learning for beginners. I think many beginners will give up before
                being able to solve many of the puzzles unfortunately.
            </p>
            """
    loveOfLearning:
        rating: 3
        explanation:
            """
            <p>
                The storyline with the puzzles makes for an engaging experience. I struggled to get in to it myself, but
                someone else make get in to it more easily.
            </p>
            <p>
                The biggest issue when it comes to "love of learning" is that I fear a beginner will become too confused. I'm
                not entirely sure as there are feedback loops and mistakes are ok, but I get the sense that it was designed as
                additional material for students to practice concepts they were already taught, rather than trying to teach
                them the concepts through the puzzle.
            </p>
            <p>
                If the puzzles were more granualar (starting very easy and gradually getting harder) and had tighter feedback loops
                so that the learning process could happen more quickly, then I think the puzzles would be much more effective as
                learning tools. As they are, though, I would worry that beginners would get frustrated too easily.
            </p>
            """
    intuitive:
        rating: 3
        explanation:
            """
            <p>
                I personally found Lure of the Labyrinth to be less intuitive than I would hope.
            </p>
            <p>
                You can play the puzzle independently and, although they aren't as intuitive as they could be, they
                are still intuitive enough that I could figure them out with out any help.
            </p>
            <p>
                When I tried playing the game via the story, though, I struggled to get going, unable to figure out
                what to do.
            </p>
            <p>
                I'm worried that the game was developed exclusively for classroom use, where a teacher would be on hand
                to make sure students didn't get stuck. A student on their own trying to play the game might get frustrated,
                as I did.
            </p>
            """
    engagement:
        rating: 4
        explanation:
            """
            <p>
                The storyline is a nice touch when it comes to engagement, tying together the puzzles. I would prefer that more
                attention be paid to the puzzles themselves, making them as engaging as possible by instilling a constant sense
                of progress in the student, but I do think a quality storyline is a positive.
            </p>
            <p>
                I still didn't find it engaging enough to give it very high marks. While I appreciate the storyline, and I do 
                think it's possible that some students may get in to it more than I did, I wasn't engaged with Lure of the 
                Labyrinth as much as I have been with other puzzles.
            </p>

            """
    practicality:
        rating: 5
        explanation:
            """
            <p>
                Lure of the Labyrinth was built to coincide directly with Common Core coursework in the classroom, so in
                that way, it is very practical.
            </p>
            <p>
                The puzzles themselves are also quite practical. They deal with scenarios that aren't very far removed from
                reality, such as combining the correct proportions of a recipe.
            </p>
            <br/><br/><br/><br/>
            """
    accessibility:
        rating: 3
        explanation:
            """
            <p>
                Lure of the Labyrinth is a flash game that is only available online. You can't play it on a mobile phone or 
                tablet at all, making it far less than ideal.
            </p>
            <p>
                Still, it is free, which makes it easy to try out, so it definitely deserves points for that.
            </p>
            <br/><br/><br/><br/><br/><br/>
            """
    articles: 
        """
            <p><a href='http://dogtrax.edublogs.org/2012/04/19/gaming-challenge-the-lure-of-the-labyrinth/' target='_blank'>Gaming Challenge: The Lure of the Labyrinth</a></p>
            <p><a href='http://www.youtube.com/watch?feature=player_detailpage&v=4KMwXaS_FKY#t=53s' target='_blank'>Amateur Game Demo</a></p>

            <br/><br/><br/><br/><br/><br/><br/><br/>
        """
},{
    title: 'Mozilla Thimble'
    website: 'https://thimble.webmaker.org'
    thumbnail: '/assets/images/reviews/thimble.jpg'
    company: 'Mozilla'
    companyWebsite: 'http://www.mozilla.org/'
    material: 'Programming/HTML'
    availability: 'Web'
    cost: 'Free'
    overall:
        rating: 3.2
        explanation:
            """
            <p>
                Mozilla Thimble is an effort by Mozilla.org (makers of the Firefox web browser) to make learning html more
                accessible. It harkens back to the day when most people learned html by looking at the code other people
                had written on websites by "viewing the source". In many ways the fact that you could view the source code for
                web pages was instrumental in both the education of thousands of web developers as well as the explosion of the
                web itself.
            </p>
            <p>
                Mozilla has taken it one step further with Thimble, putting the source and the website side by side and making it
                so that any change to the source immediately changes the website. This tight feedback loop is fantastic and makes it
                easier to see the effect your changes have on the website. It's a great trial-and-error learning environment.
            </p>
            <p>
                Unfortunately there's not much purpose provided by Thimble. They do try to create projects, but most have an excessive
                amount of instructions buried in the comments. I think it's unlikely that a student who is just exploring will become
                engaged by Thimble enough to get any real value out of it. It's certainly possible that a student will get in to it,
                but I think it's unlikely.
            </p>
            <p>
                So if you're coming to the table with your own motivation (e.g. you want to build a website), then I think Mozilla
                Thimble is a great tool. With education, though, too often the problem is that there is a lack of purpose and the
                educational activity needs to supply that purpose. In this case Mozilla Thimble falls short. I think it's unlikely
                that a student will run with Mozilla Thimble without a lot of encouragement, support, and assistance. 
            </p>
            """
    loveOfLearning:
        rating: 3
        explanation:
            """
            <p>
                The trial-and-error environment with tight feedback loops will certainly encourage a sense of progress and a
                desire to learn more if you start with enough motivation. Without bringing your own motivation to the table,
                though, I don't think you're going to engage with Thimble enough to create a desire to learn more.
            </p>
            <p>
                It's a tall order to get all of these aspects correct. Thimble does a very good job with the learning environment,
                but I don't think too many students are going to engage with it unless they are forced to do so or they've been
                inspired by some external factor.
            </p>
            """
    intuitive:
        rating: 3
        explanation:
            """
            <p>
                Mozilla Thimble does offer some fantastic advancements in intuitive web design. They've made it easy to
                click on a website and see what code is responsible. This makes it easy to explore a website from the outside-in,
                seeing what code creates which effects. This can be very enabling to a learner.
            </p>
            <p>
                They've also made it so that when you change the html code the website immediately changes so you can see
                the effect of your code changes. This tight feedback loop is very well done and makes it very easy to learn
                with html through trial-and-error, something we're a big fan of.
            </p>
            <p>
                Unfortunately the site relies heavily on instructions in the code to describe projects and create a sense
                of purpose. This is a real detractor from it becoming a great educational resource. I just don't think you're 
                going to be able to expose this to a student and have them run with it.
            </p>
            <p>
                So while the click-to-explore and trial-and-error environment with tight feedback make the experience of learning
                html very intuitive, the instructions buried in code make the projects and any sense of purpose far less intuitive.
            </p>
            """
    engagement:
        rating: 3
        explanation:
            """
            <p>
                This is probably the biggest issue with Mozilla Thimble. If you're not coming to it with a project in mind, it's
                unlikely that their projects are going to engage you. It's not impossible, so give it a shot, but I think they
                fall short by quite a bit.
            </p>            
            <p>
                As with most programming, once you get in to a project the engagement can come very easily. With the click-to-explore
                and automatic-refreshing of the website every time you make a code change, the engage is even more likely to kick in
                to gear.
            </p>
            <p>
                But without a better mechanism to drive purpose (we recommend puzzles), it's not very likely that a student without
                a specific project in mind will be able to get deep enough for the engagement to kick in.
            """
    practicality:
        rating: 5
        explanation:
            """
            <p>
                Mozilla Thimble is highly practical. There are no bells or whistles. The site focuses on making it very easy to learn
                html through a great trial-and-error environment with tight feedback loops. That's it. Just the material and a quality
                environment.
            </p>
            <p>
                If a student does find their way to engagement with Thimble then there's no doubt that time on Thimble is time well spent.
                As a professional programmer I'm even tempted to spend more time with Thimble for my professional work as the tight feedback
                loops are so practical even at the professional level.
            </p>
            
            <br/><br/><br/>
            """
    accessibility:
        rating: 4
        explanation:
            """ 
            <p>
                Mozilla Thimble is available for free on the web. Although it's not available in any app stores and requires an internet
                connection to access, it's still pretty accessible. Best of all, it's completely free.
            </p>
            <br/><br/><br/><br/><br/><br/><br/>
            """
    articles: 
        """
        <p><a href='http://www.techspot.com/news/49050-mozilla-previews-thimble-a-refreshingly-simple-html-coding-tool.html' target='_blank'>Mozilla previews Thimble, a refreshingly simple HTML coding tool</a></p>
        <p><a href='http://blog.mozilla.org/blog/2012/06/18/introducing_thimble/' target='_blank'>Introducing Thimble</a></p>
        <p><a href='http://mashable.com/2012/06/18/mozilla-thimble/' target='_blank'>Create Your Own Website Using Mozilla’s Thimble</a></p>
        <p><a href='http://lifehacker.com/5914119/mozilla-thimble-teaches-you-how-to-code-with-a-side+by+side-html-editor' target='_blank'>Mozilla Thimble Teaches You HTML and CSS with a Side-by-Side HTML Editor</a></p>
        <p><a href='http://techcrunch.com/2012/06/18/mozilla-launches-thimble-a-web-based-code-editor-for-teaching-html-and-css/mozilla-thimble/' target='_blank'>Mozilla Thimble</a></p>
        <br/><br/>
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
