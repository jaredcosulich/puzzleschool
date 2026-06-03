import Footer from "@/components/Footer";

export const metadata = { title: "Advisors | The Puzzle School" };

const ADVISORS = [
  {
    name: "Andrew Frishman",
    img: "frishman",
    bio: "Andrew Frishman is the Co-Executive Director of Big Picture Learning; he completed his Doctorate of Education Leadership at the Harvard Graduate School of Education. Big Picture Learning includes a growing network of schools with over 65 currently in the US, and many more around the world, all focused on putting students at the center of their own learning. Andrew has one child currently in Cambridge Public Schools and his other will enter Jr. Kindergarten in CPS next year.",
  },
  {
    name: "Natalie Kuldell",
    img: "kuldell",
    bio: "Natalie Kuldell is the Executive Director of BioBuilder and the President of the BioBuilder Educational Foundation that aims to convert current research into teachable forms. She is also an instructor at MIT in the Department of Biological Engineering focusing on developing discovery-based curricula drawn from current literature. She completed her doctoral and post-doctoral work at Harvard Medical School, and taught at Wellesley College before joining the faculty at MIT.",
  },
  {
    name: "Travis Bristol",
    img: "bristol",
    bio: "Dr. Travis J. Bristol, a former high school English teacher in New York City public schools and teacher educator with the Boston Teacher Residency program, is an Assistant Professor at Boston University where his research focuses on supporting and retaining teachers of color and the intersection of race and gender in schools. He holds an M.A. in the Teaching of English from Stanford University; a Ph.D. in Education Policy from Columbia University. Travis has two children in the Cambridge Public Schools.",
  },
  {
    name: "Ela Ben-Ur",
    img: "ben-ur",
    bio: "Ela Ben-Ur is the inventor of the Innovator's Compass, a simplified process for Design Thinking, and an adjunct assistant professor at Olin College. Ela worked for 13 years at renowned innovation firm IDEO where she co-founded IDEO’s Leadership Studio. Ela has also offered workshops through her alma mater, MIT (BS and MS in Mechanical Engineering), Sloan, Babson, Dartmouth and Harvard. Ela’s daughter is a student in Cambridge Public Schools.",
  },
  {
    name: "Khemenec Patin",
    img: "patin",
    bio: "Khemenec Pantin is an adjunct lecturer at Boston College focused on developing advocacy and critical analysis of social welfare policy through a class and racial lens. He also served as an Education Analyst for the NYC Department of Education and as a Senior Policy Advisor for Intergovernmental Affairs as a part of the NYC Young Men’s Initiative under the Mayor's Office of Strategic Planning. Khemenec has two children who are students in Cambridge Public Schools.",
  },
  {
    name: "Rob Riordan",
    img: "riordan",
    bio: "Rob Riordan, Ed.D., is a co-founder of High Tech High and President Emeritus of the HTH Graduate School of Education. A teacher, trainer, and program developer for over 45 years, he has worked with teams to develop 14 new K-12 schools. Rob taught at the Cambridge Rindge and Latin School, served as K-12 Language Arts Coordinator for Cambridge Public Schools, and was a part-time faculty member at the Harvard Graduate School of Education.",
  },
  {
    name: "Beth O'Sullivan",
    img: "osullivan",
    bio: "Beth co-founded the Science Club for Girls: a program that brings hands-on science clubs to 600 girls in the Boston area, working to close the socioeconomic and gender gaps in science. She also founded and directs the Mathemagics Workshop, which has created a series of games & activities designed to bring playful mathematics back into childrens’ experience of math.",
  },
  {
    name: "Alec Resnick",
    img: "resnick",
    bio: "Alec Resnick is the co-founder of Powderhouse Studios, a new innovation school in Somerville, MA, and recent winner of the nationwide XQ prize. Powderhouse Studios grew out of the work of sprout & co, a science education non-profit based in Somerville which has designed and run in- and afterschool programs with youth and evening programs with adults since 2009. Before sprout & co, Alec worked developing educational tools and toys and studied mathematics at MIT.",
  },
];

export default function Advisors() {
  return (
    <>
      <div className="container">
        <div className="row text-xs-center py-3 mt-3">
          <div className="col-xs-12 col-md-10 offset-md-1 col-lg-6 offset-lg-3">
            <h1 className="py-3 title">Puzzle School Advisors</h1>
            <p className="mt-1">
              We are actively connecting with prominent and innovative educators, designers, business people, scientists,
              etc. in the Cambridge area to advise the design of The Puzzle School. Our current advisors include:
            </p>
          </div>
        </div>

        {ADVISORS.map((a) => (
          <div className="row pt-2" key={a.img}>
            <div className="col-xs-12 col-md-5 col-lg-3 offset-lg-2 text-xs-center pb-2">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={`/images/advisors/${a.img}.jpg`} className="rounded-circle" alt={a.name} />
            </div>
            <div className="col-xs-12 col-md-7 col-lg-5">
              <h5>{a.name}</h5>
              <p>{a.bio}</p>
            </div>
          </div>
        ))}
      </div>

      <Footer />
    </>
  );
}
