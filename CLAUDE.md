## Claude-Specific Behavior

- Use available Skills for Laravel code style, testing, architecture, Inertia, DevOps
- If a Skill applies, prefer it over repeating rules here

## IMPORTANT

1. Before writing any code, describe your approach and wait for approval.
2. If requirements are ambiguous, ask clarifying questions before writing code.
3. After finishing code, list edge cases and suggest test cases.
4. If a task requires changes to more than 3 files, stop and break it into smaller tasks.
5. When there's a bug, start by writing a test that reproduces it, then fix it.
6. Every time I correct you, reflect on what went wrong and plan to prevent it.

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.

## Task Management

1. **Plan First**: Write plan to `docs/todo.md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `docs/todo.md`
6. **Capture Lessons**: Update `docs/lessons.md` after corrections

## Agent Dispatch (MANDATORY)

- **ALWAYS** follow the agent pipeline defined in `.claude/rules/workflow.md`
- **ALWAYS** run independent pipeline steps in parallel (e.g., Security Scanner + QA + Tester can run simultaneously after Developer completes)
- **ALWAYS** autonomously determine which agents from `.claude/agents/` should execute each part of the user's task — do NOT ask the user which agent to use
- Available agents: `ba`, `developer`, `frontend`, `tester`, `qa`, `reviewer`, `debugger`, `security-scanner`, `dba`, `ddd-architect`, `filament`, `devops`, `ci-cd-engineer`, `integration-architect`, `laravel-refactoring-expert`, `queue-specialist`, `docs-writer`
- For every non-trivial task: analyze → select agents → dispatch in parallel where possible → collect results → verify

## Rules (auto-loaded from `.claude/rules/`)

- `code-style.md` — PHP 8.4 strict types, Eloquent conventions, code quality tools
- `architecture.md` — Actions pattern, Inertia.js, domain organization, database patterns
- `testing.md` — Pest 4, mutation testing, model testing policy, test structure
- `git-operations.md` — Commit/push rules, PR description format
- `workflow.md` — Agent pipeline: BA → Developer → Tester → Security → QA → DocsWriter

## Build/Configuration Instructions

### System Requirements

- **PHP 8.4+** (Critical: The project requires PHP 8.4.0 or higher)
- **Node.js** with Yarn 4.6.0
- **PostgreSQL 17**
- **Redis 7.2+**
- **Docker & Docker Compose** (Recommended for development)

### Environment Setup

#### Option 1: Docker Development (Recommended)

```bash
# Copy environment file
cp .env.example .env

# Start all services
docker compose up -d

# Install PHP dependencies
docker compose exec app composer install

# Install Node dependencies
docker compose exec app yarn install

# Generate application key
docker compose exec app php artisan key:generate

# Run migrations
docker compose exec app php artisan migrate

# Build frontend assets
docker compose exec app yarn dev
```

#### Option 2: Local Development

Ensure PHP 8.4+ is installed, then:

```bash
# Install dependencies
docker compose exec app composer install
docker compose exec app yarn install

# Setup environment
docker compose exec app cp .env.example .env
docker compose exec app php artisan key:generate

# Configure database and run migrations
docker compose exec app php artisan migrate

# Start development servers
docker compose exec app composer run dev  # Starts Laravel Octane, queue worker, logs, and Vite
```

### Development Scripts

All commands should run from a Docker container. The project includes several
useful Composer scripts:

- `docker compose exec app composer run dev` - Start all development services (Octane, queue, logs,
  Vite)
- `docker compose exec app composer run ide-helper` - Generate IDE helper files
- `docker compose exec app composer run phpstan` - Run static analysis
- `docker compose exec app composer run pint` - Check code style
- `docker compose exec app composer run pint:fix` - Fix code style issues
- `docker compose exec app composer run rector` - Check for code modernization opportunities
- `docker compose exec app composer run rector:fix` - Apply code modernization

### CI/CD Pipeline

The project uses GitHub Actions with:

- **Linting**: PHPStan, Laravel Pint, Rector
- **Testing**: Pest with coverage and mutation testing
- **Code Coverage**: Codecov integration
- **Parallel Execution**: Tests run in parallel for faster feedback

### Environment-Specific Notes

- **Local Development**: Use Docker Compose for consistent environment
- **Testing**: Separate PostgreSQL instance for tests
- **Production**: Optimized for Laravel Octane with FrankenPHP
- **Debugging**: Xdebug available in development, Telescope for application
  debugging

### Common Commands

```bash
# Code quality checks
docker compose exec app ./vendor/bin/phpstan analyse
docker compose exec app ./vendor/bin/pint --test
docker compose exec app ./vendor/bin/rector process --dry-run

# Fix code issues
docker compose exec app ./vendor/bin/pint
docker compose exec app ./vendor/bin/rector process

# Generate IDE helpers
docker compose exec app php artisan ide-helper:generate
docker compose exec app php artisan ide-helper:models

# Clear caches
docker compose exec app php artisan config:clear
docker compose exec app php artisan cache:clear
docker compose exec app php artisan view:clear
```
