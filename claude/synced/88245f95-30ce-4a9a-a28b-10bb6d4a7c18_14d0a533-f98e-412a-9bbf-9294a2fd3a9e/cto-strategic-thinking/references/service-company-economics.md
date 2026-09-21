# Service-company economics

Every recommendation gets evaluated twice: once for whether it's good for the client, and once
for whether it's good for the business delivering it. A recommendation that fails either test
needs to be flagged, not smoothed over. Long-term trust with the client dominates short-term
billable scope — never inflate scope or complexity to protect project revenue at the client's
expense; it costs more than it earns the moment the client notices.

## Client value

- Is this actually worth paying for, independent of whether it's interesting to build?
- How large is the economic upside, and does the client's own accounting recognize it as
  savings/revenue, or only we think it is?
- Who owns the budget for this, and does that person have the authority (and incentive) to
  defend the spend to their own stakeholders?
- Can the buyer explain this decision to their boss in one sentence and have it hold up?

## Delivery

- What's the realistic engineering effort — not the optimistic estimate, the one that accounts
  for the unknowns below?
- What integration complexity exists that isn't visible yet (legacy systems, undocumented APIs,
  data quality issues that only surface mid-build)?
- What depends on the client's side — data access, stakeholder availability, a decision they
  haven't made yet, a system they haven't given us access to? Client-side dependencies are the
  single most common reason delivery timelines blow up; surface them before committing to a
  timeline.
- Is there security, compliance, or data-handling work implied that hasn't been scoped?
- What does deployment actually require — client infra, our infra, a hybrid, and who owns
  uptime after launch?

## Margin

- If this is fixed-price, what's the downside if the estimate is wrong — is it bounded or open-ended?
- What's the expected implementation-hours range (not a single number), and how sensitive is
  margin to slipping past the top of that range?
- Does this require specialized talent that's expensive, scarce, or that we'd need to hire for?
- What are the ongoing cloud/API/licensing costs, and who's paying them post-launch — us, the
  client, or is that undecided (a common source of margin erosion later)?
- What custom code are we committing to maintain forever, and does anyone on the team actually
  want to own that in a year?

## Repeatability

- Is this genuinely one-off consulting, or does it produce a reusable accelerator, connector, or
  piece of IP that reduces the cost of the *next* similar engagement?
- If it's meant to be reusable, is that actually true, or is "reusable" being used to justify
  extra build time that mostly benefits this one client?
- Could this become a repeatable offering for the industry/vertical, and if so, is this
  engagement priced (or scoped) to reflect that it's partly R&D?

## Commercial

- Does solving this open a larger engagement, or is it a ceiling (once this is done, there's
  nothing else to sell)?
- Is there a land-and-expand path, and is it realistic given the buyer's actual authority and
  budget cycle?
- Does solving the *underlying* problem (as opposed to the literal request) shrink this
  project's scope but build enough trust to expand the relationship? That trade is usually worth
  taking even when it reduces immediate billable hours.
- Is there a more valuable adjacent problem visible from here that's worth surfacing, even if
  it's not this engagement's scope?

## Risk

- Can this recommendation cause the client actual losses if it goes wrong (financial,
  operational, reputational)?
- Is there regulatory or compliance exposure — data handling, industry-specific rules, contract
  terms that create liability?
- Could this cause an operational outage or degrade something that currently works?
- Does this involve an automated system taking a consequential action without human review — and
  if so, is that appropriate given the stakes, or does it need a human-in-the-loop step?
- What's the reputational downside if this fails publicly or visibly to the client's customers?
- Is there SLA exposure — are we committing to uptime/response times we can actually meet?

## Synthesis

When client value is high and delivery/margin/risk are acceptable — recommend and scope
carefully. When client value is real but margin or risk is bad — say so plainly and propose a
smaller or differently-shaped engagement rather than either declining silently or overselling.
When client value itself is weak (the underlying business case doesn't hold up) — that's a
"don't build this yet" conversation regardless of how good the margin looks, because a client
that pays for something that doesn't work for them is a client that leaves.
