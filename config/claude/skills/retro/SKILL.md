---
name: retro
description: Run a retrospective after completing a feature or project. Analyzes Git history, conversation context, and test results to suggest improvements to CLAUDE.md, skills, slash commands, and other customizations. Interview the user to capture learnings and improve development workflow.
---

# Retrospective Skill

Run an agile-style retrospective after completing a feature, project, or significant work. This skill analyzes what happened, captures learnings, and proposes concrete improvements to your development environment.

## When to Use

Invoke via `/retro` after:

- Merging a feature branch
- Completing a project phase
- Finishing a significant piece of work
- Any time you want to reflect and improve your workflow

## Scope Identification

First, determine what work to review:

1. **Current session**: Always include the current conversation
2. **Related sessions**: Check auto memory for references to:
   - Active projects or features
   - Branch names mentioned in current session
   - Issue/MR numbers
   - Related work spanning multiple sessions
3. **Git history**: Identify relevant commits by:
   - Current branch vs main/develop
   - Commits since last retro (check memory for timestamp)
   - Specific branch if user provides one

Ask the user: "I see we've been working on [identified scope]. Should I include anything else in this retro?"

## Analysis Phase

Run these analyses in parallel to save time:

### Git History Analysis

Examine commits in scope:

- **Commit patterns**: Frequency, size, message quality
- **Branch lifecycle**: Time from branch creation to merge, rebase/squash usage
- **CI/CD results**: Pipeline success rate, common failures
- **Files changed**: Which areas saw most churn, any unexpected modifications
- **Friction indicators**: Force pushes, reverted commits, merge conflicts

Look for patterns that indicate:

- Missing instructions (repeated manual fixes)
- Tool gaps (workarounds in commit messages)
- Documentation needs (exploratory commits)

### Conversation Analysis

Review the current session and related sessions:

- **Repeated corrections**: Where you had to correct me multiple times
- **Missing context**: Questions I asked that CLAUDE.md should have answered
- **Tool usage**:
  - Tools I used inefficiently
  - Available tools I should have used but didn't
  - Bash usage that should have been dedicated tools (Read/Edit/Grep/etc)
- **Workflow friction**:
  - Tasks that took longer than expected
  - Times when I needed explicit instruction vs. following patterns
  - Moments where I violated existing instructions
- **Memory gaps**: Information I should have remembered but didn't

### Test & Verification Results

If tests were run during this work:

- Pass/fail rates
- New tests added
- Test gaps discovered
- Verification steps that became patterns

### Memory Review

Check auto memory files for:

- Patterns documented during this work
- Whether documented patterns were actually followed
- Lessons learned that aren't yet in memory
- Outdated information that should be updated/removed

## Structured Retro Interview

After analysis, conduct the interview using this structure:

### 1. What Went Well? 🟢

"Let's start with the positives. What went well during this work?"

Prompt for:

- Smooth workflows
- Tools/skills that worked great
- Instructions that helped
- Things you want to do more of

### 2. What Didn't Go Well? 🔴

"Now let's talk about friction. What didn't go well?"

Prompt for:

- Blockers or slowdowns
- Repeated issues
- Frustrating moments
- Things that should have been easier

### 3. What Should We Change? 🔵

"Based on what we learned, what should we change going forward?"

Prompt for:

- New instructions to add
- Existing instructions to modify/remove
- Skills to create or improve
- Memory updates
- Workflow changes

### 4. Specific Observations

Share your analysis findings and ask:

- "I noticed [pattern]. Is this something we should address?"
- "You corrected me on [X] multiple times. Should I add this to CLAUDE.md?"
- "I used [tool/approach] but [alternative] might work better. Thoughts?"

## Synthesize Improvements

Based on analysis + user input, propose specific changes:

### CLAUDE.md Updates

- **New patterns**: Document workflows that worked well
- **Clarifications**: Add details where I needed repeated guidance
- **Corrections**: Fix instructions I misinterpreted
- **Removals**: Delete outdated or unhelpful instructions

**Note**: Ask the user about their preference for pattern location (CLAUDE.md vs memory). Some users prefer keeping discovered patterns in memory files rather than promoting them to CLAUDE.md to avoid bloat.

Format proposals as diffs showing before/after.

### Skill Improvements

- **Existing skills**: Propose updates to skills used during this work
- **New skills**: Suggest creating skills for repeated workflows
- **Skill gaps**: Identify missing skills that would have helped

### Memory Updates

- **New learnings**: Add patterns discovered during this work
- **Update existing**: Refine patterns that evolved
- **Remove outdated**: Delete information that's no longer accurate
- **Cross-references**: Add links between related topics

### Slash Command Ideas

Identify repeated workflows that could become slash commands.

## Approval & Implementation

Present each proposed change individually:

1. **Show the change**: Full diff or new content
2. **Explain the why**: What problem it solves, what it improves
3. **Get approval**: Wait for explicit yes/no
4. **Implement**: Make the change only after approval
5. **Verify**: Show the file after updating

Never batch multiple changes into one approval request. Each change should be reviewed individually.

## Documentation

After completing the retro, save a summary to auto memory:

```markdown
## Retro: [Feature/Project Name] - [Date]

**Scope**: [branch/timeframe]

**Key Learnings**:

- [Learning 1]
- [Learning 2]

**Changes Made**:

- CLAUDE.md: [summary]
- Skills: [summary]
- Memory: [summary]

**Next Retro**: [suggestion for when to run next one]
```

## Principles

- **Be specific**: Vague observations aren't actionable. "You used cat instead of bat 3 times in service X" is better than "tool usage could improve"
- **Focus on patterns**: One-off issues aren't worth documenting. Look for repeated friction
- **Prioritize impact**: Suggest high-impact changes first. A pattern that caused multiple delays is more important than a minor style preference
- **Respect scope**: Don't propose changes to areas you haven't worked in during this scope
- **Keep it tight**: CLAUDE.md under 500 lines, memory files focused. If something doesn't pull its weight, don't add it

## Example Flow

1. User invokes `/retro`
2. Identify scope: "Current branch `feature/visibility-workers` has 8 commits. I also see related work in yesterday's session. Include both?"
3. Run analyses in parallel
4. Interview: "What went well?" → "What didn't?" → "What should we change?"
5. Present findings: "I noticed you corrected me 3 times about using `rg` instead of `grep`. Here's what I found in the transcripts..."
6. Propose change: "I'd like to add this to CLAUDE.md under 'Critical Rules'..." [show diff]
7. Get approval → Implement
8. Repeat for each improvement
9. Save retro summary to memory
10. "Retro complete! We updated CLAUDE.md (2 changes), memory (3 new patterns), and created 1 new skill. Run `/retro` again after your next major feature."
