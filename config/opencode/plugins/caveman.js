// caveman — OpenCode V2 plugin: auto-activate the ultracave skill.
//
// Mirrors config/claude/caveman-flag-hook.sh: watch every submitted prompt for
// an activation phrase, keep the mode in a flag file, and attach the skill on
// each turn while it is on.
//
// OpenCode auto-discovers standalone plugins in <config-root>/plugin|plugins/*.{ts,js},
// so the home-manager symlink into ~/.config/opencode/plugins is enough; there is
// no settings.plugins entry and no npm package.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const SKILL = "ultracave";
const ON = "ultra";
const OFF = "off";
// Auto-on: a missing flag file means active. Deactivation persists "off".
const DEFAULT = ON;

// Deactivation wins over activation: "/caveman off" also matches the bare
// "/caveman" activation pattern.
const STOP = /stop caveman|normal mode|(^|\s)\/caveman\s+(off|stop)\b/i;
const START =
  /(^|\s)\/ultracave(\s|$)|(^|\s)\/caveman(\s+(ultra|on))?(\s|$)|\bcaveman mode\b|\btalk like caveman\b|\buse caveman\b/i;

export function parseCavemanText(text) {
  const value = String(text ?? "");
  if (STOP.test(value)) return OFF;
  if (START.test(value)) return ON;
  return null;
}

export function parseCavemanArgs(args, active) {
  const value = String(args ?? "").trim().toLowerCase();
  if (value === "off" || value === "stop") return OFF;
  if (value === "on" || value === ON) return ON;
  if (value === "status") return "status";
  if (value) return "invalid";
  // Bare /caveman turns it on, or reports the level when it already is on (same as /ponytail).
  return active ? "status" : ON;
}

function statePath() {
  return path.join(
    process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config"),
    "opencode",
    ".caveman-active",
  );
}

function readMode() {
  try {
    return fs.readFileSync(statePath(), "utf8").trim() === OFF ? OFF : ON;
  } catch {
    return DEFAULT;
  }
}

function writeMode(mode) {
  fs.mkdirSync(path.dirname(statePath()), { recursive: true });
  fs.writeFileSync(statePath(), mode);
}

async function hasSkill(ctx) {
  try {
    const listed = await ctx.skill.list();
    const skills = Array.isArray(listed) ? listed : (listed?.items ?? listed?.skills ?? []);
    return skills.some((skill) => skill.id === SKILL);
  } catch {
    return false;
  }
}

export default {
  id: "caveman",

  async setup(ctx) {
    // Auto-on: persist the default so `cat ~/.config/opencode/.caveman-active`
    // reflects the mode. A missing file also means on.
    if (!fs.existsSync(statePath())) writeMode(DEFAULT);

    // "prompt" fires on every submitted prompt and the mutated value is the one
    // the session sends. Attaching the skill is how V2 injects its body: core
    // resolves it through Skill.prepare and pastes the content into the message.
    await ctx.session.hook("prompt", async (input) => {
      const active = readMode() === ON;
      const change = parseCavemanText(input.prompt?.text);

      if (change === OFF) {
        if (active) {
          writeMode(OFF);
          console.log("caveman off");
        }
        return;
      }
      if (change === ON && !active) {
        writeMode(ON);
        console.log("caveman " + ON);
      }
      if (change !== ON && !active) return;

      if (!(await hasSkill(ctx))) return;
      const skills = (input.prompt.skills ??= []);
      if (!skills.some((skill) => skill.id === SKILL)) skills.push({ id: SKILL, name: SKILL });
    });

    await ctx.command.transform((editor) => {
      editor.add({
        name: "caveman",
        description: "Caveman compression: on | off | status",
        execute: async ({ sessionID, prompt, delivery }) => {
          const active = readMode() === ON;
          const action = parseCavemanArgs(prompt.text, active);
          if (action === "status") {
            await ctx.session.prompt({ ...prompt, sessionID, text: "caveman status: " + (active ? ON : OFF), delivery });
            return;
          }
          if (action === "invalid") return;
          writeMode(action);
          await ctx.session.prompt({
            ...prompt,
            sessionID,
            text: action === ON ? "caveman on" : "normal mode",
            delivery,
          });
        },
      });
    });
  },
};
