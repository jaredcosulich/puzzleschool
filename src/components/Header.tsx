import Link from "next/link";

const NAV = [
  { label: "Home", href: "/" },
  { label: "Learn More", href: "/learn_more" },
  { label: "Programs", href: "/programs" },
  { label: "Technology", href: "/technologies" },
];

export default function Header() {
  return (
    <nav className="navbar navbar-fixed-top bg-faded">
      <div className="container">
        <Link href="/">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src="/images/darker_logo_small.png" alt="The Puzzle School" />
        </Link>
        <div className="float-xs-right text-xs-right">
          <ul className="nav navbar-nav text-muted">
            {NAV.map((item) => (
              <li className="nav-item" key={item.href}>
                <Link href={item.href} className="nav-link">
                  {item.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </nav>
  );
}
