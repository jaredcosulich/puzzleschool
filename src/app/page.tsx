import Link from "next/link";
import Logo from "@/components/Logo";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <>
      <div className="container">
        <Logo />

        <div className="row py-1">
          <div className="col-xs-12 text-xs-center">
            <p>
              “Math, it&apos;s a puzzle to me.
              <br className="hidden-sm-up" /> I love figuring out puzzles.”
              <br className="hidden-sm-up" /> ~ Maya Lin
            </p>
            <p>
              “For me, writing <span className="hidden-xs-down">a novel</span> is like solving a puzzle.”
              <br className="hidden-sm-up" /> ~ Mohsin Hamid
            </p>
            <p>
              “Once I get on a puzzle, I can&apos;t get off.”
              <br className="hidden-sm-up" /> ~ Richard Feynman
            </p>
          </div>
        </div>

        <div className="row pt-3 pb-2">
          <div className="col-xs-12 text-xs-center">
            <a
              href="/PuzzleSchool-DesignMetaphor.pdf"
              className="btn btn-outline-primary btn-lg mx-2 px-3 mb-2"
            >
              The Design Metaphor
            </a>
          </div>
        </div>

        <div className="row pt-2 pb-2">
          <div className="col-xs-12 text-xs-center">
            <Link href="/learn_more" className="btn btn-outline-primary btn-lg mx-2 px-3 mb-2">
              Learn More
            </Link>
            <Link href="/programs" className="btn btn-outline-primary btn-lg mx-2 mb-2">
              Current Programs
            </Link>
            <Link href="/technologies" className="btn btn-outline-primary btn-lg mx-2 mb-2">
              Technology R&amp;D
            </Link>
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
