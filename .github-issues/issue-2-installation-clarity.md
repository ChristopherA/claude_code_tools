# Clarify Plugin Installation Naming Conventions

**Priority**: P1 - Documentation Enhancement
**Labels**: documentation, enhancement, user-experience

## Description

Clarify the plugin installation command naming conventions to reduce confusion about the `plugin-name@marketplace-name` format.

## Current State

README.md lines 28-32:
```bash
# Add this marketplace
/plugin marketplace add ChristopherA/claude_code_tools

# Install the session-skills plugin
/plugin install session-skills@session-skills
```

Users may be confused by the `session-skills@session-skills` syntax.

## Proposed Changes

Update the installation instructions to include explanatory comments:

```bash
# Add the marketplace (format: owner/repo)
/plugin marketplace add ChristopherA/claude_code_tools

# Install the plugin (format: plugin-name@marketplace-name)
# The marketplace name defaults to the last part of the repo name
/plugin install session-skills@session-skills
```

Alternatively, add a brief explanation before the code block:

```markdown
### Option 1: Plugin Installation (Recommended)

The plugin marketplace uses a two-step process:
1. Add the marketplace repository (one-time setup)
2. Install specific plugins from that marketplace

```bash
# Step 1: Add the marketplace
/plugin marketplace add ChristopherA/claude_code_tools

# Step 2: Install the session-skills plugin
/plugin install session-skills@session-skills
```
```

## Acceptance Criteria

- [ ] Installation section includes clear explanation of command format
- [ ] Comments explain `owner/repo` format for marketplace add
- [ ] Comments or text explain `plugin-name@marketplace-name` format
- [ ] Instructions remain concise and easy to follow

## Estimated Effort

5 minutes

## References

- Best practice review: Repository best practices analysis (November 2025)
- Current implementation: README.md lines 23-44
