# GBrain Setup on Hermes Agent (WSL/Linux)

GBrain (https://github.com/garrytan/gbrain) — persistent knowledge base with
hybrid search, knowledge graph, and 29 skills. Designed for AI agents.

The existing `setup-gbrain` skill (also in this skill library) targets **GStack +
Claude Code on macOS**. This reference covers the **Hermes Agent on WSL/Linux**
path — simpler, no GStack dependency, no Claude Code MCP.

## Prerequisites

- Git, curl, unzip (`sudo apt-get install -y unzip` if missing)
- Hermes Agent running (CLI or gateway)
- A markdown brain repo (e.g., `~/brain/`)

## Installation

```bash
# 1. Clone
git clone https://github.com/garrytan/gbrain.git ~/gbrain

# 2. Install Bun
curl -fsSL https://bun.sh/install | bash
export PATH="$HOME/.bun/bin:$PATH"

# 3. Install dependencies + link CLI globally
cd ~/gbrain
bun install
bun link

# 4. Verify
gbrain --version    # should print e.g. "gbrain 0.25.0"
```

> **Do NOT use `bun install -g github:garrytan/gbrain`.** Bun blocks the top-level
> postinstall hook on global installs, so schema migrations never run and the CLI
> aborts with `Aborted()`. Use `git clone + bun install && bun link`.

## Initialize the Brain

```bash
gbrain init                    # PGLite (zero-config, local only)
gbrain doctor --json           # verify: should show mostly OK/WARN
```

By default gbrain uses PGLite (embedded Postgres via WASM) — no server, no
accounts. All data lives at `~/.gbrain/`.

## Create a Brain Repo (your knowledge base)

The brain repo is SEPARATE from the gbrain tool repo. Create it wherever you
keep your notes:

```bash
mkdir -p ~/brain
cd ~/brain && git init
```

Recommended directory layout (from gbrain's schema doc):
```
brain/
├── people/       # Person pages: name, bio, org, relationship notes
├── companies/    # Company pages: domain, products, contacts
├── concepts/     # Ideas, frameworks, reference material
├── notes/        # General notes, journals
└── projects/     # Active project context
```

## Import and Index

```bash
gbrain import ~/brain/ --no-embed    # import markdown files
```

Embedding step requires `OPENAI_API_KEY` (see "Embeddings" below). Without it,
keyword search still works — vector search is skipped.

## Embeddings Limitation — OpenCode API

GBrain's embedding service uses OpenAI's `text-embedding-3-large` model. The
OpenCode Go / Zen APIs do NOT support embeddings (`/v1/embeddings` returns 404).

**Without `OPENAI_API_KEY`:**
- Keyword search works (tsvector + trigram)
- Vector search is skipped
- Hybrid search falls back to keyword-only
- Useful for small brains (<1000 pages)

**To add embeddings later:**
```bash
export OPENAI_API_KEY=sk-...
gbrain embed --stale
```

Or set `OPENAI_BASE_URL` to any OpenAI-compatible endpoint that supports
embeddings (e.g., a local vllm instance with an embedding model).

## Integrate with Hermes

Since Hermes Agent doesn't use Claude Code's MCP system, no MCP registration
is needed. Use gbrain directly via terminal commands:

```bash
gbrain query "what do I know about X?"
gbrain put people/alice --title "Alice Example" --body "..." --source "meeting"
gbrain search "keyword"                     # search brain
gbrain get people/alice                     # read a page
gbrain graph-query people/alice --depth 2   # traverse links
```

For Hermes to use gbrain naturally in conversation, load the `setup-gbrain`
skill at session start — it contains the brain-ops workflow pattern.

## Cron Jobs (recurring sync)

Set up via Hermes cron or system cron:

```bash
# Every 15 min: live sync + re-embed stale pages
cd ~/gbrain && gbrain sync --repo ~/brain 2>/dev/null && gbrain embed --stale --quiet 2>/dev/null

# Daily: health check
gbrain doctor --json
```

## Upgrading

```bash
cd ~/gbrain
git pull origin master
bun install
gbrain init                           # apply schema migrations (idempotent)
gbrain doctor --json                  # verify
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `bun: command not found` | Bun not in PATH | `export PATH="$HOME/.bun/bin:$PATH"` |
| `gbrain: command not found` | `bun link` not run | `cd ~/gbrain && bun link` |
| `Aborted()` on `gbrain` start | Global install via `bun -g` | Reinstall via `git clone + bun link` |
| `No embeddings` in doctor | No OpenAI key | Skip or add `OPENAI_API_KEY` |
| Search returns nothing | Brain empty | `gbrain import ~/brain/` first |
| Search quality low | No embeddings | See "Embeddings Limitation" above |
