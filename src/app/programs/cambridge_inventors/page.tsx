import Footer from "@/components/Footer";
import YouTube from "@/components/YouTube";

export const metadata = { title: "Cambridge Inventors Club | The Puzzle School" };

const CHARLIE_QUOTE = (
  <blockquote className="blockquote py-2 bordered">
    <p className="small">
      <em>Charlie is really enjoying himself. He said what he likes most about it:</em>
    </p>
    <ul className="small">
      <li>
        <em>The one on one help</em>
      </li>
      <li>
        <em>
          The mentors don’t tell you what to do, but they work with you to help you figure it out yourself (YaY)
        </em>
      </li>
      <li>
        <em>Really enjoys the connection with the tutors/mentors</em>
      </li>
    </ul>
    <p className="mb-0 small">
      <em>
        Charlie is finding communicating and learning easy in this environment. He does not have a lot of opportunities
        to interact with adults who inspire him the way the mentors in the program have so far. He loves that connection
        and he always leaves Monday night feeling so good about himself and his time at the open space. Before he went to
        bed he asked me, “Why can’t school be like coding class, I would be so excited to go in the morning.&quot;
      </em>
    </p>
    <footer className="blockquote-footer text-xs-right small">Mary (Charlie&apos;s Mom)</footer>
  </blockquote>
);

export default function CambridgeInventors() {
  return (
    <>
      <div className="container">
        <div className="row text-xs-center py-3 mt-3">
          <div className="col-xs-12 col-lg-8 offset-lg-2">
            <h1 className="py-3 title">Cambridge Inventors Club</h1>
            <p className="mt-1">
              Starting in August of 2016 we partnered with{" "}
              <a href="https://pivotal.io/labs" target="_blank" rel="noopener noreferrer">
                Pivotal Labs
              </a>{" "}
              on what started out as a &quot;learn to code&quot; program but has since expanded to include more hands-on
              engineering and a focus on invention.
            </p>
            <p>
              Moving forward we&apos;ll be supporting students in exploring creative problem solving using technical
              skills such as coding and engineering. We work with them on the creative process, rapid prototyping, and
              reflecting on the challenges, their solutions, and the overall environment in which they are working.
            </p>
          </div>
        </div>

        <div className="row">
          <div className="col-xs-12 col-md-6 py-2">
            <YouTube id="vS_m7DIDGS8" />
          </div>
          <div className="col-xs-12 col-md-6 py-2">
            <YouTube id="XlrA0otiTHk" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-10 offset-md-1 col-lg-6 offset-lg-1">
            <h5>The Goal</h5>
            <p>
              The primary goal of the Cambridge Inventors Club is to create a safe, healthy, interesting, and fun
              environment for young people to explore creative problem solving through the lens of technical skills such
              as coding and engineering.
            </p>
            <p>
              We bring together volunteers from the technology community in the general area around Kendall Sq and
              Cambridge to both support students in their work and to connect students with a variety of adults working in
              various technological fields.
            </p>
          </div>
          <div className="col-xs-12 col-lg-4 text-xs-center text-lg-right">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/pivotal/image1.jpg" className="rounded img-fluid" alt="" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-lg-4 offset-lg-1 hidden-md-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/pivotal/image6.jpg" className="rounded img-fluid" alt="" />
            <div className="mt-3">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/programs/pivotal/image7.jpg" className="rounded img-fluid" alt="" />
            </div>
          </div>

          <div className="col-xs-12 col-md-10 offset-md-1 offset-lg-0 col-lg-6">
            <h5>The Approach</h5>
            <p>Within this program we would focus on a number of ideas that we want to explore with The Puzzle School:</p>
            <ul className="no_shift spaced_out">
              <li>
                Exposing students to a variety of challenges and interesting problems that can stimulate their creative
                problem-solving abilities.
              </li>
              <li>
                Having students test resources and provide feedback in order to find the best resources students can use
                to learn at their own pace.
              </li>
              <li>
                Having students engage in a variety of design exercises to help foster ideas, techniques, and skills such
                as rapid-prototyping and team communication.
              </li>
              <li>
                Running retrospectives at the end of each sessions to get feedback from students around what worked and
                didn&apos;t with regard to the challenge, their work and solution, and the overall environment they are
                working in.
              </li>
              <li>
                Supporting students toward independent and small group projects (inventions) they design themselves and
                will continue working on at home.
              </li>
            </ul>
            <p>Some of the resources and activities we&apos;ve had success with include:</p>
            <ul className="no_shift spaced_out">
              <li><a href="https://codecombat.com/" target="_blank" rel="noopener noreferrer">CodeCombat</a></li>
              <li><a href="https://projecteuler.net/" target="_blank" rel="noopener noreferrer">Project Euler</a></li>
              <li><a href="https://jaredcosulich.github.io/drawing_code" target="_blank" rel="noopener noreferrer">Drawing In Code</a></li>
              <li><a href="http://www.tomwujec.com/design-projects/marshmallow-challenge/" target="_blank" rel="noopener noreferrer">Marshmallow Towers</a></li>
              <li><a href="http://courses.washington.edu/engr100/Section_Brad/01_hnd_BridgeIntro.htm" target="_blank" rel="noopener noreferrer">Popsicle Stick Bridges</a></li>
              <li><a href="http://kidsactivitiesblog.com/55055/15-easy-catapults-to-make" target="_blank" rel="noopener noreferrer">Rubber Band Catapults</a></li>
            </ul>
          </div>

          <div className="col-xs-12 hidden-lg-up text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/pivotal/image6.jpg" className="rounded img-fluid" alt="" />
            <div className="mt-3">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/programs/pivotal/image7.jpg" className="rounded img-fluid" alt="" />
            </div>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-10 offset-md-1">{CHARLIE_QUOTE}</div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-10 offset-md-1 col-lg-6 offset-lg-1">
            <h5>The Results So Far</h5>
            <p>
              We&apos;ve now run the program for two eight-week sessions and we continue to evolve and improve the design.
              What started out primarily as a coding program has evolved to become more hands-on and creative with a
              focus on invention.
            </p>
            <p>
              Most importantly the students are increasingly taking ownership of the environment, reflecting on
              everything from the challenges to the rules to the overall environment and providing us with feedback. This
              allows us to continue evolving the program in a direction that better meets the needs and interests of the
              students.
            </p>
          </div>
          <div className="col-xs-12 col-lg-4 text-xs-center text-lg-right">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/pivotal/image4.jpg" className="rounded img-fluid" alt="" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-8 offset-md-2 col-lg-6 offset-lg-3">
            <YouTube id="wMEgDLaMvU0" />
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
