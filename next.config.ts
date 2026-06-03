import type { NextConfig } from "next";

// The site is served from the custom domain puzzleschool.org at the root path,
// so no basePath is needed. (GitHub Pages + a CNAME serves the site at "/".)
const nextConfig: NextConfig = {
  output: "export",
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
