import {
  index,
  layout,
  type RouteConfig,
  route,
} from "@react-router/dev/routes";

export default [
  layout("layouts/AppShell.tsx", [
    index("routes/Home/Home.tsx"),
    route("map", "routes/Map/Map.tsx"),
    route("*", "routes/NotFound.tsx"),
  ]),
] satisfies RouteConfig;
