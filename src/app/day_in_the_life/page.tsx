import Logo from "@/components/Logo";
import Footer from "@/components/Footer";

export const metadata = { title: "A Day In The Life | The Puzzle School" };

const SCHEDULE = [
  { time: "8am - 10am", items: ["Flexible Arrival / Independent Projects"] },
  { time: "10am - 11:45am", items: ["Program / Class Time"] },
  { time: "11:45am - 12:30pm", items: ["Lunch Time"] },
  { time: "12:30pm - 1:30pm", items: ["Flex Time (experimental programs, club meetings, etc)"] },
  { time: "1:30pm - 3:15pm", items: ["Program / Class Time"] },
  { time: "3:15pm - 5:15pm", items: ["Extracurricular (sports, clubs, etc)"] },
  { time: "5:15pm - 6pm", items: ["Flexible Departure"] },
];

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="row py-3">
      <div className="col-xs-12 col-md-12 offset-lg-1 col-lg-10">
        <h4>{title}</h4>
        <div className="row py-2">{children}</div>
      </div>
    </div>
  );
}

export default function DayInTheLife() {
  return (
    <>
      <div className="container">
        <Logo />

        <div className="row py-2">
          <div className="col-xs-12 offset-lg-1 col-lg-8">
            <h4>What would a day in the life of a student look like?</h4>
            <p className="pt-1">
              This is the most frequent question we receive regarding the design of The Puzzle School.
            </p>
            <p>Below is an attempt to describe day to day activities and how they connect to the overall philosophy.</p>
          </div>
        </div>

        <Section title="A Sample Schedule">
          <div className="col-xs-12 col-md-6">
            <h5>Philosophy</h5>
            <p>
              Students may engage with The Puzzle School in different ways. One student may follow a more traditional
              pathway, taking courses and doing assignments, while another student may engage with the school in a
              self-directed manner, leveraging the school&apos;s resources in order to accomplish goals that are
              personally important to them.
            </p>
            <p>
              The schedule provided here shows a possible design for coordinated activities (e.g. a class or a club). All
              of these scheduled activities are optional. Students could, for example, engage in an independent project
              or an internship for the entire day.
            </p>
            <p>
              All students will be expected to meet with an advisor 1:1 at least one hour per week and all students will
              have to meet the required state standards, although we expect that many of The Puzzle School&apos;s
              activities will support student toward state standards without explicit instruction.
            </p>
          </div>
          <div className="col-xs-12 col-md-6" style={{ borderLeft: "1px solid #ccc" }}>
            <h5>Day To Day</h5>
            {SCHEDULE.map((s) => (
              <div key={s.time}>
                <strong>{s.time}</strong>
                <ul>
                  {s.items.map((i) => (
                    <li key={i}>{i}</li>
                  ))}
                </ul>
              </div>
            ))}
            <div>
              <strong>Important Notes</strong>
              <ul>
                <li className="pt-1">
                  This is not a definitive design, just one possibility. Many factors may change this design before the
                  school is opened.
                </li>
                <li className="pt-1">
                  All scheduled programs are optional. Students can use any time slot to engage in an independent
                  project, internship, etc.
                </li>
                <li className="pt-1">At some point each week each student will meet with an advisor 1:1 for an hour.</li>
              </ul>
            </div>
          </div>
        </Section>

        <Section title="Respect, Ownership, and Self-Direction">
          <div className="col-xs-12 col-md-6">
            <h5>Philosophy</h5>
            <p>
              The primary goal of The Puzzle School is to support students toward taking ownership of their education,
              their lives, and the school itself, with an eye toward their future and their community.
            </p>
            <p>There are two primary aspects of this goal that we focus on:</p>
            <ol>
              <li className="pb-1">
                The hypothesis that human beings do their best work when they feel respected in their environment and
                have control of their lives, their decisions, etc.
              </li>
              <li>
                The observation that there are skills, processes, and techniques that can help all people be more
                observant and intentional in their lives, supporting their ability to navigate the world in a
                self-directed manner.
              </li>
            </ol>
            <p>
              It is important to note that this does not imply that students should simply do whatever they want. Their
              decisions affect other people and the decisions of other people affect them, so they need to be conscious
              of how their decisions interact with and affect their community, their future, etc.
            </p>
          </div>
          <div className="col-xs-12 col-md-6" style={{ borderLeft: "1px solid #ccc" }}>
            <h5>Day To Day</h5>
            <p>
              There are a number of techniques we hope to leverage to support students toward greater ownership and
              self-direction.
            </p>
            <ul>
              <li className="pb-1">
                <strong>Feedback</strong>
                <br />
                We will seek feedback from students in numerous ways, asking them for their observations about programs,
                resources, how the school runs, etc. and inviting them to help us improve everything. As they come to
                trust that their feedback and ideas are respected, we believe they will become more empowered and will
                take greater control over all aspects of their education.
              </li>
              <li className="pb-1">
                <strong>Self-Directed Pathways</strong>
                <br />
                Every student will have at least one self-directed pathway they have designed for themselves with the
                help of an adult advisor. These pathways can range from an independent project to an internship to an
                online course to a book club with friends to starting a company. The important part is that they have
                designed it themselves or with a group and have ownership over the ideas and process.
              </li>
              <li className="pb-1">
                <strong>Negotiated Competencies</strong>
                <br />
                Students will be encouraged to challenge the requirements and develop a rationale for why their
                educational experience should be different with regard to their plans for the future. The goal will be to
                find alignment between students, parents, and the school with regard to any requirements.
              </li>
            </ul>
          </div>
        </Section>

        <Section title="Appreciation for the Present vs. Preparation for the Future">
          <div className="col-xs-12 col-md-6">
            <h5>Philosophy</h5>
            <p>
              Finding the right balance between learning and creating in an effort to gain acceptance to college or build
              a resume vs. thriving in a healthy manner and enjoying the present moment is one of the greatest challenges
              we all face, but it is a particularly distinct challenge for students.
            </p>
            <p>
              The puzzle-solving process provides support for navigating this challenge. As students become more
              thoughtful about their goals, both short term and long term, more observant of their own behaviors and
              intentional with their actions the specifics of what they are learning become less important. The
              underlying critical thinking skills they are learning will help them approach learning anything more
              effectively.
            </p>
            <p>
              The Puzzle School combines this with requirements and dialog with advisors in order to help students think
              about their future more effectively. While this does not guarantee a successful balancing of these
              concerns, it does provide multiple ways for students, teachers, and parents, to iterate toward an effective
              balance.
            </p>
          </div>
          <div className="col-xs-12 col-md-6" style={{ borderLeft: "1px solid #ccc" }}>
            <h5>Day To Day</h5>
            <p>
              Students, advisors, and parents will engage in frequent dialog around how to find the best balance between
              thriving in the present and preparing for the future (ideally achieving both):
            </p>
            <ul>
              <li className="pb-1">
                <strong>Personal Interests</strong>
                <br />
                One primary strategy will be to explore both current personal interests and ideas about future interests.
                Even younger students may have a sense of what interests them or what kind of life they want to live in
                the future. That exploration can both help to prepare for the future while ensuring that students are
                appreciating the present.
              </li>
              <li className="pb-1">
                <strong>Generally Relevant Challenges</strong>
                <br />
                Students may be interested in helping to run the school, exploring how the school budget is spent or how
                discipline works, etc. Or they may be interested in saving up for a big purchase, such as a car. Many of
                these present day goals will help students prepare for their future through contexts that are relevant
                and interesting today.
              </li>
              <li className="pb-1">
                <strong>Fun, Relaxation, and Direct Preparation</strong>
                <br />
                Sometimes, though, it will be necessary for students to engage in something that is more directly about
                preparing for the future or thriving in the present. As a school we will try to support both necessary
                relaxation, socialization, and fun that is crucial to healthy development (even with older students), as
                well as future skills, such as test taking, completing assignments on time, etc., that are worthwhile
                preparation even if not directly tied to current interests.
              </li>
            </ul>
          </div>
        </Section>

        <Section title="Personal Interests vs. Requirements">
          <div className="col-xs-12 col-md-6">
            <h5>Philosophy</h5>
            <p>
              The Puzzle School feels there is nothing more important than a student who understands who they are and has
              a healthy perspective about their ability to grow and change. A student who is reflective about their
              strengths, weaknesses, interests, goals, etc. can be more intentional and honest with their lives.
              Supporting students in this exploration and the activities that arise out of this exploration is a big part
              of The Puzzle School experience.
            </p>
            <p>
              At the same time there are challenges ahead that students are not always aware of and challenges the school
              faces such as state standards and general operational concerns that students must be conscientious of.
            </p>
            <p>
              In general we believe that dialog presents the best opportunity to navigate these challenges. We believe
              that students, when treated with respect and provided opportunities to make informed decisions with the
              support of competent adults are capable of navigating these challenges. As such The Puzzle School will
              present students with the best description of the challenges they may face in their future or that the
              school faces today and will work with students to develop and iterate on strategies for overcoming these
              challenges.
            </p>
          </div>
          <div className="col-xs-12 col-md-6" style={{ borderLeft: "1px solid #ccc" }}>
            <h5>Day To Day</h5>
            <p>
              The Puzzle School will explore a variety of strategies for providing students with opportunities for dialog
              with adults who can help them think about their future and make thoughtful decisions in the present. Some of
              these strategies will include:
            </p>
            <ul>
              <li className="pb-1">
                <strong>Advisor Discussions</strong>
                <br />
                Weekly discussions with advisors will ensure that students have someone to discuss their personal
                exploration with who can help them brainstorm on how to move toward personal goals. Advisors will also be
                responsible for ensuring students do not slip through the cracks and are making progress on their
                competencies.
              </li>
              <li className="pb-1">
                <strong>Recent Graduate Mentorship</strong>
                <br />
                As soon there are graduates from The Puzzle School we will seek to connect them with current students to
                provide advice on college and life after The Puzzle School from the perspective of a recent graduate.
              </li>
              <li className="pb-1">
                <strong>Community Mentorship &amp; Internships</strong>
                <br />
                Meeting with other adult mentors or leaving the school to engage in an internship both provide
                opportunities for students to gain exposure to the requirements of college, jobs, and life after The
                Puzzle School.
              </li>
            </ul>
          </div>
        </Section>

        <Section title="Flexible and Responsive vs. Structure and Stability">
          <div className="col-xs-12 col-md-6">
            <h5>Philosophy</h5>
            <p>
              The Puzzle School will practice the puzzle philosophy itself. We will constantly seek to become more
              flexible and responsive to student needs as they come up.
            </p>
            <p>
              At the same time it is important to provide a structured environment that effectively utilizes resources
              and is organized and coordinated so that students get the help they need while developing their skills for
              self-direction.
            </p>
          </div>
          <div className="col-xs-12 col-md-6" style={{ borderLeft: "1px solid #ccc" }}>
            <h5>Day To Day</h5>
            <p>
              Between structured programs, negotiated competencies, feedback processes, self-directed pathways, and
              mentorship in various forms, The Puzzle School will seek to create a healthy environment that students and
              parents appreciate.
            </p>
            <p>
              Maybe most importantly, though, The Puzzle School will listen to students and parents and will attempt to
              find solutions as problems arise. If something isn&apos;t working well for a student then every effort
              (within the resource constraints of the school) will be made to find a new path that works more effectively
              for the student.
            </p>
            <p>
              This process, of constant iteration and improvement, will be a daily experience for students and families.
              We believe it will help us identify problems earlier and maintain healthy communication between students,
              teachers, and parents.
            </p>
          </div>
        </Section>
      </div>

      <Footer />
    </>
  );
}
