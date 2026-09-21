# Discovery playbook

Don't run clients through a generic discovery questionnaire. Ask questions only when the answer
could actually change one of: whether the project should exist, its scope, its architecture,
its economics, its risk profile, or the order things get built in. Every question should be
one you'd genuinely act differently depending on the answer to.

## The shift: from open-ended to falsifiable

Generic discovery questions invite vague, unfalsifiable answers that don't change anything.
Specific, numeric, or consequence-oriented questions produce answers that actually move a
decision.

| Instead of | Ask |
|---|---|
| "Tell me about your current process." | "How many times a day does this happen?" |
| "What are your pain points?" | "What happens financially when this fails?" |
| "Have you tried anything before?" | "What prevented the previous attempt from working?" |
| "What's your tech stack?" | "What system currently holds the source of truth for this data?" |
| "What's your timeline?" | "What happens on your end if this ships two weeks late — is there a hard date something else depends on, or is that soft?" |
| "Who are the stakeholders?" | "Who signs off on this, and who's actually affected by it day to day — are those the same person?" |

## Question categories worth reaching for

**Frequency and scale** — "how many times per day/week does this happen" surfaces whether a
problem is worth solving at all before any design conversation starts.

**Financial consequence** — "what happens financially when this fails" gets past politeness and
toward the number that actually justifies (or doesn't justify) investment.

**Prior-attempt failure mode** — "what prevented the previous solution from working" is one of
the highest-value questions available: it either reveals a real constraint that needs solving
first, or reveals the previous attempt was badly scoped/executed, which changes how much
confidence to put in a similar-shaped new attempt.

**Ownership and incentive** — "who is accountable when this goes wrong today" reveals whether
the reason the problem persists is technical or organizational.

**Workaround detail** — "what do you do instead, today, when this happens" (the JTBD move) —
the answer usually reveals the real competing solution and the real bar a new build needs to
clear.

**Data reality** — "where does this data actually live right now, and who can see it" surfaces
integration and compliance complexity before it becomes a mid-project surprise.

## When not to ask

If a question's answer wouldn't change scope, architecture, economics, risk, or sequencing —
skip it. Curiosity about the client's org chart or history is fine in conversation but doesn't
belong in a discovery pass whose job is to change the shape of the recommendation. Three sharp
questions that each move the decision beat twelve broad ones that produce a nice narrative and
no new information.
