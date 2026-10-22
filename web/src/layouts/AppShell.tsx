import { Link, Outlet } from "react-router";
import { APP_NAME } from "@/constants";
import { ThemeToggle } from "@/ui/ThemeToggle";
import * as s from "./AppShell.css";

export default function AppShell() {
  return (
    <div className={s.shell}>
      <header className={s.appBar}>
        <Link to="/" className={s.title}>
          {APP_NAME}
        </Link>
        <ThemeToggle />
      </header>
      <main className={s.main}>
        <Outlet />
      </main>
    </div>
  );
}
