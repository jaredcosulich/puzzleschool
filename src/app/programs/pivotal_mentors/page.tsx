import Link from "next/link";
import Footer from "@/components/Footer";
import YouTube from "@/components/YouTube";

export const metadata = { title: "Pivotal Mentors | The Puzzle School" };

export default function PivotalMentors() {
  return (
    <>
      <div className="container">
        <div className="row text-xs-center py-3 mt-3">
          <div className="col-xs-12 col-lg-8 offset-lg-2">
            <h1 className="py-3 title">Pivotal Mentors &quot;Learn To Code&quot;</h1>
            <p className="mt-1">
              Starting in August of 2016 we partnered with{" "}
              <a href="https://pivotal.io/labs" target="_blank" rel="noopener noreferrer">
                Pivotal Labs
              </a>{" "}
              on an ongoing &quot;Learn To Code&quot; program we dubbed the &quot;Pivotal Mentors Program&quot;. As the
              program has evolved we have integrated in more hands-on engineering and creative art activities in an
              attempt to explore a wider range of design oriented experiences.
            </p>
            <h3 className="mt-3">Cambridge Inventors Club</h3>
            <p>
              The Pivotal Mentors Program is now the{" "}
              <Link href="/programs/cambridge_inventors">Cambridge Inventors Club</Link>
            </p>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-8 offset-md-2 col-lg-6 offset-lg-3">
            <YouTube id="wMEgDLaMvU0" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-10 offset-md-1 col-lg-6 offset-lg-1">
            <h5>The Goal</h5>
            <p>
              The goal for the program was simple. Can we make use of the Pivotal Labs office and coordinate some of the
              engineers at Pivotal Labs to help students in the Cambridge area learn how to code? We simply wanted to
              start by providing positive software development experiences for students in order to hopefully inspire
              some to continue learning more once the program was over and ensure that all students felt capable of
              coding if they ever did decide they wanted to pursue it later in life.
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
                Having students test resources and provide feedback in order to find the best resources students can use
                to learn at their own pace.
              </li>
              <li>
                Having students engage in hands-on group projects to support a healthy social environment and explore
                diverse design exercises.
              </li>
              <li>
                Running retrospectives at the end of each sessions to get feedback from students around what worked and
                didn&apos;t that week.
              </li>
              <li>
                Supporting students toward independent and small group projects they design themselves and will continue
                working on at home.
              </li>
            </ul>
            <p>Some of the resources and activities we&apos;ve had success with include:</p>
            <ul className="no_shift spaced_out">
              <li><a href="https://codecombat.com/" target="_blank" rel="noopener noreferrer">CodeCombat</a></li>
              <li><a href="https://projecteuler.net/" target="_blank" rel="noopener noreferrer">Project Euler</a></li>
              <li><a href="https://jaredcosulich.github.io/drawing_code" target="_blank" rel="noopener noreferrer">Drawing In Code</a></li>
              <li><a href="http://www.tomwujec.com/design-projects/marshmallow-challenge/" target="_blank" rel="noopener noreferrer">Marshmallow Towers</a></li>
              <li><a href="http://courses.washington.edu/engr100/Section_Brad/01_hnd_BridgeIntro.htm" target="_blank" rel="noopener noreferrer">Tongue Depressor Bridges</a></li>
            </ul>
            <p>
              We also developed a number of discrete challenge-based activities, including a scavenger hunt focused on
              decrypting messages using algorithms.
            </p>
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
          <div className="col-xs-12 col-md-10 offset-md-1">
            <blockquote className="blockquote py-2 bordered">
              <p className="small">
                <em>Charlie is really enjoying himself. He said what he likes most about it:</em>
              </p>
              <ul className="small">
                <li><em>The one on one help</em></li>
                <li>
                  <em>
                    The mentors don’t tell you what to do, but they work with you to help you figure it out yourself
                    (YaY)
                  </em>
                </li>
                <li><em>Really enjoys the connection with the tutors/mentors</em></li>
              </ul>
              <p className="mb-0 small">
                <em>
                  Charlie is finding communicating and learning easy in this environment. He does not have a lot of
                  opportunities to interact with adults who inspire him the way the mentors in the program have so far. He
                  loves that connection and he always leaves Monday night feeling so good about himself and his time at
                  the open space. Before he went to bed he asked me, “Why can’t school be like coding class, I would be so
                  excited to go in the morning.&quot;
                </em>
              </p>
              <footer className="blockquote-footer text-xs-right small">Mary (Charlie&apos;s Mom)</footer>
            </blockquote>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-10 offset-md-1 col-lg-6 offset-lg-1">
            <h5>The Results So Far</h5>
            <p>
              We&apos;ve now run the program twice. In the first 7-week session we focused mostly on coding exercises. In
              the second session we&apos;ve opened up the design to do more hands-on activities.
            </p>
            <p>
              Both styles of activities have been well-received although the hands-on activities are clearly more
              engaging. Most recently we&apos;ve been exploring activities that bridge the gap between coding and a
              hands-on, more active experience, such as &quot;coding&quot; instructions on index cards that describe how
              to draw something simple and then seeing if another team can properly draw the same thing from your
              instructions.
            </p>
            <p>
              These hybrid activities have been well-received as well, but require more iteration in order to find
              activities that are active and hands-on but also help students develop their coding skills.
            </p>
          </div>
          <div className="col-xs-12 col-lg-4 text-xs-center text-lg-right">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/pivotal/image4.jpg" className="rounded img-fluid" alt="" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-8 offset-md-2 col-lg-6 offset-lg-3">
            <YouTube id="vS_m7DIDGS8" />
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
