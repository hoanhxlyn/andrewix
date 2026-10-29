import { beforeEach, expect, test } from "bun:test";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import plugin, { parseCavemanArgs, parseCavemanText } from "../caveman.js";

// Keep the plugin's flag file out of ~/.config/opencode while testing.
const configHome = fs.mkdtempSync(path.join(os.tmpdir(), "caveman-test-"));
process.env.XDG_CONFIG_HOME = configHome;
const flag = path.join(configHome, "opencode", ".caveman-active");

beforeEach(() => fs.rmSync(flag, { force: true }));

test("activation phrases turn the mode on", () => {
  expect(parseCavemanText("/ultracave")).toBe("ultra");
  expect(parseCavemanText("/caveman")).toBe("ultra");
  expect(parseCavemanText("/caveman ultra")).toBe("ultra");
  expect(parseCavemanText("caveman mode")).toBe("ultra");
  expect(parseCavemanText("talk like caveman")).toBe("ultra");
  expect(parseCavemanText("use caveman")).toBe("ultra");
});

test("deactivation wins over activation", () => {
  expect(parseCavemanText("stop caveman")).toBe("off");
  expect(parseCavemanText("normal mode")).toBe("off");
  expect(parseCavemanText("/caveman off")).toBe("off");
  expect(parseCavemanText("/caveman stop")).toBe("off");
});

test("ordinary text does not toggle", () => {
  expect(parseCavemanText("refactor the parser")).toBe(null);
  expect(parseCavemanText("mycaveman")).toBe(null);
});

test("command arguments", () => {
  expect(parseCavemanArgs("on", false)).toBe("ultra");
  expect(parseCavemanArgs("ultra", false)).toBe("ultra");
  expect(parseCavemanArgs("off", true)).toBe("off");
  expect(parseCavemanArgs("stop", true)).toBe("off");
  expect(parseCavemanArgs("status", true)).toBe("status");
  expect(parseCavemanArgs("", false)).toBe("ultra");
  expect(parseCavemanArgs("", true)).toBe("status");
  expect(parseCavemanArgs("bogus", false)).toBe("invalid");
});

async function setup(skills = [{ id: "ultracave" }]) {
  const hooks = {};
  const commands = [];
  await plugin.setup({
    session: {
      hook: async (name, callback) => {
        hooks[name] = callback;
      },
      prompt: async () => {},
    },
    command: {
      transform: async (callback) => callback({ add: (command) => commands.push(command) }),
    },
    skill: { list: async () => skills },
  });
  return { hooks, commands };
}

test("prompt hook attaches the skill on activation and every turn while on", async () => {
  const { hooks } = await setup();
  const activating = { text: "/ultracave", skills: [] };
  await hooks.prompt({ prompt: activating });
  expect(activating.skills).toEqual([{ id: "ultracave", name: "ultracave" }]);
  expect(fs.readFileSync(flag, "utf8")).toBe("ultra");

  const ordinary = { text: "refactor the parser" };
  await hooks.prompt({ prompt: ordinary });
  expect(ordinary.skills).toEqual([{ id: "ultracave", name: "ultracave" }]);
});

test("prompt hook stays silent when off and clears on deactivation", async () => {
  const { hooks } = await setup();
  const idle = { text: "refactor the parser" };
  await hooks.prompt({ prompt: idle });
  expect(idle.skills).toBeUndefined();

  fs.mkdirSync(path.dirname(flag), { recursive: true });
  fs.writeFileSync(flag, "ultra");
  const stopping = { text: "stop caveman" };
  await hooks.prompt({ prompt: stopping });
  expect(stopping.skills).toBeUndefined();
  expect(fs.readFileSync(flag, "utf8")).toBe("off");
});

test("missing skill sets the mode but never blocks the prompt", async () => {
  const { hooks } = await setup([]);
  const prompt = { text: "/ultracave" };
  await hooks.prompt({ prompt });
  expect(prompt.skills).toBeUndefined();
  expect(fs.readFileSync(flag, "utf8")).toBe("ultra");
});

test("registers the /caveman command", async () => {
  const { commands } = await setup();
  expect(commands.map((command) => command.name)).toEqual(["caveman"]);
});
