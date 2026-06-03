import Link from "next/link";

const QUOTES = [
  {
    text: "So this was the big secret historians keep to themselves: historical research is wildly seductive and fun. There's a thrill in the process of digging, then piecing together details like a puzzle.",
    author: "Nancy Horan",
  },
  {
    text: "As a kid, I was into music, played guitar in a band. Then I started acting in plays in junior high school and just got lost in the puzzle of acting, the magic of it. I think it was an escape for me.",
    author: "Michael J. Fox",
  },
  {
    text: "When you write non-fiction, you sit down at your desk with a pile of notebooks, newspaper clippings, and books and you research and put a book together the way you would a jigsaw puzzle.",
    author: "Janine di Giovanni",
  },
  {
    text: "I tell people all the time, as I was going through my process of being a comedian or being an actor and a writer at 'SNL,' I tell people that everything you do is all a piece of your puzzle to determine where you're going to end up at.",
    author: "J. B. Smoove",
  },
];

export default function Footer({ showQuotes = true }: { showQuotes?: boolean }) {
  return (
    <>
      {showQuotes && (
        <div className="container">
          <div className="row py-3">
            <div className="col-xs-10 offset-xs-1 col-lg-6 offset-lg-3">
              {QUOTES.map((q) => (
                <div className="pt-2 pb-3" key={q.author}>
                  <p>“{q.text}”</p>
                  <p className="text-xs-right">~ {q.author}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      <footer className="footer">
        <div className="container">
          <div className="row text-muted">
            <div className="col-xs-4 py-1 my-1">
              <p><Link href="/learn_more">Learn More</Link></p>
              <p><Link href="/technologies">Technology</Link></p>
              <p><Link href="/programs">Programs</Link></p>
              <p><Link href="/contact">Contact</Link></p>
            </div>
            <div className="col-xs-4 py-3 text-xs-center">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src="/images/compass_small.png" alt="Compass" />
            </div>
            <div className="col-xs-4 py-1 my-1 text-xs-right">
              &copy; <span className="hidden-xs-down">Puzzle School</span> 2018
              <div className="pt-2 text-xs-right" style={{ paddingRight: 27 }}>
                <p>Follow Us On</p>
                <a href="https://www.facebook.com/puzzleschool/" target="_blank" rel="noopener noreferrer">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src="/images/facebook.png" alt="Facebook" />
                </a>
                &nbsp; &nbsp;
                <a href="https://twitter.com/puzzleschool" target="_blank" rel="noopener noreferrer" style={{ marginRight: 3 }}>
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src="/images/twitter.png" alt="Twitter" />
                </a>
              </div>
            </div>
          </div>

          <div className="row text-muted mt-3">
            <div className="col">
              <p>
                <small>
                  * The Puzzle School does not and shall not discriminate on the basis of race, color, religion (creed),
                  gender, gender expression, age, national origin (ancestry), disability, marital status, sexual
                  orientation, or military status, in any of its activities or operations. These activities include, but
                  are not limited to, hiring and firing of staff, selection of volunteers and vendors, and provision of
                  services. We are committed to providing an inclusive and welcoming environment for all members of our
                  staff, clients, volunteers, subcontractors, vendors, and clients.
                </small>
              </p>
              <p>
                <small>
                  * The Puzzle School is an equal opportunity employer. We will not discriminate and will take
                  affirmative action measures to ensure against discrimination in employment, recruitment, advertisements
                  for employment, compensation, termination, upgrading, promotions, and other conditions of employment
                  against any employee or job applicant on the bases of race, color, gender, national origin, age,
                  religion, creed, disability, veteran&apos;s status, sexual orientation, gender identity or gender
                  expression.
                </small>
              </p>
            </div>
          </div>
        </div>
      </footer>
    </>
  );
}
