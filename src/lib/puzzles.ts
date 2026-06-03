// The Code Puzzle content.
//
// The original puzzles lived in a Postgres database that is no longer available,
// so these are reconstructed sample puzzles that exercise the same turtle-graphics
// engine the original used. Each card is a single instruction:
//
//   A1 Move Forward   A2 Move Backward   A3 Rotate Right   A4 Rotate Left
//   A5 Fill Color     P1 Pen Up          P2 Pen Down       P3 Pen Size
//   P4 Pen Color      F1 Function        F2 End Function   L1 Loop    L2 End Loop
//
// `param` is a number for moves/rotations/sizes, or an "r g b" triple (0–1 each)
// for colors. Paramless cards use "".

export type Card = { code: string; param: string };

export type Project = {
  slug: string;
  title: string;
  description: string;
  cards: Card[];
};

const card = (code: string, param: string | number = ""): Card => ({
  code,
  param: String(param),
});

// ----- Square: the simplest loop -----
const square: Card[] = [
  card("P3", 2),
  card("L1", 4),
  card("A1", 160),
  card("A3", 90),
  card("L2"),
];

// ----- Triangle -----
const triangle: Card[] = [
  card("P3", 2),
  card("L1", 3),
  card("A1", 220),
  card("A3", 120),
  card("L2"),
];

// ----- Five-pointed star -----
const star: Card[] = [
  card("P3", 2),
  card("P4", "0.85 0.1 0.1"),
  card("L1", 5),
  card("A1", 260),
  card("A3", 144),
  card("L2"),
];

// ----- Spiral: unrolled, each segment a little longer -----
const spiral: Card[] = [card("P3", 2), card("P4", "0.1 0.3 0.8")];
for (let i = 1; i <= 40; i++) {
  spiral.push(card("A1", i * 6));
  spiral.push(card("A3", 91));
}

// ----- Color pinwheel: a different pen color per spoke, returning to center -----
const pinwheelColors = [
  "0.90 0.10 0.10", // red
  "0.95 0.55 0.10", // orange
  "0.95 0.85 0.10", // yellow
  "0.20 0.70 0.20", // green
  "0.10 0.55 0.85", // blue
  "0.30 0.25 0.70", // indigo
  "0.60 0.20 0.70", // violet
  "0.40 0.40 0.40", // gray
];
const pinwheel: Card[] = [card("P3", 3)];
for (const color of pinwheelColors) {
  pinwheel.push(card("P4", color));
  pinwheel.push(card("A1", 250)); // draw spoke out
  pinwheel.push(card("P1")); // pen up
  pinwheel.push(card("A2", 250)); // back to center
  pinwheel.push(card("P2")); // pen down
  pinwheel.push(card("A3", 360 / pinwheelColors.length));
}

export const PROJECTS: Project[] = [
  {
    slug: "square",
    title: "Square",
    description: "A loop that draws four sides — the first step into turtle graphics.",
    cards: square,
  },
  {
    slug: "triangle",
    title: "Triangle",
    description: "Same idea as the square, but turning 120° three times.",
    cards: triangle,
  },
  {
    slug: "star",
    title: "Five-Pointed Star",
    description: "Turning 144° each step traces a star instead of a pentagon.",
    cards: star,
  },
  {
    slug: "spiral",
    title: "Spiral",
    description: "Each step is a little longer than the last, winding outward.",
    cards: spiral,
  },
  {
    slug: "pinwheel",
    title: "Color Pinwheel",
    description: "Pen Up / Pen Down and a new Pen Color on every spoke.",
    cards: pinwheel,
  },
];

export function getProject(slug: string): Project | undefined {
  return PROJECTS.find((p) => p.slug === slug);
}
