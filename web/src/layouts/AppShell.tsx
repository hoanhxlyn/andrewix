import { Link, Outlet } from "react-router";
import { APP_NAME } from "@/constants";
import { ThemeToggle } from "@/ui/ThemeToggle";
import * as s from "./AppShell.css";

export default function AppShell() {
  return (
    <div className={s.shell}>
      <header className={s.appBar}>
        <Link to="/" className={s.title} viewTransition>
          {APP_NAME}
        </Link>
        <nav className={s.nav}>
          <Link to="/walls" className={s.navLink} viewTransition>
            Wallpapers
          </Link>
          <ThemeToggle />
        </nav>
      </header>
      <main className={s.main}>
        <Outlet />
      </main>
    </div>
  );
}
