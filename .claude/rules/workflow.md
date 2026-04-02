# Agent Workflow Orchestration

## Workflow Orchestration

### 1. General Rules
- Enter **plan mode** for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately – don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity
- Never mark a task complete without proving it works

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update `./docs/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes – don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests – then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. **Plan First**: Write plan to `./docs/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `./docs/todo.md`

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Standard Feature Pipeline

Use this pipeline when the task meets **ANY** of the following criteria:
- Creates or modifies a Laravel Action class
- Requires a database migration
- Adds or changes a route, controller, or Form Request
- Adds or changes a Vue component or Inertia page
- Involves authorization logic (Policy, Gate, middleware)
- Touches more than 2 files

If none apply (e.g. fixing a typo, updating a config value) — skip the pipeline.

Follow this agent pipeline in order:

### Step 1: Analysis (BA Agent)
- Analyze the task requirements
- Break down into user stories with acceptance criteria
- Identify affected domains and dependencies
- Output: clear requirements, scope definition, implementation roadmap

### Step 2: Implementation (Developer Agent)
- Write backend + frontend code following the architecture
- Use Actions pattern, Inertia.js, Vue 3 Composition API
- Run Pint + PHPStan after code changes
- Output: working code changes

### Step 3: Test Coverage (Tester Agent)
- Write unit tests for Actions, Services, Observers
- Write feature tests for HTTP endpoints
- Run mutation testing to verify test quality
- Output: test files, coverage report

### Step 4: Code Review (Reviewer Agent)
- Review all code changes against project coding standards and architecture
- Check for logic errors, code smells, SOLID violations, and maintainability issues
- Classify findings by severity: Critical, Important, Minor
- **If Critical or Important issues found**: route findings back to Developer Agent (code fixes) and Tester Agent (test gaps) — repeat Steps 2–4 until clean
- **If only Minor issues or clean**: proceed to next step
- Output: review report with findings, severity ratings, and resolution status

### Step 5: Security Review (Security Scanner Agent)
- Scan new code for OWASP Top 10 vulnerabilities
- Check auth/authz (Policies, Form Requests)
- Verify no credential leaks, no PII in logs
- Output: security findings with severity ratings

### Step 6: E2E Verification and Browser Tests(QA Agent)
- Verify user flows work in browser via Playwright
- Check responsive design, accessibility
- Test integration points
- Output: E2E test results, screenshots if needed

### Step 7: Report & PR (DocsWriter Agent)
- Write a summary report of all changes made
- Create PR description (what changed, why, which files)
- Create the PR automatically via Github CLI and `gh` command
- PR description rules: no AI mentions, no stats, no test checklists

## Architecture Tasks

For tasks involving architectural decisions or domain modeling:
- Insert **DDD Architect** between BA (Step 1) and Developer (Step 2)
- DDD Architect designs domain model, decides logic placement (Action vs Service vs Observer)

## CI/CD Tasks

For tasks involving CI/CD, Docker, or deployment:
- Use **DevOps Agent** instead of Developer for infrastructure changes
- Use **CI/CD Engineer** for GitHub Actions workflow changes

## Bug Fix Pipeline (Simplified)

1. **Debugger Agent** — investigate root cause
2. **Developer Agent** — implement fix
3. **Tester Agent** — write regression test
4. Verify fix + existing tests pass
