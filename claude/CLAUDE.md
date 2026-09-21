# Global standing rules

## LLD / system design diagrams: always full detail

Any low-level design (LLD) or system architecture diagram — in any project — must be built at
full component-level detail, never a simplified high-level sketch, even if the request just
says "make a diagram" or "update the graph." Load the `lld-diagram-standard` skill before
building or updating one. Reuse the project's own design doc/spec if one exists rather than
inventing a thinner parallel structure.

## Documents and artifacts: DevX Doctrine style

Any document or artifact created in any project — reports, memos, PRDs, decks, one-pagers,
written analyses, dashboards, proposals — must follow the DevX Doctrine for both prose and
visual style, except LLD/system-architecture diagrams (see above; those follow
`lld-diagram-standard` instead and are exempt from this doctrine's visual restraint). Load the
`devx-doctrine` skill before creating or substantially updating one.
