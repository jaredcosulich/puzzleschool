import Link from "next/link";
import Footer from "@/components/Footer";

export const metadata = { title: "Technology / R&D | The Puzzle School" };

export default function Technologies() {
  return (
    <>
      <div className="container">
        <div className="row py-3 mt-3">
          <div className="col-xs-12 col-md-8 offset-md-2">
            <h1 className="py-3 title text-xs-center">Technology / Research &amp; Development</h1>
            <h4 className="mt-1 text-xs-center">Clarification</h4>
            <p className="mt-1">
              People sometimes mistake The Puzzle School for an online learning effort or a school where the curriculum
              would be primarily through online resources.
            </p>
            <p>
              In reality The Puzzle School seeks to be a physical school that offers students a wide range of experiences.
              We are trying to create a school where students have greater ownership over their environment and
              education, where they develop meaningful relationships with teachers and mentors, and where they have time
              to explore their interests and engage in a wide range of studies, projects, and real world experiences such
              as internships.
            </p>
            <p>
              The primary puzzle will be how we can piece everything together, from programs to technology to community
              resources in a flexible and responsive manner to best serve the needs of each individual student.
            </p>
            <p>
              <b>Technology will play a role in supporting this vision, but it is far from the only concern.</b>
            </p>
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 offset-lg-2 col-lg-8">
            <h2 className="text-xs-center">Infrastructure</h2>
            <p className="mt-2">
              The following websites have been developed to help with infrastructural challenges at The Puzzle School,
              including better communication between students, teachers, and parents as well as better ways of connecting
              with the community and exploring student interests.
            </p>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-lg-2">
            <h5>EdContext</h5>
          </div>
          <div className="col-xs-12 col-md-7 col-lg-5 offset-lg-2">
            <p>
              We&apos;ve partnered up with Jack Schneider, an assistant professor at Holy Cross and the Director of
              Research with the Massachusetts Consortium for Innovative Education Assessment to build a text-messaging
              service that will allow The Puzzle School (and other schools) to collect feedback from students, parents,
              and teachers throughout the year on a wide-ranging set of questions about their experiences with the
              school.
            </p>
            <p>
              We believe this will help The Puzzle School (and other schools) more effectively listen to everyone
              involved in the school, helping to ensure that the loudest voices are not the only opinions considered. We
              hope the EdContext tool can help foster a more supportive, communicative, and involved community by
              collecting feedback from everyone in the community and making that feedback, aggregated to protect privacy,
              available for everyone else to see and act on.
            </p>
            <p>
              <b>Status:</b> Initial pilots in Cambridge and Somerville Public Schools
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/images/technologies/edcontext.png"
              className="img-fluid rounded-circle"
              style={{ border: "1px solid #aaa" }}
              alt="EdContext"
            />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-md-6 offset-lg-5">
            <h5>ThoughtfulRecommendations</h5>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3 text-xs-center offset-lg-2 hidden-sm-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/images/technologies/thoughtfulrecommendations.png"
              className="img-fluid rounded-circle"
              style={{ border: "1px solid #aaa" }}
              alt="ThoughtfulRecommendations"
            />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-5">
            <p>
              The primary goal of ThoughtfulRecommendations is to provide students with more visibility into the
              interests, hobbies, and passions of the teachers at The Puzzle School and other adult mentors in the
              community. The website makes it easy for someone to create a profile and list out everything they&apos;ve
              discovered in the world that they really appreciate, that they would recommend to just about anyone. When
              you list something you also provide a &quot;thoughtful recommendation&quot;, so there&apos;s a description
              of why you would recommend it.
            </p>
            <p>
              This allows students to discover fascinating resources and experiences that their teachers and other adults
              in their life really appreciate. It also allows students to get a more intimate idea of who the adults in
              their life are and how complex their interests and lives may be. They may even discover that they share
              some interests and then the student can explore the recommendations or even connect with the teacher around
              that interest.
            </p>
            <p>
              Students could also create profiles for themselves, building up a list of high quality resources along with
              thoughtful recommendations about each one. This could help a student share their observations about the
              world around them and their interests with teachers, colleges, and future employers.
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center hidden-md-up">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/images/technologies/thoughtfulrecommendations.png"
              className="img-fluid rounded-circle"
              style={{ border: "1px solid #aaa" }}
              alt="ThoughtfulRecommendations"
            />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 offset-lg-2 col-lg-8">
            <h2 className="text-xs-center">Curriculum</h2>
            <p className="mt-2">
              The following projects are explorations around creating high quality resources that support students in
              their learning through the puzzle-solving process that The Puzzle School is built around. Each resource is
              designed to be interactive, iterative, and scaffolded with high quality feedback loops.
            </p>
            <p>
              Again it should be stressed that these projects would not be the only learning resources used in The Puzzle
              School. They simply represent our ongoing exploration around creating high quality{" "}
              <Link href="/programs">programs</Link> and resources to support students in diverse learning pathways.
            </p>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-md-6 offset-lg-5">
            <h5>The Code Puzzle</h5>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3 offset-lg-2 text-xs-center hidden-sm-down">
            <Link href="/codepuzzle">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/technologies/codepuzzle.png" className="img-fluid" alt="The Code Puzzle" />
            </Link>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-5">
            <p>
              The Code Puzzle is a &quot;learn to code&quot; activity involving physical cards you can print out and an
              app that scans and executes your program.
            </p>
            <p>
              You arrange the cards and write in parameters to create a program. Then the program is drawn out one
              instruction at a time, like a little turtle-graphics robot following your code.
            </p>
            <p>
              <b>Try it:</b> <Link href="/codepuzzle">The Code Puzzle</Link>
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center hidden-md-up">
            <Link href="/codepuzzle">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/technologies/codepuzzle.png" className="img-fluid" alt="The Code Puzzle" />
            </Link>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-lg-2">
            <h5>Circuitous</h5>
          </div>
          <div className="col-xs-12 col-md-7 col-lg-5 offset-lg-2">
            <p>
              Circuitous is a fully functional circuit simulator. We&apos;ve layered on top a series of challenges that
              can help direct a student&apos;s learning, but students can simply play around with the simulator as well.
            </p>
            <p>Each challenge has a series of hints, an example solution, and a video explanation of the challenge and solution.</p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/technologies/circuitous.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="Circuitous" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-md-6 offset-lg-5">
            <h5>XYFlyer</h5>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3 offset-lg-2 text-xs-center hidden-sm-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/technologies/xyflyer.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="XYFlyer" />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-5">
            <p>
              XYFlyer is a simple puzzle app that provides a series of challenges around constructing equations. With
              each equation constructed you can immediately see the resulting graph and how different changes to each
              equation affect the graph.
            </p>
            <p>
              We&apos;ve created over 200 levels that get more and more challenging. They can help students gain a better
              visual intuition about how equations graph out.
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center hidden-md-up">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/technologies/xyflyer.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="XYFlyer" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-lg-2">
            <h5>Drawing In Code</h5>
          </div>
          <div className="col-xs-12 col-md-7 col-lg-5 offset-lg-2">
            <p>
              The Puzzle School is collaborating with David Ng, the founder of{" "}
              <a href="http://www.verticallearning.org" target="_blank" rel="noopener noreferrer">
                Vertical Learning Labs
              </a>
              , to develop an online resource designed to support an exploration of artistic observation and
              computational thinking. Essentially students will learn how to teach a computer to draw and design games.
              We are currently using the resource as one pathway for students to explore in our{" "}
              <Link href="/programs">programs</Link>.
            </p>
            <p>
              Through a series of challenges students will develop their ability to observe their physical world and
              translate that into code so that a computer can draw it. From there students will be able to animate their
              drawing and make them interactive (games).
            </p>
            <p>
              <b>Visit:</b>{" "}
              <a href="https://jaredcosulich.github.io/drawing_code/index.html" target="_blank" rel="noopener noreferrer">
                Drawing In Code
              </a>
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/building.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="Drawing In Code" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-md-6 offset-lg-5">
            <h5>Peanutty</h5>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3 offset-lg-2 text-xs-center hidden-sm-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/technologies/peanutty.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="Peanutty" />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-5">
            <p>
              Peanutty provides an interesting physics-based puzzle-solving environment where you can interact with a
              challenge by dragging, dropping, and drawing, and, with each interaction code is generated. Then you can
              edit the code to affect the interaction.
            </p>
            <p>
              Drop a ball and then change the dimensions of the ball to be much bigger and watch it drop again. Develop
              creative solutions to puzzles and then develop your own puzzles by tweaking or rewriting the level code.
            </p>
            <p>
              <b>Visit:</b>{" "}
              <a href="http://peanutty.org" target="_blank" rel="noopener noreferrer">
                Peanutty
              </a>
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center hidden-md-up">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/technologies/peanutty.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="Peanutty" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-lg-2">
            <h5>Language Scramble</h5>
          </div>
          <div className="col-xs-12 col-md-7 col-lg-5 offset-lg-2">
            <p>
              Language Scramble is a simple puzzle meant to help people learn a new language (right now we just have
              Italian).
            </p>
            <p>
              You&apos;re presented with a foreign (in this case Italian) word and need to unscramble the letters to form
              a correct translation in English.
            </p>
            <p>
              It&apos;s a little limited right now, focusing on translation of written words, but has the potential to
              feature images and audio in the future.
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/technologies/language_scramble.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="Language Scramble" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 offset-md-6 offset-lg-5">
            <h5>Light It Up</h5>
          </div>
          <div className="col-xs-12 col-md-6 col-lg-3 offset-lg-2 text-xs-center hidden-sm-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/technologies/lightitup.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="Light It Up" />
          </div>
          <div className="col-xs-12 col-md-6 col-lg-5">
            <p>
              Light It Up was inspired by the fractions game, Refraction, developed by the{" "}
              <a href="http://centerforgamescience.org/blog/portfolio/refraction/" target="_blank" rel="noopener noreferrer">
                University of Washington&apos;s Center for Game Science
              </a>
              .
            </p>
            <p>While we loved Refraction, we wanted to make a few changes.</p>
            <ul className="spaced_out">
              <li>
                We wanted to create puzzles that would teach students fractions more directly, so we reduced the number
                of obstacles in our levels, making the puzzles more about the fractions than the obstacles.
              </li>
              <li>
                We created a level editor that allows teachers to easily create custom levels to teach a specific
                fraction-based idea. The level editor also allows students to create their own puzzles, improving their
                mastery of fractions while creating puzzles as well as solving puzzles.
              </li>
              <li>
                We wanted to add in a feature that would walk you through the solution to the puzzle if you got stuck. We
                wanted to make the game more about learning than about solving the puzzles, so we focused on creating more
                levels with the ability to get help on any level that is too hard.
              </li>
            </ul>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center hidden-md-up">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/technologies/lightitup.png" className="img-fluid" style={{ border: "1px solid #aaa" }} alt="Light It Up" />
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
