import { keyframes, style } from "@vanilla-extract/css";
import { inComponents } from "@/styles/layers.css";
import { vars } from "@/styles/tokens.css";

const fadeIn = keyframes({ from: { opacity: 0 }, to: { opacity: 1 } });

/** The box growing into place as it opens; played in reverse as it closes. */
const growIn = keyframes({
  from: { opacity: 0, transform: "scale(0.96)" },
  to: { opacity: 1, transform: "scale(1)" },
});

const timing = `${vars.motion.emphasizedDuration} ${vars.motion.emphasizedEasing}`;

/** The page behind the modal, dimmed by the scrim and blurred over it. */
export const overlay = style(
  inComponents({
    position: "fixed",
    inset: 0,
    zIndex: vars.layer.overlay,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    background: "rgb(0 0 0 / 0.32)",
    backdropFilter: "blur(8px)",
    selectors: {
      "&[data-entering]": {
        animation: `${fadeIn} ${timing}`,
        "@media": { "(prefers-reduced-motion: reduce)": { animation: "none" } },
      },
      "&[data-exiting]": {
        animation: `${fadeIn} ${timing} reverse forwards`,
        "@media": { "(prefers-reduced-motion: reduce)": { animation: "none" } },
      },
    },
  }),
);

/** Box of the modal over the scrim; the caller sizes it through `className`. */
export const modal = style(
  inComponents({
    display: "flex",
    flexDirection: "column",
    overflow: "hidden",
    background: vars.color.surface,
    boxShadow: vars.elevation.level2,
    selectors: {
      "&[data-entering]": {
        animation: `${growIn} ${timing}`,
        "@media": { "(prefers-reduced-motion: reduce)": { animation: "none" } },
      },
      "&[data-exiting]": {
        animation: `${growIn} ${timing} reverse forwards`,
        "@media": { "(prefers-reduced-motion: reduce)": { animation: "none" } },
      },
    },
  }),
);

/** The dialog inside the box, filling it; focus lands here when the modal opens. */
export const dialog = style(
  inComponents({
    display: "flex",
    flexDirection: "column",
    flex: 1,
    minHeight: 0,
    outline: "none",
  }),
);
