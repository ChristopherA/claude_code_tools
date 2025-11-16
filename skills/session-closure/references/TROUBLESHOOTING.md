# Troubleshooting - session-closure

## Resume Not Created

**Symptoms**: CLAUDE_RESUME.md doesn't exist after closure

**Causes**:
- Skill not invoked (say "close context" explicitly)
- Error during creation (check terminal output)
- Permission issues (check file permissions)

**Fix**:
1. Verify skill activated: Look for "session-closure is running"
2. Check for errors in output
3. Try manual creation: Follow SKILL.md steps manually

## Resume Not Committed

**Symptoms**: Resume created but `git status` shows uncommitted

**Causes**:
- Not a git repository
- commit_resume.sh failed
- Permission not granted for script

**Fix**:
1. Check `git rev-parse --git-dir` (should succeed)
2. Run manually: `~/.claude/skills/session-closure/scripts/commit_resume.sh "$PWD"`
3. Check permissions in `.claude/settings.local.json`

## Secret Files Warning

**Symptoms**: "Secret files detected" blocks closure

**Cause**: .env, credentials, keys in uncommitted changes

**Fix**:
1. Review files listed in warning
2. Add to .gitignore if truly secret
3. Commit if safe to track
4. Remove from working directory if temporary

## Archive Not Created

**Symptoms**: Previous resume not archived

**Causes**:
- No previous resume existed
- Archive script failed
- Directory permissions

**Fix**: Check `claude/archive/sessions/` exists and is writable

## Phantom Tasks

**Symptoms**: Tasks in resume that don't exist in todo list

**Cause**: Todo list cleared but resume captures old state

**Fix**: Accept as historical record, or edit resume manually before closure

## Getting Help

1. Check error messages in terminal
2. Review SKILL.md for protocol
3. Test scripts manually
4. Report issues: https://github.com/ChristopherA/claude_code_tools/issues

---

*Troubleshooting guide for session-closure v1.3.7*
