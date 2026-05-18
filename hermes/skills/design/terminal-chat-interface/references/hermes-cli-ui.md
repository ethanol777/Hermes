# Hermes CLI UI Architecture

Read from actual source code (May 2026).

## Key Files

| File | Lines | Purpose |
|------|-------|---------|
| `cli.py` | ~14,000 | Main HermesCLI class — interactive REPL |
| `agent/display.py` | ~987 | KawaiiSpinner + tool preview + diff rendering |
| `hermes_cli/skin_engine.py` | ~921 | YAML-driven skin/theme system |
| `hermes_cli/curses_ui.py` | ~472 | Curses multi-select checklists for `hermes tools` / `hermes skills` |
| `hermes_cli/commands.py` | - | Central COMMAND_REGISTRY for all slash commands |
| `ui-tui/` | - | Ink (React) terminal UI — `hermes --tui` |
| `tui_gateway/` | - | Python JSON-RPC backend for the above |

## KawaiiSpinner (agent/display.py)

The spinner is **threading-based**, not asyncio. Runs in a daemon thread.

### Spinner Types
```python
SPINNERS = {
    'dots': ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'],
    'bounce': ['⠁', '⠂', '⠄', '⡀', '⢀', '⠠', '⠐', '⠈'],
    'grow': ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█', '▇', '▆', '▅', '▄', '▃', '▂'],
    'arrows': ['←', '↖', '↑', '↗', '→', '↘', '↓', '↙'],
    'star': ['✶', '✷', '✸', '✹', '✺', '✹', '✸', '✷'],
    'moon': ['🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘'],
    'pulse': ['◜', '◠', '◝', '◞', '◡', '◟'],
    'brain': ['🧠', '💭', '💡', '✨', '💫', '🌟', '💡', '💭'],
    'sparkle': ['⁺', '˚', '*', '✧', '✦', '✧', '*', '˚'],
}
```

### Animation Format
```python
# With wings (from skin):
"  ⟪⚔ {frame} {message} ⚔⟫ ({elapsed:.1f}s)"

# Without wings:
"  {frame} {message} ({elapsed:.1f}s)"
```

### Key features:
- **`print_above()`**: clears spinner line, prints text, lets next tick redraw — for interleaving tool output with spinner
- **`update_text()`**: changes spinner message mid-flight
- **Non-TTY fallback**: writes `"  [tool] {message}"` once, no animation
- **StdoutProxy detection**: skips `\r` animation inside prompt_toolkit's `patch_stdout`
- **Thread-safe**: uses captured `self._out` reference (not `sys.stdout`)

## Skin Engine (hermes_cli/skin_engine.py)

YAML-driven theme system. Built-in skins: `default` (gold/kawaii), `ares` (crimson), `mono` (grayscale), `slate` (blue), `daylight` (light bg), `warm-lightmode`.

### Skin YAML Schema
```yaml
name: mytheme
description: Short description

colors:
  banner_border: "#CD7F32"
  banner_title: "#FFD700"
  banner_accent: "#FFBF00"
  banner_dim: "#B8860B"
  banner_text: "#FFF8DC"
  ui_accent: "#FFBF00"
  ui_label: "#DAA520"
  ui_ok: "#4caf50"
  ui_error: "#ef5350"
  ui_warn: "#ffa726"
  prompt: "#FFF8DC"
  input_rule: "#CD7F32"
  response_border: "#FFD700"
  status_bar_bg: "#1a1a2e"
  status_bar_text: "#C0C0C0"
  status_bar_strong: "#FFD700"
  status_bar_dim: "#8B8682"
  status_bar_good: "#8FBC8F"
  status_bar_warn: "#FFD700"
  status_bar_bad: "#FF8C00"
  status_bar_critical: "#FF6B6B"
  session_label: "#DAA520"
  session_border: "#8B8682"
  selection_bg: "#333355"
  completion_menu_bg: "#1a1a2e"
  completion_menu_current_bg: "#333355"

spinner:
  waiting_faces: ["(⚔)", "(⛨)"]
  thinking_faces: ["(⌁)", "(<>)"]
  thinking_verbs: ["forging", "plotting"]
  wings:
    - ["⟪⚔", "⚔⟫"]
    - ["⟪▲", "▲⟫"]

branding:
  agent_name: "Hermes Agent"
  welcome: "Welcome message"
  goodbye: "Goodbye! ⚕"
  response_label: " ⚕ Hermes "
  prompt_symbol: "❯"
  help_header: "(^_^)? Commands"

tool_prefix: "┊"

tool_emojis:
  terminal: "⚔"
  web_search: "🔮"
```

### API
```python
from hermes_cli.skin_engine import get_active_skin, list_skins, set_active_skin
skin = get_active_skin()
color = skin.get_color("banner_title", "#FFD700")
```

## CLI Architecture (cli.py)

### Stack
- **prompt_toolkit** for the TUI layout (Application + HSplit + TextArea)
- **rich** for formatted output (through `patch_stdout`)
- **KawaiiSpinner** for tool execution feedback
- **FileHistory** for input history
- **CompletionsMenu** for /-commands autocomplete

### Layout Structure
```
HSplit([
    Window(content=FormattedTextControl())  # Scrollable output area
    Window(content=FormattedTextControl())  # Context usage bar (status bar)
    TextArea()                              # Fixed bottom input
])
```

### Key Patterns
1. **`patch_stdout()`** — wraps `print()` calls so they don't corrupt the prompt_toolkit TUI layout
2. **`_pt_print(ANSI(text))`** — alternative to `print()` for safe TUI output
3. **`load_cli_config()`** — merges hardcoded defaults + user config YAML
4. **`process_command()`** — dispatches slash commands via `resolve_command()` from central registry
5. **`_spinner_text` widget** — TUI widget that displays spinner state (when in prompt_toolkit mode)

## Response Box (Rich Panel)

Hermes renders responses as Rich panels with:

```python
Panel(
    Text(content),
    title=f"╚ {branding.response_label}",
    title_align="right",
    box=box.ROUNDED,
    border_style="bright_yellow",
)
```

Note: `title_align="right"` pushes the label to the right side, `"╚ "` prefix creates a visual anchor.

## Tool Call Display

After each tool completes, Hermes prints a line like:

```
┊ {emoji} {verb:9} {detail}  {duration}
```

Example:
```
┊ ⚔ terminal:9 ls -la  0.3s
┊ 🔮 search:9 "python tui"  1.2s
```

Failure indicators: `red foreground` prefix + `[exit 1]` / `[error]` / `[full]` suffix.

## Context Usage Bar

Fixed window at the bottom showing token/context usage:

```
{context_pct}% · {tokens_used:,} / {context_limit:,} · ${cost_estimate}
```

Color-coded by usage level: green (<75%), yellow (75-90%), orange (90-95%), red (>95%).
