import { sprinkles } from "@/styles/sprinkles.css";
import { vars } from "@/styles/tokens.css";
import { Button, type ButtonVariants } from "@/ui/Button";
import { Card, type CardVariants } from "@/ui/Card";
import { Diagram } from "@/ui/Diagram";
import { Grid } from "@/ui/Grid";
import { ThemeScope } from "@/ui/ThemeScope";
import AddIcon from "~icons/material-symbols/add-rounded";
import * as s from "./Design.css";
import example from "./example.mmd";

function keysOf<T extends object>(obj: T) {
  return Object.keys(obj) as (keyof T & string)[];
}

const buttonVariants: Exclude<
  NonNullable<ButtonVariants["variant"]>,
  "icon"
>[] = ["filled", "tonal", "outlined", "text"];
const cardVariants: NonNullable<CardVariants["variant"]>[] = [
  "elevated",
  "outlined",
];

const row = sprinkles({
  display: "flex",
  flexWrap: "wrap",
  alignItems: "center",
  gap: "lg",
});
const stack = sprinkles({ display: "grid", gap: "lg" });

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section className={stack}>
      <h2 className={s.heading}>{title}</h2>
      {children}
    </section>
  );
}

function Components() {
  return (
    <div className={stack}>
      <div className={row}>
        {buttonVariants.map((variant) => (
          <Button key={variant} variant={variant}>
            {variant}
          </Button>
        ))}
      </div>
      <div className={row}>
        {buttonVariants.map((variant) => (
          <Button key={variant} variant={variant} icon={<AddIcon />}>
            With icon
          </Button>
        ))}
      </div>
      <div className={row}>
        {buttonVariants.map((variant) => (
          <Button key={variant} variant={variant} isDisabled>
            Disabled
          </Button>
        ))}
        <Button variant="icon" icon={<AddIcon />} aria-label="Add" />
      </div>
      <div className={row}>
        {cardVariants.map((variant) => (
          <Card key={variant} variant={variant}>
            {variant} card
          </Card>
        ))}
      </div>
    </div>
  );
}

export default function Design() {
  return (
    <div className={sprinkles({ display: "grid", gap: "xl", padding: "xl" })}>
      <Section title="Color">
        <div className={s.grid}>
          {keysOf(vars.color).map((role) => (
            <div key={role} className={s.swatch}>
              <div
                className={s.swatchColor}
                style={{ background: vars.color[role] }}
              />
              <p className={s.caption}>{role}</p>
            </div>
          ))}
        </div>
      </Section>

      <Section title="Typography">
        {keysOf(vars.type).map((role) => (
          <div key={role}>
            <p className={s.caption}>{role}</p>
            <p className={s.typeSample[role]}>
              The quick brown fox jumps over the lazy dog
            </p>
          </div>
        ))}
      </Section>

      <Section title="Space">
        {keysOf(vars.space).map((step) => (
          <div key={step}>
            <p className={s.caption}>{step}</p>
            <div className={s.spaceBar} style={{ width: vars.space[step] }} />
          </div>
        ))}
      </Section>

      <Section title="Shape">
        <div className={row}>
          {keysOf(vars.shape).map((radius) => (
            <div
              key={radius}
              className={s.sample}
              style={{ borderRadius: vars.shape[radius] }}
            >
              {radius}
            </div>
          ))}
        </div>
      </Section>

      <Section title="Elevation">
        <div className={row}>
          {keysOf(vars.elevation).map((level) => (
            <div
              key={level}
              className={s.sample}
              style={{ boxShadow: vars.elevation[level] }}
            >
              {level}
            </div>
          ))}
        </div>
      </Section>

      <Section title="Layout">
        <Grid>
          {Array.from({ length: 12 }, (_, i) => i + 1).map((n) => (
            <div key={n} className={s.cell}>
              {n}
            </div>
          ))}
        </Grid>
      </Section>

      <Section title="Diagram">
        <Diagram diagram={example} />
      </Section>

      <Section title="Components">
        <div className={s.themes}>
          <ThemeScope theme="light">
            <p className={s.caption}>Light</p>
            <Components />
          </ThemeScope>
          <ThemeScope theme="dark">
            <p className={s.caption}>Dark</p>
            <Components />
          </ThemeScope>
        </div>
      </Section>
    </div>
  );
}
