import { Link } from "react-router";
import { APP_NAME } from "@/constants";
import { button } from "@/ui/Button";
import * as s from "./Home.css";

/** Landing banner introducing the app and leading to the map. */
export default function Home() {
  return (
    <section className={s.hero}>
      <h1 className={s.heroTitle}>{APP_NAME}</h1>
      <p className={s.heroTagline}>
        The NixOS modules and app configs of this repository, drawn from its
        folders.
      </p>
      <Link to="/map" className={button({ variant: "filled" })}>
        Open the map
      </Link>
    </section>
  );
}
