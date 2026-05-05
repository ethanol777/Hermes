# Integrating External Agent/Role Libraries into Hermes

Many community projects bundle ready-made Hermes Skills (SKILL.md format) or have scripts to convert their agent role files to Hermes format. This reference documents the workflow for importing them.

## Quick Workflow

```bash
# 1. Clone the repo
cd ~
git clone https://github.com/example/agent-library.git

# 2. Check for built-in Hermes support
ls agent-library/integrations/hermes/ 2>/dev/null   # pre-converted?
ls agent-library/scripts/convert.sh   2>/dev/null    # converter script available?
ls agent-library/scripts/install.sh   2>/dev/null    # installer script available?

# 3a. If the repo has its own convert + install for Hermes:
cd agent-library
bash scripts/convert.sh --tool hermes
bash scripts/install.sh --tool hermes

# 3b. If the repo already has integrations/hermes/ but no install script:
cp -r agent-library/integrations/hermes/* ~/.hermes/skills/

# 3c. If the repo has no Hermes support — write a converter:
#     Each Hermes skill lives at: ~/.hermes/skills/<category>/<slug>/SKILL.md
#     SKILL.md needs YAML frontmatter:
#       ---
#       name: <slug>
#       description: <one-line description>
#       version: 1.0.0
#       author: <source>
#       license: <license>
#       ---
#     The body is the agent's full prompt/markdown content.
```

## Real Example: agency-agents-zh

The [agency-agents-zh](https://github.com/jnMetaCode/agency-agents-zh) repo (211 Chinese AI expert roles) already has Hermes support built-in:

```bash
cd ~
git clone https://github.com/jnMetaCode/agency-agents-zh.git
cd agency-agents-zh

# Step 1: Convert source .md files → Hermes skill format
bash scripts/convert.sh --tool hermes

# Step 2: Copy integrations/hermes/ → ~/.hermes/skills/
bash scripts/install.sh --tool hermes

# Step 3: Optionally commit to skills git repo
cd ~/.hermes/skills
git add <new-categories>
git commit -m "feat: import N skills from agency-agents-zh"
git push
```

### Notes

- `convert.sh --tool hermes` reads each `.md` file from the source directories (e.g. `engineering/`, `marketing/`) and writes `integrations/hermes/<category>/<slug>/SKILL.md` with the proper Hermes frontmatter.
- `install.sh --tool hermes` copies from `integrations/hermes/` to `~/.hermes/skills/`.
- Use `--category <name>` to install only specific categories (useful if the full set is too large for Discord's 8000-char command limit).
- If the skills git repo (`~/.hermes/skills`) is synced to GitHub, commit and push after installation for multi-device availability.

## Common Caveats

- **Frontmatter mismatch**: Some repos use `name:` in Chinese while Hermes prefers an ASCII slug. Check the converted `SKILL.md` frontmatter matches the pattern: `name: category-role-slug`.
- **Missing description**: The `description:` field in SKILL.md frontmatter is required for Hermes to index the skill. Converters should extract it from the source.
- **File encoding**: Ensure SKILL.md is UTF-8 without BOM, especially when copied from Windows environments.
- **Skills repo**: If `~/.hermes/skills/` is a git repo (common for multi-device sync), remember to `git add` and commit new skills, then `git push`.
