# Quantifying business impact

The goal is not a spreadsheet that looks impressive — it's a number honest enough to survive
someone on the client side pushing back on it. Fake precision is worse than a clearly-labeled
range, because it invites false confidence and then blows up in the room.

## The core shape

For most operational problems, impact decomposes into:

```
Volume × Frequency × Unit Cost × Failure Rate × Time
```

Work through what's knowable in each of these before reaching for a total:

- **Volume** — how many units/transactions/tickets/orders does this touch?
- **Frequency** — how often does the problem occur, per unit, per day, per cycle?
- **Unit cost** — what does one occurrence cost (time, money, lost revenue, rework)?
- **Failure rate** — what fraction of occurrences actually go wrong, vs. get caught?
- **Time** — over what period does this accumulate (annualized is usually the useful frame)?

Then translate into the categories that actually matter to a decision-maker:

- Revenue gained (new, or protected/retained)
- Cost removed (labor, infrastructure, error/rework cost)
- Hours saved — but see the "vanity ROI" warning below before quoting this alone
- Conversion impact
- Error/failure rate reduction
- Risk reduction (harder to quantify — frame as avoided cost × probability, or as exposure reduced)
- Implementation cost (engineering time, tools, licenses)
- Ongoing operating cost (infra, API usage, monitoring)
- Support cost (who fixes it when it breaks, how often)
- Migration cost (getting from current state to new state)
- Opportunity cost (what doesn't get built because this does)

## Label every number

Every figure in a recommendation should carry one of four tags, explicitly or in how it's
phrased:

- **KNOWN** — client gave you this number, or it's in a system you can query. State it plainly.
- **ESTIMATED** — derived from a reasonable calculation off known inputs. Show the calculation,
  don't just state the output — "roughly 40 hrs/week based on your stated ticket volume of X at
  Y minutes each" beats "saves 40 hours a week."
- **ASSUMED** — you don't have data, so you're using an industry-typical or directionally
  reasonable placeholder. Flag it as an assumption explicitly and say what it would take to
  confirm it.
- **UNKNOWN** — you don't have enough to estimate even roughly. Say so, and say what's the
  cheapest way to find out, rather than filling the gap with a guess dressed as a number.

If a recommendation depends heavily on ASSUMED or UNKNOWN numbers, that's not a reason to avoid
recommending — it's a reason to make the recommendation conditional on getting the 1-3 numbers
that would most change the decision, named explicitly.

## The vanity ROI trap

"Saves 3,000 hours a year" sounds decisive and usually isn't, because those hours are rarely
convertible into actual economic value:

- Distributed thin slivers of time across many people's days rarely turn into headcount
  reduction, new revenue, or anything bookable — check whether the saved time is *concentrated*
  enough to be redeployed, or just diffuse enough to evaporate.
- Ask: what would the client's team actually do with the freed time? If the honest answer is
  "nothing different," the hours aren't worth what they're being priced at.
- Prefer framing in terms of a bottleneck relieved, an SLA met, a error/incident avoided, or a
  decision made faster — outcomes with a clearer path to dollars — over raw hours saved, when
  raw hours don't survive that test.

## What to say when the number can't be built responsibly

It's fine, and often more credible, to say "I don't have enough here to size this responsibly —
here's the smallest piece of data that would let me." That's a stronger position than a number
built on three stacked assumptions presented as if it were derived.
