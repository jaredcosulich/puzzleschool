import Footer from "@/components/Footer";
import YouTube from "@/components/YouTube";

export const metadata = { title: "Redesign High School | The Puzzle School" };

export default function RedesignHighSchool() {
  return (
    <>
      <div className="container">
        <div className="row text-xs-center py-3 mt-3">
          <div className="col-xs-12 col-lg-8 offset-lg-2">
            <h1 className="py-3 title">Redesign High School</h1>
            <p className="mt-1">
              We&apos;ve been meeting with a small group of high school students to get their thoughts on the ideal
              school design and feedback on The Puzzle School design.
            </p>
          </div>
        </div>

        <div className="row pb-2">
          <div className="col-xs-12 col-md-8 offset-md-2 col-lg-6 offset-lg-3">
            <YouTube id="pv7s8AyucyY" />
          </div>
        </div>

        <div className="row py-2 mt-2">
          <div className="col-xs-12 col-md-10 offset-md-1 col-lg-6 offset-lg-1">
            <h5>The Goal</h5>
            <p>
              A primary goal of The Puzzle School is to put students at the center and give them greater ownership of
              their environment and their learning. So these discussions started out primarily as a way for us to get
              feedback about The Puzzle School design.
            </p>
            <p>
              The students we have been working with, though, have shown a great deal of interest in reflecting on their
              own educational experiences in search of a more effective school design.
            </p>
            <p>As such we&apos;ve had a wide range of discussions around:</p>
            <ul className="spaced_out">
              <li>Their experiences progressing through various schools</li>
              <li>How they might handle publicly racist/sexist/etc actions in the school community.</li>
              <li>What the ideal school schedule might be.</li>
              <li>What subjects should be required.</li>
              <li>How they are approaching getting into college and how that affects their school experience.</li>
              <li>What great teaching looks like.</li>
              <li>
                What they would want to explore if they were to engage in an independent project of their own design.
              </li>
            </ul>
          </div>
          <div className="col-xs-12 col-lg-4 text-xs-center text-lg-right">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/voice/image1.jpg" className="rounded img-fluid" alt="" />
            <div className="mt-3">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/programs/voice/image2.jpg" className="rounded img-fluid" alt="" />
            </div>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-lg-4 offset-lg-1 hidden-md-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/voice/image3.jpg" className="rounded img-fluid" alt="" />
          </div>
          <div className="col-xs-12 col-md-10 offset-md-1 offset-lg-0 col-lg-6">
            <h5>The Process</h5>
            <p>
              As our discussions progressed it became clear that many of the challenges the students saw in their
              educational experiences were not easily solved.
            </p>
            <p>This level of reflection has some significant benefits:</p>
            <ol className="spaced_out">
              <li>
                Students have an opportunity to develop their observational skills, their ability to articulate those
                observations, and their ability to empathize with the teachers and administrators at their school.
              </li>
              <li>
                As students recognize the complexity of the situation they often come to appreciate how hard everyone in
                the school is trying and may come to appreciate more what their school is doing for them.
              </li>
            </ol>
          </div>
          <div className="col-xs-12 hidden-lg-up text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/voice/image3.jpg" className="rounded img-fluid" alt="" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-10 offset-md-1 col-lg-6 offset-lg-1">
            <h5>Moving Forward</h5>
            <p>
              As The Puzzle School exploration progresses we hope to continue to get feedback directly from students.
              Eventually we will form a student advisory board, ideally consisting of students that will attend The Puzzle
              School.
            </p>
            <p>
              Once The Puzzle School exists these discussions will become regular practice as The Puzzle School
              continuously evolves to better meet the needs of students.
            </p>
          </div>
          <div className="col-xs-12 col-lg-4 text-xs-center text-lg-right">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/voice/image4.jpg" className="rounded img-fluid" alt="" />
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12 col-md-8 offset-md-2 col-lg-6 offset-lg-3">
            <YouTube id="6PRKTd96A48" />
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
