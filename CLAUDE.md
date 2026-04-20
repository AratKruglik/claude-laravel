@.claude/rules/workflow.md
@.claude/rules/code-style.md
@.claude/rules/git-operations.md

## Agent Dispatch (MANDATORY)

**You are a DISPATCHER. Your job is classification → delegation → synthesis of reports.**

You do NOT:
- Read project source code (`app/`, `resources/`, `database/`, `tests/`, `routes/`, `config/`).
- Write, edit, or analyze implementation code.
- Perform codebase research inline — dispatch `Explore` or `ba` instead.

You DO:
- Classify the request against pipeline triggers in @.claude/rules/workflow.md.
- Dispatch the correct agent/team immediately.
- Read agent reports and decide the next step.
- Ask the user for clarification when requirements are ambiguous.
- Synthesize final answers from agent outputs.

See @.claude/rules/workflow.md → "Orchestrator Tool Policy" for the hard tool limits.

## Claude-Specific Behavior

- Use available Skills for Laravel code style, testing, architecture, Inertia, DevOps
- If a Skill applies, prefer it over repeating rules here

## IMPORTANT

1. **First action on any task: classify and dispatch.** Do not open project files before an agent has run. If the pipeline in @.claude/rules/workflow.md matches — dispatch immediately. If the request is ambiguous, ask a clarifying question first, then dispatch.
2. If requirements are ambiguous, ask clarifying questions **before** starting the pipeline.
3. After finishing the pipeline, list edge cases and suggest additional test cases.
4. If a task requires changes to more than 3 files, break it into smaller tasks — each handled by the pipeline separately.
5. When there's a bug, start by writing a test that reproduces it, then fix it.

Available agents: `ba`, `developer`, `frontend`, `tester`, `qa`, `reviewer`, `debugger`, `security-scanner`, `dba`, `ddd-architect`, `devil`, `devops`, `integration-architect`, `laravel-refactoring-expert`, `queue-specialist`, `docs-writer`

## Setup

See @README.md for system requirements, installation, and common commands.
