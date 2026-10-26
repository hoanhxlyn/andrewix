import { NuqsAdapter } from "nuqs/adapters/react-router/v8";
import { Links, Meta, Outlet, Scripts, ScrollRestoration } from "react-router";
import { preloadSettings } from "@/atoms/settings";
import { APP_NAME } from "@/constants";
import "unfonts.css";
import "./styles/global.css";

export function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <meta charSet="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>{APP_NAME}</title>
        <script src="/theme-init.js" />
        <Meta />
        <Links />
      </head>
      <body>
        {children}
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}

// The stored settings are read before the first render, so the sidebar, the open tabs and the
// gallery layout show as left instead of flashing their defaults. Later navigations reuse the read.
export async function clientLoader() {
  await preloadSettings();
  return null;
}

export default function Root() {
  return (
    <NuqsAdapter>
      <Outlet />
    </NuqsAdapter>
  );
}

export function HydrateFallback() {
  return null;
}
