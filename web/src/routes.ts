import {
  index,
  layout,
  type RouteConfig,
  route,
} from "@react-router/dev/routes";

export default [
  layout("components/AppShell.tsx", [
    index("routes/Home.tsx"),
    route("design", "routes/Design.tsx"),
    route("*", "routes/NotFound.tsx"),
  ]),
] satisfies RouteConfig;
