# Installing Skills from External GitHub Repos

Some community skill repos use the same SKILL.md format as Hermes but are published outside the Hermes hub. This reference covers installing them manually.

## Step 1: Evaluate the Repo

Not every GitHub repo with "skill" in the name is directly installable. Here's how to tell:

| Structure | Is it a Hermes skill? | Example |
|-----------|----------------------|---------|
| Has `SKILL.md` at root with YAML frontmatter (`name:`, `description:`) | ✅ Yes — compatible | `FANzR-arch/Numerologist_skills/qimen-dunjia/` |
| Has a `skills/` subdirectory with individual skill folders | ✅ Yes — install individual entries | `titanwings/colleague-skill/` |
| Is a README-only "awesome list" with links to other repos | ❌ No — it's a catalog, not a skill | `mliu98/awesome-human-distillation/` |
| Has `SKILL.md` but no frontmatter or wrong format | ⚠️ May need adaptation | Check `name:` field exists |

**Quick check:**
```bash
# Does it have a SKILL.md?
curl -sI "https://raw.githubusercontent.com/OWNER/REPO/main/SKILL.md" | head -3

# Does it have proper frontmatter?
curl -sL "https://raw.githubusercontent.com/OWNER/REPO/main/SKILL.md" | head -5
# First line should be "---"
```

## Step 2: Clone the Repo

```bash
cd ~
git clone https://github.com/OWNER/REPO.git
cd REPO
```

If the repo contains multiple skills in subdirectories (like `Numerologist_skills`), each subdirectory with a `SKILL.md` is a separate skill.

## Step 3: Install Dependencies

Check the `SKILL.md` frontmatter for a `compatibility:` field — it often lists required packages.

```bash
# Example: qimen-dunjia requires
pip install "lunar_python>=1.4.8,<2" "tzdata>=2024.1"
```

If no compatibility field, check if the skill has a `scripts/` directory with Python files — those may hint at dependencies.

## Step 4: Register as a Hermes Skill

There are two approaches:

### Option A: Symlink (recommended — stays in sync with repo)

```bash
ln -s ~/REPO_PATH/skill-dir ~/.hermes/skills/SKILL_NAME
```

This way, `git pull` in the repo keeps the skill updated automatically.

### Option B: Copy

```bash
cp -r ~/REPO_PATH/skill-dir ~/.hermes/skills/SKILL_NAME
```

Use this only if you want a snapshot that won't change with repo updates.

## Step 5: Verify Installation

```bash
# Check the skill is loaded
skill_view(name="SKILL_NAME")

# Check linked files (references, scripts, templates)
skill_view(name="SKILL_NAME", file_path="references/FILE.md")

# For skills with CLI scripts, verify they execute
cd ~/REPO
python3 skill-dir/scripts/script.py --help
```

The skill should now appear in `skills_list()` and be auto-triggerable by its trigger keywords.

## Handling Awesome-List / Catalog Repos

Repos like `mliu98/awesome-human-distillation` are **directories of skills**, not skills themselves. They contain a README that lists hundreds of individual skill repos.

**How to use them:**
1. Browse the README for skills you want
2. Each table row has a "Skill" column with a GitHub link
3. Follow this workflow (Step 1-5) for each individual repo

**What not to do:**
- Don't try to "install" the catalog repo itself as a skill
- Don't clone the entire catalog unless you want multiple individual skills
