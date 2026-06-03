import type { Metadata } from "next";
import "./globals.css";
import Header from "@/components/Header";

export const metadata: Metadata = {
  title: "The Puzzle School",
  description:
    "An educational philosophy focused on developing the metacognitive skills for navigating ambiguity. A new public innovation school in the exploratory stage, based in Cambridge, MA.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link
          href="https://fonts.googleapis.com/css?family=Roboto:400,700"
          rel="stylesheet"
        />
      </head>
      <body>
        <Header />
        <div className="site-content">{children}</div>
      </body>
    </html>
  );
}
