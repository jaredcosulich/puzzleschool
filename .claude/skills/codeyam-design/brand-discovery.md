<!--
  The strategy frame in "Reading the answers" — category, audience, emotional
  promise, cultural position, symbolic metaphor, what the brand must avoid — is
  adapted from the "Brand strategy first" section of the brandkit skill in
  Leonxlnx/taste-skill (MIT, read 2026-09-23). That skill generates brand-board
  images with an image model; nothing here does. The questions themselves, the
  gate, and the mapping onto a design round are CodeYam's.
-->

# Brand discovery

A brief that says what a product *does* says almost nothing about how it should
*look*. "A cycle tracker," "a gym log," "a tool for planning trips" each admit a
hundred visual directions, and an agent handed one of them without further
signal will pick the safest — which is how six mockups end up being the same
design in six palettes. The interview below exists to turn a functional brief
into a design brief before a single file is written.

It is short on purpose. A studio's real discovery runs for days; this runs
inside an onboarding step, and a user who is asked ten questions before seeing
anything will abandon the step. Five questions, asked once, get roughly eighty
percent of the separating signal.

## When to run it, and when not to

**Run it when the brief carries no visual direction.** That is the trigger: read
`projectDescription` and ask whether it constrains *any* of palette, type
personality, tone, density, or reference points. A brief that names none of them
is a functional spec, and the interview runs.

**Skip it entirely when the brief already names a direction.** "Dark, minimal,
Spanish and English" is a direction. So is "playful, for kids," "clinical,"
"like a Swiss timetable," or an uploaded logo whose palette and type personality
you can read. Asking a user to describe what they already described is the
fastest way to make an onboarding feel like it is not listening. In this case
say nothing about discovery and go straight to the design read.

**Skip the axes already answered.** The choice is per question, not
all-or-nothing. A brief that says "dark and minimal" but nothing about audience
gets the audience question and not the tone question.

**Never block on it.** Offer the user a way past: *"or tell me to just go, and
I'll make the calls myself and show you where I landed."* If they skip, proceed
on your own reading and state the assumptions you made in the Step 4 numbered
key, so the mockups themselves become the question.

## How to ask

**All of it in one message.** Numbered, each answerable in a line, with a
one-line reason for why you are asking at all. Never one question per turn: a
studio asks a focused set once and then goes away and works. The whole exchange
should cost the user under a minute.

Open by saying what you already took from the brief, so the questions read as
listening rather than as a form. *"I've got a daily wellness tracker, personal,
mobile-first. Five quick ones before I draw anything."*

## The five

Ask the ones the brief has not already answered.

1. **Who opens this, and what are they doing right before they do?** Someone
   checking a number between sets at the gym and someone reviewing a quarter at
   a desk need different densities, different type sizes, and different amounts
   of chrome. This question sets the surface more reliably than asking about
   platform.

2. **What should the first three seconds feel like?** Ask for feeling, not
   adjectives about design: *calm, in control, energized, taken seriously,
   private*. This is the palette and type-personality question in disguise, and
   users answer it far better than they answer "what colors do you like."

3. **Name one or two things whose look you'd be happy to be compared to.** Let
   them name anything: an app, a magazine, a book cover, a physical object, a
   place. Non-software answers are usually the most useful, because they carry a
   material and a mood rather than a UI pattern. If they name a product that
   exists in `design_references/`, read that file — but under the
   never-as-a-skin rule.

4. **What must this absolutely not look like?** The separating question, and the
   one to keep if you keep only one. What a brand refuses is sharper than what
   it likes: "not clinical," "not another dark developer tool," "not a period
   app that's all pink and flowers" each rule out more than any preference adds.
   A set built without an anti-reference drifts toward the category default,
   which is exactly the repetition complaint.

5. **Anything fixed?** An existing logo, a color that must appear, a name with a
   meaning, a platform constraint. Cheap to ask, expensive to discover after six
   mockups.

## Reading the answers

Translate before you design. Each answer should land on a concrete axis, and the
translation is the part to get right:

| Answer | Lands on |
|---|---|
| Who, and what they were doing | Density, type scale, how much chrome, mobile vs desktop weight |
| First-three-seconds feeling | Palette temperature and contrast, type personality, whether motion is implied at all |
| Comparison points | Craft references and material vocabulary — never a palette to copy |
| The anti-reference | A hard constraint on every slot, and usually the axis the set spreads along |
| Fixed assets | Tokens that survive every tier unchanged |

Then, from those, write the strategy read the design actually runs on:
**category** · **audience** · **what the product promises emotionally** · **where
it sits culturally relative to its category** · **the one metaphor worth carrying,
if any** · **what it must avoid**. That last line is not optional; it is the
anti-reference made operational, and it is what you check each finished mockup
against.

## The one rule that makes this worth doing

**An anti-reference is a constraint, not a preference.** If the user says "not
another dark developer tool," a dark developer tool is not available as the
anchored slot, no matter how well it would score otherwise. Treating the answer
as a soft signal that a strong enough design can override is the same failure as
not asking.

## Reporting back

Do not summarize the answers back at length before working — it reads as
stalling. One line confirming the direction you took, then go: *"Got it: private
and calm, nothing clinical, nothing pink-and-flowers. Drawing six now."* The
mockups are the real response.
