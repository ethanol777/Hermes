---
name: internship-project-prep
description: |
  Framework for preparing computer science internship applications by converting 
  job descriptions (JD) into resume-ready, interview-ready project experience.
  Based on the shushu-internship-tool methodology: JD → Project → Resume → Interview.
trigger: |
  - User asks about internship preparation or finding CS internships
  - User mentions "鼠鼠实习" or shushu-internship-tool
  - Converting JD (job description) to project experience
  - Preparing technical projects for resume
  - Interview preparation for internship roles
  - Need to quickly build demo projects for job applications
---

# Internship Project Preparation

## Overview

Convert target job descriptions (JD) into resume-ready, interview-ready project experience.

**Core Workflow**: JD → Project → Resume → Interview

## 8-Step Workflow

### 1. Intake (信息收集)

Gather context before starting:
- **Target JD**: Position type, company, tech stack requirements
- **User background**: Current level, familiar languages/frameworks, existing projects
- **Time budget**: Half-day / 1-2 days / One week / Long-term
- **Resources**: Local env, Docker, cloud servers, GPU, budget
- **Current resume**: Existing projects, courses, competitions
- **Run depth**: 
  - `interview-only`: Just prepare talking points, no code execution
  - `smoke-test`: Minimal runnable path (Docker/mock data)
  - `local-full-run`: Complete local baseline
  - `remote-full-run`: Cloud environment (requires budget)

**Default assumptions** (if user doesn't specify):
- Level: Course knowledge but few projects
- Tech stack: Follow JD requirements
- Time: 1-2 days
- Resources: Local + Docker
- Depth: smoke-test

### 2. Repo Discovery (项目发现)

Find 2-3 candidate GitHub projects matching:
- High JD tech keyword match (Java/Spring, Go, Node.js, React, Vue, Docker, K8s, etc.)
- Clear README with install/run instructions
- Has minimal runnable path
- Resource requirements match user's environment
- Has modification potential for interview stories

### 3. Candidate Ranking (项目评分)

Use scoring script to rank candidates:
```bash
python -m shushu_internship_tool.candidate_score \
  --jd jd.txt \
  --candidates candidates.json \
  --out reports/ranking
```

### 4. Project Recon (项目审计)

Non-destructive codebase analysis:
```bash
python -m shushu_internship_tool.repo_audit \
  --repo <repo> \
  --out reports/audit \
  --name <project-name>
```

**Analysis checklist**:
- README, dependencies, install path
- Entry points: API, frontend pages, CLI, workers
- Core data flows: request flow, state flow, task flow
- Data & state: database schema, cache, queues, configs
- Minimum runnable commands and failure points

### 5. Baseline Run (基线运行)

Execute based on chosen depth:
- **interview-only**: Skip execution, focus on code reading and interview prep
- **smoke-test**: Local minimal path with Docker/mock data/small dataset
- **local-full-run**: Full local baseline execution
- **remote-full-run**: Cloud environment execution

### 6. Ownership Build (魔改项目)

Make a modifiable, explainable, interview-ready enhancement.

**Low-risk modifications** (recommended):
- **Backend**: Add CRUD API, pagination/search, validation, error codes, OpenAPI docs
- **Frontend**: Add page, form validation, loading/error states, responsive layout
- **Full-stack**: End-to-end business flow (login, ticket creation, order query)
- **Testing**: Unit tests, integration tests, mock data, CI smoke test
- **AI/ML**: Swap dataset, add demo, evaluation table, error analysis

**Medium-risk modifications**:
- **Backend**: Redis cache, message queues, async tasks, RBAC, rate limiting
- **Frontend**: State management, permission routing, visualization
- **Testing**: E2E, coverage, contract tests, load testing
- **AI/ML**: Swap backbone/embedding, ablation studies, benchmarks

**High-risk modifications** (not recommended for beginners):
- Database sharding, distributed transactions
- Streaming batch processing, data lakes
- LoRA, distillation, MLOps monitoring

### 7. Interview Pack (面试材料包)

Generate interview materials:
```bash
python -m shushu_internship_tool.interview_pack \
  --project-notes <notes> \
  --out reports/interview-pack
```

**Contents**:
- 4-5 line STAR resume bullets
- Interviewer Q&A drill
- Core code explanation script
- PPT presentation prompts
- Application checklist

### 8. Interview Readiness Gate (就绪检查)

Final verification - can you:
- [ ] Explain resume bullets that directly hit JD keywords
- [ ] Verbally explain project background, architecture, input/output, core code
- [ ] Describe engineering outcomes if no metrics available
- [ ] Answer追问 about failures, modification motivations, engineering trade-offs
- [ ] Present materials for a technical interview round

## Anti-patterns to Avoid

- Only changing README, variable names, colors, titles
- Screenshotting others' results without understanding the flow
- Claiming specific improvement percentages without running baseline
- Introducing complex libraries or cloud services you can't explain

## References

- [shushu-tool-notes.md](references/shushu-tool-notes.md) - Detailed session notes on the methodology

## Comparison with Thesis/Project Work

This methodology can be adapted for:
- Converting thesis requirements to experimental design
- Preparing defense presentations (PPT → Q&A)
- Writing project experience descriptions for graduate applications