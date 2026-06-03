import Footer from "@/components/Footer";
import YouTube from "@/components/YouTube";

export const metadata = { title: "Moses Youth Center | The Puzzle School" };

export default function MosesYouthCenter() {
  return (
    <>
      <div className="container">
        <div className="row text-xs-center py-3 mt-3">
          <div className="col-xs-12 col-lg-8 offset-lg-2">
            <h1 className="py-3 title">Moses Youth Center</h1>
            <p className="mt-1">We have been running weekly programs at the Moses Youth Center in Cambridge.</p>
          </div>
        </div>

        <div className="row pb-3">
          <div className="col-xs-12 col-md-8 offset-md-2 col-lg-6 offset-lg-3">
            <YouTube id="iW55C7Dl5V8" />
          </div>
        </div>

        <div className="row py-2 mt-2">
          <div className="col-xs-12 col-md-10 offset-md-1 col-lg-6 offset-lg-1">
            <h5>The Goal</h5>
            <p>
              The Moses Youth Center has offered us a lot of flexibility in running programs with the students who come to
              the center after school. We&apos;ve used this flexibility to explore a variety of experiences with the
              students:
            </p>
            <ul className="spaced_out">
              <li>Coding with CodeCombat and Scratch</li>
              <li>Robotics with drawing machines being developed at MIT&apos;s Media Lab</li>
              <li>Hands-on engineering challenges</li>
            </ul>
          </div>
          <div className="col-xs-12 col-lg-4 text-xs-center text-lg-right">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/moses/image1.jpg" className="rounded img-fluid" alt="" />
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 col-md-10 offset-md-1">
            <blockquote className="blockquote py-2 bordered">
              <p className="small">
                <em>The Puzzle School programming has energized our participants attitudes toward STEAM learning!</em>
              </p>
              <p className="small">
                <em>
                  Youth are regularly engaged in complex projects, where they are challenged to hypothesize, create,
                  experiment, design and collaborate with other thinkers. Jared, Romaine, and the other volunteers are
                  excellent at asking thought-provoking questions and encouraging a general curiosity for learning. We
                  are excited to continue to strengthen this partnership and the work that is resulting from it.
                </em>
              </p>
              <footer className="blockquote-footer text-xs-right small">
                Nicole Rodriguez (Director, Moses Youth Center)
              </footer>
            </blockquote>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-lg-4 offset-lg-1 hidden-md-down">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/moses/image2.jpg" className="rounded img-fluid" alt="" />
          </div>
          <div className="col-xs-12 col-md-10 offset-md-1 offset-lg-0 col-lg-6">
            <h5>Moving Forward</h5>
            <p>
              We continue to discuss with the students what they want to do. Some of the students are interested in
              athletics and have expressed interest in exploring activities that connect their love of basketball (and
              other sports) with scientific explorations such as those shown in ESPN&apos;s show{" "}
              <a href="http://www.espn.com/espn/sportscience/" target="_blank" rel="noopener noreferrer">
                Sports Science
              </a>
            </p>
            <p>
              Others have expressed their interest in the popular coding/gaming platform{" "}
              <a href="https://www.roblox.com/" target="_blank" rel="noopener noreferrer">
                Roblox
              </a>
              . This platform allows for students to build their own games in an environment that looks like Minecraft,
              but provides ways to explicitly code the environment.
            </p>
            <p>We are in the process of exploring both of these possibilities for future programs at the Youth Center.</p>
          </div>
          <div className="col-xs-12 hidden-lg-up text-xs-center">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/moses/image2.jpg" className="rounded img-fluid" alt="" />
          </div>
        </div>

        <div className="row">
          <div className="col-xs-12 col-md-6 text-xs-center py-3">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/moses/image3.jpg" className="rounded img-fluid" alt="" />
          </div>
          <div className="col-xs-12 col-md-6 text-xs-center py-3">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/images/programs/moses/image4.jpg" className="rounded img-fluid" alt="" />
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
