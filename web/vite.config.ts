import { fileURLToPath } from "node:url";
import { reactRouter } from "@react-router/dev/vite";
import { vanillaExtractPlugin } from "@vanilla-extract/vite-plugin";
import Unfonts from "unplugin-fonts/vite";
import Icons from "unplugin-icons/vite";
import { defineConfig } from "vite";
import { repoTree } from "./vite/repo-tree.ts";

export default defineConfig({
  resolve: { tsconfigPaths: true },
  // The config sources live above the app, so the dev server has to serve them from there.
  server: { fs: { allow: [fileURLToPath(new URL("..", import.meta.url))] } },
  plugins: [
    reactRouter(),
    vanillaExtractPlugin(),
    repoTree(),
    Icons({ compiler: "jsx", jsx: "react" }),
    Unfonts({
      fontsource: {
        families: ["Roboto Variable", "Roboto Mono Variable"],
      },
    }),
  ],
});
