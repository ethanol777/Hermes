# Skill Writing Best Practices — from hello-agents Extra08

Source: https://github.com/datawhalechina/hello-agents (50.7k★), Extra-Chapter/Extra08

## Core Principle: Your Reader Is AI, Not Human

Skills written like human documentation fail with AI. Every line must change AI behavior or be deleted.

### What Humans Want (Don't Do This)
- Background / origin story ("Based on years of team experience...")
- Vague principles ("Keep a professional tone", "Balance strictness and flexibility")
- Version history (v1.0, v1.1) — every session is fresh
- Generic description — the `description` field is the ONLY thing the AI sees to decide activation

### What AI Needs
- Exact triggers for when to activate
- Numbered step sequences (LLMs follow ordered steps much better than paragraphs)
- Concrete examples (input → expected output)
- Anti-patterns: what NOT to do
- Verification steps to confirm task completion

## The Three-Tier Architecture

### L1: Frontmatter (always in context, ~100 tokens)
Only `name` + `description`. The sole basis for AI's activation decision.

### L2: SKILL.md Body (loaded on activation, 1k-5k tokens)
Full instructions, workflows, best practices, examples.

### L3: Support Files (loaded only when needed)
- `references/` — read by AI when it needs to look something up
- `scripts/` — executed by AI (ZERO token cost), not read. For fragile operations.
- `templates/` — copied and modified by AI

## The Freedom Spectrum

| Freedom Level | Task Type | Instruction Style |
|--------------|-----------|-------------------|
| High | Creative (blog posts, design) | Direction + taste + examples |
| Medium | Routine (code review, testing) | Numbered workflow + checkpoints |
| Low | Fragile (config, YAML, permissions) | Script — AI should execute, not generate |

**Rule of thumb:** If there's one right way and 100 wrong ways, write a script.

## Skills vs MCP (from Extra05)

MCP and Agent Skills are complementary, not competitive:

- **MCP** solves connectivity — gives AI access to tools and data (standardized protocol)
- **Skills** solve capability — gives AI domain knowledge and best practices (how to USE those tools)

The ideal architecture: Skills layer orchestrates, MCP layer executes.

> "MCP像是USB接口或驱动程序，它定义了设备如何连接；Skills像是软件应用程序，它定义了如何使用这些连接的设备来完成具体任务。"

For Hermes specifically: native_MCP (MCP) + SKILL.md system (Skills) already implement this architecture. The skills define workflows; MCP tools provide the execution backend.
