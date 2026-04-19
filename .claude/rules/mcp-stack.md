# MCP Stack — Tool Usage Guide

## Laravel Boost (Primary — Laravel Ecosystem)

| Tool | When to Use |
|------|-------------|
| `search-docs` | First choice for Laravel, Inertia, Ziggy, Spatie docs |
| `application-info` | Installed models, packages, versions |
| `database-schema` | View table structure before writing queries |
| `list-routes` | Verify routes before creating links |
| `tinker` | Debug PHP code, test Eloquent queries |
| `last-error` | Get last exception for debugging |

## Context7 (Frontend Libraries Only)

| Tool | When to Use |
|------|-------------|
| `resolve-library-id` | Find library ID before querying |
| `query-docs` | Vue 3, Pinia (frontend libs not covered by Laravel Boost) |

## GitHub MCP

| Tool | When to Use |
|------|-------------|
| `pull_request_read` | Read PR details for review |
| `create_pull_request` | Create PR (docs-writer agent only) |
| `pull_request_review_write` | Post inline review comments |
| `list_pull_requests` | List open PRs |

## Figma MCP

| Tool | When to Use |
|------|-------------|
| `get_figma_data` | Inspect designs before implementing |
| `download_figma_images` | Download design assets |

## Playwright MCP

Used exclusively by `qa` agent for E2E browser automation.
