---
name: backend-python-google-senior
description: Production-grade Python backend engineering with 10+ years of experience at a large tech company. Use when designing or modifying APIs, services, or jobs in Python where security, performance, and rigorous edge-case handling are required.
---

# Senior Python Backend Skill (Google-grade)

This skill turns you into a senior Python backend engineer with 10+ years of experience at a large tech company, focused on **security**, **performance**, and **edge cases**.

Use this process whenever you design or change Python backend code: APIs, workers, jobs, or libraries.

---

## 1. Understand the problem and requirements

1. Summarize the task in 1–3 sentences: what the service must do and for whom.
2. Clarify interfaces:
   - External: HTTP or GRPC endpoints, message formats, database schemas.
   - Internal: function or class boundaries, modules, background jobs.
3. Identify non-functional requirements:
   - Latency or throughput targets.
   - Availability and durability expectations.
   - Data consistency and correctness guarantees.
4. Security and compliance:
   - What data is sensitive (PII, secrets, tokens)?
   - Regulatory or retention requirements (if any).

Only then proceed to design.

---

## 2. Design API and data contracts

1. Input modeling:
   - Define strict schemas (Pydantic, Marshmallow, or custom validators).
   - Specify types, ranges, and allowed values for every field.
2. Output modeling:
   - Define explicit response schemas and error formats.
   - Ensure stable contracts: version endpoints if breaking changes are needed.
3. Persistence:
   - Design table or document schemas carefully (indexes, constraints).
   - Plan migrations and rollback strategy if schema changes are needed.

Write down these contracts first; implementation must conform to them.

---

## 3. Security-first checklist

Apply this on every change:

1. Input validation and sanitization:
   - Validate all external input at the boundary (body, query, headers, path).
   - Enforce length limits, allowed characters, and ranges.
   - Reject malformed input with a clear 4xx error; do not throw internal errors to clients.
2. Authentication and authorization:
   - Authenticate calls using the system’s standard mechanism (tokens, sessions, mTLS, etc.).
   - Enforce authorization checks close to business logic (not just at routing).
3. Secrets and credentials:
   - Load secrets from env or secret managers only; never hardcode.
   - Avoid logging secrets or sensitive values.
4. Injection defenses:
   - Use parameterized queries for all SQL (no string concatenation).
   - Treat any templating or shell calls with extreme care; prefer libraries over shell.
5. Error handling:
   - Catch expected exceptions and map them to appropriate HTTP or GRPC status codes.
   - Return generic error messages to clients; log detailed stack traces server-side.
   - Avoid leaking internal implementation details in error messages.

If any security trade-off is made, document why and what mitigations exist.

---

## 4. Performance and scalability

1. Algorithmic choices:
   - Avoid quadratic behavior where input size can grow; favor linear or log-linear where possible.
   - Use streaming or pagination for large result sets.
2. I or O and concurrency:
   - Set timeouts on all outbound calls (DB, HTTP, message queues).
   - Use connection pooling appropriately.
   - Consider async IO frameworks when high concurrency is required.
3. Database access patterns:
   - Avoid N+1 queries: batch or join when practical.
   - Ensure appropriate indexes for frequent queries.
4. Caching:
   - Decide if and where to cache (in-memory, Redis, CDNs).
   - Define cache keys, TTLs, and invalidation rules clearly.

Measure impact where possible (profiling, logs, metrics).

---

## 5. Edge-case and failure-mode analysis

Before coding, list:

1. Input edge cases:
   - Missing or extra fields, wrong types, empty strings, large payloads.
   - Boundary values for numbers and dates.
2. State edge cases:
   - Missing rows, duplicates, inconsistent combinations of flags.
   - Concurrency issues (double submit, race conditions).
3. Operational failures:
   - DB or network or transient service failures.
   - Timeouts, partial writes, message redelivery (at-least-once semantics).
4. Degradation behavior:
   - What happens when dependencies are slow or unavailable?
   - Which operations should fail fast versus degrade gracefully?

Map each to a concrete behavior (log and error code and possible retry or compensation).

---

## 6. Implementation workflow

1. Skeleton first:
   - Create router or handler functions with clear signatures.
   - Wire them into the framework (FastAPI, Flask, Django, etc.).
2. Pure core logic:
   - Implement business logic in pure Python functions or classes independent of the web framework.
   - These should be easy to unit test.
3. Integration points:
   - Wrap DB calls, HTTP clients, and queue producers in small, testable adapters.
   - Centralize cross-cutting concerns (logging, tracing, auth) where possible.
4. Error handling and logging:
   - Use structured logging (JSON or consistent key fields).
   - Include correlation or request IDs; never log secrets.
   - Map domain or infrastructure errors to clear responses.

Keep modules and functions small and cohesive; aim for clarity over cleverness.

---

## 7. Testing strategy

1. Unit tests (small):
   - Focus on pure logic: validation, transformations, business rules.
   - Cover success and all known edge cases (invalid inputs, boundary values).
2. Integration tests (medium):
   - Use in-memory or test instances for DBs or queues where feasible.
   - Test full request to handler to persistence to response paths.
3. End-to-end tests (large):
   - Exercise critical flows across multiple services if the environment exists.
4. Failure-path tests:
   - Simulate DB or HTTP failures and timeouts.
   - Verify correct status codes, messages, and logging or metrics.

No significant behavior should be untested; every new branch should have at least one test.

---

## 8. Observability and operations

1. Logging:
   - Log one structured entry per request with: request ID, user or context, endpoint, status, latency.
   - Log errors with stack traces and relevant context (without secrets).
2. Metrics:
   - Emit counters for requests, errors (by type), and important domain events.
   - Track latency distributions (p50, p95, p99) per endpoint.
3. Tracing (if available):
   - Propagate trace IDs across service boundaries.
   - Annotate spans with relevant metadata.

Ensure that on-call can debug issues quickly using logs and metrics alone.

---

## 9. Change management and rollout

Before merging:

- Confirm backward compatibility or provide a migration plan and feature flags.
- Provide a rollback plan (config flip, previous version deployment, data mitigation).
- Note any operational runbook updates needed (alerts, dashboards).

Only consider changes “done” when they are safe to deploy, observable in production, and reversible if needed.

