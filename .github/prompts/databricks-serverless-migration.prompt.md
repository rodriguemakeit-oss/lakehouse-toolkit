---
agent: agent
description: Migrate Databricks workloads from classic compute to serverless compute
---

Apply the guidance in `.claude/skills/databricks-serverless-migration/SKILL.md` and its
`references/` folder (same content also at
`.assistant/skills/databricks-serverless-migration/` for Genie Code) — read them before
proceeding, don't restate from memory.

Use this when migrating notebooks, jobs, pipelines, or Scala JAR tasks from classic clusters to
serverless, checking whether existing code is serverless-compatible, or writing new
serverless-compatible code — relevant given `standards/orchestration.md` defaults new jobs to
`PERFORMANCE_OPTIMIZED`/serverless-eligible.
