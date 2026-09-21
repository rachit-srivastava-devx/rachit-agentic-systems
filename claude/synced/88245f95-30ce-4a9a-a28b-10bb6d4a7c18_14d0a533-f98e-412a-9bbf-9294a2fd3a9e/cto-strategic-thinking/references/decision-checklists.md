# Decision checklists

## Decision quality test

Run this before finalizing any consequential recommendation. If several answers are "no,"
keep working before recommending.

1. Do I understand the business outcome we're actually trying to change?
2. Did I challenge the proposed solution rather than just design it?
3. Did I identify the actual constraint, not just a downstream symptom?
4. Did I quantify impact where the data allows it?
5. Did I distinguish known facts from assumptions?
6. Did I consider doing nothing as a real option, not a throwaway line?
7. Did I consider non-technical interventions (process, policy, incentive)?
8. Did I weigh build vs. buy vs. integrate vs. defer?
9. Did I think through second-order effects, not just the immediate one?
10. Did I consider the client-side incentives at play?
11. Did I evaluate delivery margin and the support burden we're signing up for?
12. Did I identify the single biggest uncertainty in this recommendation?
13. Did I define a cheap way to validate before full commitment?
14. Did I name plausible failure modes?
15. Can I explain, concretely, why this creates more value than the alternatives — not just that it does?

## Dangerous reasoning patterns to catch

Flag these when they show up in your own draft recommendation before it goes out, and name them
plainly if you see them in someone else's proposal:

- **Solutionism** — "we have AI, where can we use it" (technology looking for a problem, instead
  of the reverse).
- **Technology bias** — defaulting to "building is better than buying" without a differentiation
  argument.
- **Feature thinking** — "the client asked for it, therefore they need it," skipping the check
  on whether the request maps to the actual problem.
- **Local optimization** — a step got faster but the end-to-end process didn't improve (or got
  worse because the bottleneck just moved).
- **Vanity ROI** — "thousands of hours saved" that can't actually convert into redeployed time,
  headcount change, or booked value. See `business-evaluation.md` for the fuller version of
  this trap.
- **Fake precision** — an ROI number built mostly on assumptions, presented with the confidence
  of a measured figure.
- **Automation bias** — automating a process that's broken, instead of fixing the process (now
  you have a broken process that runs faster and is harder to change).
- **Sunk-cost bias** — continuing because of work already done, rather than because the forward
  case still holds.
- **Novelty bias** — reaching for a sophisticated design when a simpler intervention captures
  most of the value.
- **Architecture astronautics** — designing for hypothetical future scale instead of the actual
  current constraint.
- **Consulting theater** — an impressive diagram or deck that doesn't actually change what the
  client decides to do next. The most common form is not a bad diagram — it's *endless
  reframing*: diagnosing the diagnosis, naming the constraint, listing what you'd validate, and
  never committing to a concrete intervention. Reframing is safe because it can't be wrong; a
  specific recommendation can be. Watch for this in your own drafts: if you have a sharp read on
  what's wrong and no equally sharp statement of what to *do*, you've theatered. The tell is a
  response that would survive unchanged no matter what the underlying facts were.
- **Altitude mirroring** — answering at the same level the question was framed, when the real
  leverage is a level below. Strategy questions get strategy answers; the actual value was in
  the specific engineering intervention underneath, and nobody descended to it. A thinking
  companion drops to the object level on its own initiative rather than reflecting the user's
  altitude back at them.
- **Deference-as-analysis** — disagreeing fluently with the absent client while never
  disagreeing with the user in the room. Real pushback includes telling the person you're
  talking to that they're about to skip the hard part.

## The canonical anti-pattern

**Don't do this:**

> Client: "We need an AI agent."
> Response: "Here's an architecture using LangGraph, a vector DB, Redis, and Kafka..."

**Do this instead** — walk the chain before touching architecture:

```
AI agent requested
  ↓ what decision or action is this supposed to drive?
  ↓ what's the current workflow around that decision/action?
  ↓ where exactly does it fail today, and how do we know?
  ↓ how often does that failure happen?
  ↓ what's the economic consequence when it does?
  ↓ what's the actual constraint — is it really capability, or something upstream?
  ↓ can the need for this step be eliminated or restructured instead?
  ↓ is AI specifically the right tool here, or would deterministic logic do it more reliably?
  ↓ would an existing SaaS product cover most of this already?
  ↓ what's the smallest experiment that tests the riskiest assumption?
  ↓ only now: architecture
```

## Premortem template

For any project sizable enough to matter, before recommending, run:

"Imagine this failed badly 12 months from now. Why?"

Check against this list and surface the 3 most credible:

- Adoption failure (built the right thing, nobody used it)
- Wrong problem (solved what was asked, not what mattered)
- Integration failure (the systems it needed to talk to didn't cooperate)
- Insufficient or unreliable data
- Cost explosion (infra, API usage, or engineering time far exceeded plan)
- Model/system unreliability at the edges
- Organizational resistance (the people whose workflow changed didn't want it to)
- Vendor dependency (a third party's roadmap or pricing broke the plan)
- Security incident
- Regulatory constraint surfaced late
- Operational complexity the client's team can't actually run
- Poor unit economics once it's at real volume
- The client's team can't maintain what we built after we leave

## Validation template

For any recommendation resting on an uncertain assumption, spell out:

```
HYPOTHESIS:            what we believe is true
SIGNAL:                what we'd observe if it's true
EXPERIMENT:             the cheapest thing that tests it
COST:                   time/money to run it
TIME:                   how long until there's a result
SUCCESS THRESHOLD:     what result means "go"
FAILURE THRESHOLD:     what result means "stop"
NEXT DECISION:          what actually happens after each outcome
```

Avoid designing a pilot that can't produce a decision either way — if neither threshold would
actually change what happens next, it isn't a real experiment, it's a delay.

## High-stakes discipline

For anything with real client money, irreversible commitments, or consequential automated
decisions on the line:

- Keep facts and assumptions visibly separate — don't let an assumption read like a fact because
  it's stated plainly.
- Don't invent client data to fill a gap — say what's missing instead.
- Don't imply causality from correlation.
- Don't hide uncertainty to make a recommendation sound cleaner than it is.
- Don't recommend irreversible implementation before the critical assumptions have been
  validated.
- Don't let generative AI make consequential decisions autonomously where deterministic rules,
  human approval, or verification are actually required — say explicitly where that line is.
- Name explicitly where expert review is needed — legal, security, compliance, financial, or
  other domain sign-off — rather than quietly assuming it'll happen.
