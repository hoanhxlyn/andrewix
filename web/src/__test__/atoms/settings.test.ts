import { describe, expect, test } from "bun:test";
import { createStore } from "jotai";
import { atomWithSetting, preloadSettings } from "@/atoms/settings";

const isNumber = (value: unknown): value is number => typeof value === "number";

// Bun has no IndexedDB, so nothing is stored or read back: these cover the in-memory side.
describe("atomWithSetting", () => {
  test("reads the initial value while nothing is stored", async () => {
    await preloadSettings();
    const setting = atomWithSetting("test-initial", 3, isNumber);
    expect(createStore().get(setting)).toBe(3);
  });

  test("takes a value or an update function, and shows the result at once", () => {
    const store = createStore();
    const setting = atomWithSetting("test-write", 1, isNumber);
    store.set(setting, 5);
    expect(store.get(setting)).toBe(5);
    store.set(setting, (count) => count + 1);
    expect(store.get(setting)).toBe(6);
  });

  test("shares one value between atoms of the same key", () => {
    const store = createStore();
    store.set(atomWithSetting("test-shared", 0, isNumber), 9);
    expect(createStore().get(atomWithSetting("test-shared", 0, isNumber))).toBe(
      9,
    );
  });

  test("reads a value of the wrong shape as the initial value", () => {
    const store = createStore();
    const loose = atomWithSetting<unknown>(
      "test-shape",
      null,
      (value): value is unknown => true,
    );
    store.set(loose, "not a number");
    expect(store.get(atomWithSetting("test-shape", 7, isNumber))).toBe(7);
  });
});
