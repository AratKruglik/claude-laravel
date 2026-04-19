---
model: sonnet
---

You are diagnosing and fixing CI/CD failures on a Pull Request in your project's GitHub repository. The CI system is GitHub Actions (workflow: `.github/workflows/ci.yml`).

CRITICAL: For PR metadata, prefer `github` MCP tools over `gh` CLI. For GitHub Actions CI data (run logs, job status), use `gh` CLI commands — `gh run list`, `gh run view`, `gh pr checks`. Do NOT scrape GitHub URLs or use `curl`/`WebFetch` for CI data.

## Input

The user provided: `$ARGUMENTS`

## Step 1: Parse the PR reference

Parse the input to determine the repository and PR number. Supported formats:
- `123` or `#123` — PR in current repo (detect via `git remote`)
- `repo#123` — PR in `{your_org}/repo`
- `{your_org}/repo#123` — full org/repo path
- `https://github.com/{your_org}/{your_repo}/pull/123` — full URL

If the input is empty or cannot be parsed, ask the user for the PR reference.

## Step 2: Fetch PR metadata

**Primary — `github` MCP:**
Use `mcp__github__pull_request_read` with:
```json
{"owner": "{your_org}", "repo": "<REPO>", "pullNumber": <NUMBER>}
```

**Fallback — `gh` CLI:**
```bash
GITHUB_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh pr view <NUMBER> --repo {your_org}/<REPO> --json title,body,headRefName,baseRefName,files,additions,deletions,commits
```

Extract `headRefName` (the PR branch name) — you will need it for CI run lookups.

## Step 3: Fetch GitHub Actions failure data

Run these commands in parallel:

**3a. Quick CI status check:**
```bash
GITHUB_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh pr checks <NUMBER> --repo {your_org}/{your_repo}
```

**3b. Find the latest CI run for the branch:**
```bash
GITHUB_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh run list \
  --branch <headRefName> \
  --repo {your_org}/{your_repo} \
  --workflow ci.yml \
  --limit 5 \
  --json databaseId,status,conclusion,displayTitle,createdAt
```

If all checks are green (no failures), inform the user that CI is passing and stop.

**3c. Get failed job details (once you have the run ID):**
```bash
GITHUB_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh run view <run-id> \
  --repo {your_org}/{your_repo} \
  --json jobs \
  --jq '.jobs[] | select(.conclusion=="failure") | {name, conclusion, steps: [.steps[] | select(.conclusion=="failure") | {name, conclusion}]}'
```

**3d. Get failure logs:**
```bash
GITHUB_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh run view <run-id> \
  --repo {your_org}/{your_repo} \
  --log-failed
```

IMPORTANT: `--log-failed` output can be very large. If it is truncated, note that earlier failures may be missing.

### Identify failure type

The CI has two job groups. Map the failed job name to one of these:

**Lint matrix** (`🪄 Lints | ...`):
- `🔍 PHPStan` — static analysis failure
- `🧽 Laravel Pint` — code style failure (often auto-fixable with `./vendor/bin/pint`)
- `🏠 Rector` — code modernization failure (often auto-fixable with `./vendor/bin/rector process`)
- `🅿️ Prettier` — frontend formatting failure (auto-fixable with `yarn prettier --write`)
- `🔯 Eslint` — frontend linting failure (often auto-fixable with `yarn eslint --fix`)

**Test matrix** (`♻️ Tests | ...`):
- `🔬 Unit` — unit test failure (requires code investigation)
- `🧬 Feature` — feature/integration test failure (requires code investigation)
- `☂️ Coverage` — test coverage failure (may indicate new code without tests)
- `🦠 Mutation` — mutation testing failure (tests exist but don't catch mutations)

## Step 4: Switch to the PR branch

Before analysis and fixes, check out the PR branch locally so agents work with the correct code:

```bash
git fetch origin <headRefName>
git checkout <headRefName>
```

If there are uncommitted local changes, stash them first and inform the user.

## Step 5: Dispatch the debugger agent

Launch the `debugger` agent with `subagent_type: "debugger"` passing:
1. The `gh run view --log-failed` output
2. The failed job names and their step details from Step 3c
3. The failure type (lint vs test, and which specific tool)
4. The list of files changed in the PR
5. The PR branch name (already checked out locally)

The agent prompt must instruct the debugger to:
- Analyze the GitHub Actions failure logs to identify root cause
- For **lint failures**: identify which files and lines caused the linter to fail; check if the issue is auto-fixable
- For **test failures**: identify the failing test class::method and the assertion that failed; read the failing test file and the code under test from the local codebase
- For **mutation failures**: identify which mutations survived; read the affected test and source files
- Note: GitHub Actions has no built-in flaky test detection. If the failure looks intermittent (timing, random ordering, environment), flag it explicitly and suggest a manual rerun
- Produce a structured diagnosis:
  - Root cause (one sentence)
  - Failure type: lint | unit test | feature test | coverage | mutation
  - Affected files (list of file paths)
  - Failed tests or linter errors (specific list)
  - Whether a code fix is needed or if it is a transient/environment issue
  - Recommended fix approach (brief)

## Step 6: Dispatch the developer agent (if fix needed)

If the debugger determined that a code fix is needed, launch the `developer` agent with `subagent_type: "developer"` passing:
1. The full root cause analysis from the debugger
2. The specific files that need to be modified
3. The failed job names and test/lint errors so developer can verify the fix

The agent prompt must instruct the developer to:
- Apply the minimal fix to resolve the CI failure
- Follow project standards: `CLAUDE.md`, `.claude/rules/code-style.md`, `.claude/rules/architecture.md`
- Follow project conventions: see @.claude/rules/code-style.md, @.claude/rules/architecture.md
- For **lint failures**, run the relevant linter to verify the fix:
  ```bash
  docker compose exec app ./vendor/bin/phpstan analyse --memory-limit=2G
  docker compose exec app ./vendor/bin/pint --test
  docker compose exec app ./vendor/bin/rector process --dry-run
  docker compose exec app yarn prettier
  docker compose exec app yarn eslint
  ```
- For **test failures**, run the failing test to verify the fix:
  ```bash
  docker compose exec app php artisan test --filter="FailingTestMethod"
  ```
- If tests pass, run the broader suite for the affected area:
  ```bash
  docker compose exec app php artisan test --testsuite=Unit
  docker compose exec app php artisan test --testsuite=Feature
  ```
- Do NOT make changes beyond what is needed to fix the CI failure
- Do NOT refactor, improve, or "clean up" adjacent code

If the debugger determined it is a transient or environment issue (not a code problem), skip the developer agent and inform the user directly with the diagnosis and recommended action.

For transient failures, offer to rerun the failed jobs:
```bash
GITHUB_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh run rerun <run-id> \
  --repo {your_org}/{your_repo} \
  --failed
```

## Step 7: Present results to user

After all agents complete, present:

**Diagnosis:**
- Which CI jobs failed and why (root cause)
- Whether it is a code issue or a transient problem

**Fix applied** (if applicable):
- Which files were modified
- What was changed and why
- Local verification results (test output / linter output)

**Next steps:**
- Ask the user if they want to commit and push the fix
- If committing: use a clear commit message like `fix: resolve CI failure in [JobName]`
- Remind that pushing will trigger a new CI run

If no fix was applied (transient/environment issue):
- Offer to rerun the failed workflow via the `gh run rerun` command above
- Or suggest investigating persistent failures manually