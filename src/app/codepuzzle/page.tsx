import Link from "next/link";
import Footer from "@/components/Footer";
import { PROJECTS } from "@/lib/puzzles";

export const metadata = { title: "The Code Puzzle | The Puzzle School" };

export default function CodePuzzleIndex() {
  return (
    <>
      <div className="container">
        <div className="row text-xs-center py-3 mt-3">
          <div className="col-xs-12">
            <h1 className="title">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/technologies/codepuzzle.png" className="img-fluid" alt="The Code Puzzle" />
            </h1>
          </div>
        </div>

        <div className="row">
          <div className="col-xs-12 col-md-8 offset-md-2 text-xs-center">
            <p>
              The Code Puzzle is a &quot;learn to code&quot; activity. You arrange instruction cards — Move Forward,
              Rotate, Loop, Pen Color — into a program, and a turtle-graphics robot draws it out one step at a time.
            </p>
            <p>
              Pick a puzzle below to watch the code run. You can change the speed, pause, or click any card to jump to
              that step.
            </p>
            <p className="small text-muted">
              Note: the original puzzle library lived in a database that is no longer available, so these are
              reconstructed sample puzzles that run on the same engine.
            </p>
          </div>
        </div>

        <div className="row py-3">
          <div className="col-xs-12">
            <div className="cp-project-grid">
              {PROJECTS.map((project) => (
                <Link key={project.slug} href={`/codepuzzle/${project.slug}`} className="cp-project-card">
                  <h5>{project.title}</h5>
                  <p className="small text-muted mb-0">{project.description}</p>
                </Link>
              ))}
            </div>
          </div>
        </div>

        <div className="row py-2">
          <div className="col-xs-12 text-xs-center">
            <a href="/code_puzzle/cards.zip" className="btn btn-outline-primary px-3">
              Download the printable cards
            </a>
          </div>
        </div>
      </div>

      <Footer showQuotes={false} />
    </>
  );
}
