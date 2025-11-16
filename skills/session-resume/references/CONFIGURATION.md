# Configuration - session-resume

## Installation

**Plugin** (recommended):
```bash
/plugin marketplace add ChristopherA/claude_code_tools
/plugin install session-skills@session-skills
```

**Manual**:
```bash
git clone https://github.com/ChristopherA/claude_code_tools.git
cp -r claude_code_tools/skills/session-resume ~/.claude/skills/
```

## Required Permission

Add to `.claude/settings.local.json`:
```json
{
  "permissions": {
    "allow": [
      "Skill(session-resume)",
      "Bash(~/.claude/skills/session-resume/scripts/check_staleness.sh:*)",
      "Bash(~/.claude/skills/session-resume/scripts/check_uncommitted_changes.sh:*)"
    ]
  }
}
```

## SessionStart Hook (Optional)

Notifies when resume available:

```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "date +'📅 Today is %A, %B %d, %Y' && ([ -f CLAUDE_RESUME.md ] && echo '\\n📋 Previous session available. Say \"resume\" to continue.' || true) && (git rev-parse --git-dir >/dev/null 2>&1 && [ -n \"$(git status --porcelain=v2)\" ] && echo '\\n⚠️  Uncommitted changes from previous session. Review with \"git status\".' || true)"
    }]
  }
}
```

## Upgrading to v1.3.8

**What changed**: Step 0.5 extracted to script (eliminates permission prompts)

**Update permission**:
```json
"Bash(~/.claude/skills/session-resume/scripts/check_uncommitted_changes.sh:*)"
```

**Update files**:
```bash
/plugin update session-skills
# OR
rsync -av --delete ~/path/to/claude_code_tools/skills/session-resume/ ~/.claude/skills/session-resume/
```

**Test**: Say "resume" - should work without approval prompts

**Rollback** (if needed):
```bash
cd ~/.claude/skills/session-resume && git checkout v1.3.7
```

## Customization

**Staleness thresholds**: Edit `scripts/check_staleness.sh` (lines 70-80)
**Resume location**: CLAUDE_RESUME.md in project root
**Archive location**: archives/CLAUDE_RESUME/ (optional)

---

*Configuration guide for session-resume v1.3.8*
