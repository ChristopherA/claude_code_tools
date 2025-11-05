# Design Decisions - session-resume

This document explains the architectural decisions and design rationale behind the session-resume skill.

---

## Why Explicit Triggering Only?

### Design Decision

session-resume NEVER auto-invokes. It requires explicit user request ("resume").

### Rationale

**Problem**: Auto-loading previous context could be disruptive.

**User scenarios**:
1. User wants fresh start (new feature, different task)
2. User working on different branch/context
3. Previous resume outdated or irrelevant
4. User wants to check current state first

**Solution**: Require explicit user intention.

**Benefits**:
1. **User control**: User decides when to load context
2. **No surprises**: Context never loads unexpectedly
3. **Clear intent**: "resume" means "I want previous context"
4. **Branch awareness**: Different branches can have different contexts

**Alternatives considered**:

**Auto-invoke on session start**:
- ❌ Disruptive if user wants fresh start
- ❌ May load wrong context (branch switches)
- ❌ Can't distinguish intent

**Auto-invoke if resume exists**:
- ❌ Presence doesn't mean relevance
- ❌ File may be stale
- ❌ User may want to ignore it

**SessionStart hook with prompt**:
- ✅ Shows notification (implemented)
- ✅ But doesn't auto-load
- ✅ User still controls

**Verdict**: Explicit-only triggering is correct design.

---

## Why Use Scripts?

### Design Decision

Use executable shell scripts for staleness detection and archive listing instead of inline bash code in SKILL.md.

### Rationale

**Same as session-closure** - see that skill's DESIGN_DECISIONS.md.

**1. Consistency**
- Scripts behave identically every invocation
- Not re-interpreted by Claude each time
- Deterministic behavior guaranteed

**2. Testability**
- Validated by automated test suite (8 tests)
- Test once, works forever
- Regression detection automatic

**3. Token Efficiency**
- Call script: ~30 tokens
- Parse pseudo-code every time: ~300+ tokens
- 10x reduction in token usage

**4. Maintainability**
- Update script once, affects all invocations
- Version control for logic changes
- Clear separation of concerns

**5. Cross-Platform Support**
- Scripts handle OS detection
- Platform-specific logic encapsulated
- Tested on macOS and Linux

**Verdict**: Executable scripts proven pattern from project-cleanup v1.2.0.

---

## Why Staleness Detection?

### Design Decision

Calculate resume age and warn user about potentially outdated context.

### Rationale

**Problem**: Old resumes may not reflect current project state.

**User risk scenarios**:
1. Resume from 2 weeks ago - project evolved significantly
2. Resume from different branch - context mismatch
3. Resume from before major refactor - code structure changed
4. Resume references deleted files or obsolete approaches

**Solution**: Four-level staleness categorization with warnings.

**Staleness Levels**:

**fresh** (< 1 day):
- ✅ Very likely accurate
- ✅ Project state probably unchanged
- ✅ Safe to load without hesitation

**recent** (1-6 days):
- ⚠️ Possibly accurate
- ⚠️ Minor changes likely
- ⚠️ Review before acting

**stale** (7-29 days):
- ⚠️ Likely outdated
- ⚠️ Significant changes probable
- ⚠️ Verify project state

**very_stale** (30+ days):
- ❌ Almost certainly outdated
- ❌ Major evolution likely
- ❌ Treat as historical reference only

**Benefits**:
1. **User awareness**: Clear indication of risk
2. **Informed decisions**: User can judge relevance
3. **Prevents errors**: Avoids acting on stale information
4. **Graduated warnings**: Appropriate to age

**Thresholds chosen**:
- 1 day: Working day boundary (overnight = fresh)
- 7 days: Working week boundary (weekly cycle)
- 30 days: Monthly boundary (significant time)

**Alternative considered**:

**No staleness checking**:
- ❌ User unaware of risk
- ❌ May act on outdated info
- ❌ No warning system

**Binary check (fresh/stale)**:
- ❌ Too simplistic
- ❌ No graduation of risk
- ❌ 2-day-old same as 60-day-old

**Verdict**: Four-level categorization provides appropriate graduated warnings.

---

## Why Archive Browsing?

### Design Decision

If no current resume, show available archives and suggest loading one.

### Rationale

**Problem**: User says "resume" but CLAUDE_RESUME.md missing.

**Without archive browsing**:
```
User: resume
Claude: No CLAUDE_RESUME.md found. [END]

User: (Doesn't know if archives exist or how to find them)
```

**With archive browsing**:
```
User: resume
Claude: No current resume, but I found these archives:
- 2025-11-04-1430.md (November 4, 2:30 PM)
- 2025-11-03-1615.md (November 3, 4:15 PM)

Would you like me to load one?
```

**Benefits**:
1. **Discoverability**: User learns archives exist
2. **Helpful**: Immediate next steps
3. **Time-saving**: Don't need to manually browse files
4. **User-friendly**: Clear dates and times

**Implementation**:
- Uses `list_archives.sh` script
- Shows 5 most recent (configurable)
- Sorted newest first
- Human-readable timestamps

**Verdict**: Archive browsing makes skill helpful, not just informative.

---

## Progressive Disclosure Architecture

### Design Decision

Split content into SKILL.md (task instructions) and references/ (detailed documentation).

### Rationale

**From Official Anthropic Guidance**:
> "Three-level context loading: 1. Metadata (~100 words) - always available, 2. SKILL.md body (<5k words) - when skill triggers, 3. Bundled resources - loaded on-demand by Claude"

**Implementation**:
- **Level 1**: Frontmatter (name, description, version) - ~100 words
- **Level 2**: SKILL.md body (task instructions) - ~1500 words
- **Level 3**: references/ (detailed docs) - loaded when needed

**Benefits**:
1. **Token Efficiency**: Only load what's needed
   - v1.2.1: ~6500 words loaded every time
   - v1.3.0: ~1500 words loaded, ~5000 on-demand
   - 77% reduction in initial load

2. **Faster Skill Execution**: Less context to process

3. **Better Maintainability**: Update references/ without touching SKILL.md

4. **Clearer Task Instructions**: No distractions from meta-information

### What Goes Where

**SKILL.md** (task instructions):
- How to perform the task
- Step-by-step workflow
- Script invocations
- Decision points
- Section recognition

**references/** (detailed documentation):
- Why design choices were made (DESIGN_DECISIONS.md)
- How to configure (CONFIGURATION.md)
- How to test (TESTING.md, DEVELOPMENT.md)
- Examples and use cases (EXAMPLES.md)
- Future plans (ROADMAP.md)

**Verdict**: Aligns perfectly with official best practices.

---

## Why Remove "When This Skill Activates" Section?

### Design Decision (v1.3.0)

Remove the separate "## When This Skill Activates" section from SKILL.md body.

### Rationale

**Official Anthropic Guidance**:
> "The `description` field is critical for Claude to discover when to use your Skill. It should include both what the Skill does and when Claude should use it."

**Current redundancy**:
- Lines 10-17: WHEN/WHEN NOT in frontmatter description ✅
- Lines 22-42: "## When This Skill Activates" section ❌ (duplicate)

**Why duplicate is wrong**:
1. **Information duplication**: Same triggers listed twice
2. **Against best practice**: "Avoid duplication between SKILL.md and reference files"
3. **Token waste**: Loading same information twice
4. **Maintenance burden**: Update in two places

**Official pattern**:
- anthropics/skills examples don't have separate trigger sections
- All trigger info in description field
- Body focuses on task instructions

**Impact of removal**:
- Saves ~21 lines
- Eliminates redundancy
- Aligns with official pattern
- No functional change (description field sufficient)

**Verdict**: Correct de-duplication aligned with official guidance.

---

## Project Status Section Recognition

### Design Decision

Recognize and highlight optional "Project Status" section for inter-project communication.

### Rationale

**Use Case**: Multiple related projects need to coordinate.

**Problem**: Each project isolated, no awareness of others.

**Solution**: Standardized status section that other projects can read.

**Format**:
```markdown
## Project Status

- **Current State**: 🔄 IN PROGRESS - Brief description
- **Key Changes**: What changed this session
- **Next Priority**: Immediate next action
- **Dependencies**: Blockers or waiting on others
- **Project Health**: Overall assessment
```

**Why session-resume should recognize it**:
1. **Highlight important info**: Status shown prominently
2. **Dependency awareness**: User reminded of blockers
3. **Coordination support**: Facilitates multi-project work
4. **Standard format**: Easy to parse and understand

**Implementation**:
- Optional section (not required)
- Uses `grep -qi "Project Status"` to detect
- If found, highlights in summary
- If not found, no mention (graceful)

**Verdict**: Enables multi-project workflows without complexity.

---

## Sync Status Section Recognition

### Design Decision

Recognize and highlight optional "Sync Status" section for tracking authoritative external sources.

### Rationale

**Use Case**: Some projects sync from Google Docs, HackMD, or GitHub (as authoritative master).

**Problem**: Need to track when last synced and if sources are stale.

**Solution**: Conditional section documenting sync state.

**Format**:
```markdown
## Sync Status

**Authoritative Sources**:
- **API Spec**: https://docs.google.com/... (synced 2025-11-03)
- **Architecture**: https://hackmd.io/@team/... (synced 2025-11-02)

**Sync Health**: ✅ All sources current
```

**Why session-resume should recognize it**:
1. **Sync awareness**: User reminded of authoritative sources
2. **Staleness tracking**: When last synced shown
3. **Source URLs**: Quick access to masters
4. **Health indicator**: At-a-glance status

**When to include** (in resume):
- Project has Google Docs as master
- Project has HackMD as master
- Local synced from external source

**When to omit** (in resume):
- Everything local/git only
- No synchronization workflow

**Implementation**:
- Optional section (not required)
- Uses `grep -qi "Sync Status"` to detect
- If found, highlights sources and dates
- If not found, no mention (graceful)

**Verdict**: Useful for distributed documentation workflows.

---

## Cross-Platform Date Handling

### Design Decision (v1.3.0)

Detect OS and use appropriate date command (BSD vs GNU).

### Rationale

**Problem**: macOS uses BSD date, Linux uses GNU date, with different syntax.

**macOS (BSD)**:
```bash
date -j -f "%B %d, %Y" "November 5, 2025" +%s
```

**Linux (GNU)**:
```bash
date -d "November 5, 2025" +%s
```

**Without OS detection** (v1.2.1 and earlier):
- ✅ Worked on macOS
- ❌ Failed on Linux (hung tests)
- ❌ Blocked 50% of potential users

**With OS detection** (v1.3.0):
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    SESSION_EPOCH=$(date -j -f "%B %d, %Y" "$SESSION_DATE" +%s)
else
    # Linux
    SESSION_EPOCH=$(date -d "$SESSION_DATE" +%s)
fi
```

**Benefits**:
1. **Cross-platform**: Works on both macOS and Linux
2. **No user intervention**: Automatic OS detection
3. **Tested**: Both branches verified
4. **Production-ready**: Unblocks Linux users

**Why $OSTYPE**:
- Built-in bash variable
- Reliable OS detection
- Works on all platforms
- Examples:
  - macOS: `darwin*`
  - Linux: `linux-gnu`
  - WSL: `linux-gnu`

**Verdict**: Critical fix for production readiness (v1.2.2).

---

## Learned from project-cleanup v1.2.0

### Pattern Replication

Successfully applied lessons from project-cleanup skill to session skills:

**Pattern 1: Executable Scripts**
- project-cleanup proved scripts > pseudo-code
- Applied to check_staleness.sh and list_archives.sh
- Result: Deterministic, tested, efficient

**Pattern 2: Automated Testing**
- project-cleanup showed value of test suites
- Applied: 8 automated tests for session-resume
- Result: Confidence in changes, regression detection

**Pattern 3: Progressive Disclosure**
- project-cleanup pioneered references/ pattern
- Applied: Extracted meta-content to references/
- Result: SKILL.md focused on task instructions

**Pattern 4: Documentation Organization**
- project-cleanup structured docs by audience
- Applied: CONFIGURATION.md (users), DEVELOPMENT.md (devs), etc.
- Result: Right info for right audience

**Verdict**: Proven patterns scale across skills.

---

## Why No Auto-Archive Loading?

### Design Decision

Don't automatically load most recent archive if current resume missing.

### Rationale

**Considered feature**:
```
User: resume
[No CLAUDE_RESUME.md]
→ Auto-load archives/CLAUDE_RESUME/2025-11-04-1430.md
```

**Why we don't do this**:

**1. Ambiguous Intent**
- User said "resume" - does that mean "latest archive"?
- User might want specific archive, not latest
- Latest might be from wrong branch/context

**2. Potentially Wrong Context**
- Latest archive might be from different project phase
- Latest might be from abandoned work
- Latest might be pre-refactor state

**3. User Awareness**
- User should know they're loading archive
- User should see archive list and choose
- Explicit selection better than implicit

**Instead**: Show archive list, let user choose.

**Verdict**: Explicit selection respects user intent.

---

## Resume Format Flexibility

### Design Decision

Support multiple resume format versions gracefully.

### Rationale

**Problem**: Resume format may evolve over time.

**Supported versions**:
- v1.2.0 (current) - Has Project Status, Sync Status
- v1.1.0 (legacy) - Basic format
- Future versions - Forward compatibility

**Parsing strategy**:
- Use flexible pattern matching
- Don't require exact section names
- Gracefully handle missing sections
- Case-insensitive matching

**Example**:
```bash
# Accepts all these
grep -qi "Last Session" RESUME
grep -qi "Last Activity" RESUME
grep -qi "Pending" RESUME
```

**Benefits**:
1. **Backward compatibility**: Old resumes still work
2. **Forward compatibility**: New sections don't break parsing
3. **User-friendly**: Minor format variations OK
4. **Robust**: Resilient to user customization

**Verdict**: Flexibility > strict format enforcement.

---

## Why Separate check_staleness.sh Script?

### Design Decision

Extract staleness calculation to separate script instead of inline in SKILL.md.

### Rationale

**Specific benefits beyond general "why scripts"**:

**1. Reusability**
- Other skills could use it
- CLI tools could call it
- Automation scripts could check staleness
- Not locked to session-resume skill

**2. Testability**
- 3 tests specifically for staleness
- Known inputs → known outputs
- Edge cases covered (missing file, invalid date)
- Regression protection

**3. Cross-Platform Complexity**
- OS detection logic complex
- Date command variations complex
- Better to encapsulate than inline
- Single place to update

**4. Performance**
- Fast execution (~5ms)
- No overhead from extraction
- Single file read + calculation
- Efficient implementation

**Verdict**: Separation justified by reusability and testability.

---

## Why Separate list_archives.sh Script?

### Design Decision

Extract archive listing to separate script instead of inline bash.

### Rationale

**Specific benefits beyond general "why scripts"**:

**1. Formatting Options**
- `--format short` vs `--format detailed`
- `--limit N` option
- Extensible: could add `--since DATE`
- Clean interface

**2. Sorting Logic**
- `ls -t` for time-based sort
- Newest first (most relevant)
- Could add other sort options
- Encapsulated logic

**3. Reusability**
- Users can call directly: `./scripts/list_archives.sh`
- Other tools could use it
- CLI friendly
- Not skill-locked

**4. Testability**
- 4 tests specifically for archive listing
- Various scenarios covered
- Format variations tested
- Edge cases handled

**Verdict**: Separation provides clean interface and reusability.

---

*Design decisions for session-resume v1.3.0*
