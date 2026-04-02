---
name: laravel-architecture
description:
    Generates a Laravel architecture based on best practices for modern Laravel
    applications.

    Українською: архітектура Laravel, структура проєкту, патерни Laravel, сервісний шар, екшни, доменна логіка, організація коду, спроєктуй архітектуру, створи структуру, рефакторинг архітектури, доменна структура, Action клас
---

# Laravel Architecture

## Instructions

### Architecture Patterns

- **Laravel Actions**: Business logic organized in Action classes
  (`lorisleiva/laravel-actions`)
- **Inertia.js**: Frontend built with Vue.js via Inertia.js
- **Domain Organization**: Features organized by domain (Auth, Posts,
  etc.)
- **Repository Pattern**: Not explicitly used, relies on Eloquent models
- **Service Layer**: Implemented via Action classes
- **Database Migrations**: Every change in the DB structure should be reflected
  in a new migration
- **Database Seeders**: Every change in DB data should be reflected in a seeder
- **Database Factories**: Every change in DB data should be reflected in a
  factory
- **Database Queries**: Prefer Eloquent models over raw queries
- **Database Relationships**: Prefer Eloquent relationships to raw queries
- **Database Eager Loading**: Prefer Eloquent eager loading over raw queries
- **Database Pagination**: Prefer Eloquent pagination over raw queries
- **Database Scopes**: Prefer Eloquent scopes over raw queries
- **Database Soft Deletes**: Prefer Eloquent soft deletes over raw queries

### Performance Considerations

- **Laravel Octane**: Uses FrankenPHP for high-performance application server
- **Redis**: Used for caching, sessions, and queue management
- **Database**: PostgreSQL with proper indexing
- **Asset Optimization**: Image optimization tools included in Docker setup

### Laravel 12 Structure

- No middleware files in `app/Http/Middleware/`.
- `bootstrap/app.php` is the file to register middleware, exceptions, and
  routing files.
- `bootstrap/providers.php` contains application specific service providers.
- **No app\Console\Kernel.php** - use `bootstrap/app.php` or
  `routes/console.php` for console configuration.
- **Commands auto-register** - files in `app/Console/Commands/` are
  automatically available and do not require manual registration.
