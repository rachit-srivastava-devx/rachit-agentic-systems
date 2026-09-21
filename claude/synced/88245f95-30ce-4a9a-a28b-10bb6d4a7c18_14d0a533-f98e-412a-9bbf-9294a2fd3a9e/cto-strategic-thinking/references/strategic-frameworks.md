# Strategic frameworks, as reasoning moves

These are mental models to reach for silently — they should change what questions get asked
and what options get generated, not show up as name-dropped citations in the output. Use them
as a checklist of angles when diagnosing a problem or generating options (Step 4–5 of the main
reasoning sequence), not as something to explain to the client.

## Diagnosis and strategy shape (Rumelt)

Good strategy starts from an honest diagnosis of what's actually going on, names the single
biggest obstacle (the crux), sets a guiding policy for dealing with it, and lays out coherent
actions that reinforce each other. Bad strategy skips the diagnosis and jumps to a list of
goals or a grab-bag of initiatives that don't add up to anything.

Questions to ask:
- If you had to name the *one* obstacle that, if removed, would make the rest much easier — what is it?
- Is what's being proposed a coherent set of actions aimed at that obstacle, or a list of nice-to-haves?
- Are the "objectives" here actually proximate (achievable, near-term, within our control) or are they restated wishes ("increase revenue")?

## Where the durable advantage comes from (7 Powers)

Ask whether the proposed solution creates or protects something durable, or just narrows a gap
that a competitor (or the client's next vendor) can close in a quarter.

- **Counter-positioning** — is there an approach that benefits us/the client precisely because
  an incumbent can't adopt it without cannibalizing their existing business?
- **Switching costs** — does this solution make the client's next migration harder (in a way
  that benefits them, e.g., integration depth) or just add lock-in that benefits us?
- **Scale economies / network effects** — does value increase with more users/data, or is this
  a linear-cost, linear-value build?
- **Process power** — is there a repeatable, hard-to-copy way of delivering this that compounds
  across engagements?
- **Branding / cornered resource** — is there a resource (proprietary data, a relationship, an
  integration) that others can't easily get?

Most internal tooling and one-off automation has none of these — that's fine, but say so rather
than implying the build creates a moat it doesn't.

## What is actually being hired (Jobs To Be Done)

Before designing anything, be explicit about:
- What progress is the client trying to make, in their own operational terms — not "we need a
  dashboard" but "I need to know by 9am whether yesterday's batch run finished clean without
  logging into three systems."
- What are they currently hiring to make that progress happen? A spreadsheet, a Slack habit, a
  person checking manually, a competitor's tool, nothing? The real competition for a new build
  is usually the workaround, not another vendor.
- Would solving the job well obsolete the *want* they originally stated?

## Feedback loops and leverage points (Thinking in Systems)

Treat the client's operation as a system with stocks, flows, delays, and feedback — not a
sequence of tasks to speed up.

- Where's the delay between an action and its consequence being visible? Long delays are why
  bad practices persist — by the time the cost shows up, no one traces it back to the cause.
- Is there local optimization happening — a team/step getting faster while the overall process
  doesn't improve, or gets worse (a classic sign the wrong step got automated)?
- What are the actual incentives operating on the people in this process? If the incentives
  don't change, don't expect the behavior to change no matter what gets built.
- Leverage points, roughly in order of power: changing the goal of the system > changing the
  rules/incentives > changing information flows > changing feedback loops > parameters
  (the last is where most "just add automation" proposals live — real but usually the weakest
  lever available).
- What's the second-order consequence if this works exactly as intended? Who absorbs the
  downstream effect?

## Playing to Win

- Where to play: which client, segment, or problem is this actually for? A solution that's
  right for enterprise clients can be wrong for this client's stage.
- How to win: what's the actual mechanism by which this beats the status quo or a competitor —
  not "it's AI-powered" but a specific, falsifiable claim.
- What capabilities and systems does winning here require, and do we (or the client) actually
  have them, or are we assuming they'll materialize?

## Theory of Constraints

Identify the real bottleneck before optimizing anything else — a faster non-constraint doesn't
move the system's output. Sequence: **Identify → Exploit** (get more from the constraint before
spending money) **→ Subordinate** (make everything else serve the constraint) **→ Elevate**
(only now add capacity/technology). Skipping straight to "elevate" — buying/building new tech —
before exploiting what's already there is one of the most common expensive mistakes.

## High Output Management

- What's the actual leverage of this activity — does it change the output of many people, or
  just one task?
- Is the constraint here managerial (decision rights, unclear ownership, review bottlenecks) or
  operational (system capacity, latency, throughput)? Don't propose a technical fix for a
  managerial constraint.

## Wardley Mapping

- Where does this capability sit on the evolution axis — genesis (novel, worth building
  in-house), custom-built, product, or commodity/utility (should be bought, not built)?
- Building a commodity capability from scratch is usually wasted effort; differentiating in a
  genesis-stage capability is where custom build earns its cost.

## Lean Startup

- What's the riskiest assumption in this plan, and what's the cheapest experiment that could
  invalidate it before committing real engineering time?
- Define kill criteria up front — what result would make us stop, not just "results we'll
  review later."

## Inversion, first principles, expected value

- Inversion: instead of "how do we solve this," ask "what would guarantee this fails," then
  make sure the plan avoids those things.
- First principles: strip the request back to physical/economic constraints — what's actually
  true here, independent of how it's usually done?
- Expected value: weigh probability-weighted outcomes, not just the best case. A high-upside,
  low-probability bet needs a small enough downside to be worth it; don't recommend it as if the
  upside were guaranteed.

## Reversibility, scenario analysis, mechanism design

- Classify: Type 1 (hard/expensive to reverse — hiring, architecture that locks in a data
  model, contractual commitments) vs Type 2 (cheap/reversible — a config flag, a pilot with 3
  users, a script). Type 1 needs real evidence; Type 2 is where fast experiments belong.
- Sketch at least two future scenarios (not just the expected one) where this recommendation
  plays out differently, and check it still holds up reasonably in the less-likely one.
- Mechanism design: if the plan relies on people behaving a certain way, what incentive
  actually makes that behavior the easy/rational choice, rather than relying on compliance or
  good intentions?
