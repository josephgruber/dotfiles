---
name: gemini
description: Manually invoke this skill when the user explicitly asks to consult Gemini, get a second opinion, or wants an independent AI perspective on a problem. This skill is user-triggered only — do not invoke it autonomously. Use it for: (a) escalating genuinely hard architectural/design problems where an outside view adds value, and (b) analyzing large codebases or file sets that benefit from Gemini's extended context window.
---

# Gemini Consulting Skill

## What this skill is for

This skill is **manually triggered by the user**. Do not invoke it unless asked.

Two primary use cases:

1. **Second opinion / escalation** — The user wants an independent perspective on a hard problem: architectural tradeoffs, ambiguous bugs, design decisions where reasonable engineers disagree.

2. **Large context analysis** — The user wants Gemini to ingest a large codebase or set of files and return a synthesis. Gemini's context window handles large file sets that would exceed Claude's limits.

## Running Gemini

Use the `gemini` CLI via Bash. Gemini can read files and search the web independently.

**Fresh session:**

```bash
gemini -p "You are a senior consulting engineer. I am Claude, the lead engineer. [Context]. [Question]."
```

**Continue the same session** (follow-up, pushback, or deeper question):

```bash
gemini -p "Following up on your last point — [counter-argument or next question]." -r latest
```

The `-r latest` flag resumes the most recent session, so Gemini has full context of what was said before.

## Back-and-Forth Protocol

Conduct the full exchange with Gemini autonomously — do not relay partial results to the user mid-conversation.
The user triggered this to get a synthesized outcome, not to be a message courier.

The loop:

1. Send the initial prompt
2. Read Gemini's response
3. Decide: is the response complete enough to synthesize, or does it need a follow-up?
4. If follow-up is needed, run another `gemini -p "..." -r latest` — no user involvement yet
5. Repeat until you have enough to form a unified recommendation
6. Only then present the synthesized result to the user

Good reasons to continue the loop:

- Gemini raised a concern you want to push back on
- The response was high-level and you need specifics
- You disagree and want to make your counter-argument
- A tradeoff was mentioned but not fully explored

Good reasons to stop:

- You have a clear, reasoned position to present
- You and Gemini have reached agreement or productive disagreement
- 3–4 rounds in and diminishing returns

Gemini's first response is often correct but generic. A single follow-up — pushing back, asking for specifics,
or challenging an assumption — consistently produces a more refined and useful answer.
Treat round 1 as the opening position, not the conclusion.

## Escalation (Second Opinion)

Frame Gemini as a peer, not a search engine. Give it the context it needs to reason, not just facts to retrieve.

Good escalation prompt structure:

- Current state / constraints
- What you (Claude) currently think and why
- Where you're uncertain or where the user has doubts
- Specific question you want Gemini's view on

Example:

```bash
gemini -p "Consulting SWE: I'm the lead engineer on a multi-tenant SaaS app. \
We're debating RLS in Postgres vs. a separate schema per tenant. \
Our current leaning is RLS due to operational simplicity, but we're worried \
about query performance at scale (10k+ tenants). \
What are the real tradeoffs, and where does RLS tend to break down in practice?"
```

## Large Codebase Analysis

Use `@` syntax to include files/directories in the prompt:

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

Paths are relative to your working directory when invoking the command.

## Synthesizing the output

Don't just relay Gemini's response. Your job is to synthesize it with your own understanding:

1. Note where you and Gemini **agree** — this builds confidence in the direction
2. Note where you **disagree** — explain the tradeoff and your reasoning for preferring one approach
3. Give the user a **single clear recommendation** that incorporates both perspectives

The goal is a unified engineering judgment, not a "here's what Gemini said" summary.
