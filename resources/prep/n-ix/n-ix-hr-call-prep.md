# HR / recruiter call prep: N-iX — Senior/Lead PHP Engineer

Context: Yura (Talent Sourcer) pre-screened by email. You answered the 8 questions. The next step is a **call with the recruiter**.
For technical prep, see [n-ix-php-leader-prep.md](./n-ix-php-leader-prep.md).

---

## 1. What an HR call actually checks

A recruiter call is a filter, not a technical exam. They're confirming that:

1. **You match what you wrote.** They'll ask you to repeat or expand your email answers out loud. Consistency matters.
2. **Your English is good enough to put you in front of the client.** They need Upper-Intermediate or higher. This is assessed throughout the call, not as a separate test.
3. **You're realistic about the conditions:** Toronto hours, 6 months, B2B, the rate.
4. **You're motivated and stable,** not likely to vanish after two weeks or accept a better offer mid-process.
5. **They can sell you to the client.** They need a crisp summary of you to forward. Give them one.

Plan for 20–40 minutes. Speak in short, structured answers. Don't go deep technically unless they ask.

---

## 2. Your email answers: what they'll probe and how to strengthen each

### Q1. MySQL/PostgreSQL experience: "~14 years MySQL"
- **Likely follow-up:** "What was the largest database you worked with? Any PostgreSQL?"
- **Prepare:**
  - One concrete number for scale (table size, rows, QPS or users) and one concrete optimization story (slow query → index or query change → result).
  - PostgreSQL: be honest about how much you've used it. You use Postgres in job-radar (Neon + Drizzle), so you can say "MySQL is my main one for 14 years; I've been using PostgreSQL in recent projects."
- **Why it matters:** the posting says "MySQL *or* PostgreSQL", and the client may use either. Showing both removes a doubt.

### Q2. AI/LLM integration: your weakest written answer
Your email answer was short and a bit vague ("2 MVPs", "lobechat", "job seeker project"). AI is a **must-have** for this role, so expect them to ask you to describe it. Prepare a 60-second spoken version:

> "I've integrated LLMs in three places. First, I set up and extended a self-hosted LobeChat environment — [what you configured: models/providers, plugins/tools, knowledge base, who used it]. Second, [the other MVP — one sentence: what it did, which LLM API]. Third, my current project, a job-search dashboard: it uses the Claude API to score how well a job fits a candidate's preferences. It returns structured output that's validated before saving, the prompt is versioned so I can re-run analyses when it changes, and I have a labeled evaluation set to measure accuracy when I change the prompt. Cheap rule-based scoring runs first so the LLM only handles the nuanced part — that keeps cost down. I build day to day with Claude Code."

- **Fill in the brackets before the call.** The recruiter will forward your description to the client, so concrete beats generic.
- Keywords the recruiter is probably listening for (from the posting): **LLM APIs, function/tool calling, retrieval (RAG), agents, Claude Code/Codex.** Say the ones that are true for you, out loud.

### Q3. Toronto time zone: "Yes". Make sure you really mean it.
- **The math:** Bucharest is **7 hours ahead** of Toronto most of the year (summer: EEST UTC+3 vs EDT UTC−4; winter: EET UTC+2 vs EST UTC−5).
  - Toronto 9:00–17:00 = **Bucharest 16:00–24:00**.
  - "Almost complete overlap" = you work afternoons and evenings until midnight, every working day, for 6 months.
- **Note:** Europe and North America change clocks on different dates, so for about a week each spring and autumn the gap is 6 hours. This year Europe goes back on Oct 25 and Toronto on Nov 1.
- **Likely follow-up:** "Have you worked in a US/Canada time zone before?" "How will you handle it?"
- **Prepare:** any past experience with North American hours, and a short answer on how you'll organize your day (e.g. morning free, start at 15:30–16:00, stable routine).
- **Worth asking them:** the exact core hours. Is it 9–5 Toronto, or e.g. 10–6, and can you start a bit earlier? Also, are Romanian or Canadian public holidays observed?

### Q4. 6-month contract: "Yes"
- **Likely follow-up:** "What if it's extended?" or "What do you plan after?"
- **Good answer:** you're open to extension and to other N-iX projects afterwards. It shows stability without depending on the extension.
- **Ask them:** how often projects like this get extended, and what happens at month 6 (renewal, a move to another project, or the end).

### Q5. Notice period: "Immediately"
- **Likely follow-up:** "Are you in other interview processes?"
- **Be honest but neutral:** "Yes, I'm in a couple of other processes at different stages." This creates mild urgency without pressure. Don't name companies or rates.
- Have a realistic **start date** ready (e.g. "within a week of signing").

### Q6. Location and legal status: "Bucharest, Romania. I have my own IT consulting company."
- **Watch the wording:** in Q7 you gave a **PFA** (Persoană Fizică Autorizată). A PFA is a self-employed individual status, **not a company** (an SRL is a company). If they ask, clarify plainly: "I work through my PFA, a registered sole-trader entity, so I invoice B2B." Don't let it look inconsistent.
- **Legal status:** you're a Romanian (EU) citizen living in Romania. Say it directly; it's what the question is about.

### Q7. Entity type: "Ciuculescu Dan Andrei Persoana Fizica Autorizata"
- The **type** is PFA. The rest is the registered name. That's fine.
- **Know these details before the call** (they may need them for the contract):
  - Registered for VAT or not? Cross-border B2B services within the EU are usually invoiced with **reverse charge**. If you aren't VAT-registered, cross-border services from another EU company require an intra-community VAT code (*cod de TVA intracomunitar*, Art. 316 or 317). **Check this with your accountant**; it can block the first invoice.
  - Which **N-iX legal entity** would you contract with, and in which country? Ask. It affects VAT and invoicing.
  - Your bank account: USD or EUR invoicing, and conversion costs.

### Q8. Rate: asked $9,800 → they offered **$8,600 gross/month B2B** → you accepted
- **Where it stands:** they said "up to $8,600". You accepted, noted you'd hoped for closer to $9,800, and confirmed interest. That was a good reply: polite, keeps you in the process, and puts on record that you're at the top of their range.
- **For reference:** $8,600 / ~168 h ≈ **$51/hour**. That's above the Kraków anchor for a Lead PHP role at N-iX ($6,000–6,668 net B2B), so it's a solid offer for this market.
- **On the call: don't reopen the base rate.** You've accepted it in writing. Pushing again now looks inconsistent and can cost you goodwill. If they bring it up, confirm: "Yes, $8,600 works for me, as I wrote."
- **Where you still have room to negotiate is the package, not the number.** Ask these as clarifying questions, not demands:
  - **Paid days off / vacation.** Many B2B contracts have **none**. 20 unpaid days a year ≈ 0.95 months ≈ **$8,200 less per year**, so this is worth more than a small rate bump.
  - **Paid sick days.**
  - **Public holidays:** Romanian or Canadian? Paid or unpaid? If you follow the Canadian calendar, Romanian holidays become working days for you; if they are unpaid either way, that is ~2 weeks of lost income a year.
  - **Rate review** at extension (month 6). This is the natural moment to go back toward $9,800. Phrase it as: "Could we agree to review the rate if the contract is extended?"
  - Payment terms (paid within how many days), invoicing currency (USD vs EUR, conversion costs), equipment, termination notice on both sides.
- **If they ask "are you okay with this rate?" again:** "Yes. I'd just like to understand the full B2B package: paid time off, holidays, and whether there's a rate review on extension."

---

## 3. Other questions HR usually asks, with suggested answers

**"Tell me about yourself."** (60–90 s, the most important answer of the call)
Structure: who you are → key experience → what you're doing now → why this role.
> "I'm a backend engineer with 15 years in PHP, 10 of them in Laravel, plus about 6 years of AWS. I've worked on small to large projects, [one highlight: e.g. a high-traffic system / leading a team]. I run my own consulting practice, and recently I've focused on integrating AI into products — LLM APIs, structured outputs, evaluations — and I use Claude Code daily. This role is a strong match because it combines deep Laravel work with agentic AI at a large marketplace."

**"Why are you looking for a new role / why now?"**
Keep it positive and forward-looking (a bigger product, AI work at scale, a strong team). Never complain about past clients or employers.

**"Why N-iX? / What do you know about us?"**
From the posting: founded in **2002**, **2,400+ professionals**, a global software development company. Add one thing you like (stable company, interesting client, AI focus). Spend 5 minutes on their website before the call for one extra fact.

**"Why this project?"**
High-scale marketplace (30M users/month, 18 countries), real product impact, and AI integration as a core part of the work, not a side experiment.

**"Describe your most recent project / role."**
Have one client project ready (not only job-radar): team size, your role, stack, one result.

**"Have you led or mentored people?"**
It's a Senior/Lead role. Give one concrete example (onboarding someone, code reviews, setting standards, making technical decisions).

**"Are you comfortable working with a client's in-house team?"**
Yes. Mention working within their processes, proactive communication and raising risks early.

**"Do you have other offers or processes?"** See Q5 above.

**"When are you available for the next interviews?"**
Have your calendar open. Offer two or three specific slots.

---

## 4. Questions you should ask the recruiter

You already asked in the email for the **interview process outline**. If they haven't answered, ask again. Also:

1. **What are the interview stages?** Technical with N-iX, then the client? Live coding, system design, take-home? How long does it usually take?
2. **Who is the client?** They may not say before an NDA. That's fine; ask anyway.
3. **What are the exact working hours,** and how strict is the overlap?
4. **What is the team setup?** Size, other N-iX engineers on the project, whether "Lead" means people leadership or technical leadership.
5. **What is the AI work concretely?** New agentic features, internal tooling, or both?
6. **B2B package details** (the list in Q8): paid days off, holidays, payment terms, equipment, rate review on extension, notice period. This is now your main negotiation lever.
7. **Which N-iX entity signs the contract,** and invoicing details (currency, VAT).
8. **What happens after 6 months?**

Pick the 4–5 most important if time is short: **1, 3, 6, 8** and **2**.

---

## 5. Checklist before the call

- [ ] Fill in the brackets in the AI answer (Q2) and say it out loud twice.
- [ ] Practise "Tell me about yourself" out loud (60–90 s).
- [ ] Rate is agreed ($8,600). Decide which package items matter most: paid days off, holidays, rate review on extension.
- [ ] Check PFA VAT / intra-community VAT status with your accountant if you're unsure.
- [ ] Be sure about the Toronto hours (16:00–24:00 Bucharest) and what it means for your routine.
- [ ] Have one recent client project story ready (not only job-radar).
- [ ] 5 minutes on n-ix.com for one extra fact about the company.
- [ ] Quiet room, good mic, camera on, this file open.

---

## Sources
- [N-iX job posting](https://careers.n-ix.com/jobs/4529257101-php-leader/)
- [Lead PHP Engineer – justjoin.it (pay range anchor)](https://justjoin.it/job-offer/n-ix-lead-php-engineer-krakow-php)
