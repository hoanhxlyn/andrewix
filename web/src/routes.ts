import {
  index,
  layout,
  type RouteConfig,
  route,
} from "@react-router/dev/routes";

export default [
  layout("layouts/AppShell.tsx", [
    index("routes/Home/Home.tsx"),
    route("walls", "routes/Walls/Walls.tsx", [
      route(":id", "routes/Walls/Wall.tsx"),
    ]),
    route("*", "routes/NotFound.tsx"),
  ]),
] satisfies RouteConfig;
