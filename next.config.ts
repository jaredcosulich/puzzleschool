import type { NextConfig } from "next";

const isProduction = process.env.NODE_ENV === 'production'
const repoName = 'puzzleschool'

const nextConfig: NextConfig = {
  basePath: isProduction ? `/${repoName}` : '',
  output: "export",
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
