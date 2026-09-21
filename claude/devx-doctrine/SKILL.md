---
name: devx-doctrine
description: House style for any document or artifact produced for the user — reports, memos, PRDs, decks, one-pagers, written analyses, dashboards, proposals. Combines DevX Labs' visual design doctrine (typography, color, and spacing tokens; a restrained, editorial, McKinsey/Stripe-influenced look) with a low-cognitive-load writing style (lead with conclusions, cite evidence inline, use exact numbers instead of vague qualifiers, short declarative sentences). This skill should be used whenever creating or substantially updating any such artifact, except low-level-design or system-architecture diagrams, which follow the separate lld-diagram-standard skill instead and are exempt from this doctrine's visual restraint.
---

# DevX Doctrine

## Overview

Apply this skill to make every document or artifact produced for the user read and look like it came from the same disciplined hand: prose that's easy to scan and hard to distrust, and — when there is a visual surface — a restrained, typographic look rather than a decorative one.

Two reference layers do the actual work:

- `references/writing-style.md` — sentence- and structure-level rules for the prose itself. Applies to every artifact under this skill, regardless of format.
- `references/visual-doctrine.md` — DevX Labs' visual design tokens and patterns. Applies whenever the artifact has its own visual presentation (HTML, a published Artifact, a styled PDF, a deck).

## When to use

Use for any requested document or artifact: executive assessments, memos, PRDs, decks/slides, one-pagers, dashboards, marketing pages, written analyses, proposals.

Do not use for LLD or system-architecture diagrams — those follow `lld-diagram-standard` at full component detail, which needs exhaustive technical density, not editorial minimalism.

Not every response is "an artifact." A one-line answer, a terminal command, an inline code fix, or a quick clarification is out of scope — this skill governs deliverables meant to stand alone: something with a title, sections, or a reader other than "run this now."

## Workflow

1. **Read both reference files before drafting.** Don't rely on memory of them past a few turns — reread if it's been a while, since the exact tokens (hex values, pixel sizes) are easy to misremember and matter here.
2. **Structure first, style second.** Apply `references/writing-style.md`'s structure rules to the content outline before worrying about visual presentation: bottom line first, bold-claim-then-detail findings, evidence cited inline, methodology pushed to the end, numbered actions at the close.
3. **If the artifact has visual presentation**, apply `references/visual-doctrine.md`'s tokens and patterns. Link or inline `assets/doctrine.css` directly in HTML output; hand-translate the tokens when the target isn't CSS (a slide tool, a design app). Match the surface-specific guidance (decks vs. marketing vs. internal docs) for margins, type scale, and which liberties are permitted.
4. **If the artifact is plain-text or Markdown-only** (a chat-native memo, a text PRD), apply only the typographic spirit of the visual doctrine — restraint, hierarchy via headers, no decoration — since there's no CSS to render.
5. **If the artifact is published via the Artifact tool**, this doctrine governs the *look*; the `artifact-design` skill (and `artifact-capabilities` if the page needs runtime state) governs the *platform mechanics* — load whichever of those applies too. The doctrine is a deliberate light-mode-only editorial system (paper/ink); it's fine to commit to that single look and skip the Artifact tool's dark-mode token blocks rather than invent a mismatched dark palette — but still paint every color explicitly, per that skill's rules, rather than leaving anything to inherit.
6. **Self-check before delivering:**
   - From `references/writing-style.md` — could a reader get the whole argument from the bold claims and headers alone? Is every non-obvious number traceable to a source?
   - From `references/visual-doctrine.md`'s "never do" list — no emoji, no gradients, no rounded cards or drop-shadows beyond the one page-shadow, one accent color used sparingly, no stock photography or AI-generated illustration, no "click here."

## If a request conflicts with the doctrine

State the conflict plainly and propose the doctrine-compliant version, rather than silently complying (which breaks the house style) or silently ignoring the request (which drops what the user asked for). Example: a request to "make it more playful" or "add some icons" gets a short note that the doctrine treats icons as punctuation and drops decoration by default, plus a version that stays in doctrine. The doctrine wins by default; the user can always override explicitly.

## Resources

- `references/writing-style.md` — prose and structure rules, derived from analysis of a well-received internal assessment document.
- `references/visual-doctrine.md` — DevX Labs' visual design tokens, pattern library, surface-specific guidance, and never-do list (source: "The DevX Doctrine" v1.0, April 2026).
- `assets/doctrine.css` — the doctrine's CSS custom properties and base styles, ready to link or inline into any HTML artifact.
