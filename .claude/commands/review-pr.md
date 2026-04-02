---
model: sonnet
---

You are performing a comprehensive code review of a Pull Request in your project's GitHub repository.

CRITICAL RULES:
- NEVER use emojis anywhere in comments or output
- NEVER mention AI, Claude, LLM, or automation — write as a human engineer
- Post comments as INLINE review comments on specific diff lines, NOT as a single summary comment

## Input

The user provided: `$ARGUMENTS`

## Step 1: Parse the PR reference

Parse the input to determine the repository and PR number. Supported formats:
- `123` or `#123` — PR in current repo (detect via `git remote`)
- `repo#123` — PR in `{your_org}/repo`
- `{your_org}/repo#123` — full org/repo path
- `https://github.com/{your_org}/{your_repo}/pull/123` — full URL

If the input is empty or cannot be parsed, ask the user for the PR reference.

## Step 2: Fetch PR data

**Primary — `github` MCP (run in parallel):**

1. PR metadata via `mcp__github__pull_request_read`:
   ```json
   {"owner": "{your_org}", "repo": "<REPO>", "pullNumber": <NUMBER>}
   ```
   This returns title, body, author, labels, state, base/head refs, files, and commits.

2. PR diff — MCP has no diff endpoint, use `gh` CLI:
   ```bash
   GITHUB_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh pr diff <NUMBER> --repo {your_org}/<REPO>
   ```

3. CI checks status:
   ```bash
   GITHUB_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh pr checks <NUMBER> --repo {your_org}/<REPO>
   ```

4. Existing review comments:
   ```bash
   GH_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh api repos/{your_org}/<REPO>/pulls/<NUMBER>/comments --paginate
   ```

## Step 3: Dispatch the review

Launch the `reviewer` agent with `subagent_type: "reviewer"` passing:
1. Full PR metadata (title, author, description, labels)
2. Complete diff content
3. CI status
4. Existing review comments
5. The list of changed files

The agent prompt MUST include these rules:
- NEVER use emojis in any output
- NEVER mention AI, Claude, LLM, automation, or that this is an automated review
- Write all comments in English, in natural human engineer tone
- For each finding, return: file path, line number (from the diff), severity (critical/important/suggestion), and the comment text
- Use skills: `code-reviewer`, `security-audit`, `laravel-architecture`, `verification-before-completion`
- Read relevant project docs when applicable: `CLAUDE.md`, `.claude/rules/architecture.md`, `.claude/rules/code-style.md`, `.claude/rules/testing.md`, `.claude/rules/git-operations.md`
- Read the actual changed files from the local codebase (not just the diff) for full context
- Return findings as a structured list with: file, line, severity, comment

**Project-specific patterns to check:**
- `declare(strict_types=1)` present in all PHP files
- `getKey()` used instead of `->id` for model primary keys
- `query()` used for model queries (not static `Model::where(...)`)
- Laravel Actions pattern (lorisleiva/laravel-actions) — not traditional controllers
- Form Requests used for all input validation
- PHP 8.4+ features used where appropriate
- PHPStan level 7 compatibility (no type errors, no unresolved calls)
- Inertia.js props design — only necessary data passed to frontend
- Vue 3 Composition API used (not Options API)
- Pest BDD syntax: `describe()` + `it()` + `expect()`
- Eager loading to prevent N+1 queries

## Step 4: Post inline review comments

**Primary — `github` MCP (three-step workflow):**

1. Create a pending review via `mcp__github__pull_request_review_write`:
   ```json
   {"method": "create", "owner": "{your_org}", "repo": "<REPO>", "pullNumber": <NUMBER>, "body": "<short summary — no emojis, no AI mention>"}
   ```

2. Add each finding as an inline comment via `mcp__github__add_comment_to_pending_review`:
   ```json
   {"owner": "{your_org}", "repo": "<REPO>", "pullNumber": <NUMBER>, "path": "<file>", "line": <line>, "body": "<comment>", "side": "RIGHT"}
   ```
   Use `side: "LEFT"` for deleted lines, `side: "RIGHT"` for added lines.

3. Submit the pending review via `mcp__github__pull_request_review_write`:
   ```json
   {"method": "submit_pending", "owner": "{your_org}", "repo": "<REPO>", "pullNumber": <NUMBER>, "event": "<COMMENT|REQUEST_CHANGES>"}
   ```
   Use `REQUEST_CHANGES` if any critical findings were posted; otherwise use `COMMENT`.

**Fallback — `gh` CLI (only if MCP fails):**

Get the latest commit SHA:
```bash
GH_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh api repos/{your_org}/<REPO>/pulls/<NUMBER> --jq '.head.sha'
```

Create review with inline comments:
```bash
GH_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN gh api repos/{your_org}/<REPO>/pulls/<NUMBER>/reviews \
  --method POST \
  --field commit_id="<COMMIT_SHA>" \
  --field event="COMMENT" \
  --field body="<short summary sentence — no emojis, no AI mention>" \
  --field 'comments=[{"path":"<file>","line":<line>,"side":"RIGHT","body":"<comment>"}]'
```

Rules for posting:
- Each comment must reference the exact file path and diff line number
- Use `start_line` + `line` for multi-line comments
- The review body should be a single concise sentence (e.g., "A few issues to address before merge" or "Looks good overall, minor suggestions inline")
- For critical issues, use `event: "REQUEST_CHANGES"`
- For clean PRs with only suggestions, use `event: "COMMENT"`

## Step 5: Present summary to user

After posting, show a brief local summary:
- How many comments were posted (by severity: critical / important / suggestion)
- The review event type (COMMENT or REQUEST_CHANGES)
- Link to the PR: `https://github.com/{your_org}/<REPO>/pull/<NUMBER>`