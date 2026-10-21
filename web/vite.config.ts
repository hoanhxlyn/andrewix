import { reactRouter } from "@react-router/dev/vite";
import { vanillaExtractPlugin } from "@vanilla-extract/vite-plugin";
import { ondine } from "ondine/vite";
import Unfonts from "unplugin-fonts/vite";
import Icons from "unplugin-icons/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [
    reactRouter(),
    vanillaExtractPlugin(),
    ondine(),
    Icons({ compiler: "jsx", jsx: "react" }),
    Unfonts({
      fontsource: {
        families: ["Roboto Variable", "Roboto Mono Variable"],
      },
    }),
  ],
});
