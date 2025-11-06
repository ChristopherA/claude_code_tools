# Add Troubleshooting Quick-Start to SKILL.md Files

**Priority**: P1 - Documentation Enhancement
**Labels**: documentation, enhancement, usability

## Description

Add a brief troubleshooting section to both `SKILL.md` files to help users quickly resolve common script execution issues without needing to navigate to reference documentation.

## Rationale

While comprehensive troubleshooting exists in `references/TROUBLESHOOTING.md`, users encountering script errors need immediate guidance. A quick-start section in SKILL.md provides faster resolution for common issues while maintaining progressive disclosure (detailed info stays in references/).

## Proposed Changes

Add the following section to both `skills/session-closure/SKILL.md` and `skills/session-resume/SKILL.md` (suggested location: after main steps, before "Related Skills" section):

```markdown
---

## Troubleshooting Quick-Start

**If script execution fails**:

1. **Check permissions**: `chmod +x scripts/*.sh`
2. **Verify bash**: `which bash` (scripts require bash shell)
3. **Check current directory**: Scripts run from project root
4. **Review script output**: Error messages indicate specific issues

**For detailed troubleshooting**, see:
- references/TROUBLESHOOTING.md (common issues and solutions)
- references/TESTING.md (run test suite to verify installation)

**Test the scripts**:
```bash
cd tests && ./test_scripts.sh
```

Expected: All tests passing
```

## Files to Update

1. `skills/session-closure/SKILL.md` (add after Step 5, before "Related Skills")
2. `skills/session-resume/SKILL.md` (add after Step 5, before "Related Skills")

## Acceptance Criteria

- [ ] Troubleshooting Quick-Start section added to session-closure/SKILL.md
- [ ] Troubleshooting Quick-Start section added to session-resume/SKILL.md
- [ ] Section covers 4 most common issues: permissions, bash availability, directory, script output
- [ ] References detailed documentation for deeper issues
- [ ] Includes test suite command
- [ ] Maintains progressive disclosure principle (brief in SKILL.md, detailed in references/)

## Estimated Effort

10 minutes (5 minutes per file)

## References

- Best practice review: Repository best practices analysis (November 2025)
- Existing troubleshooting: `skills/*/references/TROUBLESHOOTING.md`
- Progressive disclosure principle: Keep SKILL.md concise, details in references/
