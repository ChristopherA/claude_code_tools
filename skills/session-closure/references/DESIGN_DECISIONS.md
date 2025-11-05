# Design Decisions - session-closure

This document explains the architectural decisions and design rationale behind the session-closure skill.

---

## Why Use Scripts?

### Design Decision

Use executable shell scripts for archiving and validation instead of inline bash code in SKILL.md.

### Rationale

**1. Consistency**
- Scripts behave identically every invocation
- Not re-interpreted by Claude each time
- Deterministic behavior guaranteed
- No variation based on Claude's understanding

**2. Testability**
- Can be validated by automated test suite
- Test once, works forever
- Regression detection automatic
- 20 automated tests ensure correctness

**3. Token Efficiency**
- Call script: ~50 tokens
- Parse pseudo-code every time: ~500+ tokens
- 10x reduction in token usage
- Faster skill execution

**4. Maintainability**
- Update script once, affects all invocations
- Don't need to update SKILL.md documentation
- Version control for logic changes
- Clear separation of concerns

**5. Portability**
- Scripts work across different Claude Code versions
- No dependency on Claude's bash interpretation
- Standard bash features only
- Tested on macOS and Linux

### Trade-offs

**Pros**:
- ✅ Deterministic behavior
- ✅ Tested and validated
- ✅ Token-efficient
- ✅ Easy to maintain

**Cons**:
- ⚠️ Requires bash shell
- ⚠️ May need reading for environment adjustments
- ⚠️ Less flexible than inline code
- ⚠️ Debugging requires script knowledge

**Verdict**: Pros outweigh cons for repeated operations.

---

## Why Validate Resumes?

### Design Decision

Run validation script before finalizing session closure.

### Rationale

**1. Ensures Completeness**
- Resume has all required sections
- Session-resume can load it correctly
- No missing critical information
- Catches creation bugs early

**2. Catches Errors Before Session Ends**
- Fix issues while context available
- Don't discover problems in next session
- Immediate feedback loop
- User confidence in resume quality

**3. Tested Behavior**
- Validation logic validated by test suite
- No manual checking needed
- Consistent quality bar
- Automated quality assurance

**4. Clear Error Messages**
- Lists specific missing sections
- User knows exactly what to fix
- No guessing or debugging
- Fast resolution

### Trade-offs

**Pros**:
- ✅ Quality assurance
- ✅ Early error detection
- ✅ User confidence
- ✅ Consistent format

**Cons**:
- ⚠️ Extra step in workflow
- ⚠️ Slight performance overhead (~5ms)
- ⚠️ May fail for edge cases

**Verdict**: Quality benefit worth the minimal overhead.

---

## Progressive Disclosure Architecture

### Design Decision

Split content into SKILL.md (task instructions) and references/ (detailed documentation).

### Rationale

**From Official Anthropic Guidance**:
> "Three-level context loading: 1. Metadata (~100 words) - always available, 2. SKILL.md body (<5k words) - when skill triggers, 3. Bundled resources - loaded on-demand by Claude"

**Implementation**:
- **Level 1**: Frontmatter (name, description, version) - ~100 words
- **Level 2**: SKILL.md body (task instructions) - ~2000 words
- **Level 3**: references/ (detailed docs) - loaded when needed

**Benefits**:
1. **Token Efficiency**: Only load what's needed
   - v1.2.0: ~8000 words loaded every time
   - v1.3.0: ~2000 words loaded, ~6000 on-demand
   - 75% reduction in initial load

2. **Faster Skill Execution**: Less context to process

3. **Better Maintainability**: Update references/ without touching SKILL.md

4. **Clearer Task Instructions**: No distractions from meta-information

### What Goes Where

**SKILL.md** (task instructions):
- How to perform the task
- Step-by-step workflow
- Script invocations
- Decision points

**references/** (detailed documentation):
- Why design choices were made (DESIGN_DECISIONS.md)
- How to configure (CONFIGURATION.md)
- How to test (TESTING.md, DEVELOPMENT.md)
- How to troubleshoot (TROUBLESHOOTING.md)
- Implementation details (IMPLEMENTATION_DETAILS.md)
- Format specifications (RESUME_FORMAT_v1.2.md)

**Verdict**: Aligns perfectly with official best practices.

---

## Git-Aware Archiving

### Design Decision

Detect if CLAUDE_RESUME.md is tracked in git and skip archiving if so.

### Rationale

**Problem**: Redundant archives when git already tracks history.

**Solution**: Check git tracking status before archiving.

**Logic**:
```
if resume_tracked_in_git:
    skip_archive()  # Git history is the archive
else:
    create_archive()  # No git history, need backup
```

**Benefits**:
1. **Avoids Redundancy**: Don't duplicate git history
2. **Respects User Choice**: If user tracks in git, honor that
3. **Reduces Clutter**: Fewer archive files
4. **Clear Communication**: Tell user why skipping

**Implementation**:
```bash
if git ls-files --error-unmatch CLAUDE_RESUME.md >/dev/null 2>&1; then
    echo "✓ Resume tracked in git - skipping archive"
else
    # Create archive
fi
```

**Edge Cases Handled**:
- Not in git repository: Archive created
- File tracked: Archive skipped
- File in .gitignore: Archive created
- Git not installed: Archive created (command fails gracefully)

**Verdict**: Smart behavior respecting user workflow.

---

## Three Operational Modes

### Design Decision

Support Full, Minimal, and Emergency modes based on available context.

### Rationale

**Problem**: Running out of context mid-closure loses all session state.

**Solution**: Degrade gracefully based on available tokens.

**Modes**:

**Full Mode** (>30k tokens):
- Complete analysis
- All sections
- Detailed insights
- Best user experience

**Minimal Mode** (<30k tokens):
- Essential state only
- Abbreviated sections
- Critical info preserved
- Better than nothing

**Emergency Mode** (critically low):
- Template to chat
- User manual save
- Prevents total loss
- Always works

**Benefits**:
1. **Graceful Degradation**: Never fail completely
2. **Context Preservation**: Save what we can
3. **User Awareness**: Clear about limitations
4. **Flexible**: Works in any situation

**Verdict**: Essential for reliability.

---

## Project Status Section

### Design Decision

Include Project Status section for inter-project communication.

### Rationale

**Use Case**: Multiple related projects need to coordinate.

**Problem**: Each project isolated, no awareness of others.

**Solution**: Include standardized status other projects can read.

**Format**:
```markdown
## Project Status

- **Current State**: 🔄 IN PROGRESS - Brief description
- **Key Changes**: What changed this session
- **Next Priority**: Immediate next action
- **Dependencies**: Blockers or waiting on others
- **Project Health**: Overall assessment
```

**Benefits**:
1. **Inter-Project Awareness**: Projects know each other's status
2. **Dependency Tracking**: Clear what's blocked on what
3. **Coordination**: Team can see overall progress
4. **Standard Format**: Easy to parse and understand

**Not Just Upward Reporting**: Peer-to-peer communication.

**Verdict**: Enables multi-project workflows.

---

## Sync Status Section (Conditional)

### Design Decision

Include Sync Status section only when project has authoritative external sources.

### Rationale

**Use Case**: Some projects sync from Google Docs, HackMD, or GitHub.

**Problem**: Need to track when last synced and if sources are stale.

**Solution**: Conditional section documenting sync state.

**When to include**:
- Project has Google Docs as master
- Project has HackMD as master
- Local synced from external source

**When to omit**:
- Everything local/git only
- No synchronization workflow

**Benefits**:
1. **Sync Awareness**: Know if local is stale
2. **Source Tracking**: Clear what the masters are
3. **Date Tracking**: When last synced
4. **Conditional**: No clutter if not needed

**Verdict**: Useful for distributed documentation workflows.

---

## Why Remove "When This Skill Activates" Section

### Design Decision (v1.3.0)

Remove the separate "## When This Skill Activates" section from SKILL.md body.

### Rationale

**Official Anthropic Guidance**:
> "The `description` field is critical for Claude to discover when to use your Skill. It should include both what the Skill does and when Claude should use it."

**Current redundancy**:
- Lines 12-19: WHEN/WHEN NOT in frontmatter description ✅
- Lines 24-42: "## When This Skill Activates" section ❌ (duplicate)

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
- Saves ~20 lines
- Eliminates redundancy
- Aligns with official pattern
- No functional change (description field sufficient)

**Verdict**: Correct de-duplication aligned with official guidance.

---

## Learned from project-cleanup v1.2.0

### Pattern Replication

Successfully applied lessons from project-cleanup skill to session skills:

**Pattern 1: Executable Scripts**
- project-cleanup proved scripts > pseudo-code
- Applied to archive_resume.sh and validate_resume.sh
- Result: Deterministic, tested, efficient

**Pattern 2: Automated Testing**
- project-cleanup showed value of test suites
- Applied: 20 automated tests across both session skills
- Result: Confidence in changes, regression detection

**Pattern 3: Progressive Disclosure**
- project-cleanup pioneered references/ pattern
- Applied: Extracted meta-content to references/
- Result: SKILL.md <350 lines, better organization

**Pattern 4: Documentation Organization**
- project-cleanup structured docs by audience
- Applied: DEVELOPMENT.md (devs), CONFIGURATION.md (users), etc.
- Result: Right info for right audience

**Verdict**: Proven patterns scale across skills.

---

*Design decisions for session-closure v1.3.0*
