import Link from "next/link";
import { notFound } from "next/navigation";
import Footer from "@/components/Footer";
import CodePuzzle from "@/components/CodePuzzle";
import { PROJECTS, getProject } from "@/lib/puzzles";

export function generateStaticParams() {
  return PROJECTS.map((p) => ({ project: p.slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ project: string }> }) {
  const { project: slug } = await params;
  const project = getProject(slug);
  return { title: `${project?.title ?? "Code Puzzle"} | The Puzzle School` };
}

export default async function CodePuzzleProject({ params }: { params: Promise<{ project: string }> }) {
  const { project: slug } = await params;
  const project = getProject(slug);
  if (!project) notFound();

  return (
    <>
      <div className="container">
        <div className="row text-xs-center py-3 mt-3">
          <div className="col-xs-12">
            <h1 className="title">{project.title}</h1>
            <p className="text-muted">{project.description}</p>
            <p className="small">
              <Link href="/codepuzzle">&larr; All Code Puzzles</Link>
            </p>
          </div>
        </div>

        <div className="row pb-3">
          <div className="col-xs-12">
            <CodePuzzle cards={project.cards} title={project.title} />
          </div>
        </div>
      </div>

      <Footer showQuotes={false} />
    </>
  );
}
