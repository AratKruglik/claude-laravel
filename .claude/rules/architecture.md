# Architecture Patterns

## Business Logic

- **Laravel Actions** (`lorisleiva/laravel-actions`) — all business logic in Action classes
- **Service Layer**: implemented via Action classes (no separate service classes)
- **Repository Pattern**: not used — rely on Eloquent models directly

## Frontend

- **Inertia.js** with Vue.js — frontend built as SPA via server-driven routing
- **Domain Organization**: features organized by domain (Auth, Posts, Categories, etc.)

## Database

- Every DB structure change → new migration
- Every DB data change → update seeder + factory
- Prefer Eloquent models over raw queries (`DB::` facade)
- Prefer Eloquent relationships over manual joins
- Prefer Eloquent eager loading over lazy loading (N+1 prevention)
- Prefer Eloquent pagination, scopes, soft deletes over raw alternatives

## Performance

- **Laravel Octane** with FrankenPHP — high-performance application server
- **Redis** — caching, sessions, queue management
- **PostgreSQL** with proper indexing
- Image optimization tools included in Docker setup

## Development Tools

- **Telescope** — debugging assistant (enabled in testing)
- **Log Viewer** — web-based log viewing
- **IDE Helpers** — auto-generated (`php artisan ide-helper:generate`)
- **Xdebug** — available in Docker development environment
