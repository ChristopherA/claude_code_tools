# GitHub Issues for Best Practices Review

This directory contains issue templates created from the best practices review (November 2025).

## Created Issues

### Priority 1: Documentation Enhancements

1. **issue-1-security-statement.md** - Add Security Statement to README
   - **Effort**: 5 minutes
   - **Impact**: High - Builds user trust and follows security best practices

2. **issue-2-installation-clarity.md** - Clarify Plugin Installation Naming Conventions
   - **Effort**: 5 minutes
   - **Impact**: Medium - Reduces user confusion during installation

3. **issue-3-troubleshooting-quickstart.md** - Add Troubleshooting Quick-Start to SKILL.md Files
   - **Effort**: 10 minutes
   - **Impact**: High - Faster issue resolution for users

### Priority 2: Minor Improvements

4. **issue-4-author-metadata.md** - Add Author Field to SKILL.md Frontmatter
   - **Effort**: 2 minutes
   - **Impact**: Low - Better attribution and metadata completeness

5. **issue-5-error-recovery-docs.md** - Enhance Error Recovery Documentation in SKILL.md
   - **Effort**: 15 minutes
   - **Impact**: Medium - Improves resilience and user experience

## How to Create Issues on GitHub

Since the `gh` CLI is not available, create issues manually:

### Method 1: GitHub Web Interface

1. Go to https://github.com/ChristopherA/claude_code_tools/issues
2. Click "New issue"
3. Copy the title from the issue file (first line, remove `# `)
4. Copy the content from the issue file
5. Add labels as indicated in the file
6. Submit the issue

### Method 2: Copy-Paste Template

For each issue file:

```bash
# View the issue content
cat .github-issues/issue-1-security-statement.md

# Copy the content and paste into GitHub's new issue form
```

## Suggested Labels

Create these labels in your repository if they don't exist:

- `documentation` - Documentation improvements
- `enhancement` - New features or improvements
- `good first issue` - Good for newcomers
- `user-experience` - UX improvements
- `usability` - Usability improvements
- `metadata` - Metadata and configuration

## Issue Order

Suggested creation order (by impact and effort):

1. Issue 1 (Security Statement) - High impact, 5 min
2. Issue 3 (Troubleshooting) - High impact, 10 min
3. Issue 2 (Installation Clarity) - Medium impact, 5 min
4. Issue 4 (Author Metadata) - Low impact, 2 min
5. Issue 5 (Error Recovery) - Medium impact, 15 min

## Cleanup

After creating issues on GitHub, you can safely delete this directory:

```bash
rm -rf .github-issues/
```

Or keep it for reference and add to `.gitignore`:

```bash
echo ".github-issues/" >> .gitignore
```

---

*Generated from best practices review on November 6, 2025*
