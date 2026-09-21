# Writing style: low cognitive load, high trust

Derived from analysis of a well-received internal assessment document. The mechanism that made it work: the conclusion comes before the evidence, at every scale — document, section, and sentence. The rules below reproduce that mechanism.

## 1. Lead with the conclusion

- Open with a "Bottom line" (or equivalent) section stating the answer, before any background, methodology, or system explanation. Most technical writing builds up to a conclusion; invert that.
- Give the title a point of view, not just a topic. "X: the cost of leaving it as it is" beats "X Assessment."
- Push methodology, caveats, and process notes to the end, in reduced visual weight. Rigor should be documented, not force the reader through it first.

## 2. Structure claims as bold-claim-then-detail

Write each finding as one bolded, skimmable sentence that states the claim, followed by the specifics that support it. A reader scanning only the bold clauses should come away with the whole argument; a reader who wants to verify continues into the detail after it.

## 3. Make every claim checkable

- Replace vague qualifiers ("many," "rarely," "a lot of," "significant") with an exact count, date, or span pulled from real data. "Fourteen commits in three years" beats "barely touched."
- After a claim or claim block, cite where it came from — a file path and line range, a query, a dataset, a link — in the audience's own language. Engineers get file:line; executives get a source and a date.
- When a statement is not verified against source material — an assumption, something from general knowledge, an estimate — say so explicitly and flag it for the reader to verify. Never blur "I checked this" into "I'm asserting this."

## 4. Correct errors in the open

If a claim in an earlier draft or a prior document turns out wrong, retract it visibly and explain the actual cause, rather than silently fixing it or quietly dropping it. A visible correction reads as more trustworthy than an invisible one.

## 5. Write short, declarative sentences

- Concrete subjects, active voice. "Tetris is one binary serving two logical services" beats "Two logical services are served by a single binary known as Tetris."
- No throat-clearing. Never open with "In order to understand X, it's important to first consider..." — start with the fact.
- State the document's organizing idea in the first sentence of the intro, and let the rest of the document develop it.

## 6. Group, don't enumerate

A list of seven bullets is almost always three grouped concepts. Find the groups before listing. Cap any single list at five items; split longer ones into "must" vs. "nice to have" or similar.

## 7. Use structure that carries meaning, not decoration

- A status tag, a severity label, a stat row: keep it, because it compresses something real and lets the reader compare at a glance.
- A diagram: include it only when the relationship being shown is genuinely graph-shaped (who calls whom, what flows where). Otherwise prose or a table says it faster.
- Never add a visual element — chart, icon, diagram — to make a document look more thorough. If it doesn't carry information the surrounding text doesn't already carry, cut it.

## 8. Close with action, not summary

End with numbered, concrete recommendations or next steps — each one sized (who does it, how much effort) — not a restatement of what the document already said.

## Self-check before delivering

- Could a reader get the whole argument from the bold claims and headers alone?
- Is every non-obvious number traceable to a source?
- Does anything here raise cognitive load without adding information — jargon, hedging, a redundant diagram, a qualifier that isn't load-bearing? Cut it.
