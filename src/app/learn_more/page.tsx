import Link from "next/link";
import Logo from "@/components/Logo";
import Footer from "@/components/Footer";

export const metadata = { title: "Learn More | The Puzzle School" };

export default function LearnMore() {
  return (
    <>
      <div className="container">
        <Logo />

        <div className="row py-2">
          <div className="col-md-5 col-lg-3 offset-lg-2 hidden-sm-down">
            <a href="/PuzzleSchoolDescription.pdf" target="_blank" rel="noopener noreferrer">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/puzzleschool_pdf.png" alt="Puzzle School description PDF" />
            </a>
          </div>

          <div className="col-xs-12 col-md-7 col-lg-5">
            <h5>The Puzzle School Exploration</h5>
            <p>
              We are in the early stages of exploring a new public innovation high school or middle school in Cambridge,
              MA. The innovation school model, described below, works within the local district.
            </p>
            <p>
              The &quot;puzzle&quot; metaphor is about a process rather than a specific design. The process consists of
              deep observations, developing and testing hypotheses, and seeking feedback as you make progress toward your
              goal.
            </p>
            <p>
              This process will inform all aspects of The Puzzle School, from how the school is run to the student&apos;s
              day-to-day experience to how students approach their own learning.
            </p>
            <p>
              You can read more in this{" "}
              <a href="/PuzzleSchoolDescription.pdf" target="_blank" rel="noopener noreferrer">
                pdf description
              </a>{" "}
              of The Puzzle School.
            </p>
          </div>

          <div className="col-xs-12 text-xs-center hidden-md-up">
            <a href="/PuzzleSchoolDescription.pdf" target="_blank" rel="noopener noreferrer">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/puzzleschool_pdf.png" alt="Puzzle School description PDF" />
            </a>
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 col-md-8 offset-lg-2 col-lg-5">
            <h5>The Innovation School Model</h5>
            <p>
              The Innovation Schools initiative was signed into law in January 2010. It allows districts to explore
              innovative ideas while keeping school funding within districts.
            </p>
            <p>
              It requires that the Superintendent, Teacher&apos;s Union (Cambridge Education Association), and the School
              Committee all have a voice in the planning process and a vote in the approval process.
            </p>
            <p>There are currently 50 innovations schools around Massachusetts including 7 in Boston.</p>
            <p>There are not yet any innovation schools in Cambridge.</p>
          </div>

          <div className="col-xs-12 col-md-4 col-lg-3 text-xs-center text-md-right">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/massachusetts-seal.jpg" alt="Massachusetts seal" />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-md-5 offset-lg-2 col-lg-3 hidden-sm-down">
            <Link href="/day_in_the_life">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/day_to_day.png" alt="A day in the life" />
            </Link>
          </div>

          <div className="col-xs-12 col-md-7 col-lg-5">
            <h5>A Day In The Life</h5>
            <p>
              What would a day in the life be like at The Puzzle School? It&apos;s a difficult question to answer, but
              we&apos;ve provided some thoughts on:
            </p>
            <ul className="no_shift spaced_out">
              <li>A sample schedule.</li>
              <li>Appreciating the Present vs. Preparing for the Future</li>
              <li>Personal Interests vs. Requirements</li>
            </ul>
            <p>
              Read more about <Link href="/day_in_the_life">a day in the life &gt;</Link>
            </p>
          </div>

          <div className="col-xs-12 hidden-md-up text-xs-center">
            <Link href="/day_in_the_life">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/day_to_day.png" alt="A day in the life" />
            </Link>
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 col-md-9 col-lg-6 offset-lg-2">
            <h5>Our Programs</h5>
            <p>
              We are currently running programs with students in Cambridge. Some of the programs we have run or are
              developing include:
            </p>
            <ul className="no_shift spaced_out">
              <li>Exploring student interests, strengths, and problems they are interested in solving in the world.</li>
              <li>Exploring math, art, and self expression through coding.</li>
              <li>Helping students think through goals and problems in their own lives using Design Thinking.</li>
            </ul>
            <p>
              Read more about our <Link href="/programs">programs &gt;</Link>
            </p>
          </div>

          <div className="col-xs-12 col-md-3 col-lg-2 text-xs-center text-md-right">
            <Link href="/programs">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/programs_thumb.png" className="rounded-circle" alt="Programs" />
            </Link>
          </div>
        </div>

        <div className="row py-3">
          <div className="col-md-5 offset-lg-2 col-lg-3 hidden-sm-down">
            <Link href="/technologies">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/images/technologies/thoughtfulrecommendations.png"
                className="img-fluid rounded-circle"
                alt="Technology"
              />
            </Link>
          </div>

          <div className="col-xs-12 col-md-7 col-lg-5">
            <h5>Technology / Research &amp; Development</h5>
            <p>The Puzzle School believes that technology can play an effective role in helping schools to:</p>
            <ul>
              <li>Ensure all voices in the school community are heard</li>
              <li>Communicate more effectively with families</li>
              <li>Support students in diverse pathways</li>
              <li>Help students connect with mentors and internships</li>
              <li>Support new and innovative ways to learn</li>
            </ul>
            <p>
              Read more about <Link href="/technologies">technology &gt;</Link>
            </p>
          </div>

          <div className="col-xs-12 hidden-md-up text-xs-center">
            <Link href="/technologies">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/images/technologies/thoughtfulrecommendations.png"
                className="img-fluid rounded-circle"
                alt="Technology"
              />
            </Link>
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 col-md-9 col-lg-6 offset-lg-2">
            <h5>Our Advisors</h5>
            <p>The Puzzle School is working with educational leaders from around Cambridge.</p>
            <p>
              They represent decades of teaching experience and have started, run, and worked for innovative and
              prominent schools in the country:
            </p>
            <ul className="no_shift spaced_out">
              <li>A co-founder of High Tech High</li>
              <li>A co-executive director of Big Picture Learning</li>
              <li>Instructors from MIT, Olin, and Boston College</li>
              <li>The founder of Science Club for Girls</li>
            </ul>
            <p>
              Learn more about our <Link href="/advisors">advisors &gt;</Link>
            </p>
          </div>

          <div className="col-xs-12 col-md-3 col-lg-2 text-xs-center">
            <div className="row">
              {["kuldell", "riordan", "bristol", "osullivan", "ben-ur", "frishman"].map((name) => (
                <div className="col-xs-4 col-sm-2 col-md-6 pb-1" key={name}>
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={`/images/advisors/${name}-thumb.jpg`} className="rounded" alt={name} />
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
