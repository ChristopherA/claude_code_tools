# Local Session Cleanup Template

Copy this template to `claude/processes/local-session-cleanup.md` in your project and customize for project-specific cleanup checks.

---

## What the Generic Skill Already Handles

**Don't duplicate these in your local file** — the session-cleanup skill handles them automatically:

| Generic Check | Skill Step |
|---------------|------------|
| Uncommitted git changes | Step 0.5 |
| Planning doc staleness (generic) | Step 2 ultrathink |
| File proliferation / anti-proliferation | Step 2 + 3 |
| New files in wrong locations | Step 2 ultrathink |
| Git state validation | Step 3 |
| Cross-references / broken links | Step 2 ultrathink |
| Technical debt / TODOs | Step 2 ultrathink |

**Your local file should add project-specific knowledge** the generic skill can't know.

---

## Common Patterns for Local Checks

Based on real-world usage, consider which patterns apply to your project:

### Pattern 1: Deployment Sync
**If your project deploys somewhere** (npm, PyPI, GitHub releases, user directories):

```bash
echo "=== Deployment Status ==="
git -C /path/to/deploy/target status --short 2>/dev/null || echo "  (not found)"
```

Projects that deploy: CLI tools, libraries, skills, plugins, packages.

### Pattern 2: Cross-Project Coordination
**If you work with related projects** that may send/receive handoffs:

- Check for incoming `CLAUDE_HANDOFF.md`
- Note ownership boundaries (what this project owns vs others)

### Pattern 3: Consistency Audits
**If your project has conventions that can drift**:

- Terminology (e.g., "PlaySet" vs "Playset")
- Version markers across files
- Naming conventions
- Emoji usage patterns

### Pattern 4: Project-Specific Requirements
**If you have requirements/standards docs**:

- Are they current with practice?
- Were any issues resolved this session?
- Do exemplar tables need updating?

### Pattern 5: Build/Test Artifacts
**If your project builds or generates files**:

- Are generated files current?
- Test coverage changes?
- Build artifacts need cleanup?

### Pattern 6: Project State Awareness
**If your project has different modes** (active development, maintenance, paused):

- Remind of current state
- List re-activation triggers

---

## Template

```markdown
# Local Session Cleanup - [Project Name]

*[Project]-specific checks (extends generic session-cleanup)*

---

## Project-Specific Checks

### 2.1 [Most Important Check]

**Why this matters for [project]**: [Brief explanation]

```bash
# Quick verification command
echo "=== [Check Name] ==="
[command] || echo "  (not found)"
```

**If issue found**: [What to do]

### 2.2 [Second Check]

[Description and verification]

### 2.3 [Third Check]

[Description and verification]

## Conditional Checks

### If [condition applies]

- [ ] [Action item]
- [ ] [Action item]

---

*Local cleanup for [Project] - [Month Year]*
*Used by session-cleanup skill v1.1.0*
```

---

## Real-World Examples

### Example: Skill Development Project

```markdown
# Local Session Cleanup - My Skill

*Skill-specific checks (extends generic session-cleanup)*

---

## Project-Specific Checks

### 2.1 Distribution Sync

**If skill deploys to a distribution repo**:

```bash
echo "=== Distribution Status ==="
git -C /path/to/distribution/repo status --short 2>/dev/null
```

**If uncommitted**: Deploy before session close.

### 2.2 SKILL.md Size Limit

**Per Anthropic guidance** (<500 lines):

```bash
wc -l ~/.claude/skills/my-skill/SKILL.md
```

**If over 500**: Apply cleanup (see skill-authoring.md).

### 2.3 Cross-Project Ownership

**What this skill owns vs other projects**:
- This project: [skill name], [related hooks]
- Other project: [what they own]

Check for handoffs if boundaries were crossed.

---

*Local cleanup for My Skill - December 2025*
```

### Example: Content/Documentation Project

```markdown
# Local Session Cleanup - Docs Project

*Docs-specific checks (extends generic session-cleanup)*

---

## Project-Specific Checks

### 2.1 Consistency Audit

**Terminology drift**:
- Term A vs Term B (which is canonical?)
- Version markers (v1.0 vs 1.0 vs version 1)

### 2.2 Requirements Currency

```bash
echo "=== Requirements Last Modified ==="
ls -la requirements/*.md | head -5
```

**If requirements changed**: Update "Last updated" in README.

### 2.3 Content Directories

- `content/drafts/`: Anything ready to promote?
- `content/archive/`: Anything to archive?

## Conditional Checks

### If terminology changed
- [ ] Update glossary
- [ ] Check all files for old term

---

*Local cleanup for Docs Project - December 2025*
```

### Example: API/Library Project

```markdown
# Local Session Cleanup - API Project

*API-specific checks (extends generic session-cleanup)*

---

## Project-Specific Checks

### 2.1 API Spec Sync

```bash
echo "=== OpenAPI Spec ==="
diff docs/api.yaml generated/api.yaml 2>/dev/null && echo "In sync" || echo "DRIFT DETECTED"
```

### 2.2 Test Coverage

```bash
echo "=== Coverage ==="
cat coverage/summary.txt 2>/dev/null | grep "Total" || echo "Run tests first"
```

### 2.3 Changelog Currency

**If user-facing changes made**: Add CHANGELOG.md entry.

## Conditional Checks

### If endpoints added/modified
- [ ] Update Postman collection
- [ ] Verify rate limiting
- [ ] Check auth requirements

---

*Local cleanup for API Project - December 2025*
```

---

## Usage

1. Copy the template to `claude/processes/local-session-cleanup.md`
2. Delete patterns that don't apply to your project
3. Add project-specific checks using the patterns above
4. Session-cleanup skill automatically detects and loads this file
5. Update as project evolves

## Tips

- **Keep it short**: Only add what the generic skill can't know
- **Use bash blocks**: For quick verification commands
- **Use checklists**: For manual verification items
- **Section numbers start at 2.x**: Generic skill uses Step 1-3, local is Step 4
- **Delete unused sections**: Don't keep placeholder sections
- **Update when patterns change**: If you find yourself skipping checks, remove them

---

*Template for project-specific cleanup checklists - December 2025*
*Used by session-cleanup skill v1.1.0*
