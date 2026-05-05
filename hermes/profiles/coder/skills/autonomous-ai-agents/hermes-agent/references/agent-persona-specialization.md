# Agent Persona & Specialization

How to make Hermes specialize in a particular domain (e.g., backend dev, AI research, DevOps, data analysis).

There are **three mechanisms**, from simplest to most powerful:

---

## 1. Persona File (Session-Level)

The Persona file is the markdown content at the top of every conversation (like the one that starts with "Hermes Agent Persona"). It defines the agent's tone, style, and focus for that session.

**Edit it directly** — change the content to reflect your specialization:

```
You are a Python backend expert. Focus on FastAPI, SQLAlchemy, async patterns.
Always include Pydantic models, Alembic migrations, and pytest tests.
Write concise, production-ready code with Chinese comments.
```

The agent reads this at session start. Changes take effect immediately on the next turn.

---

## 2. Personalities (In-Session)

Hermes supports a `/personality` slash command:

```
/personality expert        # Switch to expert mode
/personality creative      # Switch to creative mode
/personality default       # Reset to default
```

Personalities are defined in `~/.hermes/config.yaml` under the `personalities` section. Each personality can override:

- System prompt tone
- Reasoning effort defaults
- Verbosity level

Check available personalities:
```
/personality       # List available
```

---

## 3. Profiles (Full Isolation)

Profiles completely isolate agent instances — separate config, sessions, skills, and memory:

```bash
# Create a specialized profile
hermes profile create coding-expert --clone

# Switch to it
hermes profile use coding-expert

# Or run a session with it
hermes --profile coding-expert

# Each profile has its own:
# ~/.hermes/profiles/coding-expert/config.yaml
# ~/.hermes/profiles/coding-expert/.env
# ~/.hermes/profiles/coding-expert/sessions/
# ~/.hermes/profiles/coding-expert/skills/   (separate skills!)
```

**Different persona per profile:** each profile reads its own Persona file at `~/.hermes/profiles/<name>/persona.md`. Edit it for domain-specific behavior.

**Use cases for profiles:**
- `coding-expert` — focused on software dev, loads `python-debugpy`, `github-*` skills
- `ai-research` — focused on ML, loads `arxiv`, `llama-cpp`, `huggingface-*` skills
- `devops` — focused on ops, loads `webhook-subscriptions`, `cron`, `inference-sh` skills

---

## 4. Specialization Skill (Self-Contained)

You can also create a skill whose sole purpose is to define a specialization. When loaded, it overrides the agent's behavior for that domain.

```
---
name: backend-expert
description: "Specialize as a Python backend expert"
version: 1.0.0
---

# Backend Expert Persona

When this skill is loaded, behave as:
- A senior Python backend engineer
- Focus on: FastAPI, SQLAlchemy, async, Redis, PostgreSQL
- Always provide: Pydantic schemas, Alembic migrations, pytest tests
- Write production-quality code with Chinese comments
- Prefer async patterns over sync
```

Load it with `/skill backend-expert` or `hermes -s backend-expert`.

**Compared to the Persona file:** a specialization skill can be loaded/unloaded mid-session via `/skill name` and toggled on demand. The Persona file is static for the whole session.

---

## Quick Comparison

| Method | Scope | Persistence | Toggle mid-session |
|--------|-------|-------------|-------------------|
| Persona file | Single session | Per session | No (reload needed) |
| `/personality` | Single session | Config-defined | Yes |
| Profile | Multiple sessions | Permanent | Switch at start |
| Specialization skill | Per skill load | Until unloaded | Yes (`/skill`) |
