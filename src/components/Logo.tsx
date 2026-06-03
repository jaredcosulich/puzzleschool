import Link from "next/link";

export default function Logo() {
  return (
    <div className="logo-header text-xs-center">
      <h1 className="pt-3 mt-3">
        <Link href="/">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src="/images/darker_logo.png" className="logo img-fluid" alt="The Puzzle School" />
        </Link>
      </h1>
      <p className="text-uppercase py-3">
        A new public innovation school in the exploratory stage
        <br />
        Based in Cambridge, MA
      </p>
    </div>
  );
}
