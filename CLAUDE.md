@.claude/rules/workflow.md
@.claude/rules/code-style.md
@.claude/rules/git-operations.md

## Agent Dispatch (MANDATORY)

**You are the orchestrator. You NEVER write code directly when the pipeline applies.**
Follow the pipeline in `.claude/rules/workflow.md`. Run independent steps in parallel. Never ask the user which agent to use — decide autonomously.

## Claude-Specific Behavior

- Use available Skills for Laravel code style, testing, architecture, Inertia, DevOps
- If a Skill applies, prefer it over repeating rules here

## IMPORTANT

1. Before starting any task, evaluate pipeline trigger conditions in `.claude/rules/workflow.md`. If pipeline applies — start it immediately.
2. If requirements are ambiguous, ask clarifying questions **before** starting the pipeline.
3. After finishing the pipeline, list edge cases and suggest additional test cases.
4. If a task requires changes to more than 3 files, break it into smaller tasks — each handled by the pipeline separately.
5. When there's a bug, start by writing a test that reproduces it, then fix it.

Available agents: `ba`, `developer`, `frontend`, `tester`, `qa`, `reviewer`, `debugger`, `security-scanner`, `dba`, `ddd-architect`, `devil`, `filament`, `devops`, `integration-architect`, `laravel-refactoring-expert`, `queue-specialist`, `docs-writer`

## Setup

See `README.md` for system requirements, installation, and common commands.
