---
name: pi-coding-agent
description: |
  Install and use earendil-works/pi, an AI coding agent CLI toolkit. 
  Pi is a self-extensible agent framework with TUI, supporting multiple LLM providers (OpenAI, Anthropic, Google).
trigger: |
  - User asks about "pi" agent or earendil-works/pi
  - User wants to install pi coding agent
  - User needs to use pi for coding tasks
  - Comparing pi with other coding agents (claude-code, codex)
---

# Pi Coding Agent

## Installation

Requires Node.js (v18+):

```bash
npm install -g @earendil-works/pi-coding-agent
```

Verify installation:
```bash
pi --version
```

## Configuration

Set API key for your preferred provider:

```bash
# OpenAI
export OPENAI_API_KEY=sk-...

# Anthropic (Claude)
export ANTHROPIC_API_KEY=sk-ant-...

# Google (Gemini)
export GOOGLE_API_KEY=...
```

## Basic Usage

```bash
# Start interactive TUI in current directory
pi

# Start in specific project directory
pi /path/to/project

# Specify model
pi --model claude-sonnet-4
pi --model gpt-4

# Get help
pi --help
```

## Key Features

- **Self-extensible**: Agent can modify its own code
- **Interactive TUI**: Terminal UI with differential rendering
- **Multi-provider**: Unified API for OpenAI, Anthropic, Google
- **Session sharing**: Can publish sessions to Hugging Face for training data

## Comparison with Other Agents

| Feature | Pi | Claude Code | Codex |
|---------|-----|-------------|-------|
| Self-extensible | Yes | No | No |
| TUI | Yes | Yes | Yes |
| Multi-provider | Yes | No (Anthropic only) | No (OpenAI only) |
| Web UI | Available | No | No |

## Pitfalls

- Requires npm/Node.js environment
- Newer project (check for Windows-specific issues)
- API keys must be set before starting