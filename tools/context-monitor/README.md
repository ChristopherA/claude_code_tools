# context-monitor

Always-visible context usage monitor for Claude Code statusline.

## Features

- **Always visible** - Shows context % even when Claude's built-in indicator is hidden (appears only at ~12%)
- **Color-coded thresholds**:
  - Green: >40% remaining (normal)
  - Yellow: 21-40% remaining (caution)
  - Red: ≤20% remaining with ⚠️ (critical)
- **Model display** - Shows current model (e.g., `[Opus 4.5]`)
- **Configurable** - Environment variables for tuning

## Installation

### 1. Copy the script

```bash
mkdir -p ~/.claude/scripts
cp tools/context-monitor/scripts/status-line.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/status-line.sh
```

### 2. Configure Claude Code

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "command": "~/.claude/scripts/status-line.sh"
  }
}
```

### 3. Verify

Restart Claude Code. You should see `[Model] XX%` in your statusline.

## Requirements

- `jq` - JSON processor (install via `brew install jq` on macOS)

## Configuration

Environment variables (optional):

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_CONTEXT_OVERHEAD` | `42000` | Token overhead for system prompt/tools. Adjust if % doesn't match Claude's indicator. |
| `CLAUDE_SHOW_COST` | (unset) | Set to any value to show session cost after percentage. |

### Example with cost display

```bash
export CLAUDE_SHOW_COST=1
```

Output: `[Opus 4.5] 67% $0.42`

## Display Format

```
[Model] XX%           # Normal (green)
[Model] XX%           # Caution (yellow, 21-40%)
[Model] XX% ⚠️        # Critical (red, ≤20%)
[Model] XX% ⚠️ $0.00  # Critical with cost (if CLAUDE_SHOW_COST set)
```

## How It Works

The script receives JSON from Claude Code via stdin containing:
- Context window size and current token usage
- Model information
- Session cost data

It calculates remaining context percentage, applies color thresholds, and outputs a single line for the statusline.

## Troubleshooting

**Percentage doesn't match Claude's indicator:**
Adjust the overhead value:
```bash
export CLAUDE_CONTEXT_OVERHEAD=45000  # Try higher/lower values
```

**No output / "jq required":**
Install jq: `brew install jq` (macOS) or `apt install jq` (Linux)

**Statusline not updating:**
Check that the script is executable: `chmod +x ~/.claude/scripts/status-line.sh`

---

*context-monitor v0.1.0*
