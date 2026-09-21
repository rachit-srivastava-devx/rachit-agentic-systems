# Visual doctrine (DevX Labs)

Source: DevX Labs' internal design system, "The DevX Doctrine" v1.0, April 2026. Governs any artifact with its own visual presentation — HTML, a published Artifact, a styled PDF, a deck. For plain-text/Markdown-only deliverables, apply the spirit (restraint, hierarchy via headers, no decoration) since there's no CSS to render.

## Essence

Design like a top-tier consulting firm that ships code: the editorial restraint of McKinsey and Bloomberg, the typographic discipline of Stripe and Linear, none of the visual tropes of an AI startup. Heavy white space, one accent color, typography doing the work other firms give to color, gradients, and decoration. When in doubt: remove, don't add.

## Five principles

1. **Editorial restraint over decorative excitement.** Default move on any visual problem is to remove, not add. One strong headline, one rule, one accent beats five gradients and three CTAs.
2. **Structural grid discipline.** 12-column grid, generous margins, hairline (1px, neutral gray) rules dividing content instead of boxes/shadows. The grid stays visible, not hidden.
3. **Typography is the primary visual device.** Hierarchy, mood, and emphasis come from type, not color or decoration: a display sans for headlines, an italic serif for editorial emphasis, a monospace face for labels and numerics.
4. **One accent, used sparingly.** A single blue (`#1E6FFF`), 2-4 times per surface, never more. If everything is accented, nothing is.
5. **Monoline, hand-drawn iconography.** 1.25px stroke, no fills, geometric, treated as punctuation. Default to no icon; when one is used, it never carries meaning the text doesn't already carry.

## Tokens

### Color

```
Ink             #0A0A0A    Body text, primary
Ink-2           #1A1A1A    Secondary text
Muted           #5C6066    Supporting text, captions
Muted-2         #8A8F96    Metadata, eyebrows on dark surfaces
Rule            #E5E5E5    Hairline dividers
Rule-2          #F0F0F0    Subtle internal rules
Paper           #FFFFFF    Default background
Paper-2         #FAFAF8    Card backgrounds, subtle fills
Paper-3         #F4F4F1    Block quotes, inset panels

Accent          #1E6FFF    The single accent — emphasis, italics, active states
Accent-soft     #E8F0FF    Accent backgrounds (used very rarely)

Warn            #C0392B    Errors, "before" states in case studies
OK              #0A7C53    Success, "after" states in case studies
```

White-on-dark is permitted only on a single inverted card on an otherwise light surface (`Ink` background, `Accent` for emphasis text). Never invert a full page — this doctrine is a light-mode, paper/ink system by design; see the note on Artifact dark-mode handling in `SKILL.md`.

### Typography

```
Display + UI    Inter Tight       300, 400, 500, 600, 700
Editorial       Source Serif 4    400, 500 (italic 400 for emphasis)
Monospace       JetBrains Mono    400, 500
```

All three are free Google Fonts (import string in the header comment of `assets/doctrine.css`). Paid upgrade path, when it matters: swap Source Serif 4 for Tiempos Headline or GT Sectra — same role, more luxurious feel.

Type rules:

- **Headlines** — Inter Tight 500, letter-spacing `-0.02em` to `-0.025em`. Feels heavier than it reads: confident without shouting.
- **Inside a headline**, one or two key words switch to italic Source Serif 4 in accent color. This is the single most recognizable device in the system. Once per headline, never more.
- **Body** — Inter Tight 400/500, 14-16px, line-height 1.5, color `Ink-2` or `Muted` depending on hierarchy.
- **Eyebrows and labels** — JetBrains Mono, 10-11px, `letter-spacing: 0.12em-0.16em`, uppercase, color `Muted` or `Accent`. Always.
- **Numerics** — Inter Tight with tabular figures (`font-feature-settings: "tnum"`). Stat numbers 44-64px, weight 400, letter-spacing `-0.035em`.
- **Pull quotes** — Source Serif 4 italic, 24-32px, line-height 1.18, 2px accent rule on the left.

### Spacing scale

```
4   8   12   16   24   32   48   64   96
```

Use only these values. Don't invent 18, 20, or 28 — they're not in the system.

### Rules and dividers

- **Hairline** — `1px solid #E5E5E5` — default divider
- **Subtle** — `1px solid #F0F0F0` — inside cards, between repeated rows
- **Heavy** — `1px solid #0A0A0A` — separates a section heading from its content
- **Accent** — `2px solid #1E6FFF`, 56-96px wide — under a section title, or left of a pull quote

### Iconography

```
Style         Monoline, geometric, no fills
Stroke        1.25px (1.5px on dark surfaces)
Stroke-cap    round
Stroke-join   round
Size          16-22px inline; 36-44px in icon containers
Container     1px ink border, square, content centered
Color         currentColor (inherits from text)
```

Inside a "card with icon header" pattern, the icon sits in a 36-44px square container with a 1px solid Ink border. Never filled, never colored, never with a drop shadow.

### Shadows

Almost never. The one approved shadow is a page/document floating on a paper-3 canvas:

```css
box-shadow: 0 1px 0 rgba(0,0,0,.04), 0 30px 60px -30px rgba(0,0,0,.18);
```

No card shadows, no button shadows, no hover shadows. Depth comes from rules and spacing, not elevation.

## Pattern library

- **Display headline with italicized emphasis** — sans headline, one key phrase in accent-blue italic serif. Carries most of the brand recognition on its own.
- **Monospace eyebrow** — small uppercase label above every section title; names the section before the headline.
- **Four-cell stat row** — 3-4 large numerics with hairline vertical rules between them, under a 1px-ink top rule. For credentials, outcomes, before/after numbers.
- **Slide stamp** — top-right corner, `05 · 11` in monospace. Reads like a printed report.
- **Breadcrumb** — top-left, `Section 02 / The partner thesis`, section number in accent.
- **Editorial pull quote** — Source Serif 4 italic, large, 2px accent left rule, monospace attribution in caps below. Sets tone, never summarizes.
- **Before/after case study block** — two stacked blocks with colored left rules: `Warn` red for before, `OK` green for after.
- **Dark inversion card** — a single `Ink`-background card, white text, accent emphasis, used to break visual rhythm. Never a full-page background.
- **Numbered grid** — 3x2 or 2x2 cards, small numeral top-right, icon in a square container, headline, body copy, 2-3 bullets. For any "N pillars" pattern.
- **Bordered container, not rounded card** — `1px solid #E5E5E5`, sharp corners, no shadow. Reads as "document," not "app."

## Never do

- No emoji, anywhere, including bullet points.
- No rounded "friendly" shapes — `border-radius: 0` on containers and icon frames. The one exception is a small "Confidential" pill at `border-radius: 999px`.
- No gradients — not on backgrounds, text, or buttons.
- No drop shadows on UI elements beyond the single page-shadow. Buttons, cards, inputs sit flat.
- No teal, purple, neon, or iridescent — these read as "AI startup." The accent is one specific blue, full stop.
- No center-aligned body text (headlines may center on a cover only).
- No stock photography of people — no suited executives, no diverse-team-at-laptops, no abstract "innovation" photography.
- No AI-generated illustration (DALL-E/Midjourney/Imagen-style art) — its visual signature is exactly what this doctrine avoids.
- No bullet-point overload — a list of 7 is almost always 3 grouped concepts.
- No "click here" or "learn more" — buttons are verbs naming the action: "Begin co-sell conversation," "View case study."
- No exclamation marks, anywhere.

## Surface-specific guidance

Same doctrine everywhere; the liberties differ.

**Executive decks & client proposals** — the most editorial surface, full strength on all five principles. Landscape 1280x760, full-bleed cover, generous margins (56px), large display type (44-96px). No animation. Ship as a single self-contained HTML file (deck-as-website pattern). Chrome — left-rail TOC, slide stamps, breadcrumbs, keyboard nav — is part of the brand on this surface, not just UI.

**Marketing pages** — inherits decks, adds: subtle motion is permitted (fade-in on scroll, smooth-scroll anchors, 150ms-ease hover color shifts — no bounce, no spring physics, no parallax, no scroll-jacking); hero type can run 80-120px on desktop; sectioned long-scroll with alternating Paper/Paper-2 backgrounds separated by full-bleed hairline rules; flat buttons (1px ink border, ink background, white text; hover flips background and border to accent); forms use the same 1px-rule, no-radius input pattern, focus state is border-color to accent.

**Internal docs, memos, PRDs** — the least editorial surface. Strip the chrome (no slide rails, no chapter stamps) but keep the type stack — Inter Tight body with Source Serif 4 italic for emphasis still reads as doctrine. Default to flowing prose with H1/H2/H3 hierarchy, not bullet-soup. Use the monospace eyebrow above section headers only for formal deliverables (an RFP response, an executive memo); skip it for quick internal notes. Tables: hairline rules, no zebra striping, no row backgrounds. Code blocks: JetBrains Mono, Paper-3 background, no border-radius. Max page width: 720px for prose, 960px for docs with tables — wider is uncomfortable to read.

## Reference exemplars

Model after: McKinsey Quarterly (editorial typography, restraint, italic emphasis in headlines), BCG perspectives reports (section structure, stat rows), Stripe.com (type-led marketing, one sparing accent), Linear.app (product UI restraint, hairline rules, monospace detail), Bloomberg Businessweek (the editorial italic move, monospace as a system), Pentagram's institutional identity work.

Do not model after: Lovable.dev, Vercel marketing pages (too playful for this positioning), generic SaaS landing-page templates, or anything from the 2024-cohort AI-startup visual style (purple gradients, glassmorphism, bento boxes).
