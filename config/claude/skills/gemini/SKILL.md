---
name: gemini
description: Manually invoke this skill when the user explicitly asks to consult Gemini, get a second opinion, or wants an independent AI perspective on a problem. This skill is user-triggered only — do not invoke it autonomously. Use it for: (a) escalating genuinely hard architectural/design problems where an outside view adds value, and (b) analyzing large codebases or file sets that benefit from Gemini's extended context window.
---

# Gemini Consulting Skill

## What this skill is for

**User-triggered only.** Don't invoke unless asked.

Two uses:

1. **Second opinion / escalation** — User wants independent view on hard problem: architectural tradeoffs, ambiguous bugs, design decisions where engineers disagree.

2. **Large context analysis** — User wants Gemini to ingest large codebase or file set, return synthesis. Gemini's context window handles large file sets exceeding Claude's limits.

## Running Gemini

Use `gemini` CLI via Bash. Gemini reads files and searches web independently.

**Fresh session:**

```bash
gemini -p "You are a senior consulting engineer. I am Claude, the lead engineer. [Context]. [Question]."
```

**Continue same session** (follow-up, pushback, deeper question):

```bash
gemini -p "Following up on your last point — [counter-argument or next question]." -r latest
```

`-r latest` resumes most recent session — Gemini has full prior context.

## Back-and-Forth Protocol

Run full exchange with Gemini autonomously — don't relay partial results mid-conversation. User triggered this for synthesized outcome, not message courier.

Loop:

1. Send initial prompt
2. Read Gemini's response
3. Decide: complete enough to synthesize, or needs follow-up?
4. If follow-up needed, run another `gemini -p "..." -r latest` — no user involvement yet
5. Repeat until enough for unified recommendation
6. Only then present synthesized result to user

Continue loop when:

- Gemini raised concern worth pushing back on
- Response too high-level, need specifics
- You disagree, want counter-argument
- Tradeoff mentioned but not fully explored

Stop when:

- Clear, reasoned position to present
- Agreement or productive disagreement reached
- 3–4 rounds in with diminishing returns

Gemini's first response often correct but generic. Single follow-up — pushback, specifics request, challenging assumption — consistently produces more refined answer. Round 1 = opening position, not conclusion.

## Escalation (Second Opinion)

Frame Gemini as peer, not search engine. Give context to reason, not just facts to retrieve.

Good escalation prompt:

- Current state / constraints
- What you (Claude) think and why
- Where you're uncertain or user has doubts
- Specific question for Gemini's view

Example:

```bash
gemini -p "Consulting SWE: I'm the lead engineer on a multi-tenant SaaS app. \
We're debating RLS in Postgres vs. a separate schema per tenant. \
Our current leaning is RLS due to operational simplicity, but we're worried \
about query performance at scale (10k+ tenants). \
What are the real tradeoffs, and where does RLS tend to break down in practice?"
```

## Large Codebase Analysis

Use `@` syntax to include files/directories:

```bash
# Single file
gemini -p "@src/main.py Explain the architecture and any obvious risks"

# Directory
gemini -p "@src/ Summarize the overall architecture and identify coupling hotspots"

# Multiple targets
gemini -p "@src/ @tests/ How well does the test coverage map to the core business logic?"

# Whole project (via directory)
gemini -p "@./ Give me an architectural overview and flag anything that looks fragile"
```

Paths relative to working directory when invoking.

## Synthesizing the output

Don't relay Gemini's response. Synthesize with own understanding:

1. Where you and Gemini **agree** — builds confidence in direction
2. Where you **disagree** — explain tradeoff, reasoning for preferred approach
3. **Single clear recommendation** incorporating both perspectives

Goal: unified engineering judgment, not "here's what Gemini said."