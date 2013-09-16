# Inner Tube Games Wuzzit

# http://io9.com/these-cool-games-let-you-do-real-life-science-486173006

# Monster Physics - http://dan-russell-pinson.com/category/games/monster-physics/

# 32 Builder - https://www.appolearning.com/app_reviews/596-cyberchase-3d-builder

# Scratch 2.0 - http://scratch.mit.edu

# Escape the room games

# Geoguessr http://www.geoguessr.com/

# http://www.robocatz.com/simulator4.htm

# BotLogic.us
# Kodable - https://itunes.apple.com/us/app/kodable/id577673067?mt=8
# Sphero MacroLab - https://itunes.apple.com/us/app/id519917219?mt=8

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
# Graph Wars: http://www.graphwar.com/
# Universe Sandbox: http://universesandbox.com/
# Eye Paint - http://www.curioushat.com/eye-paint/
# Horse Race (fractions) - http://davidwees.com/horserace/
# Save Our Dumb Planet - http://www.mangahigh.com/en_us/games/saveourdumbplanet
# Origami Game - http://t.co/9OnASCWt
# DrawQuest - ipad game
# Universe and More Graphing - http://www.theuniverseandmore.com/SUGC/
# Letterschool - http://letterschool.com/
# Circuit Coder - https://itunes.apple.com/us/app/id492180472?mt=8


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
}, {
    title: 'DragonBox'
    website: 'http://dragonboxapp.com/'
    thumbnail: '/assets/images/reviews/dragonbox.jpg'
    company: 'We Want To Know'
    companyWebsite: 'http://wewanttoknow.com'
    material: 'Algebra'
    availability: 'Mobile, Tablet'
    cost: '$2.95 - $5.95'
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
}, {
    title: 'CargoBot'
    website: 'http://twolivesleft.com/CargoBot/'
    thumbnail: '/assets/images/reviews/cargobot.jpg'
    company: 'Two Lives Left'
    companyWebsite: 'hhttp://twolivesleft.com/'
    material: 'Basic Programming'
    availability: 'iPad'
    cost: 'Free'
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
}, {
    title: 'Shikaku'
    website: 'http://itunes.apple.com/us/app/shikaku-free/id355469616?mt=8'
    thumbnail: '/assets/images/reviews/shikaku.jpg'
    company: 'Nikoli'
    companyWebsite: 'http://www.nikoli.com'
    material: 'Multiplication / Factors'
    availability: 'Web, Mobile, Paper'
    cost: 'Free - $5.99'
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
}, {
    title: 'ST Math'
    website: 'http://web.stmath.com/'
    thumbnail: '/assets/images/reviews/stmath.jpg'
    company: 'MIND Research Institute'
    companyWebsite: 'http://www.mindresearch.net'
    material: 'Math'
    availability: 'Web'
    cost: '???'
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
}, {
    title: 'Lure of the Labyrinth'
    website: 'http://labyrinth.thinkport.org'
    thumbnail: '/assets/images/reviews/lureofthelabyrinth.jpg'
    company: 'Maryland Public Television, MIT'
    companyWebsite: 'http://wewanttoknow.com'
    material: 'Pre-Algebra'
    availability: 'Web'
    cost: 'Free'
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
},{
    title: 'Mozilla Thimble'
    website: 'https://thimble.webmaker.org'
    thumbnail: '/assets/images/reviews/thimble.jpg'
    company: 'Mozilla'
    companyWebsite: 'http://www.mozilla.org/'
    material: 'Programming/HTML'
    availability: 'Web'
    cost: 'Free'
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
}, {
    title: 'Foldit'
    website: 'http://fold.it'
    thumbnail: '/assets/images/reviews/foldit.jpg'
    company: 'UW Center for Game Science'
    companyWebsite: 'http://www.centerforgamescience.org'
    material: 'Biochemistry'
    availability: 'Web'
    cost: 'Free'
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
    }]
