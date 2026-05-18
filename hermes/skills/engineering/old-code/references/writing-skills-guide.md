# Skill Writing Principles (from hello-agents Extra08)

Used to rewrite this skill. Condensed reference for future iterations.

## Core: Write for AI, Not for Humans

The reader of SKILL.md is an LLM, not a developer. Every line must change AI behavior or be deleted.

| ❌ Human-centric | ✅ AI-centric |
|----------------|--------------|
| "Based on team experience..." | Skip origins. AI doesn't care. |
| "Keep a professional tone" | Vague → infinite variations. Give concrete rules. |
| "Balance strictness and flexibility" | AI can't operationalize this without a decision tree. |
| Version history (v1.0, v1.1...) | Every session is fresh — meaningless. |
| Generic description | Description is the ONLY trigger signal. Be precise. |

## Progressive Disclosure (Three-Tier Loading)

| Tier | What | Token cost |
|------|------|-----------|
| L1 | Frontmatter (name + description) | ~100 tokens — always in context |
| L2 | SKILL.md body | 1k-5k tokens — loaded on activation |
| L3 | references/ scripts/ templates/ | Unlimited — loaded on demand |

## The Freedom Spectrum

| Freedom | Task type | Style |
|---------|-----------|-------|
| High | Creative (blog, design) | Direction + taste + examples |
| Medium | Routine (review, test) | Numbered workflow + checkpoints |
| Low | Fragile (config, YAML, perms) | **Script** — execute, don't generate |

**Rule of thumb:** One right way, 100 wrong ways → write a script.

## Actionable Body Structure

- Preconditions first
- Numbered steps (LLMs follow sequences better than paragraphs)
- Concrete examples (input → expected output)
- Anti-patterns (what NOT to do)
- End with verification steps
