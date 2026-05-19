# 鼠鼠实习妙妙工具 (shushu-internship-tool) 学习笔记

**Source**: https://github.com/LiuMengxuan04/shushu-internship-tool  
**Core Philosophy**: 把岗位描述变项目，把项目变简历，把简历变面试

---

## 8-Step Workflow

### 1. Intake (信息收集)

Collect user info to determine strategy:
- **Target JD**: Position type, company type, region
- **User background**: Current knowledge level, familiar languages/frameworks, existing projects, weak points
- **Time budget**: Half-day / 1-2 days / One week / Long-term
- **Resource conditions**: Local environment, Docker, cloud servers, GPU, budget
- **Current resume**: Existing projects, courses, competitions, papers, open source
- **Run depth**: interview-only / smoke-test / local-full-run / remote-full-run

**Default assumptions** (if user doesn't answer):
- Level: Course knowledge but few projects
- Tech stack: Follow JD
- Time: 1-2 days
- Resources: Local + Docker priority
- Depth: smoke-test

**Run depth meanings**:
- **interview-only**: Don't run full project, focus on repo reading, code entry points, modification plans, interview materials
- **smoke-test**: Run minimal viable path locally, just prove project can start or core workflow works
- **local-full-run**: Fully run baseline/demo locally, produce showable results
- **remote-full-run**: Plan and use cloud servers, databases, GPU or other remote environments; confirm budget and account first

### 2. Repo Discovery (项目发现)

Find 2-3 candidate GitHub projects. Prioritize:
- High JD tech keyword match (Java/Spring, Go, Node.js, React, Vue, Docker, Kubernetes, MySQL, Redis, Kafka, Spark, Airflow, CI/CD, Linux, networking, security, testing, PyTorch, LLM, RAG)
- Clear README with followable install/run path
- Has minimal runnable path (not just design diagrams or paper links)
- Resource requirements controllable (local, Docker, lightweight cloud, free cloud)
- Has modification space for interview stories (not just title changes)

### 3. Candidate Ranking (项目评分)

After filling candidate JSON, run:
```bash
python -m shushu_internship_tool.candidate_score --jd jd.txt --candidates candidates.json --out reports/ranking
```

Outputs primary project, backup project, and risk table. Script does explicit field scoring; JD semantic parsing done by agent.

### 4. Project Recon (项目审计)

After cloning, non-destructive摸底:
```bash
python -m shushu_internship_tool.repo_audit --repo <repo> --out reports/audit --name <project-name>
```

Then continue reading:
- README, dependencies, install path
- Entry points: backend API, frontend pages, mobile activity/view, CLI, worker, scheduled tasks, training/inference scripts, demo
- Core链路: request flow, page state flow, data flow, task flow, message flow, model/experiment flow
- Data and state: database schema, cache, queue, files, object storage, dataset, config, checkpoint
- Minimum runnable commands and failure points

Output should include audit.json, overview.md, overview.html, plus core code explanation notes.

### 5. Baseline Run (基线运行)

Decide execution depth based on requirements:
- **interview-only**: Skip actual running, focus on repo reading, code entry points, explainable链路, modification plans, interview materials
- **smoke-test**: Prioritize local minimal path (Docker, local database, mock data, small data, small epochs, CPU or single-card smoke test)
- **local-full-run**: Fully run baseline/demo locally, record commands, config, results, failure fixes
- **remote-full-run**: First read remote-compute-checklist.md, confirm budget, account, data and resources, then run remote environment

When running minimal path:
- Record environment, commands, time spent, hardware, failure fixes - enough for interview复盘
- On failure, narrow down: dependencies, ports, environment variables, database migrations, data paths, versions, permissions, CUDA, checkpoint, parameters

### 6. Ownership Build (魔改项目)

Do a modification that is interviewable, explainable, and fast to推进:

**Low-risk modifications**:
- Backend: Add authentication/authorization, CRUD, search, cache, rate limiting, async tasks, message queue, database migration
- Frontend/Mobile: Add pages, state management, form validation, error states, visualization, offline cache, responsive layout
- Full-stack: Connect API, pages, database, deployment and testing, make a demonstrable business闭环
- Testing/Quality: Add unit tests, integration tests, E2E, CI, coverage, mock, load testing
- Data Engineering: Add ETL, scheduling, data quality checks, metrics dashboard, incremental sync
- Cloud-native/DevOps: Docker Compose, Kubernetes manifest, CI/CD, logs, monitoring, alerting
- Security: Input validation, permission model, dependency scanning, audit logs, common vulnerability fixes
- AI/Algorithm: Swap dataset/model, add evaluation, add demo/API, optimize training or inference流程

**Medium-risk modifications**:
- Backend: Add Redis cache, message queue, async tasks, RBAC, database migration, rate limiting
- Frontend/Mobile: Add state management, permission routing, component abstraction, chart visualization, offline cache
- Full-stack: Frontend-backend联调, deploy to cloud server, add demo data and one-click startup
- Testing: Add E2E, coverage, contract testing, load testing and performance reports
- Data: Add scheduling, incremental sync, schema evolution, data lineage or metrics口径 documentation
- DevOps: Add CI/CD, Kubernetes manifest, log collection, monitoring dashboard
- Security: Add audit logs, auth middleware, dependency scanning, common vulnerability fix explanations
- AI/Algorithm: Swap backbone/embedding, add ablation, add throughput/latency benchmark

**High-risk modifications** (not recommended for beginners):
- Backend/Systems: Refactor core architecture, database sharding, distributed transactions, high-concurrency gateway, storage engine
- Frontend/Mobile: Rewrite state architecture, micro-frontends, cross-platform solutions, complex performance optimization
- Data: Streaming batch unification, real-time data warehouse, data lake, complex DAG scheduling and disaster recovery
- DevOps: Complete GitOps, multi-environment deployment, service mesh, elastic scaling, cost optimization
- Security: Permission model重构, attack-defense verification, sandbox, supply chain security
- AI/Algorithm: Change task or cross-domain migration, introduce LoRA, distillation, self-training, MLOps monitoring

### 7. Interview Pack (面试材料包)

When project notes, logs or audit reports exist, run:
```bash
python -m shushu_internship_tool.interview_pack --project-notes <notes-or-report-dir> --out reports/interview-pack
```

Then complete according to interview-pack-template.md:
- 4-5 line STAR resume bullets
- Interviewer拷问 Q&A
- Core code讲解稿
- PPT prompts
- Application checklist

### 8. Interview Readiness Gate (面试就绪检查)

Final output checklist - can you "投递、面、讲":
- [ ] Resume 4-5 lines directly hit JD
- [ ] Can verbally explain project background, architecture/method, input/output, core code
- [ ] If no complete metrics, changed to "engineering output/experimental design/next steps"稳妥 expression
- [ ] Can answer interviewer追问 about failure reasons, modification motivations, engineering trade-offs, resource estimation
- [ ] Presentation materials sufficient to support one round of technical or project interview

## Output Style Guidelines

- When facing internship-seeking users, directly give executable commands, file paths, scoring tables and next steps
- When explaining projects, write less泛泛 background, more request flow/data flow/state flow/task flow, module responsibilities, input/output and interview话术
- Resume text should be short, hard-hitting, JD-aligned; don't堆 buzzwords
- Interview Q&A should be like real interviewer追问, not just "introduce your project"

## Anti-patterns

- Only changing README, variable names, colors, titles
- Screenshotting others' results into report without being able to explain the flow
- Writing specific improvement percentages without running baseline
- Introducing complex libraries, cloud services or large model services you can't explain

## Tool Scripts

- `repo_audit.py`: Scan repo and generate audit.json, overview.md, overview.html
- `candidate_score.py`: Generate ranking based on JD and candidate project JSON
- `interview_pack.py`: Generate interview material package skeleton based on notes/reports

## Reference Files

- `repo-selection-rubric.md`: Candidate project selection and淘汰 rules
- `modification-playbook.md`: Modification menu and acceptance criteria
- `interview-pack-template.md`: Resume, Q&A, code explanation, PPT templates
- `remote-compute-checklist.md`: Remote servers, databases, GPU or cloud environment running checklist

## Adaptation for Thesis/Defense Preparation

This methodology can be applied to:
1. **Requirement-driven project design**: Treat defense requirements as JD, determine technical points to showcase
2. **Layered preparation**: Choose "explainable" vs "runnable" depth based on time
3. **Result-oriented**: Not "do perfectly", but "can explain clearly"
4. **Engineering output > perfect metrics**: When lacking metrics, write method understanding, experimental design