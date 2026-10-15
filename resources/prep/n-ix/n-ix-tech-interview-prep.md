# Technical interview prep (90 min): PHP, Laravel, AI, cloud

Deeper explanations: [n-ix-php-leader-prep.md](./n-ix-php-leader-prep.md) (sections 2–4).
This file is the **cram sheet**: short answers you can say out loud, plus code you may be asked to write.

---

## 0. How to use the next hour

| Time | What to do |
|---|---|
| 0–10 min | Read **section 1** (format) and say the **job-radar pitch** out loud once (prep file, section 2). |
| 10–30 min | **Section 2** quick answers. Cover each answer and say it before reading. Mark the ones you stumble on. |
| 30–45 min | **Section 4** (AI). It's the must-have and where you stand out. Read the PHP tool loop until you could write it from memory. |
| 45–55 min | **Section 3** live coding. Read the problems and solve 2 in your head *before* looking. |
| 55–60 min | **Section 5** (AWS) skim, **section 7** questions to ask. Water, quiet room, IDE open. |

---

## 1. What 90 minutes probably looks like

A typical N-iX technical round (reviews describe interviewers working through a topic checklist):

| Approx. | Part | Tip |
|---|---|---|
| 5–10 min | Intros, your background | 90-second summary: 15 yrs PHP, 10 Laravel, 6 AWS, recent LLM work, Claude Code daily. |
| 30–40 min | Rapid-fire theory: PHP, Laravel, DB, maybe AWS | Answer in 2–3 sentences, then stop. Offer depth: "I can go deeper on that if useful." |
| 15–25 min | Live coding or code review (shared screen / editor) | **Think aloud.** Clarify input, write simple code first, then improve, mention tests and edge cases. |
| 15–20 min | AI / system design discussion | Use the structure in section 6. |
| 5–10 min | Your questions | Section 7. |

**General rules:**
- If you don't know something, say so and reason it out: "I haven't used X directly; I'd expect it to work like Y because…". Interviewers respect that far more than bluffing.
- Bring answers back to experience: "In a project at ___ we had exactly this…".
- If they allow AI tools in live coding, use them *visibly and critically*. They want daily Claude Code users, so show that you review and test what it writes.

---

## 2. Quick answers (say these out loud)

### 2.1 PHP core

**`==` vs `===`?** `==` compares after type juggling, `===` compares value **and** type. Always use `===`. PHP 8 made `0 == "abc"` false (it was true in PHP 7), but strict comparison still avoids surprises.

**Interface vs abstract class vs trait?**
- *Interface:* a contract with no state. A class can implement many.
- *Abstract class:* a partial implementation with shared state. Single inheritance only.
- *Trait:* horizontal code reuse (copy-paste done by the compiler). It's not a type, so you can't type-hint a trait.
- Rule of thumb: program to interfaces, use traits sparingly (Laravel uses them for `HasFactory`, `SoftDeletes`, etc.).

**`self::` vs `static::`?** `self` refers to the class where the code is written. `static` refers to the class that was actually called (**late static binding**). It matters for static factories in parent classes: `return new static()` creates the subclass.

**Generators (`yield`)?** A function that produces values lazily, one at a time, keeping memory flat. Use for big files or big query results (`LazyCollection` and `cursor()` in Laravel are built on them).

**Closures?** Anonymous functions. `use ($x)` captures by value, `use (&$x)` by reference. Arrow functions `fn($x) => $x * $y` capture the outer scope automatically (by value). `Closure::bind` / `->call()` changes `$this`.

**PHP 8.x features worth naming:** enums (backed, with methods), readonly properties and classes, constructor promotion, `match`, named arguments, nullsafe `?->`, union and intersection types, `never` return type, first-class callables `foo(...)`, fibers (8.1, low-level async; the base for things like Revolt/ReactPHP), typed class constants (8.3), property hooks and asymmetric visibility (8.4).

**How does PHP-FPM run a request?** It's **share-nothing**: each request boots the app, runs and then frees everything. Simple and safe, but the bootstrap costs time on every request. **OPcache** keeps compiled bytecode in shared memory (always enable it in production). **Octane** keeps the app booted between requests (faster, but watch for leaked state).

**Composer autoloading?** **PSR-4** maps namespaces to folders. Run `composer dump-autoload -o` (classmap optimization) in production. `composer.lock` pins exact versions, so commit it for applications.

**PSRs to name:** PSR-4 (autoloading), PSR-12 / PER (coding style), PSR-3 (logger), PSR-7 / PSR-17 (HTTP messages), PSR-15 (middleware), PSR-11 (container), PSR-6 / PSR-16 (cache), PSR-18 (HTTP client).

**Security basics:**
- *SQL injection:* prepared statements / bindings. Eloquent and Query Builder bind for you, but `DB::raw()` and `whereRaw()` with user input are dangerous.
- *XSS:* escape output. Blade's `{{ }}` escapes; `{!! !!}` doesn't.
- *CSRF:* tokens on state-changing forms (Laravel middleware does it). APIs with tokens instead of cookies are not exposed to CSRF.
- *Mass assignment:* `$fillable` / `$guarded`, and validated data only: `Model::create($request->validated())`.
- *Passwords:* `password_hash()` / `Hash::make()` (bcrypt or argon2id), never md5/sha1.
- *Other:* rate-limit login, keep secrets out of git, IDOR (check ownership via Policies), validate file uploads (type, size, store outside the web root or on S3).

**SOLID in one line each:**
- **S**ingle responsibility: one reason to change.
- **O**pen/closed: extend without modifying (strategy pattern, interfaces).
- **L**iskov substitution: subclasses must be usable wherever the parent is.
- **I**nterface segregation: small, focused interfaces.
- **D**ependency inversion: depend on abstractions. Laravel's container makes this easy.

**Design patterns you'll be asked about, with Laravel examples:**
- Strategy: drivers (cache, queue, mail).
- Factory: model factories, `Manager` classes.
- Repository: optional wrapper over Eloquent. Have an opinion: "useful at boundaries or for complex queries, overkill as a 1:1 wrapper".
- Observer: model events, observers.
- Decorator / pipeline: middleware.
- Adapter: filesystem drivers.
- Singleton: container singletons.
- Facade: a static proxy to a container service, not the GoF facade.

### 2.2 Laravel

**Request lifecycle?** `public/index.php` → bootstrap the app (container) → HTTP kernel → service providers (`register` then `boot`) → global middleware → router → route middleware → controller → response travels back through middleware → `terminate`.

**`register()` vs `boot()` in providers?** `register` only binds things into the container; don't use other services there because they may not be registered yet. `boot` runs after all providers are registered: event listeners, macros, gates, `preventLazyLoading`, and so on.

**Laravel 11+ structure:** a slimmer skeleton. Middleware, exceptions and routing are configured in `bootstrap/app.php` (no `Http/Kernel.php`), and the schedule lives in `routes/console.php`.

**`bind` vs `singleton` vs `scoped`?** `bind` gives a new instance every time it's resolved. `singleton` gives one instance for the app's lifetime (under Octane that means across requests!). `scoped` gives one per request or job lifecycle, which is safe under Octane and queues.

**Eloquent vs Query Builder?** Eloquent gives models, relations, events and casts, at the cost of hydrating objects. Query Builder is lighter and good for reports and bulk operations. For big bulk writes use `insert()`, `upsert()` or `update()` on a query: one SQL statement and no per-model events.

**Relations to know:** `hasOne`, `hasMany`, `belongsTo`, `belongsToMany` (pivot table, `withPivot`, `withTimestamps`), `hasManyThrough`, polymorphic `morphTo` / `morphMany` / `morphToMany`. Plus `whereHas()` (filter by relation), `withCount()`, `withSum()`, `latestOfMany()`.

**Casts and accessors:** `casts()` for `array`, `datetime`, `encrypted`, enums, custom value objects. Accessors and mutators use `Attribute::make(get:, set:)`.

**Scopes:** local scopes (`scopeActive` → `->active()`, or the `#[Scope]` attribute in newer versions), global scopes (`SoftDeletes` is one; a good fit for multi-tenancy).

**Validation:** Form Requests (`rules()`, `authorize()`), `$request->validated()`. Custom rules as classes or closures. `Rule::unique()->ignore($id)` on updates.

**Authorization:** Gates for simple checks, Policies per model (`$this->authorize('update', $listing)`, `@can`). Policies prevent IDOR: users editing other users' listings.

**API auth:** **Sanctum** for SPA (cookie) auth and simple API tokens with abilities, which covers most apps. **Passport** is a full OAuth2 server (third-party clients, authorization code flow).

**API Resources:** `JsonResource` / `ResourceCollection` shape the output, hide internal fields and keep the API stable when the DB changes. Use `whenLoaded()` to avoid N+1 queries in resources.

**Events, listeners, observers:** decouple side effects ("listing published" → index in search, notify followers). Listeners implementing `ShouldQueue` run asynchronously. `ShouldDispatchAfterCommit` avoids firing for a transaction that later rolls back.

**Transactions and locking:**
```php
DB::transaction(function () use ($listingId, $buyerId) {
    $listing = Listing::whereKey($listingId)->lockForUpdate()->firstOrFail();
    if ($listing->status !== ListingStatus::Available) {
        throw new ListingUnavailable();
    }
    $listing->update(['status' => ListingStatus::Reserved, 'reserved_by' => $buyerId]);
}, attempts: 3); // retries on deadlock
```
- `lockForUpdate()` = `SELECT … FOR UPDATE` (pessimistic). The alternative is optimistic locking with a `version` column: `UPDATE … WHERE id=? AND version=?`, and if 0 rows changed, someone else won.
- **Atomic locks** across servers: `Cache::lock('import:'.$id, 10)->block(5, fn () => ...)` (needs Redis or a DB cache store).
- Never call slow external APIs (LLM!) inside a DB transaction, because it holds locks and connections.

**Queues:** see the prep file 3.1. Key words: Horizon, `$tries`, `backoff`, `retryUntil`, `ShouldBeUnique`, `WithoutOverlapping`, `RateLimited`, `failed()`, safe retries, batches (`Bus::batch`) and chains (`Bus::chain`).

**Scheduling:** `Schedule::command(...)->hourly()->withoutOverlapping()->onOneServer()`. `onOneServer` matters when several servers run the scheduler.

**Caching:** `Cache::remember($key, $ttl, fn)`, tags (Redis/Memcached), `Cache::flexible()` (stale-while-revalidate), and `php artisan config:cache route:cache view:cache event:cache` (or `optimize`) on deploy.

**Rate limiting:** `RateLimiter::for('api', fn (Request $r) => Limit::perMinute(60)->by($r->user()?->id ?: $r->ip()))` + `throttle:api` middleware.

**Testing:** see the prep file 3.1. Plus `assertDatabaseHas`, `actingAs`, `Http::preventStrayRequests()` (fails a test that makes a real HTTP call, which is great for LLM code).

**Performance checklist** (if asked "the app is slow, what do you do?"):
1. **Measure first:** APM (New Relic/Datadog), Telescope/Debugbar locally, the slow query log.
2. **DB:** N+1 queries, missing indexes (`EXPLAIN`), `select *` on wide tables, offset pagination.
3. **Cache** hot reads, move slow work to **queues**.
4. **Infrastructure:** OPcache, config/route cache, Octane, horizontal scaling, CDN for assets.
5. **Verify** with the same measurement again.

### 2.3 Databases

**Index types and rules:** B-tree (default; equality and ranges), composite indexes (leftmost prefix rule; equality columns first, range last), covering indexes, full-text. Indexes speed up reads and slow down writes, so don't index everything. Low-cardinality columns (a boolean) alone are rarely useful.

**Why isn't my index used?** A function on the column (`WHERE DATE(created_at) = …` → use a range instead), a leading wildcard `LIKE '%x'`, implicit type conversion (comparing a string column to an int), `OR` across different columns, or the optimizer estimating a full scan is cheaper.

**Transaction isolation levels:** Read Uncommitted (dirty reads), Read Committed (Postgres default; non-repeatable reads), Repeatable Read (**MySQL InnoDB default**; consistent snapshot), Serializable (strictest, slowest). Higher isolation gives fewer anomalies but more locking and retries.

**ACID:** Atomicity (all or nothing), Consistency (constraints hold), Isolation (concurrent transactions don't interfere), Durability (committed = survives a crash).

**Deadlock?** Two transactions each wait for a lock the other holds, and the DB kills one. Prevent it by locking rows in a consistent order and keeping transactions short. Handle it by retrying (`DB::transaction(..., attempts: 3)`).

**Normalization vs denormalization:** normalize (around 3NF) for consistency. Denormalize deliberately for read performance (counters, a search index, read models). On a marketplace, listings search is effectively a denormalized index in Elasticsearch.

**MySQL vs PostgreSQL in one breath:** Postgres has richer types (JSONB with GIN indexes, arrays), partial and expression indexes, CTEs and window functions (MySQL 8 has those too), and pgvector for embeddings. MySQL is simpler to run, has a huge ecosystem and strong replication tooling. Both are fine; it depends on the team and the workload.

**Scaling the DB:** indexes and query fixes → caching → read replicas → vertical scaling → partitioning (by date or region) → sharding (last resort, very complex).

---

## 3. Live coding: likely exercises with solutions

**How to behave:** restate the problem → ask about edge cases → write the simple version → test it with an example out loud → improve it → mention complexity (Big-O) and how you'd test it.

### 3.1 Group and aggregate (very common)
*"Given an array of listings (`make`, `price`), return the average price per make, sorted by average descending."*

```php
function averagePriceByMake(array $listings): array
{
    $sums = [];
    foreach ($listings as ['make' => $make, 'price' => $price]) {
        $sums[$make]['total'] = ($sums[$make]['total'] ?? 0) + $price;
        $sums[$make]['count'] = ($sums[$make]['count'] ?? 0) + 1;
    }

    $averages = array_map(fn (array $s) => round($s['total'] / $s['count'], 2), $sums);
    arsort($averages);

    return $averages; // ['BMW' => 31000.0, 'Dacia' => 12000.5, ...]
}
```
- *With Laravel collections:* `collect($listings)->groupBy('make')->map->avg('price')->sortDesc()->all();` Mention both versions: it shows you know the language **and** the framework.
- *In SQL:* `SELECT make, AVG(price) avg_price FROM listings GROUP BY make ORDER BY avg_price DESC;`. At scale, do it in the DB, not in PHP.
- Edge cases: an empty array, missing keys, and price as a string. Prices are best stored as integer cents to avoid float errors.

### 3.2 Two-sum / pair finding (classic algorithm)
*"Return the indexes of two numbers that add up to the target."*
```php
function twoSum(array $nums, int $target): ?array
{
    $seen = []; // value => index
    foreach ($nums as $i => $n) {
        $need = $target - $n;
        if (isset($seen[$need])) {
            return [$seen[$need], $i];
        }
        $seen[$n] = $i;
    }
    return null;
}
```
O(n) time and O(n) memory using a hash map. Mention that the brute force is O(n²).

### 3.3 Balanced brackets (stack)
```php
function isBalanced(string $s): bool
{
    $pairs = [')' => '(', ']' => '[', '}' => '{'];
    $stack = [];
    foreach (str_split($s) as $ch) {
        if (in_array($ch, $pairs, true)) {
            $stack[] = $ch;
        } elseif (isset($pairs[$ch])) {
            if (array_pop($stack) !== $pairs[$ch]) {
                return false;
            }
        }
    }
    return $stack === [];
}
```

### 3.4 Retry with exponential backoff (relevant to LLM calls)
```php
function retry(callable $fn, int $times = 3, int $baseMs = 200): mixed
{
    for ($attempt = 1; ; $attempt++) {
        try {
            return $fn();
        } catch (TransientException $e) {
            if ($attempt >= $times) {
                throw $e;
            }
            $delayMs = $baseMs * 2 ** ($attempt - 1) + random_int(0, 100); // jitter
            usleep($delayMs * 1000);
        }
    }
}
```
- Laravel has this built in: `retry(3, fn () => ..., fn (int $attempt) => $attempt * 200)` and `Http::retry(3, 200)`.
- Only retry **transient** errors (timeouts, 429, 5xx, 529 overloaded), never 400/401. Add jitter so many clients don't retry at the same moment.

### 3.5 Code review exercise (very likely for a Lead role)
*"What's wrong with this controller?"*
```php
public function store(Request $request)
{
    $listing = Listing::create($request->all());
    foreach (Listing::where('user_id', $request->user_id)->get() as $l) {
        $l->user->notify(new ListingCreated($listing));
    }
    $desc = Http::post('https://api.llm/...', ['prompt' => $request->title])->json('text');
    $listing->description = $desc;
    $listing->save();
    return $listing;
}
```
Problems to call out, roughly in order of severity:
1. **Mass assignment with `$request->all()`** and **no validation**. Use a Form Request and `->validated()`.
2. **`user_id` comes from the request**, so anyone can create listings as anyone. Use `$request->user()`, and add a Policy.
3. **N+1** on `$l->user` in the loop, and the logic notifies the same user once per listing they own, which is probably a bug.
4. **A slow, unreliable external LLM call inside the HTTP request**, with no timeout, retry or error handling. Move it to a **queued job**, use `Http::timeout()->retry()`, and handle failure (the listing is still saved, the description is filled in later).
5. **Prompt injection:** the user's title goes straight into the prompt. Treat it as data and validate the output.
6. **No transaction** / partial state, and notifications should be **queued** too.
7. **Returning the model directly:** use an API Resource and return `201`.

Improved sketch:
```php
public function store(StoreListingRequest $request): JsonResponse
{
    $listing = $request->user()->listings()->create($request->validated());

    GenerateListingDescription::dispatch($listing)->afterCommit();
    event(new ListingCreated($listing)); // queued listeners handle notifications

    return ListingResource::make($listing)->response()->setStatusCode(201);
}
```

### 3.6 Possible SQL questions
- *Second highest price:* `SELECT MAX(price) FROM listings WHERE price < (SELECT MAX(price) FROM listings);` or `ORDER BY price DESC LIMIT 1 OFFSET 1` (careful with duplicates: use `DISTINCT`).
- *Dealers with no listings in the last 30 days:* `LEFT JOIN … WHERE l.id IS NULL`, or `NOT EXISTS (SELECT 1 FROM listings l WHERE l.dealer_id = d.id AND l.created_at >= NOW() - INTERVAL 30 DAY)`.
- *Top 3 most expensive listings per make:* window function `ROW_NUMBER() OVER (PARTITION BY make ORDER BY price DESC)`, then filter `<= 3` in an outer query.
- *Duplicates:* `GROUP BY vin HAVING COUNT(*) > 1`.

---

## 4. AI: what you must be able to explain *and* code

### 4.1 Concepts (quick answers)

- **Tokens:** pieces of words. Pricing, limits and the context window are counted in tokens (roughly 4 characters of English per token).
- **Context window:** the maximum tokens in prompt + response. Long contexts cost more and can dilute attention, so retrieve only what's relevant.
- **Temperature:** randomness. Use low values for extraction and classification and higher for creative text. Note: some newer models restrict or ignore sampling parameters, so check the model docs.
- **Hallucination:** the model produces plausible but false content. Mitigate with grounding (RAG/tools), structured output, validation, "say 'unknown' if not in the context", and evals.
- **Structured output:** ask for JSON matching a schema (tool definitions or the provider's structured-output feature), then **validate** it. Never trust it blindly.
- **Function / tool calling:** you describe the tools, the model asks to call them, your code executes them. The model never runs code itself.
- **Agent:** an LLM in a loop that decides which tools to call until the task is done. A workflow (fixed steps, LLM inside some of them) is more predictable, so **prefer workflows when the steps are known** and use agents for open-ended tasks. This is a strong judgment point to make.
- **Embeddings and RAG:** see the prep file 3.3.
- **Streaming:** server-sent events let the user see tokens as they arrive. In Laravel: `response()->stream()` or `response()->eventStream()` (newer versions), or broadcast from a queued job.
- **Prompt caching:** put a stable prefix (system prompt, tools, documents) first, then the cache cuts cost and latency on repeated calls.
- **MCP (Model Context Protocol):** an open standard for exposing tools and data to AI apps and agents. One MCP server can work with any compatible client (Claude, IDEs, etc.). Laravel has an official MCP package for exposing your app's tools.
- **Evals:** a labeled dataset + automated scoring, run whenever the prompt or model changes. *Your job-radar story.*
- **Cost control:** model routing (cheap model for easy steps), caching, budgets per user, batch APIs for offline work, rules before LLM.

### 4.2 The tool-calling loop in PHP (be able to write this)

Plain Laravel HTTP client against the Anthropic Messages API. Shows you understand what SDKs and agent frameworks do under the hood.

```php
final class ListingAgent
{
    private const MAX_STEPS = 8;

    public function __construct(private readonly ComparablesService $comparables) {}

    public function run(string $question): string
    {
        $messages = [['role' => 'user', 'content' => $question]];

        for ($step = 0; $step < self::MAX_STEPS; $step++) {
            $response = Http::withHeaders([
                    'x-api-key' => config('services.anthropic.key'),
                    'anthropic-version' => '2023-06-01',
                ])
                ->timeout(60)
                ->retry(3, 500, fn ($e) => $e instanceof ConnectionException
                    || in_array($e->response?->status(), [429, 500, 529], true))
                ->post('https://api.anthropic.com/v1/messages', [
                    'model' => config('services.anthropic.model'),
                    'max_tokens' => 1024,
                    'system' => 'You help car buyers. Use tools for prices. Never invent data.',
                    'tools' => $this->tools(),
                    'messages' => $messages,
                ])
                ->throw()
                ->json();

            // Keep the assistant turn (including tool_use blocks) in the history
            $messages[] = ['role' => 'assistant', 'content' => $response['content']];

            if ($response['stop_reason'] !== 'tool_use') {
                return collect($response['content'])
                    ->where('type', 'text')->pluck('text')->implode("\n");
            }

            $results = [];
            foreach ($response['content'] as $block) {
                if ($block['type'] !== 'tool_use') {
                    continue;
                }
                $results[] = [
                    'type' => 'tool_result',
                    'tool_use_id' => $block['id'],
                    'content' => json_encode($this->callTool($block['name'], $block['input'])),
                ];
            }
            $messages[] = ['role' => 'user', 'content' => $results];
        }

        throw new AgentStepLimitReached();
    }

    private function tools(): array
    {
        return [[
            'name' => 'get_comparable_listings',
            'description' => 'Find similar listings with prices for a make/model/year.',
            'input_schema' => [
                'type' => 'object',
                'properties' => [
                    'make' => ['type' => 'string'],
                    'model' => ['type' => 'string'],
                    'year' => ['type' => 'integer'],
                ],
                'required' => ['make', 'model', 'year'],
            ],
        ]];
    }

    private function callTool(string $name, array $input): array
    {
        return match ($name) {
            'get_comparable_listings' => $this->comparables->find(
                $input['make'], $input['model'], (int) $input['year'],
            ),
            default => ['error' => "Unknown tool {$name}"],
        };
    }
}
```

**Talking points while showing it:**
- **Step cap** (`MAX_STEPS`) against infinite loops. Also cap total tokens or cost.
- **Retry only transient errors** (429 rate limit, 529 overloaded, 5xx, connection errors) with backoff.
- **Tool input is untrusted** (the model generated it). Validate it and scope it to the current user. Return errors as tool results so the model can recover instead of crashing.
- **Run it in a queued job** for anything user-facing that takes more than a few seconds. Store each step (tokens, latency, tool calls) for observability.
- **Testable:** `Http::fake()` with canned responses (first a `tool_use`, then the final text) to test the loop deterministically, plus `Http::preventStrayRequests()`.
- In real projects you'd use the official SDK or **Prism** (`prism-php/prism`) instead of raw HTTP. They handle tool loops, structured output and provider switching. Knowing the raw protocol helps you debug them.

### 4.3 Likely AI discussion questions

**"How would you add AI features to an existing Laravel monolith?"**
Put an `LlmClient` interface behind the container (swappable providers, fake in tests) and queue the jobs. Store prompts versioned in code, log every call (prompt version, model, tokens, latency, result), keep evals in CI, add feature flags and gradual rollout, and set cost budgets.

**"How do you make LLM output reliable?"**
Structured output + schema validation, low temperature for extraction, grounding via tools or RAG, retry on invalid output (feed the validation error back), deterministic rules for anything the system can decide on its own, human review for risky actions, evals for regressions.

**"How do you evaluate prompt changes?"**
A golden dataset of real inputs with expected outputs, an automated metric (exact match for classification, LLM-as-judge with a rubric for free text, calibrated against human labels), and before/after comparison in CI. Monitor production for drift and user feedback.

**"How do you handle sensitive data / GDPR with LLMs?"**
Minimize what you send (no personal data unless needed, mask or pseudonymize it), use providers with zero-data-retention / no-training terms and an EU region if required, apply log retention limits, and give tools access only to the current user's data.

**"How do you use AI coding tools in a team?"** (they explicitly want daily Claude Code / Codex users)
A shared project context file (CLAUDE.md / AGENTS.md) with conventions and commands. AI-written code goes through the **same review and CI** as human code. Use it for tests, refactors, scaffolding and exploring code. Be careful with auth, migrations and security. Never paste secrets. As a lead, measure whether it actually helps (cycle time, defect rate) rather than assuming.

---

## 5. Cloud (AWS mainly; GCP equivalents in brackets)

**Typical Laravel production architecture on AWS:**
```
Route 53 → CloudFront (CDN, static assets) → ALB (load balancer)
  → ECS Fargate tasks: web (PHP-FPM+Nginx or Octane), Horizon workers, scheduler
  → RDS / Aurora MySQL or Postgres (Multi-AZ, read replicas)
  → ElastiCache Redis (cache, sessions, queues, locks)
  → S3 (uploads, photos) + presigned URLs
  → SQS (queues alternative), SES (email), OpenSearch (search)
  → Secrets Manager / SSM Parameter Store, CloudWatch (+ Sentry/Datadog)
```

**Quick answers:**
- **EC2 vs ECS/Fargate vs Lambda?**
  - *EC2:* virtual machines; full control, but you patch them.
  - *ECS on Fargate:* containers without managing servers. A good default for Laravel.
  - *Lambda:* functions, pay per request, scales to zero. PHP runs on it via **Bref**, and **Laravel Vapor** is serverless Laravel on Lambda. Watch for cold starts and the 15-minute limit.
  - (GCP: Compute Engine / Cloud Run / Cloud Functions; GKE ≈ EKS.)
- **RDS vs Aurora?** Both managed. Aurora has faster failover, storage that auto-grows, up to 15 read replicas and a Serverless v2 option. It costs more. (GCP: Cloud SQL / AlloyDB.)
- **High availability:** multiple Availability Zones (Multi-AZ RDS, tasks spread across AZs, ALB health checks), auto-scaling on CPU, request count or **queue depth** (for workers).
- **Stateless app servers:** sessions and cache in Redis, files in S3, no local disk state. That's what makes horizontal scaling and rolling deploys possible.
- **S3 presigned URLs:** the browser uploads or downloads directly to S3 with a short-lived signed URL, so big files never go through your PHP servers. In Laravel: `Storage::temporaryUrl()` / `temporaryUploadUrl()`.
- **SQS vs Redis queues?** SQS is fully managed, very durable and scales effortlessly, but has no Horizon and allows delays of at most 15 minutes. Redis is fast and supports Horizon, but you have to run it. Both work as Laravel queue drivers.
- **IAM:** least privilege. **Tasks use IAM roles, not access keys in `.env`.** Separate accounts or roles for dev and prod.
- **Secrets:** Secrets Manager or SSM Parameter Store, injected as env vars at container start. Never in the image or in git.
- **Networking:** VPC with **public subnets** (ALB, NAT gateway) and **private subnets** (app, DB, Redis). Security groups as firewalls: the DB accepts traffic only from the app's security group.
- **CI/CD:** GitHub Actions → build the Docker image → push to ECR → run migrations as a one-off task → rolling or blue/green deploy on ECS. Infrastructure as code with Terraform or CDK.
- **Observability:** CloudWatch logs and metrics, structured JSON logs, alarms (5xx rate, p95 latency, queue depth, DB CPU and connections), tracing (X-Ray / OpenTelemetry), Sentry for errors.
- **Cost:** right-size instances, Savings Plans / reserved capacity for steady load, Spot for workers that can be interrupted, S3 lifecycle rules, and watch NAT gateway data costs.
- **AI on AWS:** **Amazon Bedrock** serves Claude and other models inside your AWS account (IAM auth, VPC endpoints, data stays in-region). Good for compliance-heavy clients. (GCP: **Vertex AI** also serves Claude.)

**If they ask about Docker specifically:** see the prep file section 4 (multi-stage build, separate web, worker and scheduler containers from one image, OPcache, `config:cache` at deploy, health checks).

---

## 6. System design: the structure to follow

Use this order for any design question ("design the listings search", "design an AI pricing assistant", "design notifications for saved searches"):

1. **Clarify requirements (2–3 min):** functional (what it does) and non-functional (users, requests per second, latency, consistency, cost, GDPR). *Ask; don't assume.*
2. **Rough numbers:** "30M users a month ≈ 1M a day. If 10% search 5 times → 500k searches a day ≈ 6/s on average, maybe 50/s at peak." It shows you think about scale before choosing tech.
3. **API and data model:** main endpoints and tables.
4. **High-level diagram:** clients → CDN → LB → app → cache / DB / queue / search / LLM.
5. **Deep dive** on the hard part: search, consistency, AI reliability, the hot path.
6. **Failure modes and operations:** what breaks, retries, safe re-runs, monitoring, rollout (feature flags), cost.
7. **Trade-offs:** say what you'd do *first* (an MVP) vs later at scale.

**Ready-made example: "Saved-search alerts" (notify buyers when a matching car is listed)**
- Store saved searches as structured filters.
- On `ListingPublished`, queue a matcher job.
- Matching at scale: **reverse search**. Elasticsearch's **percolator** stores the queries and matches a new document against all of them. Or batch it: every N minutes, run each saved search for new listings since its last watermark.
- Deduplicate notifications (unique key user + listing), digest them (hourly or daily) to avoid spam, respect user preferences and unsubscribe, send email or push via queued notifications.
- *Bonus, this mirrors job-radar:* per-source watermarks, scheduled runs, digest notifications. Mention it naturally.

---

## 7. Questions to ask at the end (pick 3)

1. What does the team look like, and how is work split between N-iX and the client's in-house engineers?
2. What's the current state of the AI work: which providers and frameworks, in production or greenfield, and how do you evaluate quality?
3. PHP and Laravel versions, monolith or services, how deploys happen (CI/CD, frequency).
4. What would make someone successful in the first 30 days on this project?
5. What are the next steps after this interview: the client interview, timeline?

---

## 8. Last-minute checklist

- [ ] IDE or editor ready and screen sharing tested (PHP installed, or 3v4l.org / phpsandbox.io bookmarked).
- [ ] Camera, mic, quiet room, water.
- [ ] Job-radar pitch said out loud once (prep file section 2).
- [ ] One production incident story + one mentoring story ready.
- [ ] Remember: **think aloud, clarify first, simple solution first, then improve, mention tests.**
