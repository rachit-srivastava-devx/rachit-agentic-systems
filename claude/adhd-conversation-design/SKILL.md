---
name: adhd-conversation-design
description: How a conversational agent should talk to someone with ADHD — carrying executive load instead of handing it back, sustaining attention without gamification, keeping company during waits, and teaching without load-dumping. Use when designing, prompting, reviewing, or testing any assistant, voice agent, coach, or companion whose user has ADHD or is stuck, overwhelmed, or juggling parallel threads.
---

# ADHD Conversation Design

Distilled from 59 literature searches across ~496 sources (peer-reviewed psychology, cognitive-load
and instructional-design research, clinical guidance from NICE/CHADD, W3C cognitive accessibility,
practitioner writing, and first-person accounts). Written for a product that talks.

**The evidence is uneven, and that matters more than the rules.** The most-repeated advice in this
space is the least-supported. Each claim below is tagged, and the tag is not decoration — it decides
whether you may build a hard control on it:

- `[strong]` — replicated experimental or meta-analytic support.
- `[moderate]` — consistent findings, narrower base, or adjacent-population evidence.
- `[thin]` — clinical observation or theory; popular online, **not** established. Never gate on it.

---

## 1. The one rule: mental work must travel toward the agent

An ADHD brain that is stuck is short of exactly the function you would be asking for. Working memory
capacity is about **four items, not 7±2** (Cowan 2001, correcting Miller) `[strong]`, and the
bottleneck is attentional — it shrinks further under stress. So a question that requires generating,
ranking, or choosing is a request the user cannot fill *right now*, however kindly phrased.

    BAD   "What feels like the smallest step you could take?"
    BAD   "How would you break this down?"
    BAD   "It's up to you." / "Your call." / "You tell me."
    GOOD  "How about we just open the file — that's it, nothing after that."
    GOOD  "I'd start with the kettle. Nothing else yet."
    GOOD  "Smallest version: reply to only the first email. Want me to wait with you?"

The defect is **the direction the load travels**, never the fact that a step was mentioned. An agent
that refuses to suggest anything has not avoided the failure; it has committed the same one while
looking humble.

**Rule 1.** Propose a specific action; never ask the user to produce one. `[strong]`
**Rule 2.** One action, no sequel. A step with a "and then" is two steps. `[moderate]`
**Rule 3.** Clarifying questions about **facts** are always welcome ("Is this the Friday report?").
Questions that hand back a **decision** are the defect. Facts cost recall; decisions cost executive
function, and only one of those is depleted. `[moderate]`
**Rule 4.** When a choice genuinely belongs to the user, give **at most two** named options and say
which you would pick. Choice overload is real and demotivating (Iyengar & Lepper; Schwartz)
`[strong]`, and it worsens with time pressure and preference uncertainty — both typical here.
**Rule 5.** Never ask the user to hold something for you, and never say "keep in mind". You hold the
threads they drop and say them back when useful. `[strong]`

## 2. Offer, never assign — autonomy is load-bearing

Demands can register as a threat to control and autonomy *even when the person agrees with the task*
(the demand-avoidance literature) `[moderate]`. Self-determination theory puts autonomy, competence
and relatedness at the centre of sustained motivation `[strong]`.

**Rule 6.** Phrase every step as an offer ("How about…", "Want to try…"), never an instruction.
**Rule 7.** "No" is a complete answer. Do not re-offer, reframe, or negotiate a refusal. Assert this
in tests: a refusal followed by a re-offer is a defect.
**Rule 8.** Never use infantilizing language or over-explain to a competent adult — it erodes dignity
and autonomy `[moderate]`. This is also the **expertise reversal effect**: information the user
already holds creates *additional* cognitive load rather than support `[strong]`. Scaffolding a
person who does not need scaffolding actively harms them.

## 3. Attention and reward — what actually holds interest

This is where popular advice is weakest and the temptation to gamify is strongest.

**Well-supported.** People with ADHD show **steeper delay discounting** — smaller-sooner rewards are
preferred over larger-later ones `[strong]` — and **delay aversion**: waiting itself acquires a
negative affective charge, so delay-rich situations become aversive in their own right (Sonuga-Barke)
`[strong]`. Delay discounting is transdiagnostic, not ADHD-specific `[strong]`.

**Thin.** "The ADHD interest-based nervous system" (Dodson) is a clinical framework from practical
observation, **not** peer-reviewed neurobiology, and it has been flattened online into something more
absolute than intended `[thin]`. **Rejection Sensitive Dysphoria** comes from the same source and is
likewise contested `[thin]`. Emotional dysregulation in ADHD is well-documented; *RSD as a discrete
entity* is not. **Body doubling** — the mechanism behind every "work alongside me" feature — has
**no controlled experimental test at all**; its dopamine explanation is a proposed mechanism, not a
finding `[thin]`.

You may still *build* body-doubling and interest-led features. You may not claim they are
evidence-based, and you must not derive hard product invariants from them.

**Rule 9.** Deliver reward as **immediacy**, not intensity. The delay-discounting finding says the
answer to a scarce-reward system is a shorter gap between action and feedback — not louder praise.
`[strong]`
**Rule 10.** Interest comes from **specificity and novelty**, never from enthusiasm. A concrete,
surprising, genuinely-yours detail engages; an exclamation mark does not.
**Rule 11.** **Do not gamify by default.** The overjustification effect is that expected extrinsic
incentives *reduce* intrinsic motivation for an already-rewarding activity `[strong]`, and it is
documented specifically in gamified platforms. Streaks and points convert a good day into a debt.
**Rule 12.** Never reference a broken streak, a past failure, or a missed intention as leverage.
**Rule 13.** Praise the **process**, never the person. Person praise ("you're so smart", "good boy")
predisposes people — *especially those with low self-esteem* — to shame after failure and to
attributing failure to the self; process praise does not (Dweck) `[strong]`. "That's a clean fix"
is safe; "you're brilliant" is a trap set for the next bad day.
**Rule 14.** Distinguish the two barriers before responding: **overwhelmed** needs the step *shrunk*;
**under-stimulated** needs stimulus *added*. One rule cannot serve both, so a policy of "always
suggest" is as wrong as "never suggest". `[moderate]`

## 4. Waiting — the failure mode nobody instruments

Delay aversion `[strong]` means an unexplained wait is not neutral time; it is actively unpleasant and
it is where sessions are abandoned. Nielsen's visibility-of-system-status heuristic says the same
thing from the UI side `[strong]`.

**Rule 15.** State an **honest duration** before any wait ("this'll take about fifteen minutes").
Never invent one. If unknown, say so and name the next check-in moment.
**Rule 16.** Keep company during the wait, with real conversation: *"how was your day?"*, *"anything
else on your mind?"*, *"what's the last thing you ate that was actually good?"* Silence during a wait
reads as abandonment.
**Rule 17.** Treat exceeding a silence budget as a **failing state**, not a degraded one. A wait with
no companion turn and no completion is a bug with a severity, not a cosmetic gap.
**Rule 18.** The user's next utterance always beats a queued companion turn. Interruptibility is not
optional.
**Rule 19.** Use **backchannels** — short listener signals that acknowledge without taking a turn
`[strong]`. These are the correct primitive for presence audio. They are *not* content, and they must
never be counted as an answer: a product that emits "mm-hm" and reports a reply has measured the
proxy, not the property.

## 5. Teaching is the one carve-out

Asking a learner to think *is* the pedagogy. The load-direction veto must exempt teaching, or you
have banned the thing that works.

**Rule 20.** In teach mode, comprehension checks are correct and required.
**Rule 21.** Follow **teach-back**, and follow the part everyone skips: the literature is explicit
that teach-back **is not a test of the person's memory** — it is a check on whether *you explained
it well*, and it is owned by the explainer `[strong]`. Frame it that way out loud: "let me check I
explained that clearly", never "let's see if you remember".
**Rule 22.** Give **wait time**. Rowe's finding is that going from ~1 second to **≥3 seconds** of
silence after a question markedly improves the length, logic and creativity of responses `[strong]`.
An agent that fills a 3-second gap has destroyed the mechanism. Silence after a question is a
feature; silence during a *wait* (§4) is a defect — do not confuse them.
**Rule 23.** Chunk to the four-item budget `[strong]`, one idea at a time, and re-anchor at each
resumption ("we were on the second of three"). After an interruption the user has lost their place,
not their intelligence.

## 6. The harm list — what breaks trust immediately

Each of these is a veto, not a preference. Emotional dysregulation and shame are well-documented in
ADHD `[strong]`, and shame reliably freezes the exact function the user arrived short of.

**Rule 24.** No shaming, moralizing, or productivity-guilt. No "you just need to focus", no "have you
tried a planner" — dismissive advice is the most-reported harm in first-person accounts `[moderate]`.
**Rule 25.** No nagging or repetition-as-pressure. Reminder systems drive resentment in ADHD adult
relationships `[moderate]`; an agent that repeats itself has become the nag.
**Rule 26.** No toxic positivity. "That sounds genuinely exhausting" is support; "stay positive!" is
abandonment with a smile.
**Rule 27.** No manufactured urgency the user did not name. Deadline-driven performance is real but it
is not yours to induce.
**Rule 28.** Never repeat the user's self-abuse back as if it were true, and never use an
imperative-shaming construction.
**Rule 29.** Plain language, one thing at a time, and a pace the listener sets — the W3C cognitive
accessibility guidance and CHADD's communication guidance converge here `[moderate]`.

---

## Mechanising this

Most of the above is judgment and cannot be linted. Two parts can, and where a check is possible a
prompt rule is not sufficient — a prompt rule is empirically a `mitigates`, never a
`kills (structural)`.

1. **An egress predicate on load direction.** Detect the interrogative-plus-modal-plus-"you" shape,
   plus the abdication idioms ("up to you", "your call", "you tell me"), and gate it on mode with
   teaching exempt. Reference implementation:
   `company/products/adhd-focus-orb/backend/relay-py/src/orb_relay/proxy/conversation_guard.py`
   (`shifts_mental_load`), with the prompt-wording gate in
   `backend/relay-py/tests/test_prompts_carry_the_load.py`.
2. **A prompt-wording gate.** Prompts drift back toward eliciting; two in that repo shipped
   instructing the model to do exactly what the guard vetoes. Assert on the wording you write.

**Two failure modes to expect when you build these:**

- **A first run is mostly false positives.** Report precision on a known-good set beside recall on
  the adversarial set. A guard that vetoes a legitimate clarifying question is worse than no guard,
  because the fallback replaces a good reply with a canned one.
- **Anchoring a pattern to line starts makes it miss real defects while catching invented ones** — a
  gate green from its first run, measuring nothing. Prove every new check red against the verbatim
  text that motivated it before trusting it.

## What this skill does not cover

Medication, diagnosis, and clinical treatment decisions. Crisis and self-harm handling, which needs
its own escalation design, not conversation guidelines. Children and adolescents — most of the
reward-sensitivity work above was done in that population and is applied here to adults by
inference, which is a real gap and not a small one. The visual and temporal design of an ADHD
interface, as distinct from what it says.
