# Interview prep: N-iX — Senior/Lead PHP Engineer with AI skills

Posting: https://careers.n-ix.com/jobs/4529257101-php-leader/ (internal #5887)

---

## 1. The role in 30 seconds

| What | Detail | Why it matters for you |
|---|---|---|
| Title | Senior/Lead PHP Engineer with AI skills, level "Leader" | They will test leadership (mentoring, ownership, decision-making), not just coding. |
| Engagement | 6 months, full time | It's a project staffing role. Ask about extension/conversion and contract type. |
| Time zone | Aligned with EDT (Toronto) | Unusual for a European client. Find out the real overlap hours before agreeing. From Europe, EDT alignment can mean working until 22:00–24:00. |
| Client | European online car marketplace, 18 countries, 30M+ monthly users | This fits **AutoScout24**, but the posting doesn't name them. Ask; don't assume. Expect high traffic, search-heavy workloads, listings, dealers and pricing. |
| Goal | Support the "next major product release" | They need someone productive fast. Stress how quickly you onboard and that you ship on your own. |
| Stack | PHP, Laravel, MySQL/PostgreSQL, Docker, AWS/GCP, LLM APIs, agent frameworks | The AI part is a must-have, not a bonus. This is where you stand out. |

### Must-haves, and how to show each one

- **6+ years of PHP, 4+ with Laravel.** Have 2–3 concrete Laravel projects ready, each with scale, your role and one hard problem you solved.
- **Hands-on GenAI (LLM APIs, function calling, retrieval, agents).** Use job-radar (section 2). Talk about real mechanics such as structured output, versioning and evals, not "I used ChatGPT".
- **Daily use of Claude Code or Codex.** They explicitly want this. Describe your actual workflow (section 2.5).
- **SQL tuning and schema design.** Prepare one real story about a slow query you fixed, with before and after numbers.
- **Docker and cloud.** Know how you'd containerize a Laravel app (PHP-FPM + Nginx, or Octane) and deploy it (ECS, Kubernetes or similar).
- **Testing, debugging, production readiness.** Talk about CI, static analysis, observability and safe deploys.
- **Working independently on unclear problems.** Prepare a STAR story (section 5).
- **English at Upper-Intermediate or higher.** The interview itself covers this. Speak in structured answers: context, then what you did, then the result.

---

## 2. Your strongest story: job-radar

**Why lead with it:** most PHP candidates can't show production-grade LLM work. You have a working app that uses the Claude API with versioned prompts, evals and cost controls, built day to day with Claude Code. That covers the two must-haves where others are weakest.

Practise a 90-second version, then be ready to go deeper on any of the points below.

### 2.1 Pluggable fetch pipeline
- Each job source implements one `JobSource` interface and is registered in a registry. The pipeline runs each source independently, so **one failing source doesn't stop the others**.
- Per-source health status is stored in the DB, along with resume state (per-keyword watermarks for Himalayas), so runs are incremental instead of re-fetching everything.
- **How to use it in the interview:** this is the same pattern as tools in an agent. Each tool has a clear contract, failures are isolated, and state is explicit. It also shows you care about reliability and running safely more than once.
- **If they ask why it's TypeScript and not PHP:** "I picked the right stack for a side project on Vercel. The patterns transfer directly: interface + registry = Laravel service container with tagged bindings, and the scheduled pipeline = queued jobs + scheduler."

### 2.2 LLM in production (Claude API fit analysis)
- Claude analyses how well a job fits the user and returns **structured output** (a schema, not free text), which the app validates before saving.
- **Versioned prompt and schema (`PROMPT_VERSION`):** changing the prompt or schema bumps the version, so old analyses are recognised as stale and can be re-run. Treating prompts like code with versions is a strong signal of maturity.
- It runs **on demand** from the job page and as optional **scheduled pre-analysis**. It's off by default and Pro-only, so it's a feature flag plus a cost gate.
- **The point to make:** LLM features need product controls (who can trigger them, how often, at what cost), not just an API call.

### 2.3 Evals
- There's a labeled dataset of jobs with expected outcomes, and a script (`ai:eval`) runs the prompt against it and reports accuracy.
- **Why it impresses:** without evals, prompt changes are guesswork. With them, you can say "version N+1 improved precision on borderline cases without breaking the clear ones." Most teams skip this.
- **If they ask how you'd do it at scale:** run it in CI on prompt changes, track metrics over time, add production samples to the dataset, and use LLM-as-judge for open-ended outputs (calibrated against human labels).

### 2.4 Rules before LLM
- Cheap, deterministic rule-based scoring (backend → PHP+Laravel → full remote + salary threshold) runs first. The LLM adds nuance on top.
- **Why:** cost, latency and predictability. Don't spend tokens on what a `WHERE` clause can decide. This is a good design-judgment talking point, because it shows you don't force an LLM into everything.

### 2.5 Your Claude Code workflow (they explicitly ask for this)
Describe it concretely:
- **Project context file (CLAUDE.md):** commands, architecture and rules, such as "writes must call `requireAppUser()`" or "never commit private data". This keeps the agent consistent across sessions.
- **You review every diff.** The agent proposes and you decide. You keep tight control over auth, DB migrations, billing and security-sensitive code.
- **Tests as the safety net:** ask for tests with changes and run them before accepting.
- **Good uses:** scaffolding, refactors across many files, writing tests, exploring an unfamiliar codebase, drafting migrations you then check.
- **Where you're careful:** confident-but-wrong answers about library APIs (check the docs), over-broad changes, and secrets in context.
- **As a lead:** you'd set up team conventions (shared context files, review rules for AI-written code) so the whole team speeds up without lowering quality.

---

## 3. Likely technical questions

### 3.1 Laravel / PHP

**N+1 queries**
- *What it is:* loading a list, then running one extra query per item when you touch a relation (`$listings` → `$listing->dealer` in a loop = 1 + N queries).
- *Fixes:* eager loading with `with('dealer')` or `load()` after the fact. Use `withCount('photos')` instead of counting a loaded relation.
- *Prevention:* `Model::preventLazyLoading(! app()->isProduction())` in a service provider throws in dev when something is lazy-loaded.
- *Large datasets:* `chunkById()` or `lazyById()` keep memory flat. Prefer `chunkById` over `chunk` when you update rows while iterating, because offset-based chunking skips rows.

**Queues**
- *Why:* anything slow or flaky (emails, image processing, **LLM calls**) belongs in a queue, not in the HTTP request.
- *Horizon:* dashboard and supervisor for Redis queues, with metrics, auto-balancing workers and failed-job visibility.
- *Safe retries:* jobs can run more than once (worker crash, timeout), so design them so a second run doesn't double-charge or double-send. Use unique keys, upserts or state checks.
- *Built-in tools:* `ShouldBeUnique` (one job per key in the queue), `WithoutOverlapping` middleware (one running at a time per key), `RateLimited` middleware (throttle, e.g. LLM provider limits), `$tries`, `backoff()` (exponential), `retryUntil()` (deadline-based) and `failed()` for cleanup and alerting.
- *LLM-specific:* put the LLM call in a job, rate-limit it per provider, add backoff on 429/529 errors, and set a timeout below the worker timeout.

**Service container and providers**
- The container resolves dependencies automatically. Bind interfaces to implementations in service providers (`$this->app->bind(LlmClient::class, AnthropicClient::class)`).
- *Contextual binding:* "when `ListingDescriber` needs an `LlmClient`, give it the cheap model; when `PricingAgent` needs one, give it the strong model."
- *Facades vs. dependency injection:* facades are static-looking proxies to container services. They're convenient and testable via `::fake()`. Constructor injection makes dependencies explicit, which is preferable in domain or service classes.

**Octane**
- Octane keeps the app in memory between requests (Swoole/RoadRunner/FrankenPHP), which is much faster.
- *The catch:* state leaks. Singletons, static properties and anything cached on a service persist across requests, so user A's data can leak to user B. Use `scoped()` bindings, avoid static state, and inject the request rather than storing it in singletons.

**Modern PHP 8.x**
- Enums (with methods and interfaces, great for statuses), readonly properties and classes (immutable DTOs/value objects), constructor property promotion, `match`, named arguments, first-class callable syntax (`strlen(...)`), and the nullsafe operator `?->`.
- Static analysis: PHPStan with **Larastan**, which understands Laravel magic. Raise the level gradually and use a baseline file for legacy code.
- Formatting: Pint. Upgrades: Rector to automate PHP and Laravel version upgrades.

**Testing**
- Pest (modern syntax, popular in Laravel) or PHPUnit. Feature tests for HTTP and integration, unit tests for pure logic.
- `RefreshDatabase` (wraps each test in a transaction or migrates fresh), factories with states (`Listing::factory()->sold()->create()`).
- `Http::fake()` to fake external APIs, **including LLM APIs**. Return canned tool-call responses to test your agent loop deterministically. Also `Queue::fake()`, `Bus::fake()`, `Event::fake()`.

### 3.2 Databases at 30M users/month

- **`EXPLAIN` / `EXPLAIN ANALYZE`:** look for full table scans, filesorts, temporary tables and row estimates that don't match reality. First step for any slow query.
- **Composite indexes and column order:** an index on `(make, model, year)` helps `WHERE make=? AND model=?` but not `WHERE model=?` alone (leftmost prefix rule). Put equality filters first and range filters (price, year) last.
- **Covering index:** the index contains every column the query needs, so the DB never reads the table rows. Big win on hot read paths.
- **Keyset vs. offset pagination:** `OFFSET 100000` still scans 100k rows, so it gets slower the deeper you go. Keyset (`WHERE id < :last_id ORDER BY id DESC LIMIT 20`) stays fast. In Laravel: `cursorPaginate()`.
- **Read replicas:** send reads to replicas and writes to the primary (Laravel supports `read`/`write` connections). Watch replication lag; Laravel's `sticky` option reads your own writes from the primary within the same request.
- **Migrations without downtime (expand/contract):** add a new column (nullable) → write to both → backfill in batches → switch reads → remove the old column in a later deploy. Never rename or drop in one step on a big, hot table. For huge MySQL tables, mention online schema change tools (gh-ost, pt-online-schema-change).
- **Caching:** Redis, `Cache::remember()`, cache tags, short TTLs plus event-based invalidation for listing changes. Mention avoiding a cache stampede (locks, or `Cache::flexible()` for stale-while-revalidate in newer Laravel).
- **Search:** a car marketplace's faceted search (make, model, price range, mileage, location) almost certainly runs on **Elasticsearch/OpenSearch**, not SQL. Keep the DB as the source of truth and sync to the search index via events or queues (Laravel Scout, or a custom indexer).

### 3.3 Agentic AI (expect the most depth here)

**How a tool-calling loop works**
1. Send the model a prompt plus tool definitions (name, description, JSON schema for the inputs).
2. The model replies either with a final answer or with a tool-use request ("call `get_comparable_listings` with `{make: 'BMW', model: '320d', year: 2019}`").
3. Your code runs the tool and sends back the result.
4. Repeat until the model gives a final answer.
5. **Always cap the iterations** (e.g. 10) and the total tokens and cost, or a confused agent loops forever.

**Production concerns**, with what to say for each:
- *Timeouts and retries:* LLM calls are slow and sometimes fail (rate limits, overload). Use exponential backoff and a deadline.
- *Safe retries for tools:* if a tool changes data and the loop retries, it must not do the action twice.
- *Cost and token budgets:* per request, per user, per day. Track tokens in your own metrics.
- *Prompt caching:* stable parts (system prompt, tool definitions, long context) go first so providers can cache them. That cuts cost and latency a lot.
- *Model choice:* use a cheap or fast model for simple steps (classification, routing) and a strong model for reasoning.
- *Structured output validation:* validate the JSON against a schema. On failure, retry with the error message or fall back.
- *Observability:* log every step (prompt version, tool calls, inputs and outputs, tokens, latency) with a trace ID. Without this you can't debug agents.
- *Human in the loop:* actions that change data (publishing a listing, emailing a customer, changing a price) need approval or must be limited to suggestions.

**RAG (retrieval-augmented generation)**
- *What it is:* before asking the LLM, retrieve relevant documents and put them in the prompt, so answers are grounded in your data rather than the model's memory.
- *Pipeline:* split docs into chunks → create embeddings → store in a vector index → at query time, embed the question, find similar chunks, add them to the prompt.
- *Where to store vectors:* **pgvector** if you're already on Postgres (simple, transactional, good enough for millions of rows), or a dedicated vector DB / OpenSearch k-NN at larger scale.
- *Hybrid search:* combine keyword (BM25) and vector search. Keyword search catches exact terms like model codes ("320d", "VIN") that embeddings blur.
- *Key insight:* answer quality depends more on **retrieval quality** than on the model. Evaluate retrieval separately (did the right chunk come back?).

**Prompt injection**
- Content the agent reads (listing descriptions, user messages, web pages) can contain instructions like "ignore previous instructions and…".
- Defences: treat tool and retrieved content as **data, not instructions**, give tools least privilege (read-only where possible, scoped to the current user), validate outputs, require human approval for risky actions, and never put secrets in prompts.

**Evals** (also covered in section 2.3)
- Golden datasets, regression testing in CI when prompts change, LLM-as-judge for open-ended answers (calibrated against human labels), and tracking production feedback.

**Laravel integration**
- Wrap the LLM provider behind your own interface (`LlmClient`) so you can swap providers and fake it in tests.
- Run agent loops as **queued jobs**, and stream progress back to the user via broadcasting/websockets (Reverb) or polling.
- **Prism** (`prism-php/prism`) is the popular Laravel package for LLMs, with one API across providers, tool calling and structured output. Knowing the name shows you follow the ecosystem.
- MCP (Model Context Protocol) is the emerging standard for exposing tools to agents. Mention it if they talk about internal tooling.

### 3.4 System design they might ask (car marketplace themed)

**Example A: "AI listing assistant", which generates a description and suggests a price from photos and specs**

Walk through it in this order and say each step out loud:
1. **API:** the dealer uploads photos and specs → `POST /listings/{id}/ai-draft` returns `202 Accepted` with a job ID (don't block the request).
2. **Queue:** a job runs the agent, with a rate limit and safe retries keyed by listing ID and version.
3. **LLM with tools:** a vision model reads the photos (condition, colour, damage). Tools such as `get_vehicle_specs(vin)` and `get_comparable_listings(make, model, year, mileage, region)` give the model real market data.
4. **Validate:** a structured-output schema, sanity checks (price within the range of comparables, no made-up features that aren't in the specs).
5. **Cache:** comparables per make/model/region for a few hours.
6. **Human review:** the dealer edits and accepts. **Never auto-publish.**
7. **Metrics:** acceptance rate, edit distance between draft and final text, time to publish, cost per draft.
8. **Cost controls:** per-dealer limits, a cheap model for the description and a strong model only for pricing.

**Example B: "Agent that answers buyer questions about a listing"**
- Use RAG over the listing data, dealer FAQ and vehicle specs, with tools like `check_availability` or `book_test_drive` (that one needs confirmation).
- Guardrails: only answer about this listing, never invent warranty or legal claims, hand off to a human dealer when unsure, and add prompt-injection protection because buyer messages are untrusted input.
- Handle multiple languages (18 countries), log conversations for evals, and handle personal data under GDPR (retention, no personal data in logs).

---

## 4. Docker and cloud (quick refresher)

- **Laravel image:** a multi-stage build (Composer install in the build stage, slim runtime), PHP-FPM + Nginx or Octane (FrankenPHP), OPcache enabled, config and route caching at build or deploy time.
- **Processes:** web, queue workers (Horizon) and the scheduler as **separate containers or services** from the same image. Scale them independently.
- **Deploy:** ECS/Fargate, EKS/GKE or Cloud Run, with migrations as a one-off pre-deploy task (the expand/contract rules from 3.2 apply), health checks and rolling or blue-green deploys.
- **Config:** env vars and a secrets manager, no secrets in the image.
- **Observability:** structured logs, metrics, tracing (OpenTelemetry), error tracking (Sentry), and alerts on queue depth and failed jobs.

---

## 5. Leadership and behavioral (it's a "Leader" level role)

Use **STAR**: Situation (1–2 sentences), Task (what was on you), Action (what *you* did, with specifics), Result (numbers if possible, plus what you learned). Keep each to about 2 minutes.

1. **Mentoring or raising the team's standards.**
   *What they're checking:* can you make others better, not just ship yourself?
   *Good angles:* introducing code review guidelines, a testing culture, PHPStan levels, pairing with a junior until they owned a feature.
2. **A requirement that was unclear.**
   *What they're checking:* the "independently on ambiguous problems" requirement.
   *Show:* you asked the right questions, wrote down assumptions, proposed options with trade-offs, got a decision, shipped in steps.
3. **A production incident.**
   *What they're checking:* calm under pressure, ownership, blameless learning.
   *Show:* how you found it, the mitigation (rollback, feature flag), the root cause, and the lasting fix (test, alert, runbook).
4. **A disagreement on a technical decision.**
   *What they're checking:* you can disagree and still commit, and you use data rather than ego.
   *Show:* the respectful disagreement, the evidence (prototype, benchmark), and the outcome, even if you didn't get your way.

**Bonus, since it's an outsourcing company:** working with a client's in-house team. Show that you communicate proactively, flag risks early and stay inside the client's processes.

---

## 6. Questions to ask them

Asking good questions shows seniority and helps you judge the offer.

- **Who is the client, and which team or product is this release for?** You need this to judge the domain and stability. They may only share it later, under NDA.
- **What does the agentic AI work look like today? Greenfield or already in production? Which LLM provider and framework?** This tells you whether you'd build from scratch (more influence, more ambiguity) or extend something existing.
- **Why Toronto time for a European marketplace? What are the actual core hours?** Possibly a North American team on the client side. This directly affects your daily life; get concrete hours.
- **What happens after 6 months: extension, another project, conversion? Contract type: B2B or employment?** It's a contract role, so know the risk.
- **Team size and composition, and do I lead people formally or by influence?** "Leader" can mean tech lead, people manager, or just a senior label.
- **What does the rest of the interview process look like?** Lets you prepare for the next stage (client interview, live coding, system design).

---

## 7. Logistics and pay

- **Pay anchor:** an N-iX "Lead PHP Engineer" listing in Kraków shows **$6,000–6,668 net/month on B2B** (justjoin.it). If they ask your expectations, anchor at or above the top of that range, given the AI requirement and the inconvenient time zone. Rates differ by country and contract type, so check what applies to you.
- **Typical N-iX process (from reviews):** HR screen → technical interview → hiring manager / client interview, about 3 weeks in total. Some reviewers describe the technical round as **checklist-style**, so have crisp one-sentence definitions ready (N+1, ACID, isolation levels, SOLID, REST vs. RPC, indexes, queues) and then add depth if they want it.
- **On the call:** quiet room, camera on, the posting and this file open, a glass of water, and 2–3 stories rehearsed out loud at least once.

---

## Sources
- [N-iX job posting](https://careers.n-ix.com/jobs/4529257101-php-leader/)
- [Lead PHP Engineer – justjoin.it (pay range)](https://justjoin.it/job-offer/n-ix-lead-php-engineer-krakow-php)
- [Glassdoor N-iX interview review](https://www.glassdoor.com.au/Interview/N-iX-Interview-E200288-RVW99282424.htm)
- [Glassdoor N-iX interview review (2)](https://www.glassdoor.sg/Interview/N-iX-Interview-E200288-RVW88223281.htm)
- [Scoutify N-iX interview guide (questions inferred, unverified)](https://scoutify.com/companies/n-ix/interview/)
