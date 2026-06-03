import Link from "next/link";
import Footer from "@/components/Footer";
import YouTube from "@/components/YouTube";

export const metadata = { title: "Programs | The Puzzle School" };

export default function Programs() {
  return (
    <>
      <div className="container">
        <div className="row text-xs-center py-3 mt-3">
          <div className="col-xs-12 col-md-6 offset-md-3">
            <h1 className="py-3 title">Programs</h1>
            <p className="mt-1">We are currently designing and running programs in and around Cambridge.</p>
            <p>
              With each program we seek to work with the public school district, the after school community, or with a
              local business partner.
            </p>
          </div>
        </div>

        <div className="row pb-2">
          <div className="col-xs-12 col-md-8 offset-md-2 col-lg-6 offset-lg-3">
            <YouTube id="6PRKTd96A48" />
            <div className="small text-xs-center">
              From the <Link href="/programs/redesign_high_school">Redesign High School</Link> Program. Click
              &apos;Learn More&apos; below for more information.
            </div>
          </div>
        </div>

        <div className="row pb-2">
          <div className="col-xs-12 col-md-8 offset-md-2 col-lg-6 offset-lg-3">
            <YouTube id="XlrA0otiTHk" />
            <div className="small text-xs-center">
              From the <Link href="/programs/cambridge_inventors">Cambridge Inventors Club</Link> Program. Click
              &apos;Learn More&apos; below for more information.
            </div>
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 col-md-7 col-lg-5 offset-lg-2">
            <h5>Cambridge Inventors Club</h5>
            <p>
              We&apos;ve partnered up with{" "}
              <a href="https://pivotal.io/labs" target="_blank" rel="noopener noreferrer">
                Pivotal Labs
              </a>{" "}
              to create an invention club hosted in Kendall Sq.
            </p>
            <p>
              The program focuses on supporting students toward creative problem solving through technical skills such as
              coding and engineering. We connect passionate mentors from the local technology community with students to
              help them explore and work together to solve interesting challenges.
            </p>
            <p className="text-xs-center">
              <Link href="/programs/cambridge_inventors" className="btn btn-outline-primary px-2">
                Learn More
              </Link>
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs_thumb.png" className="rounded-circle" alt="Cambridge Inventors Club" />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-md-5 col-lg-3 offset-lg-2 hidden-xs-down text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/studentvoice.png" className="rounded-circle" alt="Redesign High School" />
          </div>
          <div className="col-xs-12 col-md-7 col-lg-5">
            <h5>Redesign High School</h5>
            <p>
              We meet with a small group of high school students on a weekly basis to discuss their educational
              experiences and what an ideal high school experience might look like.
            </p>
            <p>
              Topics range from the ideal class to how you can better support discussions of controversial topics to what
              the ideal schedule might look like to how you might deal with discipline in a school.
            </p>
            <p className="text-xs-center">
              <Link href="/programs/redesign_high_school" className="btn btn-outline-primary px-2">
                Learn More
              </Link>
            </p>
          </div>
          <div className="col-xs-12 text-xs-center hidden-sm-up">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/studentvoice.png" className="rounded-circle" alt="Redesign High School" />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 col-md-7 offset-lg-2 col-lg-5">
            <h5>Moses Youth Center</h5>
            <p>
              We have been running a weekly program at the Moses Youth Center in Cambridge. The program has ranged from
              coding to more active engineering challenges.
            </p>
            <p>
              Many of the students at the youth center are interested in athletics so we&apos;re hoping to explore
              program designs that support that passion in the near future.
            </p>
            <p className="text-xs-center">
              <Link href="/programs/moses_youth_center" className="btn btn-outline-primary px-2">
                Learn More
              </Link>
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/moses.png" className="rounded-circle" alt="Moses Youth Center" />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-md-5 col-lg-3 offset-lg-2 hidden-xs-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/thinking.png" alt="The Art of Thinking" />
          </div>
          <div className="col-xs-12 col-md-7 col-lg-5">
            <h5>The Art of Thinking</h5>
            <p>
              Students will explore different frameworks for thinking (e.g. Design Thinking, Computational Thinking,
              First-Principle Thinking) and will develop their skills for observation through artistic exercises,
              philosophic discussions, and problem solving challenges.
            </p>
            <p>
              Students will use these skills to reframe challenges and goals in their own lives. They will practice
              observing from different perspectives, developing their ability to empathize more effectively, and question
              their own assumptions.
            </p>
            <p>
              Lastly we&apos;ll explore the way these processes and techniques have been used throughout history and
              continue to be used across all adult professional activities. Students will be supported toward becoming
              philosophers of their own lives and interests.
            </p>
            <p>
              <b>Status:</b> Pilot currently running at Cambridge Street Upper School
            </p>
          </div>
          <div className="col-xs-12 text-xs-center hidden-sm-up">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/thinking.png" alt="The Art of Thinking" />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 col-md-7 offset-lg-2 col-lg-5">
            <h5>Drawing In Code</h5>
            <p>
              The Puzzle School is collaborating with David Ng, the founder of{" "}
              <a href="http://www.verticallearning.org" target="_blank" rel="noopener noreferrer">
                Vertical Learning Labs
              </a>
              , to develop an{" "}
              <a href="https://jaredcosulich.github.io/drawing_code/index.html" target="_blank" rel="noopener noreferrer">
                online resource
              </a>{" "}
              designed to support an exploration of artistic observation and computational thinking. Essentially students
              will learn how to teach a computer to draw and design games.
            </p>
            <p>
              Through a series of challenges students will develop their ability to observe their physical world and
              translate that into code so that a computer can draw it. From there students will be able to animate their
              drawing and make them interactive (games).
            </p>
            <p>
              The eventual goal is to support students toward projects of their own design that can then be shared with
              friends and family.
            </p>
            <p>
              <b>Status:</b> In Development
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/building.png" style={{ border: "1px solid #aaa" }} alt="Drawing In Code" />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-md-5 col-lg-3 offset-lg-2 hidden-xs-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/innovators_compass.png" style={{ border: "1px solid #aaa" }} alt="Innovator's Compass" />
          </div>
          <div className="col-xs-12 col-md-7 col-lg-5">
            <h5>The Innovator&apos;s Compass</h5>
            <p>
              One of The Puzzle School&apos;s advisors, Ela Ben-Ur, is a 15 year veteran of the world-renowned design
              firm, IDEO. Drawing on her experiences at IDEO Ela has created the{" "}
              <a href="http://innovatorscompass.org/" target="_blank" rel="noopener noreferrer">
                Innovator&apos;s Compass
              </a>
              , a simplified framework for engaging in Design Thinking.
            </p>
            <p>
              We are working with Ela to design programs that leverage the Innovator&apos;s Compass and Design Thinking
              toward problems that are personally important to students. This may range from choosing a college to a
              fight with a significant other or family member. In each situation student will be asked to observe their
              situation, brainstorm on what matters most, think through possible futures, think through experiments they
              could try to achieve their goal, and then repeat.
            </p>
            <p>
              <b>Status:</b> In Development
            </p>
          </div>
          <div className="col-xs-12 text-xs-center hidden-sm-up">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/innovators_compass.png" style={{ border: "1px solid #aaa" }} alt="Innovator's Compass" />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 col-md-7 offset-lg-2 col-lg-5">
            <h5>Forge Your Unique Path</h5>
            <p>
              We are exploring a series of questionaires and activities that can help students think about themselves
              more deeply. Students will explore their interests, their strengths, their weaknesses, and how they want to
              contribute to the world in a way that leverages their abilities and would add value to their community.
            </p>
            <p>
              Using this information students will brainstorm independent and group projects and will think about
              possible adult mentors who may be able to help them navigate toward their personal goals.
            </p>
            <p>
              <b>Status:</b> In Development
            </p>
          </div>
          <div className="col-xs-12 col-md-5 col-lg-3 text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/questionaire.png" style={{ border: "1px solid #aaa" }} alt="Forge Your Unique Path" />
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
