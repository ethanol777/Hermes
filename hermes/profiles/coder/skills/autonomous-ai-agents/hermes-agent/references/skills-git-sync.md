# Hermes Skills Git Sync Across Devices

Skills live in `~/.hermes/skills/` — each device has its own copy. To keep them in sync:

## One-Time Setup (Device A — source)

```bash
cd ~/.hermes/skills
git init
cat > .gitignore << 'EOF'
.bundled_manifest
.curator_state
.usage.json
.hub/
skills_list*
EOF
git add .gitignore && git commit -m "init"

# Add remote
git remote add origin https://github.com/username/hermes-skills.git

# Push
GITHUB_TOKEN=ghp_xxx git push -u origin master
```

## Clone on Device B

```bash
cd ~/.hermes/skills
git init
git remote add origin https://github.com/username/hermes-skills.git
git pull origin master
```

## Ongoing Sync

```bash
# Device A — push changes
git add . && git commit -m "update" && git push

# Device B — pull changes
git pull origin master
```

## Credential Helper

After initial push, remove token from URL so future pushes use cached credentials:

```bash
git remote set-url origin https://github.com/username/hermes-skills.git
git config --global credential.helper cache
```

## What Gets Synced

Everything under `~/.hermes/skills/` — all skill directories and their `references/`, `templates/`, `scripts/` subdirectories.

**Not synced** (device-local, add to `.gitignore`):
- `.bundled_manifest`, `.curator_state`, `.usage.json`, `.hub/`
- Memory, sessions, cron jobs, auth — these live in `~/.hermes/` root and subdirectories

## Token for Initial Push

If no credential helper is set up yet, embed the PAT in the URL for the first push only:
```
https://ghp_TOKEN@github.com/username/repo.git
```
Then immediately remove the token with `git remote set-url origin https://github.com/username/repo.git`.
