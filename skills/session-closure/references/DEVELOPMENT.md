# Development - session-closure

## Script Documentation

### archive_resume.sh
- **Purpose**: Archive existing resume with timestamp
- **Options**: `--dry-run`
- **Exit**: 0=success

### commit_resume.sh
- **Purpose**: Commit new resume to git
- **Features**: Secrets detection, per-file summaries
- **Exit**: 0=success, 1=error

### validate_resume.sh
- **Purpose**: Verify resume structure
- **Checks**: Required sections present
- **Exit**: 0=valid, 1=invalid

## Testing

Run automated tests:
```bash
cd tests && ./test_scripts.sh
```

## Contributing

1. Make changes to scripts
2. Run tests
3. Update SKILL.md if protocol changes
4. Test manually: say "close context"

---

*Development guide for session-closure v1.3.7*
