# Development - session-resume

## Script Documentation

### check_staleness.sh
- **Purpose**: Return resume age category
- **Output**: fresh|recent|stale|very_stale|error
- **Exit**: 0=success, 1=error

### check_uncommitted_changes.sh
- **Purpose**: Block resume if uncommitted changes exist
- **Output**: Detailed change summary if changes detected
- **Exit**: 0=clean/not-git, 1=blocking, 2=error

### list_archives.sh
- **Purpose**: List archived resumes
- **Options**: `--limit N`, `--format short|detailed`
- **Exit**: 0=success

## Testing

Run automated tests:
```bash
cd tests && ./test_scripts.sh
```

8 tests cover staleness detection and archive listing.

## Contributing

1. Make changes to scripts
2. Run tests (`./test_scripts.sh`)
3. Update SKILL.md if protocol changes
4. Test manually: say "resume" in a project

---

*Development guide for session-resume v1.3.8*
