import type { Page } from "@playwright/test";

/** Reads one value of the settings store, as the app keeps it in IndexedDB. */
export function storedSetting(page: Page, key: string): Promise<unknown> {
  return page.evaluate(
    (name) =>
      new Promise<unknown>((resolve, reject) => {
        const open = indexedDB.open("andrewix-settings");
        open.onerror = () => reject(open.error);
        open.onsuccess = () => {
          const read = open.result
            .transaction("settings")
            .objectStore("settings")
            .get(name);
          read.onerror = () => reject(read.error);
          read.onsuccess = () => resolve(read.result);
        };
      }),
    key,
  );
}
