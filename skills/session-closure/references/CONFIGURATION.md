# Configuration - session-closure

## Installation

**Plugin** (recommended):
```bash
/plugin marketplace add ChristopherA/claude_code_tools
/plugin install session-skills@session-skills
```

**Manual**:
```bash
git clone https://github.com/ChristopherA/claude_code_tools.git
cp -r claude_code_tools/skills/session-closure ~/.claude/skills/
```

## Required Permission

Add to `.claude/settings.local.json`:
```json
{
  "permissions": {
    "allow": [
      "Skill(session-closure)",
      "Bash(~/.claude/skills/session-closure/scripts/commit_resume.sh:*)"
    ]
  }
}
```

## SessionEnd Hook (Optional)

Auto-invoke on /exit:

```json
{
  "hooks": {
    "SessionEnd": [{
      "type": "skill",
      "skill": "session-closure"
    }]
  }
}
```

## Customization

**Resume mode**: Set in SKILL.md frontmatter (full vs minimal)
**Archive location**: claude/archive/sessions/ (default)
**Git tracking**: Track CLAUDE_RESUME.md for backup

---

*Configuration guide for session-closure v1.3.7*
