---
name: find-skills-skill
description: "Search and discover skills from various sources (ClawHub, OpenClaw, LobeHub, GitHub, Community). Use when: user wants to find available skills, search for specific functionality, or discover new skills to install."
version: 1.0.0
author: fangkelvin (ClawHub)
homepage: https://clawhub.ai/fangkelvin/find-skills-skill
license: MIT-0
metadata:
  hermes:
    tags: [skills, discovery, search]
  openclaw:
    emoji: 🔍
    requires:
      bins: []
---

# Find Skills Skill

Search and discover OpenClaw/Hermes skills from various sources.

## When to Use

✅ **USE this skill when:**
- "Find skills for [task]"
- "Search for OpenClaw skills"
- "What skills are available?"
- "Discover new skills"
- "Find skills by category"

## When NOT to Use

❌ **DON'T use this skill when:**
- Installing skills → use `openclaw skills install <slug>` then convert to Hermes
- Managing installed skills → use `skills_list` or `skill_view()`
- Creating new skills → use `skill_manage(action='create')`

## Sources for Finding Skills

### 1. ClawHub (Primary)
- Website: https://clawhub.ai
- Search skills by keyword, category, or author
- Browse trending and popular skills

### 2. OpenClaw Directory
- Website: https://www.openclawdirectory.dev/skills
- Browse by category, popularity, or search

### 3. LobeHub Skills Marketplace
- Website: https://lobehub.com/skills
- Community-contributed skills

### 4. GitHub (Direct Search)
Search for skills directly via GitHub API when you know a skill name but not its source:

```bash
# Search repositories by keyword
curl -s "https://api.github.com/search/repositories?q=superpowers+ai+agent+skill&sort=stars&order=desc"

# Common search patterns:
# - "<skill-name> ai agent skill"
# - "<skill-name> SKILL.md"
# - "hermes skill" or "openclaw skill"
```

Look for repositories with:
- `SKILL.md` files in a `skills/` directory
- High star counts (indicates community adoption)
- Recent updates
- Clear documentation in README.md

### 5. Notable Community Skill Collections

| Project | Description | Install Method |
|---------|-------------|----------------|
| **superpowers-zh** | AI编程超能力·中文增强版 - 20个生产级skills（方法论+中国特色） | Manual clone + copy |
| agency-agents-zh | 211个AI专家角色库 | Manual / npm |

**superpowers-zh** (https://github.com/jnMetaCode/superpowers-zh):
- 14个翻译skills：头脑风暴、TDD、系统化调试、代码审查等
- 6个中国特色skills：中文代码审查、Git工作流、MCP构建等
- 支持17款AI编程工具包括Hermes
- 安装：`git clone` + copy to `~/.hermes/skills/`

### 6. Community Forums
- SitePoint: https://www.sitepoint.com/community/
- Discord: https://discord.com/invite/clawd

## CLI-Based Search (Primary Method)

The OpenClaw CLI is the fastest way to search ClawHub's 63k+ skills:

```bash
# Search by keyword (returns JSON for easy parsing)
openclaw skills search <keyword> --limit 20 --json

# Examples:
openclaw skills search "wechat" --limit 10 --json
openclaw skills search "feishu" --limit 10 --json
openclaw skills search "AI news" --limit 10 --json
openclaw skills search "self-improving" --limit 10 --json
openclaw skills search "github" --limit 10 --json
openclaw skills search "weather" --limit 10 --json
```

### Understanding Search Results

Each result has:
- `displayName` — Human-readable name
- `slug` — Install name (use this with `openclaw skills install`)
- `summary` — Skill description
- `score` — Relevance score
- `updatedAt` — Last update timestamp (Unix ms)

### Browser-Based Browsing

Web UI: https://clawhub.ai/skills
- Sort by: Featured, Most downloaded, Most starred, Recently updated, Newest
- Filter by category: MCP Tools, Prompts, Workflows, Dev Tools, Data & APIs, Security, Automation, Other
- View: List or Cards
- Security info: Each skill page shows VirusTotal, ClawScan, and Static Analysis results

### Quick Reference

See `references/notable-skills.md` for a curated table of interesting skills discovered on ClawHub, organized by category (top downloaded, Chinese ecosystem, AI news, self-improvement).

## Search Strategies

### By Functionality
```bash
openclaw skills search "web search" --limit 10 --json
openclaw skills search "weather" --limit 10 --json
openclaw skills search "document" --limit 10 --json
```

### By Integration Target
```bash
openclaw skills search "github" --limit 10 --json
openclaw skills search "notion" --limit 10 --json
openclaw skills search "calendar" --limit 10 --json
```

### By Trend / Popularity
Most downloaded and starred skills are listed at https://clawhub.ai/skills?sort=downloads

## Installing ClawHub/OpenClaw Skills into Hermes

ClawHub skills use the OpenClaw CLI, not Hermes' built-in `hermes skills install`. Convert them manually:

### Prerequisites
- `openclaw` CLI: `npm install -g openclaw` (requires Node.js)
- WSL note: npm installs to `~/.npm-global` if NVM is configured; ensure it's on PATH

### Workflow (tested on WSL with Hermes)

1. **Install OpenClaw CLI** (if not present):
   ```bash
   npm install -g openclaw
   # On WSL with NVM, npm installs to ~/.npm-global or NVM path; ensure on PATH
   ```
2. **Search for the skill** to confirm its slug:
   ```bash
   openclaw skills search <keyword> --limit 5 --json
   ```
3. **Install the skill** via OpenClaw:
   ```bash
   openclaw skills install <slug>
   ```
   Skills use hyphenated slugs (e.g. `find-skills-skill`, not `find skills`).
4. **Read installed files**:
   ```bash
   cat ~/.openclaw/workspace/skills/<slug>/SKILL.md
   cat ~/.openclaw/workspace/skills/<slug>/_meta.json       # ownerId, slug, version, publishedAt
   cat ~/.openclaw/workspace/skills/<slug>/.clawhub/origin.json  # registry URL, installedVersion
   ```
5. **Adapt SKILL.md for Hermes** — Add/modify frontmatter fields:
   ```yaml
   version: 1.0.0
   author: <author-name> (ClawHub)
   homepage: https://clawhub.ai/<author>/<slug>
   license: MIT-0   # verify on ClawHub page
   metadata:
     hermes:
       tags: [relevant, tags]
   ```
6. **Copy to Hermes skills directory**:
   ```bash
   mkdir -p ~/.hermes/skills/<slug>
   cp ~/.openclaw/workspace/skills/<slug>/SKILL.md ~/.hermes/skills/<slug>/
   cp ~/.openclaw/workspace/skills/<slug>/_meta.json ~/.hermes/skills/<slug>/ 2>/dev/null || true
   cp -r ~/.openclaw/workspace/skills/<slug>/.clawhub ~/.hermes/skills/<slug>/ 2>/dev/null || true
   ```
7. **Commit to skills git repo**:
   ```bash
   cd ~/.hermes/skills && git add <slug>/ && git commit -m "install <slug> from ClawHub" && git push
   ```
8. **Verify** — `skill_view(name='<slug>')` should load correctly.

## Installing Community Skills (Manual Method)

For skill collections like **superpowers-zh** that aren't on ClawHub but are on GitHub:

### Workflow (tested with superpowers-zh)

1. **Find the repository** via GitHub API search:
   ```bash
   curl -s "https://api.github.com/search/repositories?q=superpowers+zh+skill&sort=stars&order=desc" | grep '"html_url"'
   ```

2. **Clone to temp location**:
   ```bash
   git clone --depth 1 https://github.com/jnMetaCode/superpowers-zh.git /tmp/superpowers-zh
   ```

3. **Verify skill structure**:
   ```bash
   ls /tmp/superpowers-zh/skills/           # Should see directories with SKILL.md
   cat /tmp/superpowers-zh/skills/<name>/SKILL.md  # Verify frontmatter
   ```

4. **Copy to Hermes skills directory**:
   ```bash
   mkdir -p ~/.hermes/skills
   cp -r /tmp/superpowers-zh/skills/* ~/.hermes/skills/
   ```

5. **Verify installation**:
   ```bash
   ls ~/.hermes/skills/ | wc -l             # Count installed skills
   skill_view(name='<skill-name>')          # Test loading
   ```

6. **Create install summary** (optional but recommended):
   ```bash
   cat > ~/.hermes/superpowers_install_summary.md << 'EOF'
   # Superpowers-zh 安装完成汇总
   ## 安装时间
   $(date +%Y-%m-%d)
   ## 安装的 Skills
   $(ls ~/.hermes/skills/)
   EOF
   ```

### Key Differences from ClawHub Skills

| Aspect | ClawHub Skills | Community Skills (e.g., superpowers-zh) |
|--------|---------------|-----------------------------------------|
| Discovery | `openclaw skills search` | GitHub API search |
| Install command | `openclaw skills install` | `git clone` + manual copy |
| Structure | Single skill per repo | Multiple skills in `skills/` subdirectory |
| Frontmatter | Standard OpenClaw format | May need Hermes adaptation |
| Update mechanism | `openclaw skills update` | Re-clone and re-copy |
| Metadata | `_meta.json`, `.clawhub/` | Usually absent |

### Pitfalls

- **🔴 Context misinterpretation**: When the user asks about a feature/file/concept name (e.g. "SOUL.md", "memory"), first check if it's referenced within an **already-installed skill** before searching ClawHub. The user may be referring to a file mentioned in a skill they just asked you to install (e.g. proactive-agent references SOUL.md, AGENTS.md, USER.md). Searching ClawHub for a separate skill when the answer is already installed is a waste and requires user correction.

- **🔴 Ambiguous tool/package names**: When a user asks to install something with an ambiguous name (e.g. "openviking" could be GPS Viking or ByteDance's OpenViking), **search and disambiguate before acting**. Steps:
  1. First ask: "Did you mean X or Y?" if you already know multiple possibilities exist
  2. If not sure, search the name broadly (GitHub, web) to see what it could refer to
  3. Check if the name matches a known org/project (e.g. ByteDance/Volcengine opensource projects)
  4. Only install after confirming which one the user wants
  - **Don't** jump to install the most obvious apt/pip package without checking context
  - **Don't** assume the user means the oldest or most generic option
  - Correct flow: user says "install X-skill" → you install it → user asks about "Y file" → check X-skill's content first → if Y is mentioned as a workspace file in X-skill, create it locally rather than searching ClawHub
  - Wrong flow: user says "install X-skill" → user asks about "Y" → you search ClawHub for a Y-skill → user corrects you
- **Rate limits (HTTP 429)**: ClawHub API enforces rate limiting aggressively. Actual retry strategy (tested):
  - After **first 429**: wait 30-60 seconds, retry one at a time
  - After **repeated 429s**: wait 90-120 seconds before next attempt
  - **Batch installs WILL trigger 429** — install one at a time with `sleep 30` between successes
  - Rate limit resets roughly after 1 hour of inactivity
  - **If installing many skills**: chain them with delays: `openclaw skills install A && sleep 30 && openclaw skills install B && sleep 30 ...`
- **Hermes `skills_list` won't show it** until the SKILL.md is in `~/.hermes/skills/`. The OpenClaw install only puts it in `~/.openclaw/workspace/skills/`.
- **No `clawhub` binary**: Use `openclaw skills install`, not `clawhub install`. The `clawhub` npm package may not exist.
- **Skill name in URL slug ≠ SKILL.md frontmatter name**: The ClawHub URL has the slug, but the frontmatter `name:` field might differ. Use the slug for `openclaw skills install`, use the frontmatter name for `skill_view()`.
- **Skills with scripts/ directories**: Some skills ship with executables (e.g. `scripts/scanner.py`, `scripts/activator.sh`). These must be copied separately:
  ```bash
  cp -r ~/.openclaw/workspace/skills/<slug>/scripts/ ~/.hermes/skills/<slug>/
  ```
  After copying, verify with `skill_view(name='<slug>')` — linked scripts appear under `linked_files.scripts` in the response.
- **Frontmatter name vs display name**: The OpenClaw `name:` field in SKILL.md frontmatter often differs from the ClawHub display name and the URL slug. Example: slug `self-improving-agent` has frontmatter `name: self-improvement`. Use the slug for install, the frontmatter name for loading.

## Common Skill Categories

### Core Skills
- `weather` - Weather forecasts
- `skill-creator` - Create new skills
- `healthcheck` - Security audits

### Integration Skills
- `github` - GitHub operations
- `feishu` - Feishu integration
- `notion` - Notion API

### Search Skills
- `tavily-search` - Web search via Tavily
- `web-search-plus` - Enhanced web search

### Agent Skills
- `proactive-agent` - Proactive automation
- `coding-agent` - Code generation

## 搜索优先级规则

找 skill 的正确顺序：

1. **`openclaw skills search <keyword> --limit 10 --json`** — 最快、最准，先用这个
2. **ClawHub 网站** — `https://clawhub.ai/skills?q=<keyword>`
3. **GitHub API** — 只有在有明确关键词时才用，不要漫无目的地翻 Trending
4. **自己写** — 以上全部都搜过、确认没有现成的之后，才自己写

**这条规则适用于所有 skill 类型**（包括命理、工程、创意等），不要默认"这个领域没人做"。

### 命理类 skill 搜索关键词参考

| 类型 | 搜索关键词 |
|------|-----------|
| 八字 | `bazi`, `chinese astrology`, `八字`, `四柱` |
| 奇门 | `qimen`, `奇门` |
| 紫微斗数 | `ziwei`, `紫微斗数` |
| 玄学综合 | `fengshui`, `易经`, `命理` |

中文命理类 skill 在主流平台暂未收录，搜索时可能需要多个关键词交叉验证。

## Troubleshooting

### Rate Limits
ClawHub API enforces aggressive rate limiting. Common symptom: `ClawHub /api/v1/download failed (429)`.

**Proven retry strategy** (tested on WSL in this session):
1. First 429 → wait **30-60 seconds**, retry single skill
2. Repeated 429s → wait **90-120 seconds** before next attempt
3. **Install one at a time** — batch installs always trigger 429
4. Chain with delays: `openclaw skills install A && sleep 30 && openclaw skills install B`
5. Rate limit resets after ~1 hour of inactivity

**Alternative when rate limited:**
- Wait 1 hour before retrying
- Use alternative sources (websites)
- Search manually on GitHub

### Installation Issues
1. Check skill requirements
2. Verify network connectivity
3. Check OpenClaw version compatibility

## Best Practices

1. **Search before creating** - Don't reinvent the wheel
2. **Read documentation** - Understand skill capabilities
3. **Start simple** - Install one skill at a time
4. **Test thoroughly** - Verify skill works as expected
5. **Provide feedback** - Help improve skills
6. On Hermes, commit new skills to the skills git repo after install
